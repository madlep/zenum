defmodule Zenum.Ops.MapLiteralFn do
  import Zenum.AST

  defstruct [:n, :f]

  def build_op(n, [f]), do: %__MODULE__{n: n, f: f}

  defimpl Zenum.Op do
    def state(_op = %Zenum.Ops.MapLiteralFn{}) do
      []
    end

    def next_fn_ast(op = %Zenum.Ops.MapLiteralFn{}, id, params, context) do
      quote context: context do
        def unquote(next_fn(id, op.n))(unquote_splicing(params)) do
          unquote(next_fn(id, op.n + 1))(unquote_splicing(params))
        end
      end
    end

    def push_fn_ast(op = %Zenum.Ops.MapLiteralFn{}, id, params, context) do
      quote context: context do
        def unquote(push_fn(id, op.n))(unquote_splicing(params), value) do
          unquote(push_fn(id, op.n - 1))(unquote_splicing(params), unquote(op.f).(value))
        end
      end
    end

    def return_fn_ast(op = %Zenum.Ops.MapLiteralFn{}, id, params, context) do
      quote context: context do
        def unquote(return_fn(id, op.n))(unquote_splicing(params)) do
          unquote(return_fn(id, op.n - 1))(unquote_splicing(params))
        end
      end
    end
  end
end
