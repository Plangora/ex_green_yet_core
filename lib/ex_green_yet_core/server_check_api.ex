defmodule ExGreenYetCore.ServerCheckApi do
  @moduledoc """
    This is the internal API user in the ServerCheck GenServer. It has been extracted to make it easier to test.
  """

  @doc """
    Used to parse responses from HTTPoison when checking the current server status. Response must return a 200 code or else it will be considered an error.

    ## Examples

      iex> ExGreenYetCore.ServerCheckApi.parse_response({:ok, %HTTPoison.Response{status_code: 200, body: "{\\"fruit\\": \\"banana\\"}"}})
      %{"fruit" => "banana"}

      iex> ExGreenYetCore.ServerCheckApi.parse_response({:ok, %HTTPoison.Response{status_code: 400, body: "{\\"fruit\\": \\"banana\\"}"}})
      :error
  """
  def parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}),
    do: Jason.decode!(body)

  def parse_response(_), do: :error

  @doc """
    Updates the current status of the server check including the color and messaage, along with any components if they are included.
  """
  def update_state(%{"color" => color, "message" => message, "components" => components}, state)
      when is_list(components),
      do: %{state | color: color, message: message, components: update_components(components, [])}

  def update_state(%{"color" => color, "message" => message}, state),
    do: %{state | color: color, message: message, components: []}

  def update_state(_, state),
    do: %{state | color: "red", message: "Invalid data received", components: []}

  @doc """
    Broadcasts a string map representation of the current state using "service:" prepended to the current identifier.
  """
  def broadcast_state(state) do
    to_be_broadcasted_state =
      for {key, val} <- Map.from_struct(state),
          into: %{},
          do: {Atom.to_string(key), update_atom_map_list_to_string_map_list(val)}

    Phoenix.PubSub.broadcast(
      ExGreenYetCore.PubSub,
      "service:" <> state.identifier,
      to_be_broadcasted_state
    )

    state
  end

  defp update_atom_map_list_to_string_map_list(map_list) when is_list(map_list),
    do: update_atom_map_to_string_map(map_list, [])

  defp update_atom_map_list_to_string_map_list(val), do: val

  defp update_atom_map_to_string_map([], accumulated_maps), do: Enum.reverse(accumulated_maps)

  defp update_atom_map_to_string_map([head | tail], accumulated_maps) do
    updated_map = for {key, val} <- head, into: %{}, do: {Atom.to_string(key), val}
    update_atom_map_to_string_map(tail, [updated_map | accumulated_maps])
  end

  defp update_components(
         [%{"name" => name, "color" => color, "message" => message} | tail],
         parsed_components
       ) do
    update_components(tail, [%{name: name, color: color, message: message} | parsed_components])
  end

  defp update_components([], parsed_components), do: Enum.reverse(parsed_components)
  defp update_components(_, parsed_components), do: parsed_components
end
