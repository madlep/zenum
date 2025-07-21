defmodule ZEnum do
  alias ZEnum.AST
  alias ZEnum.Op
  alias ZEnum.Zipper

  @type id() :: non_neg_integer()

  @type debug_opt() :: boolean() | :ast | :warn
  @type opts() :: [{:debug, debug_opt()}]

  @spec __using__(opts()) :: Macro.t()
  defmacro __using__(opts) do
    try do
      Keyword.validate!(opts, [:debug])
    rescue
      e in ArgumentError -> IO.warn(e.message, __CALLER__)
    end

    debug = Keyword.get(opts, :debug)

    quote generated: true do
      require ZEnum
      @before_compile ZEnum

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
      |> Enum.flat_map(fn {_id, ops} ->
        params_ast = op_states_params_ast(ops, mod)

        Zipper.map_zipper(ops, fn ops_zipper ->
          Op.next_fun_ast(Zipper.head!(ops_zipper), ops_zipper, params_ast, mod)
        end)
      end)

    record_used_funs(ast, mod)
    ast = trim_unused_funs(ast, mod)

    AST.debug(ast, "__before_compile__", Module.get_attribute(mod, :zenum_debug), __CALLER__)

    ast
  end

  ### public API
  defmacro all?(z, f \\ nil) do
    build_zenum(z, nil, {:all?, [f, true]}, __CALLER__)
  end

  defmacro any?(z, f \\ nil) do
    build_zenum(z, nil, {:any?, [f, false]}, __CALLER__)
  end

  defmacro at(z, index, default \\ nil) do
    build_zenum(z, nil, {:at, [index, default]}, __CALLER__)
  end

  defmacro chunk_by(z, f) do
    build_zenum(z, {:chunk_by, [f]}, __CALLER__)
  end

  defmacro chunk_every(z, count) do
    build_zenum(z, {:chunk_every, [count, count, []]}, __CALLER__)
  end

  defmacro chunk_every(z, count, step, leftover \\ []) do
    build_zenum(z, {:chunk_every, [count, step, leftover]}, __CALLER__)
  end

  defmacro chunk_while(z, acc, chunk_fun, after_fun) do
    build_zenum(z, {:chunk_while, [acc, chunk_fun, after_fun]}, __CALLER__)
  end

  defmacro filter(z, f) do
    build_zenum(z, {:filter, [f]}, __CALLER__)
  end

  defmacro from_list(list) do
    build_zenum([], {:from_list, [list]}, __CALLER__)
  end

  defmacro map(z, f) do
    build_zenum(z, {:map, [f]}, __CALLER__)
  end

  defmacro to_list(z) do
    build_zenum(z, nil, {:to_list, []}, __CALLER__)
  end

  ### parse ops
  @op_mod_lookup %{
    all?: Op.Predicate,
    any?: Op.Predicate,
    at: Op.At,
    chunk_by: Op.ChunkBy,
    chunk_every: Op.ChunkEvery,
    chunk_while: Op.ChunkWhile,
    filter: Op.Filter,
    map: Op.MapLiteralFn,
    from_list: Op.FromList,
    to_list: Op.ToList
  }

  defp build_zenum(z, op_op_args, term_op_term_op_args \\ {:to_list, []}, env)

  defp build_zenum(z, nil, {term_op, term_op_args}, env)
       when is_map_key(@op_mod_lookup, term_op) do
    id = Module.get_attribute(env.module, :zenum_id, 0)

    ops =
      z
      |> AST.normalize_pipes()
      |> build_ops(id, 1)

    term_op_mod = @op_mod_lookup[term_op]

    [term_op_mod.build_op(id, 0, term_op_args) | ops]
    |> Zipper.new()
    |> build_zenum(env)
  end

  defp build_zenum(z, {op, op_args}, {term_op, term_op_args}, env)
       when is_map_key(@op_mod_lookup, op) and is_map_key(@op_mod_lookup, term_op) do
    id = Module.get_attribute(env.module, :zenum_id, 0)

    ops =
      z
      |> AST.normalize_pipes()
      |> build_ops(id, 2)

    op_mod = @op_mod_lookup[op]
    term_op_mod = @op_mod_lookup[term_op]

    [term_op_mod.build_op(id, 0, term_op_args), op_mod.build_op(id, 1, op_args) | ops]
    |> Zipper.new()
    |> build_zenum(env)
  end

  defp build_zenum(ops, env) do
    mod = env.module
    id = Module.get_attribute(mod, :zenum_id, 0)
    Module.put_attribute(mod, :zenums, {id, ops})
    Module.put_attribute(mod, :zenum_id, id + 1)

    args_ast =
      ops
      |> op_states()
      |> Enum.map(fn {_n, _param, value} ->
        value
      end)

    ast =
      quote generated: true do
        unquote(AST.next_fun_name(Zipper.head!(ops)))(unquote_splicing(args_ast))
      end

    record_used_funs(ast, env.module)
    AST.debug(ast, "to_list", Module.get_attribute(mod, :zenum_debug), env)

    ast
  end

  # zenum function
  defp build_ops({{:., _, [{:__aliases__, _, [:ZEnum]}, op]}, _, args}, id, n)
       when is_map_key(@op_mod_lookup, op) do
    mod = Map.fetch!(@op_mod_lookup, op)

    case args do
      [arg] ->
        [mod.build_op(id, n, [arg])]

      [z_args | op_args] ->
        [mod.build_op(id, n, op_args) | build_ops(z_args, id, n + 1)]
    end
  end

  # first zenum op, passed variable
  defp build_ops(arg = {var, _meta, ctx}, id, n) when is_atom(var) and is_atom(ctx) do
    [Op.FromList.build_op(id, n, [arg])]
  end

  # first zenum op, passed list
  defp build_ops(arg, id, n) when is_list(arg) do
    [Op.FromList.build_op(id, n, [arg])]
  end

  # TODO first zenum op, passed Enumerable

  defp op_states(ops) do
    Enum.flat_map(ops, &Op.state(&1))
  end

  defp state_param_name(n, param) do
    :"op_#{n}_#{param}"
  end

  defp op_states_params_ast(op, context) do
    op
    |> op_states()
    |> Enum.map(fn {n, param, _value} ->
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
