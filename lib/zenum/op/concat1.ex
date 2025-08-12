defmodule ZEnum.Op.Concat1 do
  alias __MODULE__
  alias ZEnum.Op
  import ZEnum.AST

  defstruct [:id, :n]

  def build_op(id, []), do: %Concat1{id: id}

  defimpl Op do
    use Op.DefaultImpl

    def state(_op = %Concat1{}) do
      [
        {:concat_buffer, nil}
      ]
    end

    def next_fun_ast(op = %Concat1{}, ops, params, context) do
      buffer = Macro.var(fun_param_name(op.n, :concat_buffer), context)
      value = Macro.var(:value, context)

      quote context: context, generated: true do
        defp unquote(next_fun_name(op))(unquote_splicing(params)) do
          unquote(
            ZEnum.Enumerable.next_ast(
              buffer,
              value,
              buffer,
              call_push_fun_ast(ops, params, context, value),
              next(ops, params, context),
              context
            )
          )
        end
      end
    end

    def next_ast(op = %Concat1{}, _ops, params, context) do
      quote context: context, generated: true do
        unquote(next_fun_name(op))(unquote_splicing(params))
      end
    end

    def push_ast(op = %Concat1{}, ops, params, context, {:cont, value}) do
      buffer = Macro.var(fun_param_name(op.n, :concat_buffer), context)

      quote generated: true, context: context do
        unquote(buffer) = unquote(value)
        unquote(next_ast(op, ops, params, context))
      end
    end
  end
end
