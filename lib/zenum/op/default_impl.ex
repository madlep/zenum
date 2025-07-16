defmodule ZEnum.Op.DefaultImpl do
  defmacro __using__(_opts) do
    quote do
      def state(_op), do: []

      def next_ast(_op, ops, id, params, context) do
        ops2 = ZEnum.Zipper.next!(ops)
        ZEnum.Op.next_ast(ZEnum.Zipper.head!(ops2), ops2, id, params, context)
      end

      def push_fun_ast(op, ops, id, params, context) do
        value = Macro.var(:value, context)

        fun_name = ZEnum.AST.push_fun_name(id, op.n)

        quote context: context, generated: true do
          defp unquote(fun_name)(unquote_splicing(params), unquote(value)) do
            unquote(ZEnum.Op.push_ast(op, ops, id, params, context, {:cont, value}))
          end
        end
      end

      def return_ast(_op, ops, id, params, context) do
        ops2 = ZEnum.Zipper.prev!(ops)
        ZEnum.Op.return_ast(ZEnum.Zipper.head!(ops2), ops2, id, params, context)
      end

      defoverridable state: 1, next_ast: 5, push_fun_ast: 5, return_ast: 5
    end
  end
end
