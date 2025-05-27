defmodule Zenum.Op.FromList do
  alias __MODULE__

  import Zenum.AST

  defstruct [:n, :data]

  def build_op(n, [data]), do: %FromList{n: n, data: data}

  defimpl Zenum.Op do
    def state(op = %FromList{}) do
      [{op.n, :from_list, :data, op.data}]
    end

    def next_fun_ast(op = %FromList{}, id, params, context) do
      data = fun_param_name(op.n, :data)

      quote context: context do
        def unquote(next_fun_name(id, op.n))(unquote_splicing(params)) do
          case unquote(Macro.var(data, context)) do
            [value | new_data] ->
              unquote(push_fun_name(id, op.n - 1))(
                unquote_splicing(set_param(params, data, Macro.var(:new_data, context))),
                value
              )

            [] ->
              unquote(return_fun_name(id, op.n))(unquote_splicing(params))
          end
        end
      end
    end

    # no-op - shouldn't be called
    def push_fun_ast(_op = %FromList{}, _id, _params, _context) do
      []
    end

    def return_fun_ast(op = %FromList{}, id, params, context) do
      default_return_fun_ast(op.n, id, params, context)
    end
  end
end
