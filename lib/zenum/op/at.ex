defmodule Zenum.Op.At do
  alias __MODULE__
  alias Zenum.Op
  alias Zenum.Zipper

  import Zenum.AST

  defstruct [:n, :index, :default, :acc]

  def build_op(n, [index, default]) do
    %At{n: n, index: index, default: default}
  end

  defimpl Zenum.Op do
    use Op.DefaultImpl

    def state(op = %At{}) do
      [
        {op.n, :at, :at_i, 0},
        {op.n, :at, :at_acc, []}
      ]
    end

    def push_ast(op = %At{}, ops, id, params, context, value) do
      ops2 = Zipper.next!(ops)

      i = fun_param_name(op.n, :at_i)
      acc = fun_param_name(op.n, :at_acc)

      quote do
        if unquote(op.index) >= 0 do
          if unquote(Macro.var(i, context)) == unquote(op.index) do
            unquote(value)
          else
            unquote(Macro.var(i, context)) = unquote(Macro.var(i, context)) + 1
            unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
          end
        else
          unquote(Macro.var(acc, context)) = [unquote(value) | unquote(Macro.var(acc, context))]
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        end
      end
    end

    def return_ast(op = %At{}, _ops, _id, _params, context) do
      acc = fun_param_name(op.n, :at_acc)

      quote do
        if unquote(op.index) >= 0 do
          unquote(op.default)
        else
          Enum.at(
            unquote(Macro.var(acc, context)),
            unquote(op.index) * -1 - 1,
            unquote(op.default)
          )
        end
      end
    end
  end
end
