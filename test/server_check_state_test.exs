defmodule ServerCheckStateText do
  use ExUnit.Case, async: true

  doctest ExGreenYetCore.ServerCheckState

  alias ExGreenYetCore.ServerCheckState

  setup do: {:ok, %{identifier: "app", url: "http://localhost", poll_time: 5}}

  describe "creating server check state" do
    test "requires identifier, url, and poll time", %{
      identifier: id,
      url: url,
      poll_time: poll_time
    } do
      assert %ServerCheckState{identifier: ^id, url: ^url, poll_time: ^poll_time} =
               ServerCheckState.new(id, url, poll_time)
    end
  end
end
