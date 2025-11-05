defmodule ZEnum.Op.Take do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :amount]

  def build_op(id, [amount]) do
    %Take{id: id, amount: amount}
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %Take{}) do
      [
        {:take_i, op.amount},
        {:take_acc, []}
      ]
    end

    def push_ast(op = %Take{}, ops, params, context, {zstate, value}) do
      i = Macro.var(fun_param_name(op.n, :take_i), context)
      acc = Macro.var(fun_param_name(op.n, :take_acc), context)

      quote generated: true, context: context do
        cond do
          unquote(i) > 0 ->
            unquote(i) = unquote(i) - 1
            unquote(push(ops, params, context, {zstate, value}))

          unquote(i) == 0 ->
            unquote(return(ops, params, context))

          unquote(i) < 0 ->
            unquote(acc) = [unquote(value) | unquote(acc)]
            unquote(next_or_return(ops, params, context, zstate))
        end
      end
    end

    def next_ast(op = %Take{}, ops, params, context) do
      i = Macro.var(fun_param_name(op.n, :take_i), context)
      acc = Macro.var(fun_param_name(op.n, :take_acc), context)

      quote generated: true, context: context do
        if unquote(i) >= 0 do
          unquote(next(ops, params, context))
        else
          case unquote(acc) do
            [value | unquote(acc)] ->
              unquote(call_push_fun_ast(ops, params, context, Macro.var(:value, context)))

            [] ->
              unquote(return(ops, params, context))
          end
        end
      end
    end

    def return_ast(op = %Take{}, ops, params, context) do
      i = Macro.var(fun_param_name(op.n, :take_i), context)
      acc = Macro.var(fun_param_name(op.n, :take_acc), context)

      quote generated: true, context: context do
        if unquote(i) >= 0 do
          unquote(return(ops, params, context))
        else
          unquote(acc) = unquote(acc) |> Enum.take(unquote(i) * -1) |> :lists.reverse()
          unquote(next_ast(op, ops, params, context))
        end
      end
    end
  end
end
