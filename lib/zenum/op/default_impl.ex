defmodule Zenum.Op.DefaultImpl do
  defmacro __using__(_opts) do
    quote do
      def state(_op), do: []

      def next_ast(_op, ops, id, params, context) do
        ops2 = Zenum.Zipper.next!(ops)
        Zenum.Op.next_ast(Zenum.Zipper.head!(ops2), ops2, id, params, context)
      end

      def push_fun_ast(op, ops, id, params, context) do
        value = Macro.var(:value, context)

        quote context: context, generated: true do
          defp unquote(push_fun_name(id, op.n))(unquote_splicing(params), unquote(value)) do
            unquote(push_ast(op, ops, id, params, context, value))
          end
        end
      end

      def return_ast(_op, ops, id, params, context) do
        ops2 = Zenum.Zipper.prev!(ops)
        Zenum.Op.return_ast(Zenum.Zipper.head!(ops2), ops2, id, params, context)
      end

      defoverridable state: 1, next_ast: 5, push_fun_ast: 5, return_ast: 5
    end
  end
end
