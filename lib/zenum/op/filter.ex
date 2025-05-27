defmodule Zenum.Op.Filter do
  alias __MODULE__

  import Zenum.AST

  defstruct [:n, :f]

  def build_op(n, [f]), do: %__MODULE__{n: n, f: f}

  defimpl Zenum.Op do
    def state(_op = %Filter{}) do
      []
    end

    def next_fun_ast(op = %Filter{}, id, params, context) do
      quote context: context do
        def unquote(next_fun_name(id, op.n))(unquote_splicing(params)) do
          unquote(next_fun_name(id, op.n + 1))(unquote_splicing(params))
        end
      end
    end

    def push_fun_ast(op = %Filter{}, id, params, context) do
      quote context: context do
        def unquote(push_fun_name(id, op.n))(unquote_splicing(params), v) do
          if unquote(op.f).(v) do
            unquote(push_fun_name(id, op.n - 1))(unquote_splicing(params), v)
          else
            unquote(next_fun_name(id, op.n + 1))(unquote_splicing(params))
          end
        end
      end
    end

    def return_fun_ast(op = %Filter{}, id, params, context) do
      quote context: context do
        def unquote(return_fun_name(id, op.n))(unquote_splicing(params)) do
          unquote(return_fun_name(id, op.n - 1))(unquote_splicing(params))
        end
      end
    end
  end
end
