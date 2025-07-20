defmodule ZEnum.Op.ChunkWhileTest do
  use ExUnit.Case

  use ZEnum

  defp chunk_fun(i, acc) do
    cond do
      i > 10 ->
        {:halt, acc}

      rem(i, 2) == 0 ->
        {:cont, Enum.reverse([i | acc]), []}

      true ->
        {:cont, [i | acc]}
    end
  end

  defp after_fun([]), do: {:cont, []}
  defp after_fun(acc), do: {:cont, Enum.reverse(acc), []}

  defp chunk_fn2(-1, acc), do: {:cont, acc, 0}
  defp chunk_fn2(i, acc), do: {:cont, acc + i}
  defp after_fn2(acc), do: {:cont, acc, 0}

  describe "chunk_while/4" do
    test "basic usage" do
      # TODO anonymous functions
      # chunk_fun = fn i, acc ->
      #   cond do
      #     i > 10 ->
      #       {:halt, acc}

      #     rem(i, 2) == 0 ->
      #       {:cont, Enum.reverse([i | acc]), []}

      #     true ->
      #       {:cont, [i | acc]}
      #   end
      # end

      # after_fun = fn
      #   [] -> {:cont, []}
      #   acc -> {:cont, Enum.reverse(acc), []}
      # end

      assert ZEnum.chunk_while([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [], &chunk_fun/2, &after_fun/1) ==
               [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]

      # TODO ranges
      # assert ZEnum.chunk_while(0..9, [], chunk_fun, after_fun) ==
      #         [[0], [1, 2], [3, 4], [5, 6], [7, 8], [9]]
      #
      # assert ZEnum.chunk_while(0..10, [], chunk_fun, after_fun) ==
      #         [[0], [1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]
      #
      # assert ZEnum.chunk_while(0..11, [], chunk_fun, after_fun) ==
      #         [[0], [1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]

      assert ZEnum.chunk_while([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], [], &chunk_fun/2, &after_fun/1) ==
               [[0], [1, 2], [3, 4], [5, 6], [7, 8], [9]]

      assert ZEnum.chunk_while([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [], &chunk_fun/2, &after_fun/1) ==
               [[0], [1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]

      assert ZEnum.chunk_while(
               [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
               [],
               &chunk_fun/2,
               &after_fun/1
             ) ==
               [[0], [1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]

      assert ZEnum.chunk_while([5, 7, 9, 11], [], &chunk_fun/2, &after_fun/1) == [[5, 7, 9]]

      assert ZEnum.chunk_while([1, 2, 3, 5, 7], [], &chunk_fun/2, &after_fun/1) ==
               [[1, 2], [3, 5, 7]]

      # TODO anonymous functions
      # chunk_fn2 = fn
      #   -1, acc -> {:cont, acc, 0}
      #   i, acc -> {:cont, acc + i}
      # end

      # after_fn2 = fn acc -> {:cont, acc, 0} end

      assert ZEnum.chunk_while([1, -1, 2, 3, -1, 4, 5, 6], 0, &chunk_fn2/2, &after_fn2/1) ==
               [1, 5, 15]
    end
  end
end
