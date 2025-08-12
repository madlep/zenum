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
      Keyword.validate!(opts, [:debug, :treeshake])
    rescue
      e in ArgumentError -> IO.warn(e.message, __CALLER__)
    end

    debug = Keyword.get(opts, :debug)
    treeshake = Keyword.get(opts, :treeshake, true)

    quote generated: true do
      require ZEnum
      @before_compile ZEnum

      Module.register_attribute(__MODULE__, :zenums, accumulate: true)
      Module.register_attribute(__MODULE__, :zenum_used_funs, accumulate: true)

      Module.put_attribute(__MODULE__, :zenum_debug, unquote(debug))
      Module.put_attribute(__MODULE__, :zenum_treeshake, unquote(treeshake))
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
          [
            Op.next_fun_ast(Zipper.head!(ops_zipper), ops_zipper, params_ast, mod),
            Op.push_fun_ast(Zipper.head!(ops_zipper), ops_zipper, params_ast, mod)
          ]
        end)
        |> List.flatten()
      end)

    record_used_funs(ast, mod)

    ast = if Module.get_attribute(mod, :zenum_treeshake, true), do: treeshake(ast, mod), else: ast

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

  defmacro concat(z) do
    build_zenum(z, {:concat1, []}, __CALLER__)
  end

  defmacro concat(z, right) do
    build_zenum(z, {:concat2, [right]}, __CALLER__)
  end

  defmacro count(z, f \\ nil) do
    build_zenum(z, nil, {:count, [f]}, __CALLER__)
  end

  defmacro filter(z, f) do
    build_zenum(z, {:filter, [f]}, __CALLER__)
  end

  defmacro from_enum(enum) do
    build_zenum([], {:from_enum, [enum]}, __CALLER__)
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
    concat1: Op.Concat1,
    concat2: Op.Concat2,
    count: Op.Count,
    filter: Op.Filter,
    map: Op.MapLiteralFn,
    from_list: Op.FromList,
    from_enum: Op.FromEnum,
    to_list: Op.ToList
  }

  defp build_zenum(z, op_and_args, term_op_and_args \\ {:to_list, []}, env)

  defp build_zenum(z, nil, {term_op, term_op_args}, env)
       when is_map_key(@op_mod_lookup, term_op) do
    id = Module.get_attribute(env.module, :zenum_id, 0)

    [
      @op_mod_lookup[term_op].build_op(id, term_op_args)
      | z |> AST.normalize_pipes() |> build_ops(id)
    ]
    |> build_zenum_ast(env)
  end

  defp build_zenum(z, {op, op_args}, {term_op, term_op_args}, env)
       when is_map_key(@op_mod_lookup, op) and is_map_key(@op_mod_lookup, term_op) do
    id = Module.get_attribute(env.module, :zenum_id, 0)

    [
      @op_mod_lookup[term_op].build_op(id, term_op_args),
      @op_mod_lookup[op].build_op(id, op_args)
      | z |> AST.normalize_pipes() |> build_ops(id)
    ]
    |> build_zenum_ast(env)
  end

  defp build_zenum_ast(ops, env) do
    ops_zipper =
      ops
      |> Enum.reverse()
      |> set_op_numbers()
      |> Zipper.new()

    mod = env.module
    id = Module.get_attribute(mod, :zenum_id, 0)
    Module.put_attribute(mod, :zenums, {id, ops_zipper})
    Module.put_attribute(mod, :zenum_id, id + 1)

    args_ast =
      ops_zipper
      |> op_states()
      |> Enum.map(fn {_n, _param, value} ->
        value
      end)

    ast =
      quote generated: true, context: mod do
        unquote(AST.next_fun_name(Zipper.head!(ops_zipper)))(unquote_splicing(args_ast))
      end

    record_used_funs(ast, env.module)
    AST.debug(ast, "to_list", Module.get_attribute(mod, :zenum_debug), env)

    ast
  end

  defp set_op_numbers(ops) do
    ops
    |> Enum.with_index()
    |> Enum.map(fn {op, n} -> Op.set_op_number(op, n) end)
  end

  # zenum function
  defp build_ops({{:., _, [{:__aliases__, _, [:ZEnum]}, op]}, _, args}, id)
       when is_map_key(@op_mod_lookup, op) do
    mod = Map.fetch!(@op_mod_lookup, op)

    case args do
      [arg] ->
        [mod.build_op(id, [arg])]

      [z_args | op_args] ->
        [mod.build_op(id, op_args) | build_ops(z_args, id)]
    end
  end

  # first zenum op, passed variable
  defp build_ops(arg = {var, _meta, ctx}, id) when is_atom(var) and is_atom(ctx) do
    [Op.FromEnum.build_op(id, [arg])]
  end

  # first zenum op, passed list
  defp build_ops(arg, id) when is_list(arg) do
    [Op.FromList.build_op(id, [arg])]
  end

  # first zenum op, passed enumerable continuation
  defp build_ops(arg = {:fn, _, [{:->, _, [[_arg1, _arg2], _body]}]}, id) do
    [Op.FromEnum.build_op(id, [arg])]
  end

  # TODO first zenum op, passed Enumerable

  defp op_states(ops) do
    ops
    |> Enum.with_index()
    |> Enum.flat_map(fn {op, n} ->
      op
      |> Op.state()
      |> Enum.map(fn {param, value} -> {n, param, value} end)
    end)
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

  defp treeshake(ast, module) do
    used_funs =
      Module.get_attribute(module, :zenum_used_funs)
      |> Enum.uniq()

    ast
    |> AST.treeshake(used_funs)
  end
end
