defmodule ZEnum.Op.ChunkEveryTest do
  use ExUnit.Case

  use ZEnum

  describe "chunk_every/2" do
    test "basic usage" do
      assert ZEnum.chunk_every([1, 2, 3, 4, 5], 2) == [[1, 2], [3, 4], [5]]
    end
  end

  describe "chunk_every/4" do
    test "basic usage" do
      assert ZEnum.chunk_every([1, 2, 3, 4, 5], 2, 2, [6]) == [[1, 2], [3, 4], [5, 6]]
      assert ZEnum.chunk_every([1, 2, 3, 4, 5, 6], 3, 2, :discard) == [[1, 2, 3], [3, 4, 5]]
      assert ZEnum.chunk_every([1, 2, 3, 4, 5, 6], 2, 3, :discard) == [[1, 2], [4, 5]]
      assert ZEnum.chunk_every([1, 2, 3, 4, 5, 6], 3, 2, []) == [[1, 2, 3], [3, 4, 5], [5, 6]]
      assert ZEnum.chunk_every([1, 2, 3, 4, 5, 6], 3, 3, []) == [[1, 2, 3], [4, 5, 6]]
      assert ZEnum.chunk_every([1, 2, 3, 4, 5], 4, 4, 6..10) == [[1, 2, 3, 4], [5, 6, 7, 8]]
      assert ZEnum.chunk_every([1, 2, 3, 4, 5], 2, 3, []) == [[1, 2], [4, 5]]
      assert ZEnum.chunk_every([1, 2, 3, 4, 5, 6], 2, 3, []) == [[1, 2], [4, 5]]
      assert ZEnum.chunk_every([1, 2, 3, 4, 5, 6, 7], 2, 3, []) == [[1, 2], [4, 5], [7]]
      assert ZEnum.chunk_every([1, 2, 3, 4, 5, 6, 7], 2, 3, [8]) == [[1, 2], [4, 5], [7, 8]]
      assert ZEnum.chunk_every([1, 2, 3, 4, 5, 6, 7], 2, 4, []) == [[1, 2], [5, 6]]
    end
  end
end
