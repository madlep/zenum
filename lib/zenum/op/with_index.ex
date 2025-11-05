defmodule ZEnum.Op.WithIndex do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :fun_or_offset]

  def build_op(id, [fun_or_offset]) do
    %WithIndex{id: id, fun_or_offset: fun_or_offset}
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %WithIndex{}) do
      [
        {:with_index_fun_or_offset, op.fun_or_offset},
        {:with_index_offset, 0}
      ]
    end

    def push_ast(op = %WithIndex{}, ops, params, context, {zstate, value}) do
      fun_or_offset = Macro.var(fun_param_name(op.n, :with_index_fun_or_offset), context)
      offset = Macro.var(fun_param_name(op.n, :with_index_offset), context)

      quote generated: true, context: context do
        case unquote(fun_or_offset) do
          offset when is_integer(offset) ->
            value = {unquote(value), unquote(fun_or_offset)}
            unquote(fun_or_offset) = offset + 1
            unquote(push(ops, params, context, {zstate, Macro.var(:value, context)}))

          fun when is_function(unquote(fun_or_offset), 2) ->
            value = fun.(unquote(value), unquote(offset))
            unquote(offset) = unquote(offset) + 1
            unquote(push(ops, params, context, {zstate, Macro.var(:value, context)}))
        end
      end
    end
  end
end
