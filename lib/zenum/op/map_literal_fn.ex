defmodule ZEnum.Op.MapLiteralFn do
  alias __MODULE__
  alias ZEnum.Op
  import ZEnum.AST

  defstruct [:id, :n, :f]

  def build_op(id, n, [f]), do: %__MODULE__{id: id, n: n, f: f}

  defimpl Op do
    use Op.DefaultImpl

    def push_ast(op = %MapLiteralFn{}, ops, params, context, {zstate, value}) do
      quote context: context, generated: true do
        unquote(value) = unquote(op.f).(unquote(value))
        unquote(push(ops, params, context, {zstate, value}))
      end
    end
  end
end
