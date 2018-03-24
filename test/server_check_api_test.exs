defmodule ServerCheckApiTest do
  use ExUnit.Case, async: true

  doctest ExGreenYetCore.ServerCheckApi

  alias ExGreenYetCore.{ServerCheckApi, ServerCheckState}

  setup do
    state = %ServerCheckState{
      identifier: "app",
      url: "http://localhost",
      poll_time: 5,
      components: [
        %{
          name: "Database",
          color: "red",
          message: "Wrong credentials"
        },
        %{
          name: "Cache refresh",
          color: "green",
          message: "100% completed"
        }
      ]
    }

    json_components = [
      %{
        "name" => "Database",
        "color" => "red",
        "message" => "Wrong credentials"
      },
      %{
        "name" => "Cache refresh",
        "color" => "green",
        "message" => "100% completed"
      }
    ]

    {:ok, %{state: state, json_components: json_components}}
  end

  describe "parse_response" do
    test "a proper response from HTTPoison will decode the JSON body" do
      assert %{"foo" => "bar"} ==
               ServerCheckApi.parse_response(
                 {:ok, %HTTPoison.Response{status_code: 200, body: "{\"foo\":\"bar\"}"}}
               )
    end

    test "anything else will return an error" do
      assert :error == ServerCheckApi.parse_response({:error, "foo"})
    end
  end

  describe "update_state" do
    test "will update color and message when passed in", %{state: state} do
      message = "looking good"
      color = "green"
      new_state = ServerCheckApi.update_state(%{"color" => color, "message" => message}, state)

      assert %ServerCheckState{
               identifier: "app",
               url: "http://localhost",
               poll_time: 5,
               color: color,
               message: message,
               components: []
             } == new_state
    end

    test "component data will also be rendered", %{state: state, json_components: components} do
      message = "things could be better"
      color = "yellow"

      new_state =
        ServerCheckApi.update_state(
          %{"color" => color, "message" => message, "components" => components},
          state
        )

      components = state.components

      assert %ServerCheckState{message: ^message, color: ^color, components: ^components} =
               new_state
    end

    test "invalid data will set the color to green and message to say invalid data was received",
         %{state: state} do
      new_state = ServerCheckApi.update_state(%{"foo" => "bar"}, %{state | components: ["test"]})

      assert %ServerCheckState{
               identifier: "app",
               url: "http://localhost",
               poll_time: 5,
               color: "red",
               message: "Invalid data received",
               components: []
             } == new_state
    end
  end

  describe "broadcast_state" do
    test "can update pubsub subscribers", %{state: state, json_components: components} do
      :ok = Phoenix.PubSub.subscribe(ExGreenYetCore.PubSub, "service:" <> state.identifier)
      %ServerCheckState{identifier: identifier, url: url, poll_time: poll_time} = state
      ServerCheckApi.broadcast_state(state)

      assert_receive %{
        "identifier" => ^identifier,
        "url" => ^url,
        "poll_time" => ^poll_time,
        "color" => "red",
        "components" => ^components
      }
    end
  end
end
