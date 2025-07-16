defmodule ZEnum.Op.DefaultImpl do
  defmacro __using__(_opts) do
    quote do
      def zenum_id(op), do: op.id

      def op_number(op), do: op.n

      def state(_op), do: []

      def next_ast(_op, ops, params, context), do: ZEnum.AST.next(ops, params, context)

      def push_fun_ast(op, ops, params, context) do
        value = Macro.var(:value, context)

        fun_name = ZEnum.AST.push_fun_name(op)

        quote context: context, generated: true do
          defp unquote(fun_name)(unquote_splicing(params), unquote(value)) do
            unquote(ZEnum.Op.push_ast(op, ops, params, context, {:cont, value}))
          end
        end
      end

      def return_ast(_op, ops, params, context) do
        ZEnum.AST.return(ops, params, context)
      end

      defoverridable state: 1, next_ast: 4, push_fun_ast: 4, return_ast: 4
    end
  end
end
