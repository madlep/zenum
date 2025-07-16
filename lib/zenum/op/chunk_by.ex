defmodule ZEnum.Op.ChunkBy do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.Zipper

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
      ops_1 = Zipper.prev!(ops)
      ops2 = Zipper.next!(ops)

      prev = Macro.var(fun_param_name(op.n, :chunk_by_prev), context)
      acc = Macro.var(fun_param_name(op.n, :chunk_by_acc), context)
      chunk_var = Macro.var(:chunk, context)

      quote context: context, generated: true do
        chunk_value = unquote(op.f).(unquote(value))

        if unquote(prev) == :__chunk_by_init__ do
          unquote(prev) = chunk_value
          unquote(acc) = [unquote(value)]
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, params, context))
        else
          if chunk_value != unquote(prev) do
            chunk = Enum.reverse(unquote(acc))
            unquote(prev) = chunk_value
            unquote(acc) = [unquote(value)]

            unquote(Op.push_ast(Zipper.head!(ops_1), ops_1, params, context, {:cont, chunk_var}))
          else
            unquote(acc) = [unquote(value) | unquote(acc)]
            unquote(Op.next_ast(Zipper.head!(ops2), ops2, params, context))
          end
        end
      end
    end

    def return_ast(op = %ChunkBy{}, ops, params, context) do
      acc = Macro.var(fun_param_name(op.n, :chunk_by_acc), context)
      ops_prev = ZEnum.Zipper.prev!(ops)

      quote context: context, generated: true do
        if unquote(acc) == [] do
          unquote(ZEnum.Op.return_ast(ZEnum.Zipper.head!(ops_prev), ops_prev, params, context))
        else
          chunk = Enum.reverse(unquote(acc))
          unquote(acc) = :__chunk_by_done__

          unquote(
            Op.push_ast(
              ZEnum.Zipper.head!(ops_prev),
              ops_prev,
              params,
              context,
              {:halt, Macro.var(:chunk, context)}
            )
          )
        end
      end
    end
  end
end
