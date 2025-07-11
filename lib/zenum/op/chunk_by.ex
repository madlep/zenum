defmodule ZEnum.Op.ChunkBy do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.Zipper

  import ZEnum.AST

  defstruct [:n, :f]

  def build_op(n, [f]) do
    %ChunkBy{n: n, f: f}
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %ChunkBy{}) do
      [
        {op.n, :chunk_by_prev, :__chunk_by_init__},
        {op.n, :chunk_by_acc, []}
      ]
    end

    def next_ast(op = %ChunkBy{}, ops, id, params, context) do
      ops_prev = ZEnum.Zipper.prev!(ops)
      ops_next = ZEnum.Zipper.next!(ops)
      acc = Macro.var(fun_param_name(op.n, :chunk_by_acc), context)

      quote context: context, generated: true do
        if unquote(acc) == :__chunk_by_done__ do
          unquote(
            ZEnum.Op.return_ast(ZEnum.Zipper.head!(ops_prev), ops_prev, id, params, context)
          )
        else
          unquote(ZEnum.Op.next_ast(ZEnum.Zipper.head!(ops_next), ops_next, id, params, context))
        end
      end
    end

    def push_ast(op = %ChunkBy{}, ops, id, params, context, value) do
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
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        else
          if chunk_value != unquote(prev) do
            chunk = Enum.reverse(unquote(acc))
            unquote(prev) = chunk_value
            unquote(acc) = [unquote(value)]
            unquote(Op.push_ast(Zipper.head!(ops_1), ops_1, id, params, context, chunk_var))
          else
            unquote(acc) = [unquote(value) | unquote(acc)]
            unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
          end
        end
      end
    end

    def return_ast(op = %ChunkBy{}, ops, id, params, context) do
      acc = Macro.var(fun_param_name(op.n, :chunk_by_acc), context)
      ops_prev = ZEnum.Zipper.prev!(ops)

      quote context: context, generated: true do
        if unquote(acc) == [] do
          unquote(
            ZEnum.Op.return_ast(ZEnum.Zipper.head!(ops_prev), ops_prev, id, params, context)
          )
        else
          chunk = Enum.reverse(unquote(acc))
          unquote(acc) = :__chunk_by_done__
          unquote(push_fun_name(id, op.n - 1))(unquote_splicing(params), chunk)
        end
      end
    end
  end
end
