defmodule ZEnum.Op.At do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.Zipper

  import ZEnum.AST

  defstruct [:n, :index, :default, :acc]

  def build_op(n, [index, default]) do
    %At{n: n, index: index, default: default}
  end

  defimpl ZEnum.Op do
    use Op.DefaultImpl

    def state(op = %At{}) do
      [
        {op.n, :at_i, 0},
        {op.n, :at_acc, []}
      ]
    end

    def push_ast(op = %At{}, ops, id, params, context, value) do
      ops2 = Zipper.next!(ops)

      i = Macro.var(fun_param_name(op.n, :at_i), context)
      acc = Macro.var(fun_param_name(op.n, :at_acc), context)

      quote do
        if unquote(op.index) >= 0 do
          if unquote(i) == unquote(op.index) do
            unquote(value)
          else
            unquote(i) = unquote(i) + 1
            unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
          end
        else
          unquote(acc) = [unquote(value) | unquote(acc)]
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        end
      end
    end

    def return_ast(op = %At{}, _ops, _id, _params, context) do
      acc = Macro.var(fun_param_name(op.n, :at_acc), context)

      quote do
        if unquote(op.index) >= 0 do
          unquote(op.default)
        else
          Enum.at(unquote(acc), unquote(op.index) * -1 - 1, unquote(op.default))
        end
      end
    end
  end
end
