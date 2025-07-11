defmodule ZEnum.Op.Filter do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.Zipper

  defstruct [:n, :f]

  def build_op(n, [f]), do: %__MODULE__{n: n, f: f}

  defimpl Op do
    use Op.DefaultImpl

    def push_ast(op = %Filter{}, ops, id, params, context, value) do
      ops_1 = Zipper.prev!(ops)
      ops2 = Zipper.next!(ops)

      quote context: context, generated: true do
        if unquote(op.f).(unquote(value)) do
          unquote(Op.push_ast(Zipper.head!(ops_1), ops_1, id, params, context, value))
        else
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        end
      end
    end
  end
end
