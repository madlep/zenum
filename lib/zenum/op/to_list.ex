defmodule Zenum.Op.ToList do
  alias __MODULE__

  import Zenum.AST

  defstruct [:n, :acc]

  def build_op(n, []), do: %ToList{n: n, acc: []}

  defimpl Zenum.Op do
    def state(op = %Zenum.Op.ToList{}) do
      [{op.n, :to_list, :acc, op.acc}]
    end

    def next_fun_ast(op = %ToList{}, id, params, context) do
      default_next_fun_ast(op.n, id, params, context)
    end

    def push_fun_ast(op = %ToList{}, id, params, context) do
      acc = fun_param_name(op.n, :acc)

      quote context: context do
        def unquote(push_fun_name(id, op.n))(unquote_splicing(params), v) do
          unquote(next_fun_name(id, op.n + 1))(
            unquote_splicing(
              set_param(
                params,
                acc,
                quote(context: context, do: [v | unquote(Macro.var(acc, context))])
              )
            )
          )
        end
      end
    end

    def return_fun_ast(op = %ToList{}, id, params, context) do
      quote context: context do
        def unquote(return_fun_name(id, op.n))(unquote_splicing(params)) do
          Enum.reverse(unquote(Macro.var(fun_param_name(op.n, :acc), context)))
        end
      end
    end
  end
end
