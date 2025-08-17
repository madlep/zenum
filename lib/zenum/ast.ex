defmodule ZEnum.AST do
  alias ZEnum.Op
  alias ZEnum.Zipper

  @type fun_name() :: atom()
  @type fun_param_name() :: atom()

  @doc """
  Generates function name for pushing values forward

      iex> ZEnum.AST.push_fun_name(%ZEnum.Op.ToList{id: 0, n: 2, acc: []})
      :__z_0_2_push__
  """
  @spec push_fun_name(Op.t()) :: fun_name()
  def push_fun_name(op), do: :"__z_#{Op.zenum_id(op)}_#{Op.op_number(op)}_push__"

  @doc """
  Generates function name for pulling next values

      iex> ZEnum.AST.next_fun_name(%ZEnum.Op.ToList{id: 0, n: 2, acc: []})
      :__z_0_2_next__
  """
  def next_fun_name(op), do: :"__z_#{Op.zenum_id(op)}_#{Op.op_number(op)}_next__"

  @doc """
  Generates function param name used in generated function signatures

      iex> ZEnum.AST.fun_param_name(0, :data)
      :op_0_data
  """
  @spec fun_param_name(ZEnum.id(), Op.param_name()) :: fun_param_name()
  def fun_param_name(n, name), do: :"op_#{n}_#{name}"

  @doc """
  Sets param AST in list of params AST args. Intended to set up params to pass
  to a function call in quoted AST code

      iex> ZEnum.AST.set_param([{:a, [], MyModule}, {:b, [], MyModule}, {:c, [], MyModule}], :b, 123)
      [{:a, [], MyModule}, 123, {:c, [], MyModule}]
  """
  @spec set_param(Op.params(), Op.param_name(), Op.param_value_ast()) :: Op.params()
  def set_param(params_ast, param, new_param_ast) do
    i =
      Enum.find_index(params_ast, fn
        # only replace named vars
        {p, _, _} -> p == param
        # matches etc are ignored and can't be replaced once set
        _ -> false
      end)

    List.replace_at(params_ast, i, new_param_ast)
  end

  @doc """
  Generate inlined form of function if it is safe to inline - ie doesn't close over any vars from it's parent scope
  """
  @spec maybe_inline_function(Macro.t()) ::
          {:mfa_ref, mod :: Macro.t(), fun :: Macro.t(), arity :: integer()}
          | {:local_fa_ref, fun :: Macro.t(), arity :: integer()}
          | {:mf_capture, mod :: Macro.t(), fun :: Macro.t(), args :: list(inlined_arg())}
          | {:local_f_capture, fun :: Macro.t(), args :: list(inlined_arg())}
          | {:anon_f, ast :: Macro.t()}
          | {:not_inlined, ast :: Macro.t()}
  def maybe_inline_function(f)

  # &Mod.fun/arity reference eg `&String.capitalize/1`
  def maybe_inline_function(
        {:&, _, [{:/, _, [{{:., _, [mod = {:__aliases__, _, _}, fun]}, _, []}, arity]}]}
      )
      when is_integer(arity) do
    {:mfa_ref, mod, fun, arity}
  end

  # &fun/arity local reference eg `&local_do_stuff/1`
  def maybe_inline_function({:&, _, [{:/, _, [fun, arity]}]})
      when is_integer(arity) do
    {:local_fa_ref, fun, arity}
  end

  # inlineable mf capture
  # `&String.bag_distance("something", &1)` - ok
  # `&String.bag_distance(some_var, &1)` - not ok, don't have access to `some_var` when inlined
  def maybe_inline_function(
        ast =
          {:&, _,
           [
             {{:., _, [mod = {:__aliases__, _, _}, fun]}, _, args}
           ]}
      )
      when is_list(args) do
    if Enum.all?(args, &inlineable_ast?(&1, %{})) do
      {:mf_capture, mod, fun, Enum.map(args, &inline_arg/1)}
    else
      {:not_inlined, ast}
    end
  end

  # short & &1 anonymous function
  # TODO properly distinguish between short anon fns and local capture. These are identical
  # `&{&1}` AST = `{:&, [], [{:{},  [], [{:&, [], [1]}]}]}`
  # `&foo(&1)` =  `{:&, [], [{:foo, [], [{:&, [], [1]}]}]}`
  def maybe_inline_function(ast = {:&, _, [{:&, _, [1]}]}) do
    {:anon_f, ast}
  end

  # inlineable local f capture
  def maybe_inline_function(ast = {:&, _, [{fun, _, args}]})
      when is_list(args) do
    if Enum.all?(args, &inlineable_ast?(&1, %{})) do
      {:local_f_capture, fun, Enum.map(args, &inline_arg/1)}
    else
      {:not_inlined, ast}
    end
  end

  # anonymous function
  def maybe_inline_function(ast = {:fn, _, [{:->, _, [params, _body]}]}) when is_list(params) do
    if inlineable_ast?(ast, %{}) do
      {:anon_f, ast}
    else
      {:not_inlined, ast}
    end
  end

  # local var function
  def maybe_inline_function(ast = {fun_var, _, context})
      when is_atom(fun_var) and is_atom(context),
      do: {:not_inlined, ast}

  @doc """
  Mark AST as inlined if it is able to be
  """
  @spec maybe_inline(Macro.t()) :: {:inlined, Macro.t()} | {:not_inlined, Macro.t()}
  def maybe_inline(ast) do
    if inlineable_ast?(ast, %{}) do
      {:inlined, ast}
    else
      {:not_inlined, ast}
    end
  end

  @doc """
  Determine if an AST is inlinable - ie does it close over any vars from the parent scope, which won't be available if inlined into a different scope
  """
  @spec inlineable_ast?(ast :: Macro.t(), bindings :: %{Macro.t() => any()}) :: boolean()
  def inlineable_ast?(ast, bindings)

  def inlineable_ast?(ast, _bindings) when is_atom(ast), do: true

  def inlineable_ast?(ast, _bindings) when is_number(ast), do: true

  def inlineable_ast?(ast, bindings) when is_list(ast),
    do: Enum.all?(ast, &inlineable_ast?(&1, bindings))

  def inlineable_ast?(ast, _bindings) when is_binary(ast), do: true

  def inlineable_ast?({ast1, ast2}, bindings),
    do: inlineable_ast?(ast1, bindings) && inlineable_ast?(ast2, bindings)

  # handle ::/2 operator, as this has special rules around what is allowed
  def inlineable_ast?({:"::", meta, [ast1, _bitstring_args]}, bindings) when is_list(meta),
    do: inlineable_ast?(ast1, bindings)

  # handle matches in `->` with in fn / case etc
  def inlineable_ast?({:->, _, [params, body]}, bindings) when is_list(params) do
    bindings_assigned =
      params
      |> extract_pattern_match_vars()
      |> Enum.map(&{&1, true})
      |> Enum.into(bindings)

    inlineable_ast?(body, bindings_assigned)
  end

  # handle blocks/with/for, which may assign var using `=` or `<-`
  # these have different rules about what is legal syntax, but the compiler can
  # deal with that, and we don't care here - just if vars are closed over from
  # outside the scope of this ast
  def inlineable_ast?({expression, _, expressions}, bindings)
      when expression in [:__block__, :for, :with] and is_list(expressions) do
    result =
      expressions
      |> Enum.reduce_while(bindings, fn exp, bindings2 ->
        case exp do
          {op, _, [left, _right]} when op in [:<-, :=] ->
            bindings_assigned =
              [left]
              |> extract_pattern_match_vars()
              |> Enum.map(&{&1, true})
              |> Enum.into(bindings2)

            {:cont, bindings_assigned}

          exp ->
            if inlineable_ast?(exp, bindings2) do
              {:cont, bindings2}
            else
              {:halt, :not_inlined}
            end
        end
      end)

    result != :not_inlined
  end

  # local function captures are ok
  def inlineable_ast?({:&, meta1, [{:/, meta2, [{fun, meta3, context}, arity]}]}, _bindings)
      when is_list(meta1) and is_list(meta2) and is_atom(fun) and is_list(meta3) and
             is_atom(context) and is_integer(arity),
      do: true

  # ast node that is NOT a variable
  def inlineable_ast?({ast1, meta, ast2}, bindings) when is_list(meta) and is_list(ast2),
    do: inlineable_ast?(ast1, bindings) && inlineable_ast?(ast2, bindings)

  # ast node that IS a variable, BUT it's in the bindings for this scope
  def inlineable_ast?(ast, bindings) when is_map_key(bindings, ast), do: true

  def inlineable_ast?(_ast, _bindings), do: false

  defp extract_pattern_match_vars([{:when, _, params}]) when is_list(params) do
    # when is in last spot in args list, drop it as it's not assigning match values
    params = Enum.take(params, length(params) - 1)
    extract_pattern_match_vars(params)
  end

  defp extract_pattern_match_vars(params) when is_list(params),
    do: Enum.flat_map(params, &extract_pattern_match_var/1)

  defp extract_pattern_match_var(ast = {var, meta, context})
       when is_atom(var) and is_list(meta) and is_atom(context),
       do: [ast]

  defp extract_pattern_match_var({ast1, ast2}),
    do: extract_pattern_match_var(ast1) ++ extract_pattern_match_var(ast2)

  defp extract_pattern_match_var(ast) when is_list(ast),
    do: Enum.flat_map(ast, &extract_pattern_match_var/1)

  defp extract_pattern_match_var({_ast1, _meta, ast2}), do: extract_pattern_match_var(ast2)

  defp extract_pattern_match_var(ast) when is_atom(ast), do: []
  # defp extract_pattern_match_var(_ast), do: []

  @type inlined_arg() :: {:capture, n :: integer()} | {:inlined, arg :: Macro.t()}
  def inline_arg({:&, _, [n]}), do: {:capture, n}
  def inline_arg(ast), do: {:inlined, ast}

  @doc """
  Find zenum functions that are called in a quoted AST. Used to figure out
  which generated functions to *keep*.
  """
  @spec used_zenum_funs(Macro.t()) :: [fun_name()]
  def used_zenum_funs(ast) do
    # TODO Just checks if a function is called from *anywhere*, not if that function is ultimately recursively called from the root

    ast
    |> Macro.prewalk(MapSet.new(), fn
      {:defp, _, [_f, [do: {:__block__, _, fbody}]]}, acc ->
        # skip function name and arguments AST and rewrite subsequent AST to be
        # processed, as it's indistinguishable from function calls, and it'll
        # show up as a false-positive function invocation
        {fbody, acc}

      {:defp, _, [_f, [do: fbody]]}, acc ->
        # single line function bodies need to be wrapped, or they are considered "walked" already, and won't be reprocessed below
        {List.wrap(fbody), acc}

      t = {op, _, _}, acc when is_atom(op) ->
        # we found a function call
        if Atom.to_string(op) =~ ~r/^__z_\d+_\d+[_\w]*__$/ do
          # we found a __z_1_2__ style zenum function call
          {t, MapSet.put(acc, op)}
        else
          {t, acc}
        end

      t, acc ->
        {t, acc}
    end)
    |> elem(1)
  end

  @doc """
  Trim zenum functions that are *NOT* in the list of used functions that are
  called. Used to get rid of redundant generated functions in zenum pipelines.
  """
  @spec treeshake(Macro.t(), list(fun_name())) :: Macro.t()
  def treeshake(ast, used_funs) do
    # rewrite generated AST keeping only function defp clauses that are used
    ast
    |> Macro.prewalk(fn
      t = {:defp, _, [{:when, _, [{f, _, _args} | _]}, [do: _]]} ->
        # we found a function definition
        if f in used_funs, do: t, else: :__zenum_unused__

      t = {:defp, _, [{f, _, _args}, [do: _]]} ->
        # we found a function definition
        if f in used_funs, do: t, else: :__zenum_unused__

      t ->
        t
    end)
    |> Macro.prewalk(fn
      {:__block__, meta, t} when is_list(t) ->
        {:__block__, meta, Enum.reject(t, &(&1 == :__zenum_unused__))}

      t when is_list(t) ->
        Enum.reject(t, &(&1 == :__zenum_unused__))

      t ->
        t
    end)
  end

  @doc """
  Convert piped and nested function calls into same AST
  """
  @spec normalize_pipes(Macro.t()) :: Macro.t()
  def normalize_pipes({:|>, _, [piped_ast | [{fn_ast, fn_context, fn_args}]]}) do
    {fn_ast, fn_context, [normalize_pipes(piped_ast) | fn_args]}
  end

  def normalize_pipes(ast) do
    ast
  end

  @doc """
  Display generated AST/functions
  """
  @spec debug(Macro.t(), String.t(), ZEnum.debug_opt(), Macro.Env.t()) :: Macro.t()
  def debug(ast, title, true, _env) do
    IO.puts("== #{title} ==")
    ast |> Macro.to_string() |> IO.puts()

    ast
  end

  def debug(ast, _title, :warn, env) do
    ast |> Macro.to_string() |> IO.warn(env)

    ast
  end

  def debug(ast, title, :ast, _env) do
    IO.puts("== #{title} ==")
    IO.inspect(ast, limit: :infinity)
  end

  def debug(ast, _title, _option, _env), do: ast

  @doc """
  Generate AST that will either process the next value, or return and terminate the zenum chain, depending on whether zstate is `:cont` or `:halt`
  """
  @spec next_or_return(ZEnum.Zipper.t(ZEnum.Op.t()), ZEnum.Op.params(), atom(), ZEnum.Op.zstate()) ::
          Macro.t()
  def next_or_return(ops, params, context, zstate)

  def next_or_return(ops, params, context, :cont), do: next(ops, params, context)

  def next_or_return(ops, params, context, :halt),
    do: Op.return_ast(Zipper.head!(ops), ops, params, context)

  @doc """
  Generate AST that will process the next value
  """
  @spec next(ZEnum.Zipper.t(ZEnum.Op.t()), ZEnum.Op.params(), atom()) :: Macro.t()
  def next(ops, params, context) do
    prev_ops = Zipper.prev!(ops)
    Op.next_ast(Zipper.head!(prev_ops), prev_ops, params, context)
  end

  def call_next_fun_ast(ops, params, context) do
    prev_ops = Zipper.prev!(ops)

    quote generated: true, context: context do
      unquote(next_fun_name(Zipper.head!(prev_ops)))(unquote_splicing(params))
    end
  end

  @doc """
  Generate AST that will push a value from this op along the zenum chain to be processed
  """
  @spec push(ZEnum.Zipper.t(ZEnum.Op.t()), ZEnum.Op.params(), atom(), ZEnum.Op.push_value()) ::
          Macro.t()
  def push(ops, params, context, {zstate, value}) do
    next_ops = Zipper.next!(ops)
    Op.push_ast(Zipper.head!(next_ops), next_ops, params, context, {zstate, value})
  end

  def call_push_fun_ast(ops, params, context, value) do
    next_ops = Zipper.next!(ops)

    quote generated: true, context: context do
      unquote(push_fun_name(Zipper.head!(next_ops)))(
        unquote_splicing(params),
        unquote(value)
      )
    end
  end

  @doc """
  Generate AST that will signal to the zenum chain that values from this op have been exhausted, and to do any finishing up actions, and terminate
  """
  @spec return(ZEnum.Zipper.t(ZEnum.Op.t()), ZEnum.Op.params(), atom()) :: Macro.t()
  def return(ops, params, context) do
    next_ops = ZEnum.Zipper.next!(ops)
    ZEnum.Op.return_ast(ZEnum.Zipper.head!(next_ops), next_ops, params, context)
  end
end
