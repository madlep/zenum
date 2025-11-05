defmodule ZEnum.Op.ZipWith3 do
  alias __MODULE__
  alias ZEnum.Op

  import ZEnum.AST

  defstruct [:id, :n, :enum2, :zip_fun]

  def build_op(id, [enum2, zip_fun]) do
    %ZipWith3{id: id, enum2: enum2, zip_fun: zip_fun}
  end

  defimpl Op do
    use Op.DefaultImpl

    def state(op = %ZipWith3{}) do
      [
        {:zip_with3_enum2, op.enum2},
        {:zip_with3_zip_fun, op.zip_fun}
      ]
    end

    def push_ast(op = %ZipWith3{}, ops, params, context, {zstate, value}) do
      enum2 = Macro.var(fun_param_name(op.n, :zip_with3_enum2), context)
      zip_fun = Macro.var(fun_param_name(op.n, :zip_with3_zip_fun), context)
      value2 = Macro.var(:value2, context)

      apply_fun_ast =
        quote generated: true, context: context do
          value = unquote(zip_fun).(unquote(value), unquote(value2))
          unquote(push(ops, params, context, {zstate, Macro.var(:value, context)}))
        end

      ZEnum.Enumerable.next_ast(
        enum2,
        value2,
        enum2,
        apply_fun_ast,
        return(ops, params, context),
        context
      )
    end
  end
end
