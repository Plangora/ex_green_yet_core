defmodule ServerCheckSupervisorText do
  use ExUnit.Case, async: true

  alias ExGreenYetCore.{ServerCheck, ServerCheckSupervisor}

  setup do: {:ok, %{url: "http://localhost:4000", poll_time: 5}}

  describe "start_server_check" do
    test "creates server check process", %{url: url, poll_time: poll_time} do
      identifier = generate_identifier()
      assert {:ok, _pid} = ServerCheckSupervisor.start_server_check(identifier, url, poll_time)
      via = ServerCheck.via_tuple(identifier)
      assert GenServer.whereis(via) |> Process.alive?()
    end

    test "returns error if server check process is already started", %{
      url: url,
      poll_time: poll_time
    } do
      identifier = generate_identifier()
      assert {:ok, pid} = ServerCheckSupervisor.start_server_check(identifier, url, poll_time)

      assert {:error, {:already_started, ^pid}} =
               ServerCheckSupervisor.start_server_check(identifier, url, poll_time)
    end
  end

  describe "stop_server_check" do
    test "terminates the process normally", %{url: url, poll_time: poll_time} do
      identifier = generate_identifier()

      {:ok, _pid} = ServerCheckSupervisor.start_server_check(identifier, url, poll_time)

      via = ServerCheck.via_tuple(identifier)

      assert :ok = ServerCheckSupervisor.stop_server_check(identifier)

      refute GenServer.whereis(via)
    end
  end

  def generate_identifier do
    "app#{:rand.uniform(1000)}"
  end
end
