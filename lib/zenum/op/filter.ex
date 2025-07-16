defmodule ZEnum.Op.Filter do
  alias __MODULE__
  alias ZEnum.Op
  import ZEnum.AST

  defstruct [:id, :n, :f]

  def build_op(id, n, [f]), do: %__MODULE__{id: id, n: n, f: f}

  defimpl Op do
    use Op.DefaultImpl

    def push_ast(op = %Filter{}, ops, params, context, {zstate, value}) do
      quote context: context, generated: true do
        if unquote(op.f).(unquote(value)) do
          unquote(push(ops, params, context, {zstate, value}))
        else
          unquote(next_or_return(ops, params, context, zstate))
        end
      end
    end
  end
end
