defmodule ExGreenYetCore.ServerCheckState do
  @enforce_keys [:identifier, :url, :poll_time]
  defstruct identifier: nil, url: nil, poll_time: 0, color: "red", message: nil, components: []

  @doc """
  Creates a server check state with required identifier, url, and poll time.

    iex> ExGreenYetCore.ServerCheckState.new("app", "https://example.com/status.json", 5)
    %ExGreenYetCore.ServerCheckState{identifier: "app", url: "https://example.com/status.json", poll_time: 5, color: "red", message: nil, components: []}
  """
  def new(identifier, url, poll_time)
      when is_binary(identifier) and is_binary(url) and is_integer(poll_time) do
    %__MODULE__{identifier: identifier, url: url, poll_time: poll_time}
  end
end
