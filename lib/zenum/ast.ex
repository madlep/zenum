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
      :__z_0_2_push__
  """
  @spec push_fun_name(Zenum.id(), Op.op_number()) :: fun_name()
  def push_fun_name(id, n), do: :"__z_#{id}_#{n}_push__"

  @doc """
  Generates function name for pulling next values

      iex> Zenum.AST.next_fun_name(0, 2)
      :__z_0_2_next__
  """
  @spec next_fun_name(Zenum.id(), Op.op_number()) :: fun_name()
  def next_fun_name(id, n), do: :"__z_#{id}_#{n}_next__"

  def default_next_fun_ast(n, id, params, context) do
    quote context: context do
      def unquote(next_fun_name(id, n))(unquote_splicing(params)) do
        unquote(next_fun_name(id, n + 1))(unquote_splicing(params))
      end
    end
  end

  @doc """
  Generates function name for returning at end of iteration

      iex> Zenum.AST.return_fun_name(0, 2)
      :__z_0_2_return__
  """
  @spec return_fun_name(Zenum.id(), Op.op_number()) :: fun_name()
  def return_fun_name(id, n), do: :"__z_#{id}_#{n}_return__"

  def default_return_fun_ast(n, id, params, context) do
    quote context: context do
      def unquote(return_fun_name(id, n))(unquote_splicing(params)) do
        unquote(return_fun_name(id, n - 1))(unquote_splicing(params))
      end
    end
  end

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

  # remote function reference eg `&Bar.foo/1`
end
