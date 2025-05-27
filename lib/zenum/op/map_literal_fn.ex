defmodule Zenum.Op.MapLiteralFn do
  alias __MODULE__

  import Zenum.AST

  defstruct [:n, :f]

  def build_op(n, [f]), do: %__MODULE__{n: n, f: f}

  defimpl Zenum.Op do
    def state(_op = %MapLiteralFn{}) do
      []
    end

    def next_fun_ast(op = %MapLiteralFn{}, id, params, context) do
      default_next_fun_ast(op.n, id, params, context)
    end

    def push_fun_ast(op = %MapLiteralFn{}, id, params, context) do
      quote context: context do
        def unquote(push_fun_name(id, op.n))(unquote_splicing(params), value) do
          unquote(push_fun_name(id, op.n - 1))(unquote_splicing(params), unquote(op.f).(value))
        end
      end
    end

    def return_fun_ast(op = %MapLiteralFn{}, id, params, context) do
      default_return_fun_ast(op.n, id, params, context)
    end
  end
end
