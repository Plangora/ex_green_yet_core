defmodule ExGreenYetCore.ServerCheck do
  use GenServer
  import ExGreenYetCore.ServerCheckApi
  alias ExGreenYetCore.ServerCheckState

  def start_link(identifier, url, poll_time) do
    GenServer.start_link(__MODULE__, {identifier, url, poll_time}, name: via_tuple(identifier))
  end

  def init({identifier, url, poll_time}) do
    send(self(), :check_service)
    {:ok, ServerCheckState.new(identifier, url, poll_time)}
  end

  @doc """
    Tells `ServerCheckState` to check on the server and automatically tells itself to check again following the `poll_time` set in seconds.
  """
  def handle_info(:check_service, state) do
    state =
      state.url
      |> HTTPoison.get()
      |> parse_response()
      |> update_state(state)
      |> broadcast_state()

    Process.send_after(self(), :check_service, state.poll_time * 1000)
    {:noreply, state}
  end

  @doc """
  Returns a tuple used to register and lookup a server check process by identifier. This is used to lookup the PID of the ServerCheck process.

    iex> ExGreenYetCore.ServerCheck.via_tuple("app")
    {:via, Registry, {ExGreenYetCore.ServerCheckRegistry, "app"}
  """
  def via_tuple(identifier) do
    {:via, Registry, {ExGreenYetCore.ServerCheckRegistry, identifier}}
  end
end
