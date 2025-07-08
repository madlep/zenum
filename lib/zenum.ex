defmodule Zenum do
  alias Zenum.AST
  alias Zenum.Op
  alias Zenum.Zipper

  @type id() :: non_neg_integer()

  defmacro __using__(opts) do
    Keyword.validate!(opts, [:debug])
    debug = Keyword.get(opts, :debug, false)

    quote generated: true do
      require Zenum
      @before_compile Zenum

      Module.register_attribute(__MODULE__, :zenums, accumulate: true)
      Module.register_attribute(__MODULE__, :zenum_used_funs, accumulate: true)

      Module.put_attribute(__MODULE__, :zenum_debug, unquote(debug))
      Module.put_attribute(__MODULE__, :zenum_id, 0)
    end
  end

  defmacro __before_compile__(_env) do
    mod = __CALLER__.module

    ast =
      mod
      |> Module.get_attribute(:zenums)
      |> Enum.flat_map(fn {id, ops} ->
        params_ast = op_states_params_ast(ops, mod)

        Zipper.map_zipper(ops, fn ops_zipper ->
          Op.push_fun_ast(Zipper.head!(ops_zipper), ops_zipper, id, params_ast, mod)
        end)
      end)

    record_used_funs(ast, mod)
    ast = trim_unused_funs(ast, mod)

    AST.debug(ast, "__before_compile__", Module.get_attribute(mod, :zenum_debug))

    ast
  end

  ### public API

  defmacro from_list(_z) do
    quote generated: true do
      raise "must be finished with to_list()"
    end
  end

  defmacro map(_z, _f) do
    quote generated: true do
      raise "must be finished with to_list()"
    end
  end

  defmacro filter(_z, _f) do
    quote generated: true do
      raise "must be finished with to_list()"
    end
  end

  defmacro to_list(z) do
    mod = __CALLER__.module
    id = Module.get_attribute(mod, :zenum_id, 0)

    ops =
      z
      |> AST.normalize_pipes()
      |> build_ops(1)

    ops = [Op.ToList.build_op(0, []) | ops] |> Zipper.new()

    Module.put_attribute(mod, :zenums, {id, ops})
    Module.put_attribute(mod, :zenum_id, id + 1)

    params_ast = op_states_params_ast(ops, mod)

    args_ast =
      ops
      |> op_states()
      |> Enum.map(fn {n, _op_name, param, value} ->
        var_ast = state_param_name(n, param)

        quote generated: true do
          unquote(Macro.var(var_ast, mod)) = unquote(value)
        end
      end)

    ast =
      quote generated: true do
        unquote(args_ast)
        unquote(Op.next_ast(Zipper.head!(ops), ops, id, params_ast, mod))
      end

    record_used_funs(ast, __CALLER__.module)
    AST.debug(ast, "to_list", Module.get_attribute(mod, :zenum_debug))

    ast
  end

  ### parse ops
  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :filter]}, _, [z_args, f]}, n) do
    [Op.Filter.build_op(n, [f]) | build_ops(z_args, n + 1)]
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :map]}, _, [z_args, f]}, n) do
    [Op.MapLiteralFn.build_op(n, [f]) | build_ops(z_args, n + 1)]
  end

  defp build_ops({{:., _, [{:__aliases__, _, [:Zenum]}, :from_list]}, _, args}, n) do
    [Op.FromList.build_op(n, args)]
  end

  defp op_states(ops) do
    Enum.flat_map(ops, &Op.state(&1))
  end

  defp state_param_name(n, param) do
    :"op_#{n}_#{param}"
  end

  defp op_states_params_ast(op, context) do
    op
    |> op_states()
    |> Enum.map(fn {n, _op_name, param, _value} ->
      {state_param_name(n, param), [], context}
    end)
  end

  defp record_used_funs(ast, module) do
    ast
    |> AST.used_zenum_funs()
    |> Enum.each(&Module.put_attribute(module, :zenum_used_funs, &1))
  end

  defp trim_unused_funs(ast, module) do
    used_funs =
      Module.get_attribute(module, :zenum_used_funs)
      |> Enum.uniq()

    ast
    |> AST.remove_unused_zenum_funs(used_funs)
  end
end
