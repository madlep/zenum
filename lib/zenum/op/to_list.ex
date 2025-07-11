defmodule Zenum.Op.ToList do
  alias __MODULE__
  alias Zenum.Op
  alias Zenum.Zipper

  import Zenum.AST

  defstruct [:n, :acc]

  def build_op(n, []), do: %ToList{n: n, acc: []}

  defimpl Zenum.Op do
    use Op.DefaultImpl

    def state(op = %Zenum.Op.ToList{}) do
      [{op.n, :to_list_acc, op.acc}]
    end

    def push_ast(op = %ToList{}, ops, id, params, context, value) do
      acc = Macro.var(fun_param_name(op.n, :to_list_acc), context)
      ops2 = Zipper.next!(ops)

      quote do
        unquote(acc) = [unquote(value) | unquote(acc)]
        unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
      end
    end

    def return_ast(op = %ToList{}, _ops, _id, _params, context) do
      to_list_acc = Macro.var(fun_param_name(op.n, :to_list_acc), context)

      quote context: context do
        Enum.reverse(unquote(to_list_acc))
      end
    end
  end
end
