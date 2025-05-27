defmodule Zenum.Op.Filter do
  alias __MODULE__
  alias Zenum.Op
  alias Zenum.Zipper

  import Zenum.AST

  defstruct [:n, :f]

  def build_op(n, [f]), do: %__MODULE__{n: n, f: f}

  defimpl Zenum.Op do
    def state(_op = %Filter{}) do
      []
    end

    def next_fun_ast(op = %Filter{}, _ops, id, params, context) do
      default_next_fun_ast(op.n, id, params, context)
    end

    def push_fun_ast(op = %Filter{}, _ops, id, params, context) do
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

    def return_ast(_op = %Filter{}, ops, id, params, context) do
      ops2 = Zipper.left!(ops)
      Op.return_ast(Zipper.current!(ops2), ops2, id, params, context)
    end
  end
end
