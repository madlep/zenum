defmodule ZenumTest do
  use ExUnit.Case
  doctest Zenum

  use Zenum

  test "simple pipe" do
    input = [1, 2, 3, 4, 1, 2, 3]

    actual =
      input
      |> Zenum.from_list()
      |> Zenum.map(fn x -> x * 2 end)
      |> Zenum.filter(fn x -> x <= 6 end)
      |> Zenum.to_list()

    assert actual == [2, 4, 6, 2, 4, 6]
  end

  # test "simple functions" do
  #   actual =
  #     Zenum.filter(Zenum.map([1, 2, 3, 4, 1, 2, 3], fn x -> x * 2 end), fn x -> x <= 6 end)

  #   assert actual == [2, 4, 6, 2, 4, 6]
  # end
end
