defmodule ZEnum.AST do
  alias ZEnum.Op
  alias ZEnum.Zipper

  @type fun_name() :: atom()
  @type fun_param_name() :: atom()
  # {var, [], context}
  defguard is_var_ast(ast)
           when is_tuple(ast) and
                  is_atom(elem(ast, 0)) and
                  elem(ast, 1) == [] and
                  is_atom(elem(ast, 2))

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

  # local function
  # {:&, _, [{:/, _, [{f, _, _}, a]}]}
  #
  # remote function
  # {:&, _, [{:/, _, [{{:., _, [{:__aliases__, _, [m]}, f]}, _, _}, a]}]}
  #
  # literal fn
  # {:fn, _, [{:->, _, [ args, body ]}]}
  #
  # @spec inlineable_fun?(Macro.t()) :: boolean()
  # def inlineable_fun?(ast) do
  #   # ||
  #   inlineable_local_fun_ref?(ast) ||
  #     inlineable_local_fun_partial?(ast)
  #
  #   # inlineable_remote_fun_ref?(ast) ||
  #   # inlineable_remote_fun_partial?(ast) ||
  #   # inlineable_literal_fn(ast)
  # end
  #
  # @doc """
  # Check if AST is for a local function reference which can be inlined. 
  # ASTs representing local function references can always be inlined

  #     iex> ast = quote(do: &foo/1)
  #     iex> ZEnum.AST.inlineable_local_fun_ref?(ast)
  #     true

  #     iex> ast = quote(do: my_variable)
  #     iex> ZEnum.AST.inlineable_local_fun_ref?(ast)
  #     false
  # """
  # @spec inlineable_local_fun_ref?(Macro.t()) :: boolean()
  # def inlineable_local_fun_ref?(ast) do
  #   match?(
  #     {:&, _, [{:/, _, [{fun, _, _}, arity]}]}
  #     when is_atom(fun) and is_integer(arity) and arity >= 0,
  #     ast
  #   )
  # end
  #
  # # local function partial apply eg `&foo(&1, :abc)`
  # @doc """
  # Check if AST is for a local partial function reference which can be inlined.

  #     iex> ast = quote(do: &foo(&1, :abc))
  #     iex> ZEnum.AST.inlineable_local_fun_partial?(ast)
  #     true

  #     iex> ast = quote(do: 1 + 2)
  #     iex> ZEnum.AST.inlineable_local_fun_partial?(ast)
  #     false

  # Local partial function references can't be inlined if they close over variables.

  #     iex> ast = quote(do: &foo(&1, my_var))
  #     iex> ZEnum.AST.inlineable_local_fun_partial?(ast)
  #     false

  # """
  # @spec inlineable_local_fun_partial?(Macro.t()) :: boolean()
  # def inlineable_local_fun_partial?({:&, [], [{fun, [], args}]})
  #     when is_atom(fun) and is_list(args) do
  #   # check all arguments are literals or placeholders, and not closure variables
  #   args
  #   |> Macro.prewalk(true, fn
  #     ast, true when is_var_ast(ast) -> {ast, false}
  #     ast, true -> {ast, true}
  #     ast, false -> {ast, false}
  #   end)
  #   |> elem(1)
  # end

  # def inlineable_local_fun_partial?(_ast), do: false

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
    IO.inspect(ast)
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
