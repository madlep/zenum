defmodule Zenum.Zipper do
  alias __MODULE__, as: Z

  @opaque t(v) :: %Z{prev: list(v), next: list(v)}
  defstruct prev: [], next: []

  @spec new(list(v)) :: t(v) when v: var
  def new(list) when is_list(list), do: %Z{prev: [], next: list}

  @spec head?(t(_v)) :: boolean() when _v: var
  def head?(z = %Z{}), do: z.next != []

  @spec head!(t(v)) :: v when v: var
  def head!(%Z{next: []}), do: raise("no head value")
  def head!(%Z{next: [v | _]}), do: v

  @spec head(t(v)) :: {:ok, t(v)} | {:error, :no_current} when v: var
  def head(%Z{next: []}), do: {:error, :no_current}
  def head(%Z{next: [v | _]}), do: {:ok, v}

  @spec prev?(t(_v)) :: boolean() when _v: var
  def prev?(z = %Z{}), do: z.prev != []

  @spec prev!(t(v)) :: t(v) when v: var
  def prev!(%Z{prev: []}), do: raise("no prev values")
  def prev!(%Z{prev: [v | prev], next: next}), do: %Z{prev: prev, next: [v | next]}

  @spec prev(t(v)) :: {:ok, t(v)} | {:error, :no_previous} when v: var
  def prev(%Z{prev: []}), do: {:error, :no_previous}
  def prev(%Z{prev: [v | prev], next: next}), do: {:ok, %Z{prev: prev, next: [v | next]}}

  @spec next?(t(_v)) :: boolean() when _v: var
  def next?(z = %Z{}), do: match?([_, _ | _], z.next)

  @spec next!(t(v)) :: t(v) when v: var
  def next!(%Z{next: []}), do: raise("no next values")
  def next!(%Z{prev: prev, next: [v | next]}), do: %Z{prev: [v | prev], next: next}

  @spec next(t(v)) :: {:ok, t(v)} | {:error, :no_next} when v: var
  def next(%Z{next: []}), do: {:error, :no_next}
  def next(%Z{prev: prev, next: [v | next]}), do: {:ok, %Z{prev: [v | prev], next: next}}

  @spec count(t(_v)) :: non_neg_integer() when _v: var
  def count(z = %Z{}), do: length(z.prev) + length(z.next)

  @spec concat_list(t(v), list(v)) :: t(v) when v: var
  def concat_list(z = %Z{}, list), do: %Z{z | next: z.next ++ list}

  @spec map_zipper(t(v), (t(v) -> v2)) :: list(v2) when v: var, v2: var
  def map_zipper(z = %Z{}, f), do: do_map_zipper(z, f, [])

  defp do_map_zipper(%Z{next: []}, _f, acc), do: Enum.reverse(acc)
  defp do_map_zipper(z = %Z{}, f, acc), do: z |> next!() |> do_map_zipper(f, [f.(z) | acc])

  defimpl Enumerable do
    def count(z), do: {:ok, Z.count(z)}

    def member?(_z, _), do: {:error, Z}

    def reduce(_z, {:halt, acc}, _f), do: {:halted, acc}

    def reduce(z, {:suspend, acc}, f), do: {:suspended, acc, &reduce(z, &1, f)}

    def reduce(z, {:cont, acc}, f) do
      case Z.next(z) do
        {:ok, z2} -> reduce(z2, f.(Z.head!(z), acc), f)
        {:error, _} -> {:done, acc}
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
