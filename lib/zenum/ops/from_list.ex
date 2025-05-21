defmodule Zenum.Ops.FromList do
  import Zenum.AST

  defstruct [:n, :data]

  def build_op(n, [data]), do: %Zenum.Ops.FromList{n: n, data: data}

  defimpl Zenum.Op do
    def state(op = %Zenum.Ops.FromList{}) do
      [{op.n, :from_list, :data, op.data}]
    end

    # no-op - shouldn't be called
    def push_fn_ast(_op = %Zenum.Ops.FromList{}, _id, _params, _context) do
      []
    end

    def return_fn_ast(op = %Zenum.Ops.FromList{}, id, params, context) do
      quote context: context do
        def unquote(return_fn(id, op.n))(unquote_splicing(params)) do
          unquote(return_fn(id, op.n - 1))(unquote_splicing(params))
        end
      end
    end

    def next_fn_ast(op = %Zenum.Ops.FromList{}, id, params, context) do
      data = param(op.n, :data)

      quote context: context do
        def unquote(next_fn(id, op.n))(unquote_splicing(params)) do
          case unquote(Macro.var(data, context)) do
            [value | new_data] ->
              unquote(push_fn(id, op.n - 1))(
                unquote_splicing(set_param(params, data, Macro.var(:new_data, context))),
                value
              )

            [] ->
              unquote(return_fn(id, op.n))(unquote_splicing(params))
          end
        end
      end
    end
  end
end
