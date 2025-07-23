defmodule ZEnum.Enumerable do
  def continuation(enum) do
    {:suspended, :ok, continuation} = Enumerable.reduce(enum, {:suspend, :ok}, &reducer_f/2)
    continuation
  end

  def next(continuation), do: continuation.({:cont, :ok})

  def reducer_f(value, _acc), do: {:suspend, value}
end
