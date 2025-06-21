defmodule Zenum.Op.MapLiteralFn do
  alias __MODULE__
  alias Zenum.Op
  alias Zenum.Zipper

  import Zenum.AST

  defstruct [:n, :f]

  def build_op(n, [f]), do: %__MODULE__{n: n, f: f}

  defimpl Zenum.Op do
    def state(_op = %MapLiteralFn{}) do
      []
    end

    def next_ast(_op = %MapLiteralFn{}, ops, id, params, context) do
      ops2 = Zipper.next!(ops)
      Op.next_ast(Zipper.head!(ops2), ops2, id, params, context)
    end

    def push_ast(op = %MapLiteralFn{}, ops, id, params, context, value) do
      ops2 = Zipper.prev!(ops)

      quote context: context, generated: true do
        value2 = unquote(op.f).(unquote(value))

        unquote(
          Op.push_ast(Zipper.head!(ops2), ops2, id, params, context, Macro.var(:value2, context))
        )
      end
    end

    def push_fun_ast(op = %MapLiteralFn{}, ops, id, params, context) do
      quote context: context, generated: true do
        defp unquote(push_fun_name(id, op.n))(unquote_splicing(params), value) do
          unquote(push_ast(op, ops, id, params, context, Macro.var(:value, context)))
        end
      end
    end

    def return_ast(_op = %MapLiteralFn{}, ops, id, params, context) do
      ops2 = Zipper.prev!(ops)
      Op.return_ast(Zipper.head!(ops2), ops2, id, params, context)
    end
  end
end
