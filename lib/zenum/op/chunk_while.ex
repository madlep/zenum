defmodule ZEnum.Op.ChunkWhile do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :acc, :chunk_fun, :after_fun]

  def build_op(id, n, [acc, chunk_fun, after_fun]) do
    %ChunkWhile{id: id, n: n, acc: acc, chunk_fun: chunk_fun, after_fun: after_fun}
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %ChunkWhile{}) do
      [
        {op.n, :chunk_while_acc, op.acc}
      ]
    end

    def return_ast(op = %ChunkWhile{}, ops, params, context) do
      acc = Macro.var(fun_param_name(op.n, :chunk_while_acc), context)

      quote context: context, generated: true do
        case unquote(op.after_fun).(unquote(acc)) do
          {:cont, _acc} ->
            unquote(return(ops, params, context))

          {:cont, chunk, _acc} ->
            unquote(push(ops, params, context, {:halt, Macro.var(:chunk, context)}))
        end
      end
    end

    def push_ast(op = %ChunkWhile{}, ops, params, context, {zstate, value}) do
      acc = Macro.var(fun_param_name(op.n, :chunk_while_acc), context)

      quote context: context, generated: true do
        case unquote(op.chunk_fun).(unquote(value), unquote(acc)) do
          {:cont, chunk, unquote(acc)} ->
            unquote(push(ops, params, context, {zstate, Macro.var(:chunk, context)}))

          {:cont, unquote(acc)} ->
            unquote(next(ops, params, context))

          {:halt, unquote(acc)} ->
            unquote(return_ast(op, ops, params, context))
        end
      end
    end
  end
end
