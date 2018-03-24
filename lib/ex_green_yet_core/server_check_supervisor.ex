defmodule ExGreenYetCore.ServerCheckSupervisor do
  @moduledoc """
    ServerCheck supervisor that can add and remove ServerCheck processes, dynamically.
  """
  use DynamicSupervisor

  alias ExGreenYetCore.ServerCheck

  def start_link(_args), do: DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  @doc """
  Starts a `ServerCheck` process and supervises it.
"""
  def start_server_check(identifier, url, poll_time) do
    child_spec = %{
      id: ServerCheck,
      start: {ServerCheck, :start_link, [identifier, url, poll_time]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @doc """
  Terminates a `ServerCheck` process, normally. After it is terminated, then it will not be restarted.
"""
  def stop_server_check(identifier) do
    child_pid =
      identifier
      |> ServerCheck.via_tuple()
      |> GenServer.whereis()

    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end
end
