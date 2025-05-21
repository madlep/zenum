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

  defp double(x), do: x * 2
  defp lte6(x), do: x <= 6

  test "simple pipe local functions" do
    input = [1, 2, 3, 4, 1, 2, 3]

    actual =
      input
      |> Zenum.from_list()
      |> Zenum.map(&double/1)
      |> Zenum.filter(&lte6/1)
      |> Zenum.to_list()

    assert actual == [2, 4, 6, 2, 4, 6]
  end

  # TODO doesn't compile yet. Need to store non-literal callback functions in state args
  # test "simple functions variable" do
  #   map_f = fn x -> x * 2 end
  #   filter_f = fn x -> x <= 6 end

  #   actual =
  #     Zenum.to_list(
  #       Zenum.filter(Zenum.map(Zenum.from_list([1, 2, 3, 4, 1, 2, 3]), map_f), filter_f)
  #     )

  #   assert actual == [2, 4, 6, 2, 4, 6]
  # end

  test "simple functions inline" do
    actual =
      Zenum.to_list(
        Zenum.filter(Zenum.map(Zenum.from_list([1, 2, 3, 4, 1, 2, 3]), fn x -> x * 2 end), fn x ->
          x <= 6
        end)
      )

    assert actual == [2, 4, 6, 2, 4, 6]
  end
end
