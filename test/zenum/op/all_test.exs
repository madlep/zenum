defmodule Zenum.Op.AllTest do
  use ExUnit.Case

  use Zenum

  describe "all?/1" do
    test "basic usage" do
      assert Zenum.all?([2, 4, 6])
      refute Zenum.all?([2, nil, 4])
      assert Zenum.all?([])
    end

    test "in pipeline" do
      actual =
        [1, 2, 3, 4]
        |> Zenum.filter(fn x -> x > 1 end)
        |> Zenum.all?()

      assert actual == true

      actual =
        [1, 2, nil, 4]
        |> Zenum.filter(fn x -> x > 1 end)
        |> Zenum.all?()

      assert actual == false
    end
  end

  describe "all?/2" do
    test "basic usage" do
      assert Zenum.all?([2, 4, 6], fn x -> rem(x, 2) == 0 end)
      refute Zenum.all?([2, 3, 4], fn x -> rem(x, 2) == 0 end)
    end

    test "in pipeline" do
      actual =
        [1, 2, 3, 4]
        |> Zenum.filter(fn x -> x > 1 end)
        |> Zenum.all?(fn x -> x <= 4 end)

      assert actual == true

      actual =
        [1, 2, 3, 4]
        |> Zenum.filter(fn x -> x > 1 end)
        |> Zenum.all?(fn x -> x > 4 end)

      assert actual == false
    end
  end
end
