defmodule ZEnum.Op.FromEnum do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :enum]

  def build_op(id, [enum]) do
    case enum do
      list when is_list(list) ->
        %Op.FromList{id: id, list: list}

      # {:.., _, [first, last]} ->
      #   %FromRange{id: id, n: n, first: first, last: last, step: nil}

      # {:..//, _, [first, last, step]} ->
      #   %FromRange{id: id, n: n, first: first, last: last, step: step}

      # {:%{}, _, key_values} ->
      #   %FromHash{id: id, n: n, key_values: key_values}

      enum = {var, _, context} when is_atom(var) and is_atom(context) ->
        %FromEnum{id: id, enum: enum}
    end
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %FromEnum{}) do
      continuation_ast =
        quote generated: true do
          case unquote(op.enum) do
            d when is_list(d) ->
              d

            d when is_struct(d, Range) ->
              d

            d when is_map(d) ->
              d |> :maps.iterator(:undefined) |> :maps.next()

            d ->
              {:suspended, :ok, cont} =
                Enumerable.reduce(d, {:suspend, :ok}, fn acc, _ -> {:suspend, acc} end)

              cont
          end
        end

      [
        {:from_enum_continuation, continuation_ast}
      ]
    end

    def next_fun_ast(op = %FromEnum{}, ops, params, context) do
      [
        dialyzer_opts_ast(op, ops, params, context),
        list_next_ast(op, ops, params, context),
        range_next_ast(op, ops, params, context),
        map_next_ast(op, ops, params, context),
        enum_next_ast(op, ops, params, context)
      ]
    end

    # TODO figure out if there's a better way to stop dialyzer warnings.
    # Without the `no_fail_call` option, the map {k, v} call will "fail" if passed to a map etc function that expects plain old value from a list or range or enum.
    defp dialyzer_opts_ast(op, _ops, params, context) do
      fun = next_fun_name(op)
      arity = length(params)

      quote generated: true, context: context do
        @dialyzer {:no_fail_call, [{unquote(fun), unquote(arity)}]}
      end
    end

    defp list_next_ast(op = %FromEnum{}, ops, params, context) do
      from_enum_continuation = Macro.var(fun_param_name(op.n, :from_enum_continuation), context)
      next_fun_name = next_fun_name(op)

      quote context: context, generated: true do
        defp unquote(next_fun_name)(unquote_splicing(params))
             when is_list(unquote(from_enum_continuation)) do
          case unquote(from_enum_continuation) do
            [value | unquote(from_enum_continuation)] ->
              unquote(call_push_fun_ast(ops, params, context, Macro.var(:value, context)))

            [] ->
              unquote(return(ops, params, context))
          end
        end
      end
    end

    defp range_next_ast(op = %FromEnum{}, ops, params, context) do
      from_enum_continuation = Macro.var(fun_param_name(op.n, :from_enum_continuation), context)
      next_fun_name = next_fun_name(op)

      quote context: context, generated: true do
        defp unquote(next_fun_name)(unquote_splicing(params))
             when is_struct(unquote(from_enum_continuation), Range) do
          case unquote(from_enum_continuation) do
            value..last//step when step > 0 and value <= last when step < 0 and value >= last ->
              unquote(from_enum_continuation) = (value + step)..last//step
              unquote(call_push_fun_ast(ops, params, context, Macro.var(:value, context)))

            _ ->
              unquote(return(ops, params, context))
          end
        end
      end
    end

    defp map_next_ast(op = %FromEnum{}, ops, params, context) do
      from_enum_continuation = Macro.var(fun_param_name(op.n, :from_enum_continuation), context)
      next_fun_name = next_fun_name(op)

      quote context: context, generated: true do
        defp unquote(next_fun_name)(unquote_splicing(params))
             when (is_tuple(unquote(from_enum_continuation)) and
                     tuple_size(unquote(from_enum_continuation)) == 3) or
                    unquote(from_enum_continuation) == :none do
          case unquote(from_enum_continuation) do
            :none ->
              unquote(return(ops, params, context))

            {k, v, unquote(from_enum_continuation)} ->
              value = {k, v}
              unquote(call_push_fun_ast(ops, params, context, Macro.var(:value, context)))
          end
        end
      end
    end

    defp enum_next_ast(op = %FromEnum{}, ops, params, context) do
      from_enum_continuation = Macro.var(fun_param_name(op.n, :from_enum_continuation), context)
      next_fun_name = next_fun_name(op)

      quote context: context, generated: true do
        defp unquote(next_fun_name)(unquote_splicing(params))
             when is_function(unquote(from_enum_continuation), 1) do
          case unquote(from_enum_continuation).({:cont, :ok}) do
            {:suspended, value, unquote(from_enum_continuation)} ->
              unquote(call_push_fun_ast(ops, params, context, Macro.var(:value, context)))

            {:halted, value} ->
              unquote(call_push_fun_ast(ops, params, context, Macro.var(:value, context)))

            {:done, :ok} ->
              unquote(return(ops, params, context))
          end
        end
      end
    end

    def next_ast(op = %FromEnum{}, _ops, params, context) do
      quote context: context, generated: true do
        unquote(next_fun_name(op))(unquote_splicing(params))
      end
    end

    # no-op - shouldn't be called
    def push_ast(_op = %FromEnum{}, _ops, _params, _context, _v), do: []

    def push_fun_ast(_op = %FromEnum{}, _ops, _params, _context), do: []
  end
end
