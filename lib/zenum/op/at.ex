defmodule Zenum.Op.At do
  alias __MODULE__
  alias Zenum.Op
  alias Zenum.Zipper

  import Zenum.AST

  defstruct [:n, :index, :default]

  def build_op(n, [index, default]), do: %At{n: n, index: index, default: default}

  defimpl Zenum.Op do
    def state(op = %At{}) do
      [{op.n, :at, :at_i, 0}]
    end

    def next_ast(_op = %At{}, ops, id, params, context) do
      ops2 = Zipper.next!(ops)
      Op.next_ast(Zipper.head!(ops2), ops2, id, params, context)
    end

    def push_ast(op = %At{index: index}, ops, id, params, context, value) when index >= 0 do
      ops2 = Zipper.next!(ops)

      i = fun_param_name(op.n, :at_i)

      quote do
        if unquote(Macro.var(i, context)) == unquote(op.index) do
          unquote(value)
        else
          unquote(Macro.var(i, context)) = unquote(Macro.var(i, context)) + 1
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        end
      end
    end

    def push_fun_ast(op = %At{}, ops, id, params, context) do
      quote context: context, generated: true do
        defp unquote(push_fun_name(id, op.n))(unquote_splicing(params), value) do
          unquote(push_ast(op, ops, id, params, context, Macro.var(:value, context)))
        end
      end
    end

    def return_ast(op = %At{}, _ops, _id, _params, _context) do
      quote do
        unquote(op.default)
      end
    end
  end
end
