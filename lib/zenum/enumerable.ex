defmodule ZEnum.Enumerable do
  def next_ast(enum, value, rest, next_ast, done_ast, context) do
    quote generated: true, context: context do
      case unquote(enum) do
        # list
        [unquote(value) | unquote(rest)] ->
          unquote(next_ast)

        [] ->
          unquote(done_ast)

        # range
        unquote(value)..last//step
        when step > 0 and unquote(value) <= last
        when step > 0 and unquote(value) >= last ->
          unquote(rest) = (unquote(value) + step)..(last / step)
          unquote(next_ast)

        _first.._last//_step ->
          unquote(done_ast)

        # map
        map when is_map(map) ->
          case map |> :maps.iterator(:undefined) |> :maps.next() do
            {k, v, unquote(rest)} ->
              unquote(value) = {k, v}
              unquote(next_ast)

            :none ->
              unquote(done_ast)
          end

        {k, v, unquote(rest)} ->
          unquote(value) = {k, v}
          unquote(next_ast)

        :none ->
          unquote(done_ast)

        # enum
        cont when is_function(cont, 1) ->
          case cont.({:cont, :ok}) do
            {:suspended, unquote(value), unquote(rest)} ->
              unquote(next_ast)

            {:halted, unquote(value)} ->
              unquote(rest) = []
              unquote(next_ast)

            {:done, :ok} ->
              unquote(done_ast)
          end

        enum ->
          {:suspended, :ok, cont} =
            Enumerable.reduce(enum, {:suspend, :ok}, fn value, _acc -> {:suspend, value} end)

          case cont.({:cont, :ok}) do
            {:suspended, unquote(value), unquote(rest)} ->
              unquote(next_ast)

            {:halted, unquote(value)} ->
              unquote(rest) = []
              unquote(next_ast)

            {:done, :ok} ->
              unquote(done_ast)
          end
      end
    end
  end

  @spec next(continuation :: any()) :: Enumerable.result()
  # list
  def next([value | rest]), do: {:suspended, value, rest}

  def next([]), do: {:done, :ok}

  # range
  def next(value..last//step)
      when step > 0 and value <= last
      when step < 0 and value >= last do
    {:suspended, value, (value + step)..last//step}
  end

  def next(_first.._last//_step), do: {:done, :ok}

  # map
  def next(map) when is_map(map), do: next(map |> :maps.iterator(:undefined) |> :maps.next())

  def next({k, v, iterator}), do: {:suspended, {k, v}, iterator}

  def next(:none), do: {:done, :ok}

  # enumerable
  def next(cont) when is_function(cont, 1), do: cont.({:cont, :ok})

  def next(enum) do
    {:suspended, :ok, cont} =
      Enumerable.reduce(enum, {:suspend, :ok}, fn value, _acc -> {:suspend, value} end)

    next(cont)
  end
end
