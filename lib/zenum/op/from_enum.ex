defmodule ZEnum.Op.FromEnum do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :enum]

  def build_op(id, [enum]) do
    case enum do
      list when is_list(list) ->
        %Op.FromList{id: id, list: list}

      # TODO handle other literal values
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
      [
        {:from_enum_continuation, op.enum}
      ]
    end

    def next_fun_ast(op = %FromEnum{}, ops, params, context) do
      from_enum_continuation = Macro.var(fun_param_name(op.n, :from_enum_continuation), context)

      [
        dialyzer_opts_ast(op, ops, params, context),
        quote context: context, generated: true do
          defp unquote(next_fun_name(op))(unquote_splicing(params)) do
            unquote(
              ZEnum.Enumerable.next_ast(
                from_enum_continuation,
                Macro.var(:value, context),
                from_enum_continuation,
                call_push_fun_ast(ops, params, context, Macro.var(:value, context)),
                return(ops, params, context),
                context
              )
            )
          end
        end
      ]
    end

    # TODO figure out if there's a better way to stop dialyzer warnings.
    # Without the `no_fail_call` option, the map {k, v} call will "fail" if passed to a map etc function that expects plain old value from a list or range or enum.
    defp dialyzer_opts_ast(op, _ops, params, context) do
      quote generated: true, context: context do
        @dialyzer {:no_fail_call, [{unquote(next_fun_name(op)), unquote(length(params))}]}
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
