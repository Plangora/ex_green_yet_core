defmodule ServerCheckTest do
  use ExUnit.Case, async: true

  alias ExGreenYetCore.ServerCheck
  alias Phoenix.PubSub

  setup do: {:ok, %{identifier: "supervised_app", url: "http://localhost:4000", poll_time: 5}}

  test "spawn a server check process", %{identifier: identifier, url: url, poll_time: poll_time} do
    assert {:ok, _pid} = ServerCheck.start_link(identifier, url, poll_time)
  end

  test "cannot create more than one of the same identifier", %{
    identifier: identifier,
    url: url,
    poll_time: poll_time
  } do
    assert {:ok, _pid} = ServerCheck.start_link(identifier, url, poll_time)
    assert {:error, _reason} = ServerCheck.start_link(identifier, url, poll_time)
  end

  # TODO: use Mox instead of real implementation
  test "will broadcast status of website", %{
    identifier: identifier,
    url: url,
    poll_time: poll_time
  } do
    :ok = PubSub.subscribe(ExGreenYetCore.PubSub, "service:" <> identifier)
    {:ok, _pid} = ServerCheck.start_link(identifier, url, poll_time)

    assert_receive %{
      "identifier" => ^identifier,
      "url" => ^url,
      "poll_time" => ^poll_time,
      "color" => "red"
    }
  end
end
