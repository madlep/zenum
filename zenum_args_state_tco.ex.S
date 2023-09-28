{module, 'Elixir.Bench.Transforms.ZenumArgsStateTCO'}.  %% version = 0

{exports, [{'MACRO-z3_filter',5},
           {'__info__',1},
           {module_info,0},
           {module_info,1},
           {run,1}]}.

{attributes, []}.

{labels, 63}.


{function, '__info__', 1, 2}.
  {label,1}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,'__info__'},
               1}.
  {label,2}.
    {select_val,{x,0},
                {f,10},
                {list,[{atom,attributes},
                       {f,9},
                       {atom,compile},
                       {f,9},
                       {atom,deprecated},
                       {f,8},
                       {atom,exports_md5},
                       {f,7},
                       {atom,functions},
                       {f,6},
                       {atom,macros},
                       {f,5},
                       {atom,md5},
                       {f,9},
                       {atom,module},
                       {f,4},
                       {atom,struct},
                       {f,3}]}}.
  {label,3}.
    {move,{atom,nil},{x,0}}.
    return.
  {label,4}.
    {move,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},{x,0}}.
    return.
  {label,5}.
    {move,{literal,[{z3_filter,4}]},{x,0}}.
    return.
  {label,6}.
    {move,{literal,[{run,1}]},{x,0}}.
    return.
  {label,7}.
    {move,{literal,<<76,185,57,63,235,44,174,103,150,75,35,207,85,16,147,89>>},
          {x,0}}.
    return.
  {label,8}.
    {move,nil,{x,0}}.
    return.
  {label,9}.
    {move,{x,0},{x,1}}.
    {move,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},{x,0}}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.
  {label,10}.
    {call_only,1,{f,62}}. % '-inlined-__info__/1-'/1


{function, run, 1, 12}.
  {label,11}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",77}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,run},
               1}.
  {label,12}.
    {test,is_nonempty_list,{f,13},[{x,0}]}.
    {get_list,{x,0},{x,1},{x,3}}.
    {move,{integer,20},{x,2}}.
    {move,nil,{x,0}}.
    {call_only,4,{f,15}}. % z1_filter_push/4
  {label,13}.
    {move,nil,{x,0}}.
    {call_ext_only,1,{extfunc,lists,reverse,1}}.


