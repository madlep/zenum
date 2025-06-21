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

    def next_ast(_op = %Filter{}, ops, id, params, context) do
      ops2 = Zipper.next!(ops)
      Op.next_ast(Zipper.head!(ops2), ops2, id, params, context)
    end

    def push_ast(op = %Filter{}, ops, id, params, context, value) do
      ops_1 = Zipper.prev!(ops)
      ops2 = Zipper.next!(ops)

      quote context: context, generated: true do
        if unquote(op.f).(unquote(value)) do
          unquote(Op.push_ast(Zipper.head!(ops_1), ops_1, id, params, context, value))
        else
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        end
      end
    end

    def push_fun_ast(op = %Filter{}, ops, id, params, context) do
      quote context: context, generated: true do
        defp unquote(push_fun_name(id, op.n))(unquote_splicing(params), value) do
          unquote(push_ast(op, ops, id, params, context, Macro.var(:value, context)))
        end
      end
    end

    def return_ast(_op = %Filter{}, ops, id, params, context) do
      ops2 = Zipper.prev!(ops)
      Op.return_ast(Zipper.head!(ops2), ops2, id, params, context)
    end
  end
end
