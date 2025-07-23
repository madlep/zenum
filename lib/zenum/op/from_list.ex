defmodule ZEnum.Op.FromList do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :list]

  def build_op(id, n, [list]), do: %FromList{id: id, n: n, list: list}

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %FromList{}) do
      [{op.n, :from_list_list, op.list}]
    end

    def next_fun_ast(op = %FromList{}, ops, params, context) do
      from_list_list = Macro.var(fun_param_name(op.n, :from_list_list), context)
      next_fun_name = next_fun_name(op)

      quote context: context, generated: true do
        defp unquote(next_fun_name)(unquote_splicing(params)) do
          case unquote(from_list_list) do
            [value | unquote(from_list_list)] ->
              unquote(push(ops, params, context, {:cont, Macro.var(:value, context)}))

            [] ->
              unquote(return(ops, params, context))
          end
        end
      end
    end

    def next_ast(op = %FromList{}, _ops, params, context) do
      quote context: context, generated: true do
        unquote(next_fun_name(op))(unquote_splicing(params))
      end
    end

    # no-op - shouldn't be called
    def push_ast(_op = %FromList{}, _ops, _params, _context, _v), do: []

    def push_fun_ast(_op = %FromList{}, _ops, _params, _context), do: []
  end
end
