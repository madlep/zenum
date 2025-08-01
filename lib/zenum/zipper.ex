defmodule ZEnum.Zipper do
  alias __MODULE__, as: Z

  @opaque t(v) :: %Z{prev: list(v), next: list(v)}
  defstruct prev: [], next: []

  @doc """
  Create new zipper with list content as `next` values.

      iex> ZEnum.Zipper.new([1, 2, 3, 4])
      %ZEnum.Zipper{prev: [], next: [1, 2, 3, 4]}
  """
  @spec new(list(v)) :: t(v) when v: var
  def new(list) when is_list(list), do: %Z{prev: [], next: list}

  @doc """
  Test if there is a value in the head position.

      iex> z = ZEnum.Zipper.new([1,2])
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.head?(z)
      true

  This will be `false` if the zipper is exhausted "next" values, or if it is empty.

      iex> z = ZEnum.Zipper.new([1,2])
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.head?(z)
      false

      iex> z = ZEnum.Zipper.new([])
      iex> ZEnum.Zipper.head?(z)
      false
  """
  @spec head?(t(_v)) :: boolean() when _v: var
  def head?(z = %Z{}), do: z.next != []

  @doc """
  Fetch the current head of the zipper.

      iex> z = ZEnum.Zipper.new([1,2])
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.head!(z)
      2

  Will raise if the zipper has exhausted "next" values, or is empty.

      iex> z = ZEnum.Zipper.new([1,2])
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.next!()
      iex> ExUnit.Assertions.assert_raise(RuntimeError, fn -> ZEnum.Zipper.head!(z) end)

      iex> z = ZEnum.Zipper.new([])
      iex> ExUnit.Assertions.assert_raise(RuntimeError, fn -> ZEnum.Zipper.head!(z) end)
  """
  @spec head!(t(v)) :: v when v: var
  def head!(%Z{next: [v | _]}), do: v
  def head!(%Z{}), do: raise("no head value")

  @doc """
  Get the current head of the zipper in an `:ok`/`:error` tuple

      iex> z = ZEnum.Zipper.new([1,2]) 
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.head(z)
      {:ok, 2}

      iex> z = ZEnum.Zipper.new([1,2])
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.head(z)
      {:error, :no_head}

      iex> z = ZEnum.Zipper.new([])
      iex> ZEnum.Zipper.head(z)
      {:error, :no_head}
  """
  @spec head(t(v)) :: {:ok, t(v)} | {:error, :no_head} when v: var
  def head(%Z{next: [v | _]}), do: {:ok, v}
  def head(%Z{}), do: {:error, :no_head}

  @doc """
  Test if there is are values we have moved past in the "previous" positions

      iex> z = ZEnum.Zipper.new([1,2])
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.prev?(z)
      true

  This will be `false` if the zipper the zipper has not advanced at all, or is empty

      iex> z = ZEnum.Zipper.new([1,2])
      iex> ZEnum.Zipper.prev?(z)
      false

      iex> z = ZEnum.Zipper.new([])
      iex> ZEnum.Zipper.prev?(z)
      false
  """
  @spec prev?(t(_v)) :: boolean() when _v: var
  def prev?(z = %Z{}), do: z.prev != []

  @doc """
  Move the zipper backwards to the previous position

      iex> z = ZEnum.Zipper.new([1, 2, 3])
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.prev!(z)
      %ZEnum.Zipper{prev: [1], next: [2, 3]}

  Will raise if the zipper is at the initial position, or is empty

      iex> z = ZEnum.Zipper.new([1,2])
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.prev!()
      iex> ExUnit.Assertions.assert_raise(RuntimeError, fn -> ZEnum.Zipper.prev!(z) end)

      iex> z = ZEnum.Zipper.new([])
      iex> ExUnit.Assertions.assert_raise(RuntimeError, fn -> ZEnum.Zipper.prev!(z) end)
  """
  @spec prev!(t(v)) :: t(v) when v: var
  def prev!(%Z{prev: []}), do: raise("no prev values")
  def prev!(%Z{prev: [v | prev], next: next}), do: %Z{prev: prev, next: [v | next]}

  @doc """
  Move the zipper backwards to the previous position in an `:ok`/`:error` tuple

      iex> z = ZEnum.Zipper.new([1, 2, 3])
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.prev(z)
      {:ok, %ZEnum.Zipper{prev: [1], next: [2,3]}}

      iex> z = ZEnum.Zipper.new([1, 2, 3])
      iex> ZEnum.Zipper.prev(z)
      {:error, :no_previous}

      iex> z = ZEnum.Zipper.new([])
      iex> ZEnum.Zipper.prev(z)
      {:error, :no_previous}
  """
  @spec prev(t(v)) :: {:ok, t(v)} | {:error, :no_previous} when v: var
  def prev(%Z{prev: []}), do: {:error, :no_previous}
  def prev(%Z{prev: [v | prev], next: next}), do: {:ok, %Z{prev: prev, next: [v | next]}}

  @doc """
  Test if a zipper has remaining values to move next to (not including current)

      iex> z = ZEnum.Zipper.new([1,2,3])
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.next?(z)
      true

      iex> z = ZEnum.Zipper.new([1,2])
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.next?(z)
      false

      iex> z = ZEnum.Zipper.new([])
      iex> ZEnum.Zipper.next?(z)
      false
  """
  @spec next?(t(_v)) :: boolean() when _v: var
  def next?(z = %Z{}), do: z.next != []

  @doc """
  Move the zipper forwards to the next position

      iex> z = ZEnum.Zipper.new([1, 2, 3])
      iex> ZEnum.Zipper.next!(z)
      %ZEnum.Zipper{prev: [1], next: [2, 3]}

  Will raise if the zipper is at the last position, or is empty

      iex> z = ZEnum.Zipper.new([1,2])
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.next!()
      iex> ExUnit.Assertions.assert_raise(RuntimeError, fn -> ZEnum.Zipper.next!(z) end)

      iex> z = ZEnum.Zipper.new([])
      iex> ExUnit.Assertions.assert_raise(RuntimeError, fn -> ZEnum.Zipper.next!(z) end)
  """
  @spec next!(t(v)) :: t(v) when v: var
  def next!(%Z{prev: prev, next: [v | next]}), do: %Z{prev: [v | prev], next: next}
  def next!(%Z{}), do: raise("no next values")

  @doc """
  Move the zipper forwards to the next position in an `:ok`/`:error` tuple

      iex> z = ZEnum.Zipper.new([1, 2, 3])
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.next(z)
      {:ok, %ZEnum.Zipper{prev: [2, 1], next: [3]}}

      iex> z = ZEnum.Zipper.new([1, 2, 3])
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.next!()
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.next(z)
      {:error, :no_next}

      iex> z = ZEnum.Zipper.new([])
      iex> ZEnum.Zipper.next(z)
      {:error, :no_next}
  """
  @spec next(t(v)) :: {:ok, t(v)} | {:error, :no_next} when v: var
  def next(%Z{prev: prev, next: [v | next]}), do: {:ok, %Z{prev: [v | prev], next: next}}
  def next(%Z{}), do: {:error, :no_next}

  @doc """
  Count of remaining next values. Previous values do not contribute to count.

      iex> z = ZEnum.Zipper.new([1,2,3])
      iex> ZEnum.Zipper.count(z)
      3

      iex> z = ZEnum.Zipper.new([1,2,3])
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.count(z)
      2
  """
  @spec count(t(_v)) :: non_neg_integer() when _v: var
  def count(z = %Z{}), do: length(z.next)

  @doc """
  Concatete a list on the end of the next elements for a zipper

      iex> z = ZEnum.Zipper.new([1,2,3])
      ...>   |> ZEnum.Zipper.next!()
      iex> ZEnum.Zipper.concat_list(z, [:a, :b, :c])
      %ZEnum.Zipper{prev: [1], next: [2, 3, :a, :b, :c]}
  """
  @spec concat_list(t(v), list(v)) :: t(v) when v: var
  def concat_list(z = %Z{}, list) when is_list(list), do: %Z{z | next: z.next ++ list}

  @doc """
  Map over the zipper, stepping through `next/1` and yielding the zipper at that position (as opposed to of the value at the head, which `Enum.map/2` woudld do).

      iex> z = [:a, :b, :c] |> ZEnum.Zipper.new()
      iex> ZEnum.Zipper.map_zipper(z, fn 
      ...>   z2 -> %{head: ZEnum.Zipper.head!(z2), remaining: ZEnum.Zipper.count(z2)}
      ...> end)
      [%{head: :a, remaining: 3}, %{head: :b, remaining: 2}, %{head: :c, remaining: 1}]
  """
  @spec map_zipper(t(v), (t(v) -> v2)) :: list(v2) when v: var, v2: var
  def map_zipper(z = %Z{}, f), do: do_map_zipper(z, f, [])

  defp do_map_zipper(z = %Z{}, f, acc) do
    if head?(z) do
      do_map_zipper(next!(z), f, [f.(z) | acc])
    else
      Enum.reverse(acc)
    end
  end

  @spec map(t(v), (v -> v2)) :: t(v2) when v: var, v2: var
  def map(z = %Z{}, f) do
    %Z{prev: z.prev, next: Enum.map(z.next, f)}
  end

  defimpl Enumerable do
    def count(z), do: {:ok, Z.count(z)}

    def member?(_z, _), do: {:error, Z}

    def reduce(_z, {:halt, acc}, _f), do: {:halted, acc}

    def reduce(z, {:suspend, acc}, f), do: {:suspended, acc, &reduce(z, &1, f)}

    def reduce(z, {:cont, acc}, f) do
      if Z.head?(z) do
        reduce(Z.next!(z), f.(Z.head!(z), acc), f)
      else
        {:done, acc}
      end
    end

    def slice(_z), do: {:error, Z}
  end

  defimpl Collectable do
    def into(zipper) do
      collector = fn
        acc, {:cont, elem} -> [elem | acc]
        acc, :done -> Z.concat_list(zipper, Enum.reverse(acc))
        _acc, :halt -> :ok
      end

      {[], collector}
    end
  end
end
