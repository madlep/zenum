defmodule Zenum.Op.AnyTest do
  use ExUnit.Case

  use Zenum

  describe "any?/1" do
    test "basic usage" do
      assert Zenum.any?([2, 4, 6])
      assert Zenum.any?([2, nil, 4])
      refute Zenum.any?([])
    end

    test "in pipeline" do
      actual =
        [1, 2, 3, 4]
        |> Zenum.filter(fn x -> x > 1 end)
        |> Zenum.any?()

      assert actual == true

      actual =
        [1, nil, false]
        |> Zenum.filter(fn x -> x > 1 end)
        |> Zenum.any?()

      assert actual == false
    end
  end

  describe "any?/2" do
    test "basic usage" do
      assert Zenum.any?([2, 4, 6], fn x -> rem(x, 2) == 0 end)
      refute Zenum.any?([1, 3, 5], fn x -> rem(x, 2) == 0 end)
    end

    test "in pipeline" do
      actual =
        [1, 2, 3, 4]
        |> Zenum.filter(fn x -> x > 1 end)
        |> Zenum.any?(fn x -> x >= 4 end)

      assert actual == true

      actual =
        [1, 2, 3, 4]
        |> Zenum.filter(fn x -> x > 1 end)
        |> Zenum.any?(fn x -> x > 4 end)

      assert actual == false
    end
  end
end
