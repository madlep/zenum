defmodule ZEnum.Op.ChunkBy do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :f]

  def build_op(id, n, [f]) do
    %ChunkBy{id: id, n: n, f: f}
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %ChunkBy{}) do
      [
        {op.n, :chunk_by_prev, :__chunk_by_init__},
        {op.n, :chunk_by_acc, []}
      ]
    end

    def push_ast(op = %ChunkBy{}, ops, params, context, {:cont, value}) do
      prev = Macro.var(fun_param_name(op.n, :chunk_by_prev), context)
      acc = Macro.var(fun_param_name(op.n, :chunk_by_acc), context)

      quote context: context, generated: true do
        chunk_value = unquote(op.f).(unquote(value))

        if unquote(prev) == :__chunk_by_init__ do
          unquote(prev) = chunk_value
          unquote(acc) = [unquote(value)]
          unquote(next(ops, params, context))
        else
          if chunk_value != unquote(prev) do
            chunk = Enum.reverse(unquote(acc))
            unquote(prev) = chunk_value
            unquote(acc) = [unquote(value)]
            unquote(push(ops, params, context, {:cont, Macro.var(:chunk, context)}))
          else
            unquote(acc) = [unquote(value) | unquote(acc)]
            unquote(next(ops, params, context))
          end
        end
      end
    end

    def return_ast(op = %ChunkBy{}, ops, params, context) do
      acc = Macro.var(fun_param_name(op.n, :chunk_by_acc), context)

      quote context: context, generated: true do
        if unquote(acc) == [] do
          unquote(return(ops, params, context))
        else
          chunk = Enum.reverse(unquote(acc))
          unquote(push(ops, params, context, {:halt, Macro.var(:chunk, context)}))
        end
      end
    end
  end
end
