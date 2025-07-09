defmodule Zenum.Op.Predicate do
  alias __MODULE__
  alias Zenum.Op
  alias Zenum.Zipper

  import Zenum.AST

  defstruct [:n, :f, :initial]

  def build_op(n, [f, initial]), do: %Predicate{n: n, f: f, initial: initial}

  defimpl Zenum.Op do
    def state(_op = %Predicate{}) do
      []
    end

    def next_ast(_op = %Predicate{}, ops, id, params, context) do
      ops2 = Zipper.next!(ops)
      Op.next_ast(Zipper.head!(ops2), ops2, id, params, context)
    end

    def push_ast(_op = %Predicate{f: nil, initial: true}, ops, id, params, context, value) do
      ops2 = Zipper.next!(ops)

      quote do
        if unquote(value) do
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        else
          false
        end
      end
    end

    def push_ast(_op = %Predicate{f: nil, initial: false}, ops, id, params, context, value) do
      ops2 = Zipper.next!(ops)

      quote do
        if unquote(value) do
          true
        else
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        end
      end
    end

    def push_ast(_op = %Predicate{f: f, initial: true}, ops, id, params, context, value)
        when not is_nil(f) do
      ops2 = Zipper.next!(ops)

      quote do
        if unquote(f).(unquote(value)) do
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        else
          false
        end
      end
    end

    def push_ast(_op = %Predicate{f: f, initial: false}, ops, id, params, context, value)
        when not is_nil(f) do
      ops2 = Zipper.next!(ops)

      quote do
        if unquote(f).(unquote(value)) do
          true
        else
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, id, params, context))
        end
      end
    end

    def push_fun_ast(op = %Predicate{}, ops, id, params, context) do
      quote context: context, generated: true do
        defp unquote(push_fun_name(id, op.n))(unquote_splicing(params), value) do
          unquote(push_ast(op, ops, id, params, context, Macro.var(:value, context)))
        end
      end
    end

    def return_ast(op = %Predicate{}, _ops, _id, _params, _context) do
      quote do
        unquote(op.initial)
      end
    end
  end
end
