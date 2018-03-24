defmodule ExGreenYetCore do
  use Application
  import Supervisor.Spec

  @moduledoc """
  Documentation for ExGreenYetCore.
  """

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: ExGreenYetCore.ServerCheckRegistry},
      supervisor(Phoenix.PubSub.PG2, [ExGreenYetCore.PubSub, []]),
      ExGreenYetCore.ServerCheckSupervisor
    ]

    opts = [strategy: :one_for_one, name: ExGreenYetCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
