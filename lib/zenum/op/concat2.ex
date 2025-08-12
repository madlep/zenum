defmodule ZEnum.Op.Concat2 do
  alias __MODULE__
  alias ZEnum.Op
  import ZEnum.AST

  defstruct [:id, :n, :right]

  def build_op(id, [right]), do: %Concat2{id: id, right: right}

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %Concat2{}) do
      [
        {:concat_left_done, false},
        {:concat_right, op.right}
      ]
    end

    def next_fun_ast(op = %Concat2{}, ops, params, context) do
      left_done = Macro.var(fun_param_name(op.n, :concat_left_done), context)
      right = Macro.var(fun_param_name(op.n, :concat_right), context)
      value = Macro.var(:value, context)

      quote context: context, generated: true do
        defp unquote(next_fun_name(op))(unquote_splicing(params)) do
          if unquote(left_done) do
            unquote(
              ZEnum.Enumerable.next_ast(
                right,
                value,
                right,
                call_push_fun_ast(ops, params, context, value),
                return(ops, params, context),
                context
              )
            )
          else
            unquote(next(ops, params, context))
          end
        end
      end
    end

    def next_ast(op = %Concat2{}, _ops, params, context) do
      quote context: context, generated: true do
        unquote(next_fun_name(op))(unquote_splicing(params))
      end
    end

    def push_ast(_op = %Concat2{}, ops, params, context, {:cont, value}) do
      push(ops, params, context, {:cont, value})
    end

    def return_ast(op = %Concat2{}, _ops, params, context) do
      left_done = Macro.var(fun_param_name(op.n, :concat_left_done), context)

      quote context: context, generated: true do
        unquote(left_done) = true
        unquote(next_fun_name(op))(unquote_splicing(params))
      end
    end
  end
end
