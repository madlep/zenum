defmodule ZEnum.Op.MapLiteralFn do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.Zipper

  import ZEnum.AST

  defstruct [:n, :f]

  def build_op(n, [f]), do: %__MODULE__{n: n, f: f}

  defimpl ZEnum.Op do
    use Op.DefaultImpl

    def push_ast(op = %MapLiteralFn{}, ops, id, params, context, value) do
      ops2 = Zipper.prev!(ops)

      quote context: context, generated: true do
        unquote(value) = unquote(op.f).(unquote(value))
        unquote(Op.push_ast(Zipper.head!(ops2), ops2, id, params, context, value))
      end
    end
  end
end
