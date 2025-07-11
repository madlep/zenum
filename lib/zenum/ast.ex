defmodule ZEnum.AST do
  alias ZEnum.Op

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

      iex> ZEnum.AST.push_fun_name(0, 2)
      :__z_0_2__
  """
  @spec push_fun_name(ZEnum.id(), Op.op_number()) :: fun_name()
  def push_fun_name(id, n), do: :"__z_#{id}_#{n}__"

  @doc """
  Generates function param name used in generated function signatures

      iex> ZEnum.AST.fun_param_name(0, :data)
      :op_0_data
  """
  @spec fun_param_name(ZEnum.id(), Op.param_name()) :: fun_param_name()
  def fun_param_name(n, name), do: :"op_#{n}_#{name}"

  def set_param(params_ast, param, new_param_ast) do
    i = Enum.find_index(params_ast, fn {p, _, _} -> p == param end)
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

  @spec inlineable_fun?(Macro.t()) :: boolean()
  def inlineable_fun?(ast) do
    # ||
    inlineable_local_fun_ref?(ast) ||
      inlineable_local_fun_partial?(ast)

    # inlineable_remote_fun_ref?(ast) ||
    # inlineable_remote_fun_partial?(ast) ||
    # inlineable_literal_fn(ast)
  end

  @doc """
  Check if AST is for a local function reference which can be inlined. 
  ASTs representing local function references can always be inlined

      iex> ast = quote(do: &foo/1)
      iex> ZEnum.AST.inlineable_local_fun_ref?(ast)
      true

      iex> ast = quote(do: my_variable)
      iex> ZEnum.AST.inlineable_local_fun_ref?(ast)
      false
  """
  @spec inlineable_local_fun_ref?(Macro.t()) :: boolean()
  def inlineable_local_fun_ref?(ast) do
    match?(
      {:&, _, [{:/, _, [{fun, _, _}, arity]}]}
      when is_atom(fun) and is_integer(arity) and arity >= 0,
      ast
    )
  end

  # local function partial apply eg `&foo(&1, :abc)`
  @doc """
  Check if AST is for a local partial function reference which can be inlined.

      iex> ast = quote(do: &foo(&1, :abc))
      iex> ZEnum.AST.inlineable_local_fun_partial?(ast)
      true

      iex> ast = quote(do: 1 + 2)
      iex> ZEnum.AST.inlineable_local_fun_partial?(ast)
      false

  Local partial function references can't be inlined if they close over variables.

      iex> ast = quote(do: &foo(&1, my_var))
      iex> ZEnum.AST.inlineable_local_fun_partial?(ast)
      false

  """
  @spec inlineable_local_fun_partial?(Macro.t()) :: boolean()
  def inlineable_local_fun_partial?({:&, [], [{fun, [], args}]})
      when is_atom(fun) and is_list(args) do
    # check all arguments are literals or placeholders, and not closure variables
    args
    |> Macro.prewalk(true, fn
      ast, true when is_var_ast(ast) -> {ast, false}
      ast, true -> {ast, true}
      ast, false -> {ast, false}
    end)
    |> elem(1)
  end

  def inlineable_local_fun_partial?(_ast), do: false

  def used_zenum_funs(ast) do
    ast
    |> Macro.prewalk([], fn
      {:defp, _, [_f, [do: fbody]]}, acc ->
        # skip function name and arguments AST and rewrite subsequent AST to be
        # processed, as it's indistinguishable from function calls, and it'll
        # show up as a false-positive function invocation
        {fbody, acc}

      t = {op, _, _}, acc when is_atom(op) ->
        # we found a function call
        if Atom.to_string(op) =~ ~r/^__z_\d+_\d+__$/ do
          # we found a __z_1_2__ style zenum function call
          {t, [op | acc]}
        else
          {t, acc}
        end

      t, acc ->
        {t, acc}
    end)
    |> elem(1)
  end

  def remove_unused_zenum_funs(ast, used_funs) do
    # rewrite generated AST keeping only function defp clauses that are used
    ast
    |> Macro.prewalk(fn
      t = {:defp, _, [{f, _, _args}, [do: _]]} ->
        # we found a function definition
        if f in used_funs do
          t
        else
          # which isn't in the list of called functions, so mark it in the AST to be removed
          :__zenum_unused__
        end

      t ->
        t
    end)
    |> Enum.reject(&(&1 == :__zenum_unused__))
  end

  def normalize_pipes({:|>, _, [piped_ast | [{fn_ast, fn_context, fn_args}]]}) do
    {fn_ast, fn_context, [normalize_pipes(piped_ast) | fn_args]}
  end

  def normalize_pipes(ast) do
    ast
  end

  def debug(ast, title, true, _env) do
    IO.puts(title)
    ast |> Macro.to_string() |> IO.puts()

    ast
  end

  def debug(ast, _title, :warn, env) do
    ast |> Macro.to_string() |> IO.warn(env)

    ast
  end

  def debug(ast, title, :ast, _env) do
    IO.puts(title)
    IO.inspect(ast)
  end

  def debug(ast, _title, _option, _env), do: ast
end
