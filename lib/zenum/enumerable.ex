defmodule ZEnum.Enumerable do
  @type enum_type() :: :list | :range | :map | :enum

  def continuation(list) when is_list(list), do: list
  def continuation(range) when is_struct(range, Range), do: range
  def continuation(map) when is_map(map), do: map |> :maps.iterator() |> :maps.next()

  def continuation(enum) do
    {:suspended, :ok, continuation} = Enumerable.reduce(enum, {:suspend, :ok}, &reducer_f/2)
    continuation
  end

  @spec next(continuation :: any(), type :: enum_type()) :: Enumerable.result()
  def next([value | rest], :list), do: {:suspended, value, rest}
  def next([], :list), do: {:done, :ok}

  def next(first..last//step, :range)
      when step > 0 and first <= last
      when step < 0 and first >= last do
    {:suspended, first, (first + step)..last//step}
  end

  def next(_range, :range), do: {:done, :ok}

  def next(iterator, :map) do
    case :maps.next(iterator) do
      {key, value, iterator} -> {:suspended, {key, value}, iterator}
      :none -> {:done, :ok}
    end
  end

  def next(continuation, :enum), do: continuation.({:cont, :ok})

  def reducer_f(value, _acc), do: {:suspend, value}

  @spec type(Enumerable.t()) :: enum_type()
  def type(list) when is_list(list), do: :list
  def type(range) when is_struct(range, Range), do: :range
  def type(map) when is_map(map), do: :map
  def type(_enum), do: :enum
end
