defmodule Zenum.AST do
  alias Zenum.Op

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

      iex> Zenum.AST.push_fun_name(0, 2)
      :__z_0_2__
  """
  @spec push_fun_name(Zenum.id(), Op.op_number()) :: fun_name()
  def push_fun_name(id, n), do: :"__z_#{id}_#{n}__"

  @doc """
  Generates function param name used in generated function signatures

      iex> Zenum.AST.fun_param_name(0, :data)
      :op_0_data
  """
  @spec fun_param_name(Zenum.id(), Op.param_name()) :: fun_param_name()
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
      iex> Zenum.AST.inlineable_local_fun_ref?(ast)
      true

      iex> ast = quote(do: my_variable)
      iex> Zenum.AST.inlineable_local_fun_ref?(ast)
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
      iex> Zenum.AST.inlineable_local_fun_partial?(ast)
      true

      iex> ast = quote(do: 1 + 2)
      iex> Zenum.AST.inlineable_local_fun_partial?(ast)
      false

  Local partial function references can't be inlined if they close over variables.

      iex> ast = quote(do: &foo(&1, my_var))
      iex> Zenum.AST.inlineable_local_fun_partial?(ast)
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
        {fbody, acc}

      t = {op, _, _}, acc when is_atom(op) ->
        if Atom.to_string(op) =~ ~r/^__z_\d+_\d+__$/ do
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
    ast
    |> Macro.prewalk(fn
      t = {:defp, _, [{f, _, _args}, [do: _]]} ->
        if f in used_funs do
          t
        else
          []
        end

      t ->
        t
    end)
  end

  # remote function reference eg `&Bar.foo/1`
end
