defmodule ZEnum.Op.ChunkEvery do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :count, :step, :leftover]

  def build_op(id, n, [count, step, leftover]) do
    %ChunkEvery{id: id, n: n, count: count, step: step, leftover: leftover}
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %ChunkEvery{}) do
      [
        {op.n, :count, op.count},
        {op.n, :step, op.step},
        {op.n, :leftover, op.leftover},
        {op.n, :chunk, []},
        {op.n, :chunk_size, 0},
        {op.n, :acc, []}
      ]
    end

    def push_ast(op = %ChunkEvery{}, ops, params, context, {zstate, value}) do
      count = Macro.var(fun_param_name(op.n, :count), context)
      step = Macro.var(fun_param_name(op.n, :step), context)
      chunk = Macro.var(fun_param_name(op.n, :chunk), context)
      chunk_size = Macro.var(fun_param_name(op.n, :chunk_size), context)

      quote context: context, generated: true do
        unquote(chunk) = [unquote(value) | unquote(chunk)]
        unquote(chunk_size) = unquote(chunk_size) + 1

        if unquote(chunk_size) == unquote(count) do
          if unquote(chunk_size) >= :erlang.max(unquote(count), unquote(step)) do
            unquote(chunk_size) = unquote(chunk_size) - unquote(step)
            push_chunk = :lists.reverse(unquote(chunk))
            unquote(chunk) = Enum.take(unquote(chunk), unquote(chunk_size))
            unquote(push(ops, params, context, {zstate, Macro.var(:push_chunk, context)}))
          else
            push_chunk = :lists.reverse(unquote(chunk))
            unquote(push(ops, params, context, {zstate, Macro.var(:push_chunk, context)}))
          end
        else
          if unquote(chunk_size) >= :erlang.max(unquote(count), unquote(step)) do
            unquote(chunk_size) = unquote(chunk_size) - unquote(step)
            unquote(chunk) = Enum.take(unquote(chunk), unquote(chunk_size))
            unquote(next(ops, params, context))
          else
            unquote(next(ops, params, context))
          end
        end
      end
    end

    def return_ast(op = %ChunkEvery{}, ops, params, context) do
      count = Macro.var(fun_param_name(op.n, :count), context)
      leftover = Macro.var(fun_param_name(op.n, :leftover), context)
      chunk = Macro.var(fun_param_name(op.n, :chunk), context)
      chunk_size = Macro.var(fun_param_name(op.n, :chunk_size), context)

      quote context: context, generated: true do
        if unquote(leftover) == :discard or unquote(chunk_size) == 0 or
             unquote(chunk_size) >= unquote(count) do
          unquote(return(ops, params, context))
        else
          push_chunk =
            :lists.reverse(
              unquote(chunk),
              Enum.take(unquote(leftover), unquote(count) - unquote(chunk_size))
            )

          unquote(push(ops, params, context, {:halt, Macro.var(:push_chunk, context)}))
        end
      end
    end
  end
end
