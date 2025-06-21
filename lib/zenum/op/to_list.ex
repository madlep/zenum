defmodule Zenum.Op.ToList do
  alias __MODULE__
  alias Zenum.Op
  alias Zenum.Zipper

  import Zenum.AST

  defstruct [:n, :acc]

  def build_op(n, []), do: %ToList{n: n, acc: []}

  defimpl Zenum.Op do
    def state(op = %Zenum.Op.ToList{}) do
      [{op.n, :to_list, :to_list_acc, op.acc}]
    end

    def next_ast(_op = %ToList{}, ops, id, params, context) do
      ops2 = Zipper.next!(ops)
      Op.next_ast(Zipper.head!(ops2), ops2, id, params, context)
    end

    def push_ast(op = %ToList{}, ops, id, params, context, value) do
      acc = fun_param_name(op.n, :to_list_acc)
      ops2 = Zipper.next!(ops)

      quote do
        unquote(Macro.var(acc, context)) = [unquote(value) | unquote(Macro.var(acc, context))]
        unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
      end
    end

    def push_fun_ast(op = %ToList{}, ops, id, params, context) do
      quote context: context, generated: true do
        defp unquote(push_fun_name(id, op.n))(unquote_splicing(params), value) do
          unquote(push_ast(op, ops, id, params, context, Macro.var(:value, context)))
        end
      end
    end

    def return_ast(op = %ToList{}, _ops, _id, _params, context) do
      quote context: context do
        Enum.reverse(unquote(Macro.var(fun_param_name(op.n, :to_list_acc), context)))
      end
    end
  end
end
