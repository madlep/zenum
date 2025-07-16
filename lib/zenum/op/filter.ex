defmodule ZEnum.Op.Filter do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.Zipper
  import ZEnum.AST

  defstruct [:id, :n, :f]

  def build_op(id, n, [f]), do: %__MODULE__{id: id, n: n, f: f}

  defimpl Op do
    use Op.DefaultImpl

    def push_ast(op = %Filter{}, ops, params, context, {zstate, value}) do
      ops_1 = Zipper.prev!(ops)

      quote context: context, generated: true do
        if unquote(op.f).(unquote(value)) do
          unquote(Op.push_ast(Zipper.head!(ops_1), ops_1, params, context, {zstate, value}))
        else
          unquote(next_or_return(ops, params, context, zstate))
        end
      end
    end
  end
end
