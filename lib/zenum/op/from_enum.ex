defmodule ZEnum.Op.FromEnum do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :enum]

  def build_op(id, n, [enum]) do
    case enum do
      list when is_list(list) ->
        %Op.FromList{id: id, n: n, list: list}

      # {:.., _, [first, last]} ->
      #   %FromRange{id: id, n: n, first: first, last: last, step: nil}

      # {:..//, _, [first, last, step]} ->
      #   %FromRange{id: id, n: n, first: first, last: last, step: step}

      # {:%{}, _, key_values} ->
      #   %FromHash{id: id, n: n, key_values: key_values}

      enum = {var, _, context} when is_atom(var) and is_atom(context) ->
        %FromEnum{id: id, n: n, enum: enum}
    end
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %FromEnum{}) do
      continuation_ast =
        quote generated: true do
          ZEnum.Enumerable.continuation(unquote(op.enum))
        end

      enum_type =
        quote generated: true do
          ZEnum.Enumerable.type(unquote(op.enum))
        end

      [
        {op.n, :from_enum_continuation, continuation_ast},
        {op.n, :from_enum_type, enum_type}
      ]
    end

    def next_fun_ast(op = %FromEnum{}, ops, params, context) do
      [
        list_next_ast(op, ops, params, context),
        range_next_ast(op, ops, params, context),
        enum_next_ast(op, ops, params, context)
      ]
    end

    defp list_next_ast(op = %FromEnum{}, ops, params, context) do
      from_enum_continuation = Macro.var(fun_param_name(op.n, :from_enum_continuation), context)
      from_enum_type = Macro.var(fun_param_name(op.n, :from_enum_type), context)
      next_fun_name = next_fun_name(op)

      cont_list_params =
        params
        |> set_param(
          fun_param_name(op.n, :from_enum_continuation),
          quote context: context, generated: true do
            [unquote(Macro.var(:value, context)) | unquote(from_enum_continuation)]
          end
        )
        |> set_param(
          fun_param_name(op.n, :from_enum_type),
          quote context: context, generated: true do
            unquote(from_enum_type) = :list
          end
        )

      done_list_params =
        params
        |> set_param(
          fun_param_name(op.n, :from_enum_continuation),
          quote context: context, generated: true do
            []
          end
        )
        |> set_param(
          fun_param_name(op.n, :from_enum_type),
          quote context: context, generated: true do
            unquote(from_enum_type) = :list
          end
        )

      quote context: context, generated: true do
        defp unquote(next_fun_name)(unquote_splicing(cont_list_params)) do
          unquote(push(ops, params, context, {:cont, Macro.var(:value, context)}))
        end

        defp unquote(next_fun_name)(unquote_splicing(done_list_params)) do
          unquote(return(ops, params, context))
        end
      end
    end

    defp enum_next_ast(op = %FromEnum{}, ops, params, context) do
      from_enum_continuation = Macro.var(fun_param_name(op.n, :from_enum_continuation), context)
      from_enum_type = Macro.var(fun_param_name(op.n, :from_enum_type), context)
      next_fun_name = next_fun_name(op)

      quote context: context, generated: true do
        defp unquote(next_fun_name)(unquote_splicing(params)) do
          case ZEnum.Enumerable.next(unquote(from_enum_continuation), unquote(from_enum_type)) do
            {:suspended, value, unquote(from_enum_continuation)} ->
              unquote(push(ops, params, context, {:cont, Macro.var(:value, context)}))

            {:halted, value} ->
              unquote(push(ops, params, context, {:halt, Macro.var(:value, context)}))

            {:done, :ok} ->
              unquote(return(ops, params, context))
          end
        end
      end
    end

    defp range_next_ast(op = %FromEnum{}, ops, params, context) do
      from_enum_continuation = Macro.var(fun_param_name(op.n, :from_enum_continuation), context)
      from_enum_type = Macro.var(fun_param_name(op.n, :from_enum_type), context)
      next_fun_name = next_fun_name(op)

      value = Macro.var(:value, context)
      last = Macro.var(:last, context)
      step = Macro.var(:step, context)

      params =
        params
        |> set_param(
          fun_param_name(op.n, :from_enum_type),
          quote context: context, generated: true do
            unquote(from_enum_type) = :range
          end
        )

      cont_range_params =
        params
        |> set_param(
          fun_param_name(op.n, :from_enum_continuation),
          quote context: context, generated: true do
            unquote(value)..unquote(last)//unquote(step)
          end
        )

      quote context: context, generated: true do
        defp unquote(next_fun_name)(unquote_splicing(cont_range_params))
             when unquote(step) > 0 and unquote(value) <= unquote(last)
             when unquote(step) < 0 and unquote(value) >= unquote(last) do
          unquote(from_enum_continuation) =
            (unquote(value) + unquote(step))..unquote(last)//unquote(step)

          unquote(push(ops, params, context, {:cont, Macro.var(:value, context)}))
        end

        defp unquote(next_fun_name)(unquote_splicing(params)) do
          unquote(return(ops, params, context))
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
