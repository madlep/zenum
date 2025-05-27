defmodule Zenum.Op.ToList do
  import Zenum.AST

  defstruct [:n, :acc]

  def build_op(n, []), do: %Zenum.Op.ToList{n: n, acc: []}

  defimpl Zenum.Op do
    def state(op = %Zenum.Op.ToList{}) do
      [{op.n, :to_list, :acc, op.acc}]
    end

    def next_fun_ast(op = %Zenum.Op.ToList{}, id, params, context) do
      quote context: context do
        def unquote(next_fun_name(id, op.n))(unquote_splicing(params)) do
          unquote(next_fun_name(id, op.n + 1))(unquote_splicing(params))
        end
      end
    end

    def push_fun_ast(op = %Zenum.Op.ToList{}, id, params, context) do
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

    def return_fun_ast(op = %Zenum.Op.ToList{}, id, params, context) do
      quote context: context do
        def unquote(return_fun_name(id, op.n))(unquote_splicing(params)) do
          Enum.reverse(unquote(Macro.var(fun_param_name(op.n, :acc), context)))
        end
      end
    end
  end
end
