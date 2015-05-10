defmodule PortalTest do
  use ExUnit.Case

  test "should shoot a portal with a color" do
    case Portal.shoot(:orange) do
      {:ok, _} -> assert :ok == :ok
      _        -> assert :ok == :error
    end
  end

  test "should transfer data" do
    {:ok, _} = Portal.shoot(:red)
    {:ok, _} = Portal.shoot(:blue)
    portal = Portal.transfer(:red, :blue, [1, 2, 3, 4])

    assert  nil != portal
  end
end
