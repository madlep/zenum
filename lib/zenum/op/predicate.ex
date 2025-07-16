defmodule ZEnum.Op.Predicate do
  alias __MODULE__
  alias ZEnum.Op
  alias ZEnum.Zipper

  defstruct [:id, :n, :f, :initial]

  def build_op(id, n, [f, initial]), do: %Predicate{id: id, n: n, f: f, initial: initial}

  defimpl Op do
    use Op.DefaultImpl

    def push_ast(_op = %Predicate{f: nil, initial: true}, ops, params, context, {_, value}) do
      ops2 = Zipper.next!(ops)

      quote do
        if unquote(value) do
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, params, context))
        else
          false
        end
      end
    end

    def push_ast(_op = %Predicate{f: nil, initial: false}, ops, params, context, {_, value}) do
      ops2 = Zipper.next!(ops)

      quote do
        if unquote(value) do
          true
        else
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, params, context))
        end
      end
    end

    def push_ast(_op = %Predicate{f: f, initial: true}, ops, params, context, {_, value})
        when not is_nil(f) do
      ops2 = Zipper.next!(ops)

      quote do
        if unquote(f).(unquote(value)) do
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, params, context))
        else
          false
        end
      end
    end

    def push_ast(_op = %Predicate{f: f, initial: false}, ops, params, context, {_, value})
        when not is_nil(f) do
      ops2 = Zipper.next!(ops)

      quote do
        if unquote(f).(unquote(value)) do
          true
        else
          unquote(Op.next_ast(Zipper.head!(ops2), ops2, params, context))
        end
      end
    end

    def return_ast(op = %Predicate{}, _ops, _params, _context) do
      quote do
        unquote(op.initial)
      end
    end
  end
end
