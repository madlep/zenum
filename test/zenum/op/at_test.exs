defmodule Zenum.Op.AtTest do
  use ExUnit.Case

  use Zenum

  test "at/3" do
    assert Zenum.at([2, 4, 6], 0) == 2
    assert Zenum.at([2, 4, 6], 2) == 6
    assert Zenum.at([2, 4, 6], 4) == nil
    assert Zenum.at([2, 4, 6], 4, :none) == :none
    assert Zenum.at([2, 4, 6], -2) == 4
    assert Zenum.at([2, 4, 6], -4) == nil
  end
end
