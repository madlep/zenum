defmodule ZEnum.Op.ToList do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:n, :acc]

  def build_op(n, []), do: %ToList{n: n, acc: []}

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %ZEnum.Op.ToList{}) do
      [{op.n, :to_list_acc, op.acc}]
    end

    def push_ast(op = %ToList{}, ops, id, params, context, {zstate, value}) do
      acc = Macro.var(fun_param_name(op.n, :to_list_acc), context)

      quote do
        unquote(acc) = [unquote(value) | unquote(acc)]
        unquote(next_or_return(ops, id, params, context, zstate))
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
