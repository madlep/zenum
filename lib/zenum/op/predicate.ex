defmodule ZEnum.Op.Predicate do
  alias __MODULE__
  alias ZEnum.Op
  import ZEnum.AST

  defstruct [:id, :n, :f, :initial]

  def build_op(id, n, [f, initial]), do: %Predicate{id: id, n: n, f: f, initial: initial}

  defimpl Op do
    use Op.DefaultImpl

    def push_ast(_op = %Predicate{f: nil, initial: true}, ops, params, context, {_, value}) do
      quote do
        if unquote(value), do: unquote(next(ops, params, context)), else: false
      end
    end

    def push_ast(_op = %Predicate{f: nil, initial: false}, ops, params, context, {_, value}) do
      quote do
        if unquote(value), do: true, else: unquote(next(ops, params, context))
      end
    end

    def push_ast(_op = %Predicate{f: f, initial: true}, ops, params, context, {_, value})
        when not is_nil(f) do
      quote do
        if unquote(f).(unquote(value)), do: unquote(next(ops, params, context)), else: false
      end
    end

    def push_ast(_op = %Predicate{f: f, initial: false}, ops, params, context, {_, value})
        when not is_nil(f) do
      quote do
        if unquote(f).(unquote(value)), do: true, else: unquote(next(ops, params, context))
      end
    end

    def return_ast(op = %Predicate{}, _ops, _params, _context) do
      quote do
        unquote(op.initial)
      end
    end
  end
end