{function, z1_filter_push, 4, 15}.
  {label,14}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",20}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,z1_filter_push},
               4}.
  {label,15}.
    {'%',{var_info,{x,0},[{type,{t_list,{t_tuple,2,true,#{}},nil}}]}}.
    {'%',{var_info,{x,2},[{type,{t_integer,any}}]}}.
    {allocate,4,4}.
    {move,{x,3},{y,0}}.
    {move,{x,2},{y,1}}.
    {move,{x,1},{y,2}}.
    {move,{x,0},{y,3}}.
    {test,is_map,{f,16},[{x,1}]}.
    {get_map_elements,{f,16},
                      {tr,{x,1},{t_map,any,any}},
                      {list,[{atom,reference},{x,0}]}}.
    {jump,{f,18}}.
  {label,16}.
    {test,is_atom,{f,21},[{x,1}]}.
    {select_val,{x,1},
                {f,17},
                {list,[{atom,false},
                       {f,21},
                       {atom,nil},
                       {f,21},
                       {atom,true},
                       {f,21}]}}.
  {label,17}.
    {move,{x,1},{x,0}}.
    {move,{atom,reference},{x,1}}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",21}]}.
    {apply,0}.
  {label,18}.
    {test,is_eq_exact,{f,19},[{x,0},{atom,'REF3'}]}.
    {move,{y,1},{x,2}}.
    {move,nil,{x,3}}.
    {move,{y,0},{x,4}}.
    {move,{y,2},{x,1}}.
    {move,{y,3},{x,0}}.
    {call_last,5,{f,23},4}. % z2_flat_map_push/5
  {label,19}.
    {test,is_nonempty_list,{f,20},[{y,0}]}.
    {get_list,{y,0},{x,1},{x,3}}.
    {move,{y,1},{x,2}}.
    {move,{y,3},{x,0}}.
    {call_last,4,{f,15},4}. % z1_filter_push/4
  {label,20}.
    {move,{y,3},{x,0}}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",24}]}.
    {call_ext_last,1,{extfunc,lists,reverse,1},4}.
  {label,21}.
    {test_heap,4,0}.
    {put_tuple2,{x,0},{list,[{atom,badkey},{atom,reference},{y,2}]}}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",21}]}.
    {call_ext_last,1,{extfunc,erlang,error,1},4}.


{function, z2_flat_map_push, 5, 23}.
  {label,22}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",40}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,z2_flat_map_push},
               5}.
  {label,23}.
    {'%',{var_info,{x,0},[{type,{t_list,{t_tuple,2,true,#{}},nil}}]}}.
    {'%',{var_info,{x,1},
                   [{type,{t_union,{t_atom,any},
                                   none,none,none,
                                   {t_map,any,any}}}]}}.
    {'%',{var_info,{x,2},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,3},[{type,nil}]}}.
    {allocate,3,5}.
    {move,{x,4},{y,0}}.
    {move,{x,2},{y,1}}.
    {move,{x,0},{y,2}}.
    {test,is_map,
          {f,24},
          [{tr,{x,1},{t_union,{t_atom,any},none,none,none,{t_map,any,any}}}]}.
    {get_map_elements,{f,24},
                      {tr,{x,1},{t_map,any,any}},
                      {list,[{atom,events},{x,0}]}}.
    {jump,{f,26}}.
  {label,24}.
    {test,is_atom,
          {f,29},
          [{tr,{x,1},{t_union,{t_atom,any},none,none,none,{t_map,any,any}}}]}.
    {select_val,{x,1},
                {f,25},
                {list,[{atom,false},
                       {f,29},
                       {atom,nil},
                       {f,29},
                       {atom,true},
                       {f,29}]}}.
  {label,25}.
    {move,{x,1},{x,0}}.
    {move,{atom,events},{x,1}}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",41}]}.
    {apply,0}.
  {label,26}.
    {test,is_nonempty_list,{f,27},[{x,0}]}.
    {get_list,{x,0},{x,1},{x,3}}.
    {move,{y,0},{x,4}}.
    {move,{y,1},{x,2}}.
    {move,{y,2},{x,0}}.
    {call_last,5,{f,33},3}. % z3_filter_push/5
  {label,27}.
    {test,is_nonempty_list,{f,28},[{y,0}]}.
    {get_list,{y,0},{x,1},{x,3}}.
    {move,{y,1},{x,2}}.
    {move,{y,2},{x,0}}.
    {call_last,4,{f,15},3}. % z1_filter_push/4
  {label,28}.
    {move,{y,2},{x,0}}.
    {call_ext_last,1,{extfunc,lists,reverse,1},3}.
  {label,29}.
    {test_heap,4,2}.
    {put_tuple2,{x,0},{list,[{atom,badkey},{atom,events},{x,1}]}}.
    {call_ext_last,1,{extfunc,erlang,error,1},3}.


{function, 'MACRO-z3_filter', 5, 31}.
  {label,30}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",43}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,'MACRO-z3_filter'},
               5}.
  {label,31}.
    {test_heap,12,5}.
    {put_list,{x,4},nil,{x,0}}.
    {put_list,{x,3},{x,0},{x,0}}.
    {put_list,{x,2},{x,0},{x,0}}.
    {put_list,{x,1},{x,0},{x,0}}.
    {put_tuple2,{x,0},{list,[{atom,z2_flat_map},nil,{x,0}]}}.
    return.


{function, z3_filter_push, 5, 33}.
  {label,32}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",49}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,z3_filter_push},
               5}.
  {label,33}.
    {'%',{var_info,{x,0},[{type,{t_list,{t_tuple,2,true,#{}},nil}}]}}.
    {'%',{var_info,{x,2},[{type,{t_integer,any}}]}}.
    {allocate,5,5}.
    {move,{x,4},{y,0}}.
    {move,{x,3},{y,1}}.
    {move,{x,2},{y,2}}.
    {move,{x,1},{y,3}}.
    {move,{x,0},{y,4}}.
    {test,is_map,{f,34},[{x,1}]}.
    {get_map_elements,{f,34},
                      {tr,{x,1},{t_map,any,any}},
                      {list,[{atom,'included?'},{x,0}]}}.
    {jump,{f,36}}.
  {label,34}.
    {test,is_atom,{f,41},[{x,1}]}.
    {select_val,{x,1},
                {f,35},
                {list,[{atom,false},
                       {f,41},
                       {atom,nil},
                       {f,41},
                       {atom,true},
                       {f,41}]}}.
  {label,35}.
    {move,{x,1},{x,0}}.
    {move,{atom,'included?'},{x,1}}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",50}]}.
    {apply,0}.
  {label,36}.
    {select_val,{x,0},{f,40},{list,[{atom,false},{f,37},{atom,nil},{f,37}]}}.
  {label,37}.
    {test,is_nonempty_list,{f,38},[{y,1}]}.
    {get_list,{y,1},{x,1},{x,3}}.
    {move,{y,0},{x,4}}.
    {move,{y,2},{x,2}}.
    {move,{y,4},{x,0}}.
    {call_last,5,{f,33},5}. % z3_filter_push/5
  {label,38}.
    {test,is_nonempty_list,{f,39},[{y,0}]}.
    {get_list,{y,0},{x,1},{x,3}}.
    {move,{y,2},{x,2}}.
    {move,{y,4},{x,0}}.
    {call_last,4,{f,15},5}. % z1_filter_push/4
  {label,39}.
    {move,{y,4},{x,0}}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",53}]}.
    {call_ext_last,1,{extfunc,lists,reverse,1},5}.
  {label,40}.
    {move,{y,0},{x,4}}.
    {move,{y,1},{x,3}}.
    {move,{y,2},{x,2}}.
    {move,{y,3},{x,1}}.
    {move,{y,4},{x,0}}.
    {call_last,5,{f,43},5}. % z4_map_push/5
  {label,41}.
    {test_heap,4,0}.
    {put_tuple2,{x,0},{list,[{atom,badkey},{atom,'included?'},{y,3}]}}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",50}]}.
    {call_ext_last,1,{extfunc,erlang,error,1},5}.


{function, z4_map_push, 5, 43}.
  {label,42}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",63}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,z4_map_push},
               5}.
  {label,43}.
    {'%',{var_info,{x,0},[{type,{t_list,{t_tuple,2,true,#{}},nil}}]}}.
    {'%',{var_info,{x,1},
                   [{type,{t_union,{t_atom,any},
                                   none,none,none,
                                   {t_map,any,any}}}]}}.
    {'%',{var_info,{x,2},[{type,{t_integer,any}}]}}.
    {allocate,6,5}.
    {init_yregs,{list,[{y,0}]}}.
    {move,{x,4},{y,1}}.
    {move,{x,3},{y,2}}.
    {move,{x,2},{y,3}}.
    {move,{x,1},{y,4}}.
    {move,{x,0},{y,5}}.
    {test,is_map,
          {f,44},
          [{tr,{x,1},{t_union,{t_atom,any},none,none,none,{t_map,any,any}}}]}.
    {get_map_elements,{f,44},
                      {tr,{x,1},{t_map,any,any}},
                      {list,[{atom,event_id},{x,0}]}}.
    {move,{x,0},{y,0}}.
    {jump,{f,46}}.
  {label,44}.
    {test,is_atom,
          {f,51},
          [{tr,{x,1},{t_union,{t_atom,any},none,none,none,{t_map,any,any}}}]}.
    {select_val,{x,1},
                {f,45},
                {list,[{atom,false},
                       {f,51},
                       {atom,nil},
                       {f,51},
                       {atom,true},
                       {f,51}]}}.
  {label,45}.
    {move,{x,1},{x,0}}.
    {move,{atom,event_id},{x,1}}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",64}]}.
    {apply,0}.
    {move,{x,0},{y,0}}.
  {label,46}.
    {test,is_map,
          {f,47},
          [{tr,{y,4},{t_union,{t_atom,any},none,none,none,{t_map,any,any}}}]}.
    {get_map_elements,{f,47},
                      {tr,{y,4},{t_map,any,any}},
                      {list,[{atom,parent_id},{x,0}]}}.
    {jump,{f,49}}.
  {label,47}.
    {test,is_atom,
          {f,50},
          [{tr,{y,4},{t_union,{t_atom,any},none,none,none,{t_map,any,any}}}]}.
    {select_val,{y,4},
                {f,48},
                {list,[{atom,false},
                       {f,50},
                       {atom,nil},
                       {f,50},
                       {atom,true},
                       {f,50}]}}.
  {label,48}.
    {move,{atom,parent_id},{x,1}}.
    {move,{y,4},{x,0}}.
    {init_yregs,{list,[{y,4}]}}.
    {apply,0}.
  {label,49}.
    {test_heap,3,1}.
    {put_tuple2,{x,1},{list,[{y,0},{x,0}]}}.
    {move,{y,1},{x,4}}.
    {move,{y,2},{x,3}}.
    {move,{y,3},{x,2}}.
    {move,{y,5},{x,0}}.
    {call_last,5,{f,53},6}. % z5_take_push/5
  {label,50}.
    {test_heap,4,0}.
    {put_tuple2,{x,0},{list,[{atom,badkey},{atom,parent_id},{y,4}]}}.
    {call_ext_last,1,{extfunc,erlang,error,1},6}.
  {label,51}.
    {test_heap,4,0}.
    {put_tuple2,{x,0},{list,[{atom,badkey},{atom,event_id},{y,4}]}}.
    {call_ext_last,1,{extfunc,erlang,error,1},6}.


{function, z5_take_push, 5, 53}.
  {label,52}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",72}]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,z5_take_push},
               5}.
  {label,53}.
    {'%',{var_info,{x,0},[{type,{t_list,{t_tuple,2,true,#{}},nil}}]}}.
    {'%',{var_info,{x,1},[{type,{t_tuple,2,true,#{}}}]}}.
    {'%',{var_info,{x,2},[{type,{t_integer,any}}]}}.
    {test,is_eq_exact,{f,54},[{tr,{x,2},{t_integer,any}},{integer,0}]}.
    {call_ext_only,1,{extfunc,lists,reverse,1}}.
  {label,54}.
    {test,is_nonempty_list,{f,55},[{x,3}]}.
    {get_list,{x,3},{x,5},{x,3}}.
    {line,[{location,"lib/bench/transforms/zenum_args_state_tco.ex",75}]}.
    {gc_bif,'-',{f,0},6,[{tr,{x,2},{t_integer,any}},{integer,1}],{x,2}}.
    {test_heap,2,6}.
    {put_list,{x,1},{x,0},{x,0}}.
    {move,{x,5},{x,1}}.
    {call_only,5,{f,33}}. % z3_filter_push/5
  {label,55}.
    {test,is_nonempty_list,{f,56},[{x,4}]}.
    {get_list,{x,4},{x,3},{x,4}}.
    {gc_bif,'-',{f,0},5,[{tr,{x,2},{t_integer,any}},{integer,1}],{x,2}}.
    {test_heap,2,5}.
    {put_list,{x,1},{x,0},{x,0}}.
    {move,{x,3},{x,1}}.
    {move,{x,4},{x,3}}.
    {call_only,4,{f,15}}. % z1_filter_push/4
  {label,56}.
    {test_heap,2,2}.
    {put_list,{x,1},{x,0},{x,0}}.
    {call_ext_only,1,{extfunc,lists,reverse,1}}.


{function, module_info, 0, 58}.
  {label,57}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,module_info},
               0}.
  {label,58}.
    {move,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},{x,0}}.
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.


{function, module_info, 1, 60}.
  {label,59}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,module_info},
               1}.
  {label,60}.
    {move,{x,0},{x,1}}.
    {move,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},{x,0}}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.


{function, '-inlined-__info__/1-', 1, 62}.
  {label,61}.
    {line,[]}.
    {func_info,{atom,'Elixir.Bench.Transforms.ZenumArgsStateTCO'},
               {atom,'-inlined-__info__/1-'},
               1}.
  {label,62}.
    {jump,{f,61}}.
