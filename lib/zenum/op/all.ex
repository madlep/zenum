defmodule Zenum.Op.All do
  alias __MODULE__
  alias Zenum.Op
  alias Zenum.Zipper

  import Zenum.AST

  defstruct [:n, :f]

  def build_op(n, [f]), do: %__MODULE__{n: n, f: f}

  defimpl Zenum.Op do
    def state(_op = %All{}) do
      []
    end

    def next_ast(_op = %All{}, ops, id, params, context) do
      ops2 = Zipper.next!(ops)
      Op.next_ast(Zipper.head!(ops2), ops2, id, params, context)
    end

    def push_ast(_op = %All{f: f}, ops, id, params, context, value) do
      ops2 = Zipper.next!(ops)

      if_test_ast =
        if is_nil(f) do
          value
        else
          quote(do: unquote(f).(unquote(value)))
        end

      quote do
        if unquote(if_test_ast) do
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        else
          false
        end
      end
    end

    def push_fun_ast(op = %All{}, ops, id, params, context) do
      quote context: context, generated: true do
        defp unquote(push_fun_name(id, op.n))(unquote_splicing(params), value) do
          unquote(push_ast(op, ops, id, params, context, Macro.var(:value, context)))
        end
      end
    end

    def return_ast(_op = %All{}, _ops, _id, _params, _context) do
      quote do
        true
      end
    end
  end
end
