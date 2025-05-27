defmodule Zenum.Zipper do
  alias __MODULE__

  @opaque t(v) :: %Zipper{l: list(v), r: list(v)}
  defstruct l: [], r: []

  @spec new(list(v)) :: t(v) when v: var
  def new(list) when is_list(list), do: %Zipper{l: [], r: list}

  @spec current?(t(_v)) :: boolean() when _v: var
  def current?(z = %Zipper{}), do: z.r != []

  @spec current!(t(v)) :: v when v: var
  def current!(%Zipper{r: []}), do: raise("no current value")
  def current!(%Zipper{r: [v | _]}), do: v

  @spec current(t(v)) :: {:ok, t(v)} | {:error, :no_current} when v: var
  def current(%Zipper{r: []}), do: {:error, :no_current}
  def current(%Zipper{r: [v | _]}), do: {:ok, v}

  @spec left?(t(_v)) :: boolean() when _v: var
  def left?(z = %Zipper{}), do: z.l != []

  @spec left!(t(v)) :: t(v) when v: var
  def left!(%Zipper{l: []}), do: raise("no left values")
  def left!(%Zipper{l: [v | l], r: r}), do: %Zipper{l: l, r: [v | r]}

  @spec left(t(v)) :: {:ok, t(v)} | {:error, :no_previous} when v: var
  def left(%Zipper{l: []}), do: {:error, :no_previous}
  def left(%Zipper{l: [v | l], r: r}), do: {:ok, %Zipper{l: l, r: [v | r]}}

  @spec right?(t(_v)) :: boolean() when _v: var
  def right?(z = %Zipper{}), do: match?([_, _ | _], z.r)

  @spec right!(t(v)) :: t(v) when v: var
  def right!(%Zipper{r: []}), do: raise("no next values")
  def right!(%Zipper{l: l, r: [v | r]}), do: %Zipper{l: [v | l], r: r}

  @spec right(t(v)) :: {:ok, t(v)} | {:error, :no_next} when v: var
  def right(%Zipper{r: []}), do: {:error, :no_next}
  def right(%Zipper{l: l, r: [v | r]}), do: {:ok, %Zipper{l: [v | l], r: r}}

  def count(z = %Zipper{}), do: length(z.l) + length(z.r)

  def concat_list(z = %Zipper{}, list), do: %Zipper{l: z.l, r: z.r ++ list}

  def map_zipper(z = %Zipper{}, f), do: do_map_zipper(z, f, [])

  defp do_map_zipper(%Zipper{r: []}, _f, acc), do: Enum.reverse(acc)
  defp do_map_zipper(z = %Zipper{}, f, acc), do: do_map_zipper(right!(z), f, [f.(z) | acc])

  defimpl Enumerable do
    def count(z), do: {:ok, Zipper.count(z)}

    def member?(_z, _), do: {:error, Zipper}

    def reduce(_z, {:halt, acc}, _f), do: {:halted, acc}

    def reduce(z, {:suspend, acc}, f), do: {:suspended, acc, &reduce(z, &1, f)}

    def reduce(z, {:cont, acc}, f) do
      case Zipper.right(z) do
        {:ok, z2} -> reduce(z2, f.(Zipper.current!(z), acc), f)
        {:error, _} -> {:done, acc}
      end
    end

    def slice(_z), do: {:error, Zipper}
  end

  defimpl Collectable do
    def into(zipper) do
      collector = fn
        acc, {:cont, elem} -> [elem | acc]
        acc, :done -> Zipper.concat_list(zipper, Enum.reverse(acc))
        _acc, :halt -> :ok
      end

      {[], collector}
    end
  end
end
