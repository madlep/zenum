defmodule ZEnum.Op.At do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :index, :default, :acc]

  def build_op(id, n, [index, default]) do
    %At{id: id, n: n, index: index, default: default}
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %At{}) do
      [
        {op.n, :at_i, 0},
        {op.n, :at_acc, []}
      ]
    end

    def push_ast(op = %At{}, ops, params, context, {zstate, value}) do
      i = Macro.var(fun_param_name(op.n, :at_i), context)
      acc = Macro.var(fun_param_name(op.n, :at_acc), context)

      quote generated: true, context: context do
        if unquote(op.index) >= 0 do
          if unquote(i) == unquote(op.index) do
            unquote(value)
          else
            unquote(i) = unquote(i) + 1
            unquote(next_or_return(ops, params, context, zstate))
          end
        else
          unquote(acc) = [unquote(value) | unquote(acc)]
          unquote(next_or_return(ops, params, context, zstate))
        end
      end
    end

    def return_ast(op = %At{}, _ops, _params, context) do
      acc = Macro.var(fun_param_name(op.n, :at_acc), context)

      quote generated: true, context: context do
        if unquote(op.index) >= 0 do
          unquote(op.default)
        else
          Enum.at(unquote(acc), unquote(op.index) * -1 - 1, unquote(op.default))
        end
      end
    end
  end
end
