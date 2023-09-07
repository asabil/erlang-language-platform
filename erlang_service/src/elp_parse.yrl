%% -*- erlang -*-
%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 1996-2020. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%

%% Definition of the Erlang grammar.

Nonterminals
form
attribute attr_val
function function_clauses function_clause
clause_args clause_guard clause_body
expr expr_max expr_remote
pat_expr pat_expr_max map_pat_expr record_pat_expr
pat_argument_list pat_exprs
list tail
list_comprehension lc_expr lc_exprs
map_comprehension
binary_comprehension
tuple
record_expr record_tuple record_field record_fields
map_expr map_tuple map_field map_field_assoc map_field_exact map_fields map_key
if_expr if_clause if_clauses case_expr cr_clause cr_clauses receive_expr
fun_expr fun_clause fun_clauses atom_or_var integer_or_var
try_expr try_catch try_clause try_clauses try_opt_stacktrace
function_call argument_list
exprs body_exprs guard
atomic strings
prefix_op mult_op add_op list_op comp_op
binary bin_elements bin_element bit_expr
opt_bit_size_expr bit_size_expr opt_bit_type_list bit_type_list bit_type
top_type top_types type typed_expr typed_attr_val
type_sig type_sigs type_guard type_guards fun_type binary_type
type_spec spec_fun typed_exprs typed_record_fields field_types field_type
map_pair_types map_pair_type
bin_base_type bin_unit_type
maybe_expr maybe_match_exprs maybe_match.

Terminals
char integer float atom string var

'(' ')' ',' '->' '{' '}' '[' ']' '|' '||' '<-' ';' ':' '#' '.'
'after' 'begin' 'case' 'try' 'catch' 'end' 'fun' 'if' 'of' 'receive' 'when'
'maybe' 'else'
'andalso' 'orelse'
'bnot' 'not'
'*' '/' 'div' 'rem' 'band' 'and'
'+' '-' 'bor' 'bxor' 'bsl' 'bsr' 'or' 'xor'
'++' '--'
'==' '/=' '=<' '<' '>=' '>' '=:=' '=/=' '<=' '=>' ':='
'<<' '>>'
'!' '=' '::' '..' '...'
'?='
'spec' 'callback' % helper
dot.

Expect 0.

Rootsymbol form.

%% Expressions

Unary 0 'catch'.
Right 100 '=' '!'.
Right 150 'orelse'.
Right 160 'andalso'.
Nonassoc 200 comp_op.
Right 300 list_op.
Left 400 add_op.
Left 500 mult_op.
Unary 600 prefix_op.
Nonassoc 700 '#'.
Nonassoc 800 ':'.

%% Types

Right 150 '::'.
Left 170 '|'.
Nonassoc 200 '..'.
Nonassoc 500 '*'. % for binary expressions

form -> attribute dot : '$1'.
form -> function dot : '$1'.

attribute -> '-' atom attr_val               : build_attribute('$2', element(1, '$3'), ?anno('$1', '$3')).
attribute -> '-' atom typed_attr_val         : build_typed_attribute('$2', '$3', ?anno('$1', '$3')).
attribute -> '-' atom '(' typed_attr_val ')' : build_typed_attribute('$2', '$4', ?anno('$1', '$5')).
attribute -> '-' 'spec' type_spec            : build_type_spec('$2', '$3', ?anno('$1', '$3')).
attribute -> '-' 'callback' type_spec        : build_type_spec('$2', '$3', ?anno('$1', '$3')).

type_spec -> spec_fun type_sigs :
    {type_spec, ?anno('$1', lists:last('$2')), element(1, '$1'), '$2'}.
type_spec -> '(' spec_fun type_sigs ')' :
    {type_spec, ?anno('$1', '$4'), element(1, '$2'), '$3'}.

spec_fun ->                           atom : {'$1', ?anno('$1')}.
spec_fun ->                  atom ':' atom : {{'$1', '$3'}, ?anno('$1', '$3')}.

typed_attr_val -> expr ',' typed_record_fields : {typed_record, ?anno('$1','$3'), '$1', '$3'}.
typed_attr_val -> expr '::' top_type           : {type_def, ?anno('$1','$3'), '$1', '$3'}.

typed_record_fields -> '{' typed_exprs '}' : {tuple, ?anno('$1','$3'), '$2'}.

typed_exprs -> typed_expr                 : ['$1'].
typed_exprs -> typed_expr ',' typed_exprs : ['$1'|'$3'].
typed_exprs -> expr ',' typed_exprs       : ['$1'|'$3'].
typed_exprs -> typed_expr ',' exprs       : ['$1'|'$3'].

typed_expr -> expr '::' top_type          : {typed,'$1','$3'}.

type_sigs -> type_sig                     : ['$1'].
type_sigs -> type_sig ';' type_sigs       : ['$1'|'$3'].

type_sig -> fun_type                      : '$1'.
type_sig -> fun_type 'when' type_guards   : {type, ?anno('$1',lists:last('$3')), bounded_fun,
                                             ['$1','$3']}.

type_guards -> type_guard                 : ['$1'].
type_guards -> type_guard ',' type_guards : ['$1'|'$3'].

type_guard -> atom '(' top_types ')'   : build_compat_constraint('$1', '$3', ?anno('$1', '$4')).
type_guard -> var '::' top_type        : build_constraint('$1', '$3', ?anno('$1', '$3')).

top_types -> top_type                     : ['$1'].
top_types -> top_type ',' top_types       : ['$1'|'$3'].

top_type -> var '::' top_type             : {ann_type, ?anno('$1','$3'), ['$1','$3']}.
top_type -> type '|' top_type             : lift_unions('$1','$3').
top_type -> type                          : '$1'.

type -> type '..' type                    : {type, ?anno('$1','$3'), range, ['$1', '$3']}.
type -> type add_op type                  : ?mkop2('$1', '$2', '$3').
type -> type mult_op type                 : ?mkop2('$1', '$2', '$3').
type -> prefix_op type                    : ?mkop1('$1', '$2').
type -> '(' top_type ')'                  : '$2'.
type -> var                               : '$1'.
type -> atom                              : '$1'.
type -> atom '(' ')'                      : build_gen_type('$1').
type -> atom '(' top_types ')'            : build_type('$1', '$3').
type -> atom ':' atom '(' ')'             : {remote_type, ?anno('$1','$5'),
                                             ['$1', '$3', []]}.
type -> atom ':' atom '(' top_types ')'   : {remote_type, ?anno('$1','$6'),
                                             ['$1', '$3', '$5']}.
type -> '[' ']'                           : {type, ?anno('$1','$2'), nil, []}.
type -> '[' top_type ']'                  : {type, ?anno('$1','$3'), list, ['$2']}.
type -> '[' top_type ',' '...' ']'        : {type, ?anno('$1','$5'),
                                             nonempty_list, ['$2']}.
type -> '#' '{' '}'                       : {type, ?anno('$1','$3'), map, []}.
type -> '#' '{' map_pair_types '}'        : {type, ?anno('$1','$4'), map, '$3'}.
type -> '{' '}'                           : {type, ?anno('$1','$2'), tuple, []}.
type -> '{' top_types '}'                 : {type, ?anno('$1','$3'), tuple, '$2'}.
type -> '#' atom '{' '}'                  : {type, ?anno('$1','$4'), record, ['$2']}.
type -> '#' atom '{' field_types '}'      : {type, ?anno('$1','$5'),
                                             record, ['$2'|'$4']}.
type -> binary_type                       : '$1'.
type -> integer                           : '$1'.
type -> char                              : '$1'.
type -> 'fun' '(' ')'                     : {type, ?anno('$1','$3'), 'fun', []}.
type -> 'fun' '(' fun_type ')'            : '$3'.

fun_type -> '(' '...' ')' '->' top_type   : {type, ?anno('$1','$5'), 'fun',
                                             [{type, ?anno('$1','$5'), any}, '$5']}.
fun_type -> '(' ')' '->' top_type  : {type, ?anno('$1','$4'), 'fun',
                                      [{type, ?anno('$1','$4'), product, []}, '$4']}.
fun_type -> '(' top_types ')' '->' top_type
                                   : {type, ?anno('$1','$5'), 'fun',
                                      [{type, ?anno('$1','$5'), product, '$2'},'$5']}.

map_pair_types -> map_pair_type                    : ['$1'].
map_pair_types -> map_pair_type ',' map_pair_types : ['$1'|'$3'].

map_pair_type  -> top_type '=>' top_type  : {type, ?anno('$1','$3'),
                                             map_field_assoc,['$1','$3']}.
map_pair_type  -> top_type ':=' top_type  : {type, ?anno('$1','$3'),
                                             map_field_exact,['$1','$3']}.

field_types -> field_type                 : ['$1'].
field_types -> field_type ',' field_types : ['$1'|'$3'].

field_type -> atom '::' top_type          : {type, ?anno('$1','$3'), field_type,
                                             ['$1', '$3']}.

binary_type -> '<<' '>>'                  : {type, ?anno('$1','$2'),binary,
					     [abstract2(0, ?anno('$1')),
					      abstract2(0, ?anno('$1'))]}.
binary_type -> '<<' bin_base_type '>>'    : {type, ?anno('$1','$3'),binary,
					     ['$2', abstract2(0, ?anno('$1'))]}.
binary_type -> '<<' bin_unit_type '>>'    : {type, ?anno('$1'),binary,
                                             [abstract2(0, ?anno('$1')), '$2']}.
binary_type -> '<<' bin_base_type ',' bin_unit_type '>>'
                                    : {type, ?anno('$1','$5'), binary, ['$2', '$4']}.

bin_base_type -> var ':' type          : build_bin_type(['$1'], '$3').

bin_unit_type -> var ':' var '*' type  : build_bin_type(['$1', '$3'], '$5').

attr_val -> expr                     : {['$1'], ?anno('$1')}.
attr_val -> expr ',' exprs           : {['$1' | '$3'], ?anno('$1', lists:last('$3'))}.
attr_val -> '(' expr ',' exprs ')'   : {['$2' | '$4'], ?anno('$1', '$5')}.

function -> function_clauses : build_function('$1').

function_clauses -> function_clause : ['$1'].
function_clauses -> function_clause ';' function_clauses : ['$1'|'$3'].

function_clause -> atom clause_args clause_guard clause_body :
	{clause, ?anno('$1', '$4'), element(3, '$1'), '$2', '$3', element(1, '$4')}.

clause_args -> pat_argument_list : element(1, '$1').

clause_guard -> 'when' guard : '$2'.
clause_guard -> '$empty' : [].

clause_body -> '->' body_exprs: {'$2', ?anno('$1', lists:last('$2'))}.

expr -> 'catch' expr : {'catch',?anno('$1','$2'),'$2'}.
expr -> expr '=' expr : {match,?anno('$2','$3'),'$1','$3'}.
expr -> expr '!' expr : ?mkop2('$1', '$2', '$3').
expr -> expr 'orelse' expr : ?mkop2('$1', '$2', '$3').
expr -> expr 'andalso' expr : ?mkop2('$1', '$2', '$3').
expr -> expr comp_op expr : ?mkop2('$1', '$2', '$3').
expr -> expr list_op expr : ?mkop2('$1', '$2', '$3').
expr -> expr add_op expr : ?mkop2('$1', '$2', '$3').
expr -> expr mult_op expr : ?mkop2('$1', '$2', '$3').
expr -> prefix_op expr : ?mkop1('$1', '$2').
expr -> map_expr : '$1'.
expr -> function_call : '$1'.
expr -> record_expr : '$1'.
expr -> expr_remote : '$1'.

expr_remote -> expr_max ':' expr_max : {remote, ?anno('$1', '$3'), '$1', '$3'}.
expr_remote -> expr_max : '$1'.

expr_max -> var : '$1'.
expr_max -> atomic : '$1'.
expr_max -> list : '$1'.
expr_max -> binary : '$1'.
expr_max -> list_comprehension : '$1'.
expr_max -> map_comprehension : '$1'.
expr_max -> binary_comprehension : '$1'.
expr_max -> tuple : '$1'.
expr_max -> '(' expr ')' : ?set_anno('$2', ?anno('$1', '$3')).
expr_max -> 'begin' body_exprs 'end' : {block,?anno('$1','$3'),'$2'}.
expr_max -> if_expr : '$1'.
expr_max -> case_expr : '$1'.
expr_max -> receive_expr : '$1'.
expr_max -> fun_expr : '$1'.
expr_max -> try_expr : '$1'.
expr_max -> maybe_expr : '$1'.

pat_expr -> pat_expr '=' pat_expr : {match,?anno('$1','$3'),'$1','$3'}.
pat_expr -> pat_expr comp_op pat_expr : ?mkop2('$1', '$2', '$3').
pat_expr -> pat_expr list_op pat_expr : ?mkop2('$1', '$2', '$3').
pat_expr -> pat_expr add_op pat_expr : ?mkop2('$1', '$2', '$3').
pat_expr -> pat_expr mult_op pat_expr : ?mkop2('$1', '$2', '$3').
pat_expr -> prefix_op pat_expr : ?mkop1('$1', '$2').
pat_expr -> map_pat_expr : '$1'.
pat_expr -> record_pat_expr : '$1'.
pat_expr -> pat_expr_max : '$1'.

pat_expr_max -> var : '$1'.
pat_expr_max -> atomic : '$1'.
pat_expr_max -> list : '$1'.
pat_expr_max -> binary : '$1'.
pat_expr_max -> tuple : '$1'.
pat_expr_max -> '(' pat_expr ')' : '$2'.

map_pat_expr -> '#' map_tuple :
	{map, ?anno('$1', '$2'), element(1, '$2')}.

record_pat_expr -> '#' atom '.' atom :
	{record_index,?anno('$1','$4'),element(3, '$2'),'$4'}.
record_pat_expr -> '#' atom record_tuple :
	{record, ?anno('$1', '$3'), element(3, '$2'), element(1, '$3')}.

list -> '[' ']' : {nil,?anno('$1','$2')}.
list -> '[' expr tail : {cons,?anno('$1','$3'),'$2','$3'}.

tail -> ']' : {nil, ?anno('$1')}.
tail -> '|' expr ']' : ?set_anno('$2', ?anno('$1', '$3')).
tail -> ',' expr tail : {cons, ?anno('$1', '$3'), '$2', '$3'}.

binary -> '<<' '>>' : {bin,?anno('$1','$2'),[]}.
binary -> '<<' bin_elements '>>' : {bin,?anno('$1','$3'),'$2'}.

bin_elements -> bin_element : ['$1'].
bin_elements -> bin_element ',' bin_elements : ['$1'|'$3'].

bin_element -> bit_expr opt_bit_size_expr opt_bit_type_list :
    {value, Last} = lists:search(fun(Node) -> ?anno(Node) =/= {0, 0} end, ['$3', '$2', '$1']),
    {bin_element, ?anno('$1', Last), '$1', element(1, '$2'), element(1, '$3')}.

bit_expr -> prefix_op expr_max : ?mkop1('$1', '$2').
bit_expr -> expr_max : '$1'.

opt_bit_size_expr -> ':' bit_size_expr : {'$2', ?anno('$2')}.
opt_bit_size_expr -> '$empty' : {default, {0, 0}}.

opt_bit_type_list -> '/' bit_type_list : '$2'.
opt_bit_type_list -> '$empty' : {default, {0, 0}}.

bit_type_list -> bit_type '-' bit_type_list : {[element(1, '$1') | element(1, '$3')], ?anno('$3')}.
bit_type_list -> bit_type : {[element(1, '$1')], ?anno('$1')}.

bit_type -> atom             : {element(3,'$1'), ?anno('$1')}.
bit_type -> atom ':' integer : {{element(3,'$1'), element(3,'$3')}, ?anno('$1', '$3')}.

bit_size_expr -> expr_max : '$1'.

list_comprehension -> '[' expr '||' lc_exprs ']' :
	{lc,?anno('$1','$5'),'$2','$4'}.
map_comprehension -> '#' '{' map_field_assoc '||' lc_exprs '}' :
	{mc, ?anno('$1', '$6'), '$3', '$5'}.
binary_comprehension -> '<<' expr_max '||' lc_exprs '>>' :
	{bc,?anno('$1','$5'),'$2','$4'}.
lc_exprs -> lc_expr : ['$1'].
lc_exprs -> lc_expr ',' lc_exprs : ['$1'|'$3'].

lc_expr -> expr : '$1'.
lc_expr -> map_field_exact '<-' expr : {m_generate, ?anno('$1', '$3'), '$1', '$3'}.
lc_expr -> expr '<-' expr : {generate,?anno('$1','$3'),'$1','$3'}.
lc_expr -> binary '<=' expr : {b_generate,?anno('$1','$3'),'$1','$3'}.

tuple -> '{' '}' : {tuple,?anno('$1','$2'),[]}.
tuple -> '{' exprs '}' : {tuple,?anno('$1','$3'),'$2'}.

map_expr -> '#' map_tuple :
	{map, ?anno('$1', '$2'), element(1, '$2')}.
map_expr -> expr_max '#' map_tuple :
	{map, ?anno('$1', '$3'), '$1', element(1, '$3')}.
map_expr -> map_expr '#' map_tuple :
	{map, ?anno('$1', '$3'), '$1', element(1, '$3')}.

map_tuple -> '{' '}' : {[], ?anno('$1', '$2')}.
map_tuple -> '{' map_fields '}' : {'$2', ?anno('$1', '$3')}.

map_fields -> map_field : ['$1'].
map_fields -> map_field ',' map_fields : ['$1' | '$3'].

map_field -> map_field_assoc : '$1'.
map_field -> map_field_exact : '$1'.

map_field_assoc -> map_key '=>' expr :
	{map_field_assoc,?anno('$1','$3'),'$1','$3'}.

map_field_exact -> map_key ':=' expr :
	{map_field_exact,?anno('$1','$3'),'$1','$3'}.

map_key -> expr : '$1'.

%% N.B. This is called from expr.
%% N.B. Field names are returned as the complete object, even if they are
%% always atoms for the moment, this might change in the future.

record_expr -> '#' atom '.' atom :
	{record_index, ?anno('$1', '$4'), element(3, '$2'), '$4'}.
record_expr -> '#' atom record_tuple :
	{record, ?anno('$1', '$3'), element(3, '$2'), element(1, '$3')}.
record_expr -> expr_max '#' atom '.' atom :
	{record_field, ?anno('$1', '$5'), '$1', element(3, '$3'), '$5'}.
record_expr -> expr_max '#' atom record_tuple :
	{record, ?anno('$1', '$4'), '$1', element(3, '$3'), element(1, '$4')}.
record_expr -> record_expr '#' atom '.' atom :
	{record_field, ?anno('$1', '$5'), '$1', element(3, '$3'), '$5'}.
record_expr -> record_expr '#' atom record_tuple :
	{record, ?anno('$1', '$4'), '$1', element(3, '$3'), element(1, '$4')}.

record_tuple -> '{' '}' : {[], ?anno('$1', '$2')}.
record_tuple -> '{' record_fields '}' : {'$2', ?anno('$1', '$3')}.

record_fields -> record_field : ['$1'].
record_fields -> record_field ',' record_fields : ['$1' | '$3'].

record_field -> var '=' expr : {record_field,?anno('$1','$3'),'$1','$3'}.
record_field -> atom '=' expr : {record_field,?anno('$1','$3'),'$1','$3'}.

%% N.B. This is called from expr.

function_call -> expr_remote argument_list :
	{call,?anno('$1', '$2'),'$1',element(1, '$2')}.

if_expr -> 'if' if_clauses 'end' : {'if',?anno('$1','$3'),'$2'}.

if_clauses -> if_clause : ['$1'].
if_clauses -> if_clause ';' if_clauses : ['$1' | '$3'].

if_clause -> guard clause_body :
	{clause, ?anno(hd(hd('$1')), '$2'), [], '$1', element(1, '$2')}.

case_expr -> 'case' expr 'of' cr_clauses 'end' :
	{'case', ?anno('$1', '$5'), '$2', '$4'}.

cr_clauses -> cr_clause : ['$1'].
cr_clauses -> cr_clause ';' cr_clauses : ['$1' | '$3'].

%% FIXME: merl in syntax_tools depends on patterns in a 'case' being
%% full expressions. Therefore, we can't use pat_expr here. There
%% should be a better way.

cr_clause -> expr clause_guard clause_body :
	{clause, ?anno('$1', '$3'), ['$1'], '$2', element(1, '$3')}.

receive_expr -> 'receive' cr_clauses 'end' :
	{'receive', ?anno('$1', '$3'), '$2'}.
receive_expr -> 'receive' 'after' expr clause_body 'end' :
	{'receive', ?anno('$1', '$5'), [], '$3', element(1, '$4')}.
receive_expr -> 'receive' cr_clauses 'after' expr clause_body 'end' :
	{'receive', ?anno('$1', '$6'), '$2', '$4', element(1, '$5')}.

fun_expr -> 'fun' atom '/' integer :
	{'fun',?anno('$1','$4'),{function,element(3, '$2'),element(3, '$4')}}.
fun_expr -> 'fun' atom_or_var ':' atom_or_var '/' integer_or_var :
	{'fun',?anno('$1','$6'),{function,'$2','$4','$6'}}.
fun_expr -> 'fun' fun_clauses 'end' :
	build_fun(?anno('$1','$3'), '$2').

atom_or_var -> atom : '$1'.
atom_or_var -> var : '$1'.

integer_or_var -> integer : '$1'.
integer_or_var -> var : '$1'.

fun_clauses -> fun_clause : ['$1'].
fun_clauses -> fun_clause ';' fun_clauses : ['$1' | '$3'].

fun_clause -> pat_argument_list clause_guard clause_body :
	{clause, ?anno('$1', '$3'), 'fun', element(1, '$1'), '$2', element(1, '$3')}.

fun_clause -> var pat_argument_list clause_guard clause_body :
	{clause, ?anno('$1', '$4'), element(3, '$1'), element(1, '$2'), '$3', element(1, '$4')}.

try_expr -> 'try' body_exprs 'of' cr_clauses try_catch :
	build_try('$1','$2','$4','$5').
try_expr -> 'try' body_exprs try_catch :
	build_try('$1','$2',[],'$3').

try_catch -> 'catch' try_clauses 'end' :
	{'$2',[],'$3'}.
try_catch -> 'catch' try_clauses 'after' body_exprs 'end' :
	{'$2','$4','$5'}.
try_catch -> 'after' exprs 'end' :
	{[],'$2','$3'}.

try_clauses -> try_clause : ['$1'].
try_clauses -> try_clause ';' try_clauses : ['$1' | '$3'].

try_clause -> pat_expr clause_guard clause_body :
	{clause, ?anno('$1', '$3'), [{tuple, {0, 0}, [{atom, {0, 0}, throw}, '$1', {var, {0, 0}, '_'}]}], '$2', element(1, '$3')}.
try_clause -> atom ':' pat_expr try_opt_stacktrace clause_guard clause_body :
	{clause, ?anno('$1', '$6'), [{tuple, {0, 0}, ['$1', '$3', '$4']}], '$5', element(1, '$6')}.
try_clause -> var ':' pat_expr try_opt_stacktrace clause_guard clause_body :
	{clause, ?anno('$1', '$6'), [{tuple, {0, 0}, ['$1', '$3', '$4']}], '$5', element(1, '$6')}.

try_opt_stacktrace -> ':' var : '$2'.
try_opt_stacktrace -> '$empty' : {var, {0, 0}, '_'}.

maybe_expr -> 'maybe' maybe_match_exprs 'end' :
	{'maybe', ?anno('$1', '$3'), '$2'}.
maybe_expr -> 'maybe' maybe_match_exprs 'else' cr_clauses 'end' :
        %% `erl_lint` can produce a better warning when the position
        %% of the `else` keyword is known.
	{'maybe', ?anno('$1', '$5'), '$2', {'else', ?anno('$3', '$5'), '$4'}}.

maybe_match_exprs -> maybe_match : ['$1'].
maybe_match_exprs -> maybe_match ',' maybe_match_exprs : ['$1' | '$3'].
maybe_match_exprs -> expr : ['$1'].
maybe_match_exprs -> expr ',' maybe_match_exprs : ['$1' | '$3'].

maybe_match -> expr '?=' expr : {maybe_match, ?anno('$1', '$3'), '$1', '$3'}.

argument_list -> '(' ')' : {[],?anno('$1','$2')}.
argument_list -> '(' exprs ')' : {'$2',?anno('$1','$3')}.

pat_argument_list -> '(' ')' : {[],?anno('$1','$2')}.
pat_argument_list -> '(' pat_exprs ')' : {'$2',?anno('$1','$3')}.

body_exprs -> expr : ['$1'].
body_exprs -> expr ',' body_exprs : ['$1' | '$3'].

exprs -> expr : ['$1'].
exprs -> expr ',' exprs : ['$1' | '$3'].

pat_exprs -> pat_expr : ['$1'].
pat_exprs -> pat_expr ',' pat_exprs : ['$1' | '$3'].

guard -> exprs : ['$1'].
guard -> exprs ';' guard : ['$1'|'$3'].

atomic -> char : '$1'.
atomic -> integer : '$1'.
atomic -> float : '$1'.
atomic -> atom : '$1'.
atomic -> strings : '$1'.

strings -> string : '$1'.
strings -> string strings : {string, ?anno('$1', '$2'), element(3, '$1') ++ element(3, '$2')}.

prefix_op -> '+' : '$1'.
prefix_op -> '-' : '$1'.
prefix_op -> 'bnot' : '$1'.
prefix_op -> 'not' : '$1'.

mult_op -> '/' : '$1'.
mult_op -> '*' : '$1'.
mult_op -> 'div' : '$1'.
mult_op -> 'rem' : '$1'.
mult_op -> 'band' : '$1'.
mult_op -> 'and' : '$1'.

add_op -> '+' : '$1'.
add_op -> '-' : '$1'.
add_op -> 'bor' : '$1'.
add_op -> 'bxor' : '$1'.
add_op -> 'bsl' : '$1'.
add_op -> 'bsr' : '$1'.
add_op -> 'or' : '$1'.
add_op -> 'xor' : '$1'.

list_op -> '++' : '$1'.
list_op -> '--' : '$1'.

comp_op -> '==' : '$1'.
comp_op -> '/=' : '$1'.
comp_op -> '=<' : '$1'.
comp_op -> '<' : '$1'.
comp_op -> '>=' : '$1'.
comp_op -> '>' : '$1'.
comp_op -> '=:=' : '$1'.
comp_op -> '=/=' : '$1'.

Header
"%% This file was automatically generated from the file \"erl_parse.yrl\"."
"%%"
"%% Copyright Ericsson AB 1996-2015. All Rights Reserved."
"%%"
"%% Licensed under the Apache License, Version 2.0 (the \"License\"); you may"
"%% not use this file except in compliance with the License. You may obtain"
"%% a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>"
"%%"
"%% Unless required by applicable law or agreed to in writing, software"
"%% distributed under the License is distributed on an \"AS IS\" BASIS,"
"%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied."
"%% See the License for the specific language governing permissions and"
"%% limitations under the License."
"".

Erlang code.

-export([parse_form/1, parse_exprs/1]).
-export([normalise/1, abstract/1, tokens/1, tokens/2]).
-export([abstract/2]).
-export([inop_prec/1, preop_prec/1, func_prec/0, max_prec/0]).
-export([type_inop_prec/1, type_preop_prec/1]).
-export([
    anno/2,
    map_anno/2,
    fold_anno/3,
    mapfold_anno/3,
    new_anno/1,
    anno_to_term/1,
    anno_from_term/1
]).

-export_type([
    abstract_clause/0,
    abstract_expr/0,
    abstract_form/0,
    abstract_type/0,
    form_info/0,
    error_info/0
]).
%% The following types are exported because they are used by syntax_tools
-export_type([af_binelement/1, af_generator/0, af_remote_function/0]).
%% The following type is used by PropEr
-export_type([af_field_decl/0]).

%% Removed functions
-removed([
    {set_line, 2, "use erl_anno:set_line/2"},
    {get_attributes, 1, "erl_anno:{column,line,location,text}/1 instead"},
    {get_attribute, 2, "erl_anno:{column,line,location,text}/1 instead"}
]).

%% Start of Abstract Format

-type anno() :: erl_anno:anno().

-type abstract_form() ::
    af_module()
    | af_behavior()
    | af_behaviour()
    | af_export()
    | af_import()
    | af_export_type()
    | af_compile()
    | af_file()
    | af_record_decl()
    | af_type_decl()
    | af_function_spec()
    | af_wild_attribute()
    | af_function_decl().

-type af_module() :: {'attribute', anno(), 'module', module()}.

-type af_behavior() :: {'attribute', anno(), 'behavior', behaviour()}.

-type af_behaviour() :: {'attribute', anno(), 'behaviour', behaviour()}.

-type behaviour() :: atom().

-type af_export() :: {'attribute', anno(), 'export', af_fa_list()}.

-type af_import() :: {'attribute', anno(), 'import', {module(), af_fa_list()}}.

-type af_fa_list() :: [{function_name(), arity()}].

-type af_export_type() :: {'attribute', anno(), 'export_type', af_ta_list()}.

-type af_ta_list() :: [{type_name(), arity()}].

-type af_compile() :: {'attribute', anno(), 'compile', any()}.

-type af_file() :: {'attribute', anno(), 'file', {string(), anno()}}.

-type af_record_decl() ::
    {'attribute', anno(), 'record', {record_name(), [af_field_decl()]}}.

-type af_field_decl() :: af_typed_field() | af_field().

-type af_typed_field() ::
    {'typed_record_field', af_field(), abstract_type()}.

-type af_field() ::
    {'record_field', anno(), af_field_name()}
    | {'record_field', anno(), af_field_name(), abstract_expr()}.

-type af_type_decl() ::
    {'attribute', anno(), type_attr(), {type_name(), abstract_type(), [af_variable()]}}.

-type type_attr() :: 'opaque' | 'type'.

-type af_function_spec() ::
    {'attribute', anno(), spec_attr(), {{function_name(), arity()}, af_function_type_list()}}
    | {'attribute', anno(), 'spec', {{module(), function_name(), arity()}, af_function_type_list()}}.

-type spec_attr() :: 'callback' | 'spec'.

-type af_wild_attribute() :: {'attribute', anno(), atom(), any()}.

-type af_function_decl() ::
    {'function', anno(), function_name(), arity(), af_clause_seq()}.

-type abstract_expr() ::
    af_literal()
    | af_match(abstract_expr())
    | af_maybe_match()
    | af_variable()
    | af_tuple(abstract_expr())
    | af_nil()
    | af_cons(abstract_expr())
    | af_bin(abstract_expr())
    | af_binary_op(abstract_expr())
    | af_unary_op(abstract_expr())
    | af_record_creation(abstract_expr())
    | af_record_update(abstract_expr())
    | af_record_index()
    | af_record_field_access(abstract_expr())
    | af_map_creation(abstract_expr())
    | af_map_update(abstract_expr())
    | af_catch()
    | af_local_call()
    | af_remote_call()
    | af_list_comprehension()
    | af_map_comprehension()
    | af_binary_comprehension()
    | af_block()
    | af_if()
    | af_case()
    | af_try()
    | af_receive()
    | af_local_fun()
    | af_remote_fun()
    | af_fun()
    | af_named_fun()
    | af_maybe()
    | af_maybe_else().

-type af_record_update(T) ::
    {'record', anno(), abstract_expr(), record_name(), [af_record_field(T)]}.

-type af_catch() :: {'catch', anno(), abstract_expr()}.

-type af_local_call() :: {'call', anno(), af_local_function(), af_args()}.

-type af_remote_call() :: {'call', anno(), af_remote_function(), af_args()}.

-type af_args() :: [abstract_expr()].

-type af_local_function() :: abstract_expr().

-type af_remote_function() ::
    {'remote', anno(), abstract_expr(), abstract_expr()}.

-type af_list_comprehension() ::
    {'lc', anno(), af_template(), af_qualifier_seq()}.

-type af_map_comprehension() ::
        {'mc', anno(), af_assoc(abstract_expr()), af_qualifier_seq()}.

-type af_binary_comprehension() ::
    {'bc', anno(), af_template(), af_qualifier_seq()}.

-type af_template() :: abstract_expr().

-type af_qualifier_seq() :: [af_qualifier(), ...].

-type af_qualifier() :: af_generator() | af_filter().

-type af_generator() ::
    {'generate', anno(), af_pattern(), abstract_expr()}
    | {'m_generate', anno(), af_assoc_exact(af_pattern()), abstract_expr()}
    | {'b_generate', anno(), af_pattern(), abstract_expr()}.

-type af_filter() :: abstract_expr().

-type af_block() :: {'block', anno(), af_body()}.

-type af_if() :: {'if', anno(), af_clause_seq()}.

-type af_case() :: {'case', anno(), abstract_expr(), af_clause_seq()}.

-type af_try() ::
    {'try', anno(), af_body(), af_clause_seq() | [], af_clause_seq() | [], af_body() | []}.

-type af_clause_seq() :: [af_clause(), ...].

-type af_receive() ::
    {'receive', anno(), af_clause_seq()}
    | {'receive', anno(), af_clause_seq(), abstract_expr(), af_body()}.

-type af_local_fun() ::
    {'fun', anno(), {'function', function_name(), arity()}}.

-type af_remote_fun() ::
    {'fun', anno(), {'function', module(), function_name(), arity()}}
    | {'fun', anno(), {'function', af_atom() | af_variable(), af_atom() | af_variable(), af_integer() | af_variable()}}.

-type af_fun() :: {'fun', anno(), {'clauses', af_clause_seq()}}.

-type af_named_fun() :: {'named_fun', anno(), fun_name(), af_clause_seq()}.

-type fun_name() :: atom().

-type abstract_clause() :: af_clause().

-type af_clause() ::
    {'clause', anno(), [af_pattern()], af_guard_seq(), af_body()}.

-type af_body() :: [abstract_expr(), ...].

-type af_guard_seq() :: [af_guard()].

-type af_guard() :: [af_guard_test(), ...].

-type af_guard_test() ::
    af_literal()
    | af_variable()
    | af_tuple(af_guard_test())
    | af_nil()
    | af_cons(af_guard_test())
    | af_bin(af_guard_test())
    | af_binary_op(af_guard_test())
    | af_unary_op(af_guard_test())
    | af_record_creation(af_guard_test())
    | af_record_index()
    | af_record_field_access(af_guard_test())
    | af_map_creation(af_guard_test())
    | af_map_update(af_guard_test())
    | af_guard_call()
    | af_remote_guard_call().

-type af_record_field_access(T) ::
    {'record_field', anno(), T, record_name(), af_field_name()}.

-type af_map_creation(T) :: {'map', anno(), [af_assoc(T)]}.

-type af_map_update(T) :: {'map', anno(), T, [af_assoc(T)]}.

-type af_assoc(T) ::
    {'map_field_assoc', anno(), T, T}
    | af_assoc_exact(T).

-type af_assoc_exact(T) :: {'map_field_exact', anno(), T, T}.

-type af_guard_call() :: {'call', anno(), af_atom(), [af_guard_test()]}.

-type af_remote_guard_call() ::
    {'call', anno(), {'remote', anno(), af_lit_atom('erlang'), af_atom()}, [af_guard_test()]}.

-type af_pattern() ::
    af_literal()
    | af_match(af_pattern())
    | af_variable()
    | af_tuple(af_pattern())
    | af_nil()
    | af_cons(af_pattern())
    | af_bin(af_pattern())
    | af_binary_op(af_pattern())
    | af_unary_op(af_pattern())
    | af_record_creation(af_pattern())
    | af_record_index()
    | af_map_pattern().

-type af_record_index() ::
    {'record_index', anno(), record_name(), af_field_name()}.

-type af_record_creation(T) ::
    {'record', anno(), record_name(), [af_record_field(T)]}.

-type af_record_field(T) :: {'record_field', anno(), af_field_name(), T}.

-type af_map_pattern() ::
    {'map', anno(), [af_assoc_exact(af_pattern())]}.

-type af_maybe() :: {'maybe', anno(), af_body()}.
-type af_maybe_else() :: {'maybe', anno(), af_body(), {'else', anno(), af_clause_seq()}}.

-type abstract_type() ::
    af_annotated_type()
    | af_atom()
    | af_bitstring_type()
    | af_empty_list_type()
    | af_fun_type()
    | af_integer_range_type()
    | af_map_type()
    | af_predefined_type()
    | af_record_type()
    | af_remote_type()
    | af_singleton_integer_type()
    | af_tuple_type()
    | af_type_union()
    | af_type_variable()
    | af_user_defined_type().

-type af_annotated_type() ::
    % [Var, Type]
    {'ann_type', anno(), [af_anno() | abstract_type()]}.

-type af_anno() :: af_variable().

-type af_bitstring_type() ::
    {'type', anno(), 'binary', [af_singleton_integer_type()]}.

-type af_empty_list_type() :: {'type', anno(), 'nil', []}.

-type af_fun_type() ::
    {'type', anno(), 'fun', []}
    | {'type', anno(), 'fun', [
        {'type', anno(), 'any'}
        | abstract_type()
    ]}
    | af_function_type().

-type af_integer_range_type() ::
    {'type', anno(), 'range', [af_singleton_integer_type()]}.

-type af_map_type() ::
    {'type', anno(), 'map', 'any'}
    | {'type', anno(), 'map', [af_assoc_type()]}.

-type af_assoc_type() ::
    {'type', anno(), 'map_field_assoc', [abstract_type()]}
    | {'type', anno(), 'map_field_exact', [abstract_type()]}.

-type af_predefined_type() ::
    {'type', anno(), type_name(), [abstract_type()]}.

-type af_record_type() ::
    % [Name, T1, ... Tk]
    {'type', anno(), 'record', [
        (Name :: af_atom())
        | af_record_field_type()
    ]}.

-type af_record_field_type() ::
    {'type', anno(), 'field_type', [
        (Name :: af_atom())
        % [Name, Type]
        | abstract_type()
    ]}.

-type af_remote_type() ::
    {'remote_type', anno(), [
        (Module :: af_atom())
        | (TypeName :: af_atom())
        % [Module, Name, [T]]
        | [abstract_type()]
    ]}.

-type af_tuple_type() ::
    {'type', anno(), 'tuple', 'any'}
    | {'type', anno(), 'tuple', [abstract_type()]}.

-type af_type_union() ::
    % at least two
    {'type', anno(), 'union', [abstract_type(), ...]}.

% except '_'
-type af_type_variable() :: {'var', anno(), atom()}.

-type af_user_defined_type() ::
    {'user_type', anno(), type_name(), [abstract_type()]}.

-type af_function_type_list() :: [
    af_constrained_function_type()
    | af_function_type(),
    ...
].

-type af_constrained_function_type() ::
    % [Ft, Fc]
    {'type', anno(), 'bounded_fun', [
        af_function_type()
        | af_function_constraint()
    ]}.

-type af_function_type() ::
    {'type', anno(), 'fun', [{'type', anno(), 'product', [abstract_type()]} | abstract_type()]}.

-type af_function_constraint() :: [af_constraint(), ...].

-type af_constraint() ::
    {'type', anno(), 'constraint', [
        af_lit_atom('is_subtype')
        % [IsSubtype, [V, T]]
        | [af_type_variable() | abstract_type()]
    ]}.

-type af_singleton_integer_type() ::
    af_integer()
    | af_character()
    | af_unary_op(af_singleton_integer_type())
    | af_binary_op(af_singleton_integer_type()).

-type af_literal() ::
    af_atom()
    | af_character()
    | af_float()
    | af_integer()
    | af_string().

-type af_atom() :: af_lit_atom(atom()).

-type af_lit_atom(A) :: {'atom', anno(), A}.

-type af_character() :: {'char', anno(), char()}.

-type af_float() :: {'float', anno(), float()}.

-type af_integer() :: {'integer', anno(), non_neg_integer()}.

-type af_string() :: {'string', anno(), string()}.

-type af_match(T) :: {'match', anno(), af_pattern(), T}.

-type af_maybe_match() :: {'maybe_match', anno(), af_pattern(), abstract_expr()}.

% | af_anon_variable()
-type af_variable() :: {'var', anno(), atom()}.

%-type af_anon_variable() :: {'var', anno(), '_'}.

-type af_tuple(T) :: {'tuple', anno(), [T]}.

-type af_nil() :: {'nil', anno()}.

-type af_cons(T) :: {'cons', anno(), T, T}.

-type af_bin(T) :: {'bin', anno(), [af_binelement(T)]}.

-type af_binelement(T) :: {'bin_element', anno(), T, af_binelement_size(), type_specifier_list()}.

-type af_binelement_size() :: 'default' | abstract_expr().

-type af_binary_op(T) :: {'op', anno(), binary_op(), T, T}.

-type binary_op() ::
    '/'
    | '*'
    | 'div'
    | 'rem'
    | 'band'
    | 'and'
    | '+'
    | '-'
    | 'bor'
    | 'bxor'
    | 'bsl'
    | 'bsr'
    | 'or'
    | 'xor'
    | '++'
    | '--'
    | '=='
    | '/='
    | '=<'
    | '<'
    | '>='
    | '>'
    | '=:='
    | '=/='
    | '!'.

-type af_unary_op(T) :: {'op', anno(), unary_op(), T}.

-type unary_op() :: '+' | '-' | 'bnot' | 'not'.

%% See also lib/stdlib/{src/erl_bits.erl,include/erl_bits.hrl}.
-type type_specifier_list() :: 'default' | [type_specifier(), ...].

-type type_specifier() ::
    type()
    | signedness()
    | endianness()
    | unit().

-type type() ::
    'integer'
    | 'float'
    | 'binary'
    | 'bytes'
    | 'bitstring'
    | 'bits'
    | 'utf8'
    | 'utf16'
    | 'utf32'.

-type signedness() :: 'signed' | 'unsigned'.

-type endianness() :: 'big' | 'little' | 'native'.

-type unit() :: {'unit', 1..256}.

-type record_name() :: atom().

-type af_field_name() :: af_atom().

-type function_name() :: atom().

-type type_name() :: atom().

-type form_info() ::
    {'eof', elp_anno:offset()}
    | {'error', elp_scan:error_info() | error_info()}
    | {'warning', elp_scan:error_info() | error_info()}.

%% End of Abstract Format

%% XXX. To be refined.
-type error_description() :: term().
-type error_info() :: {elp_scan:location(), module(), error_description()}.
-type token() :: elp_scan:token().

%% mkop(Op, Arg) -> {op,Anno,Op,Arg}.
%% mkop(Left, Op, Right) -> {op,Anno,Op,Left,Right}.

-define(mkop2(L, OpTok, R),
    {op, ?anno(L, R), element(1, OpTok), L, R}
).

-define(mkop1(OpTok, A),
    {op, ?anno(OpTok, A), element(1, OpTok), A}
).

%% keep track of annotation info in tokens
-define(anno(Tup), element(2, Tup)).

% -ifdef(DEBUG).
% -define(anno(First, Last), begin
%     case element(1, element(2, First)) =< element(2, element(2, Last)) of
%         true -> ok;
%         false -> ret_err(element(2, First), {bad_range, First, Last})
%     end,
%     {element(1, element(2, First)), element(2, element(2, Last))}
% end).
% -else.
-define(anno(First, Last), {
    min(element(1, element(2, First)), element(1, element(2, Last))),
    max(element(2, element(2, Last)), element(2, element(2, Last)))
}).
% -endif.

-define(set_anno(Tup, Anno), setelement(2, Tup, Anno)).

-spec parse_form(Tokens) -> {ok, AbsForm} | {error, ErrorInfo} when
    Tokens :: [token()],
    AbsForm :: abstract_form(),
    ErrorInfo :: error_info().
parse_form([{'-', A1}, {atom, A2, spec} | Tokens]) ->
    NewTokens = [{'-', A1}, {'spec', A2} | Tokens],
    parse(NewTokens);
parse_form([{'-', A1}, {atom, A2, callback} | Tokens]) ->
    NewTokens = [{'-', A1}, {'callback', A2} | Tokens],
    parse(NewTokens);
parse_form(Tokens) ->
    parse(Tokens).

-spec parse_exprs(Tokens) -> {ok, ExprList} | {error, ErrorInfo} when
    Tokens :: [token()],
    ExprList :: [abstract_expr()],
    ErrorInfo :: error_info().
parse_exprs(Tokens) ->
    A = {0, 0},
    case parse([{atom, A, f}, {'(', A}, {')', A}, {'->', A} | Tokens]) of
        {ok, {function, _Af, f, _, [{clause, _Ac, [], [], Exprs}]}} ->
            {ok, Exprs};
        {error, _} = Err ->
            Err
    end.

-type attributes() ::
    'export'
    | 'file'
    | 'import'
    | 'module'
    | 'opaque'
    | 'record'
    | 'type'.

build_typed_attribute(
    {atom, _Aa, record},
    {typed_record, _Anno, {atom, _An, RecordName}, RecTuple},
    Anno
) ->
    {attribute, Anno, record, {RecordName, record_tuple(RecTuple)}};
build_typed_attribute(
    {atom, _Aa, Attr},
    {type_def, _Anno, {call, _, {atom, _, TypeName}, Args}, Type},
    Anno
) when
    Attr =:= 'type'; Attr =:= 'opaque'
->
    lists:foreach(
        fun
            ({var, A, '_'}) -> ret_err(A, "bad type variable");
            (_) -> ok
        end,
        Args
    ),
    lists:foreach(
        fun
            ({var, _, _}) -> ok;
            (Other) -> ret_abstr_err(Other, "bad type variable")
        end,
        Args
    ),
    {attribute, Anno, Attr, {TypeName, Type, Args}};
build_typed_attribute({atom, Aa, Attr} = Abstr, _, _Anno) ->
    case Attr of
        record -> error_bad_decl(Abstr, record);
        type -> error_bad_decl(Abstr, type);
        opaque -> error_bad_decl(Abstr, opaque);
        _ -> ret_err(Aa, "bad attribute")
    end.

build_type_spec({Kind, _Aa}, {type_spec, _TA, SpecFun, TypeSpecs}, Anno) when
    Kind =:= spec; Kind =:= callback
->
    NewSpecFun =
        case SpecFun of
            {atom, _, Fun} ->
                {Fun, find_arity_from_specs(TypeSpecs)};
            {{atom, _, Mod}, {atom, _, Fun}} ->
                {Mod, Fun, find_arity_from_specs(TypeSpecs)}
        end,
    {attribute, Anno, Kind, {NewSpecFun, TypeSpecs}}.

find_arity_from_specs([Spec | _]) ->
    %% Use the first spec to find the arity. If all are not the same,
    %% erl_lint will find this.
    Fun =
        case Spec of
            {type, _, bounded_fun, [F, _]} -> F;
            {type, _, 'fun', _} = F -> F
        end,
    {type, _, 'fun', [{type, _, product, Args}, _]} = Fun,
    length(Args).

%% The 'is_subtype(V, T)' syntax is not supported as of Erlang/OTP
%% 19.0, but is kept for backward compatibility.
build_compat_constraint({atom, _, is_subtype}, [{var, _, _} = LHS, Type], Anno) ->
    build_constraint(LHS, Type, Anno);
build_compat_constraint({atom, _, is_subtype}, [LHS, _Type], _Anno) ->
    ret_abstr_err(LHS, "bad type variable");
build_compat_constraint({atom, A, Atom}, _Types, _Anno) ->
    ret_err(A, io_lib:format("unsupported constraint ~tw", [Atom])).

build_constraint({atom, _, is_subtype}, [{var, _, _} = LHS, Type], Anno) ->
    build_constraint(LHS, Type, Anno);
build_constraint({atom, A, Atom}, _Args, _Anno) ->
    ret_err(A, io_lib:format("unsupported constraint ~tw", [Atom]));
build_constraint({var, A, '_'}, _Types, _Anno) ->
    ret_err(A, "bad type variable");
build_constraint(LHS, Type, Anno) ->
    IsSubType = {atom, {0, 0}, is_subtype},
    {type, Anno, constraint, [IsSubType, [LHS, Type]]}.

lift_unions(T1, {type, _, union, List} = Tail) ->
    {type, ?anno(T1, Tail), union, [T1 | List]};
lift_unions(T1, T2) ->
    {type, ?anno(T1, T2), union, [T1, T2]}.

build_gen_type({atom, Aa, tuple}) ->
    {type, Aa, tuple, any};
build_gen_type({atom, Aa, map}) ->
    {type, Aa, map, any};
build_gen_type({atom, Aa, Name}) ->
    Tag = type_tag(Name, 0),
    {Tag, Aa, Name, []}.

build_bin_type([{var, _, '_'} | Left], Int) ->
    build_bin_type(Left, Int);
build_bin_type([], Int) ->
    Int;
build_bin_type([{var, Aa, _} | _], _) ->
    ret_err(Aa, "Bad binary type").

build_type({atom, A, Name}, Types) ->
    Tag = type_tag(Name, length(Types)),
    {Tag, A, Name, Types}.

type_tag(TypeName, NumberOfTypeVariables) ->
    case erl_internal:is_type(TypeName, NumberOfTypeVariables) of
        true -> type;
        false -> user_type
    end.

abstract2(Term, Anno) -> abstract(Term, Anno).

%% build_attribute(AttrName, AttrValue) ->
%%	{attribute,Anno,module,Module}
%%	{attribute,Anno,export,Exports}
%%	{attribute,Anno,import,Imports}
%%	{attribute,Anno,record,{Name,Inits}}
%%	{attribute,Anno,file,{Name,Line}}
%%	{attribute,Anno,Name,Val}

build_attribute({atom, _Aa, module}, Val, Anno) ->
    case Val of
        [{atom, _Am, Module}] ->
            {attribute, Anno, module, Module};
        [{atom, _Am, Module}, ExpList] ->
            {attribute, Anno, module, {Module, var_list(ExpList)}};
        [Other | _] ->
            error_bad_decl(Other, module)
    end;
build_attribute({atom, _Aa, export}, Val, Anno) ->
    case Val of
        [ExpList] ->
            {attribute, Anno, export, farity_list(ExpList)};
        [_, Other | _] ->
            error_bad_decl(Other, export)
    end;
build_attribute({atom, _Aa, import}, Val, Anno) ->
    case Val of
        [{atom, _Am, Mod}, ImpList] ->
            {attribute, Anno, import, {Mod, farity_list(ImpList)}};
        [_, Other | _] ->
            error_bad_decl(Other, import)
    end;
build_attribute({atom, _Aa, record}, Val, Anno) ->
    case Val of
        [{atom, _An, Record}, RecTuple] ->
            {attribute, Anno, record, {Record, record_tuple(RecTuple)}};
        [Other | _] ->
            error_bad_decl(Other, record)
    end;
build_attribute({atom, _Aa, file}, Val, Anno) ->
    case Val of
        [{string, _An, Name}, {integer, _Al, Line}] ->
            {attribute, Anno, file, {Name, Line}};
        [Other | _] ->
            error_bad_decl(Other, file)
    end;
build_attribute({atom, _Aa, Attr}, Val, Anno) ->
    case Val of
        [Expr0] ->
            Expr = attribute_farity(Expr0),
            {attribute, Anno, Attr, term(Expr)};
        [_, Other | _] ->
            ret_abstr_err(Other, "bad attribute")
    end.

var_list({cons, _Ac, {var, _, V}, Tail}) ->
    [V | var_list(Tail)];
var_list({nil, _An}) ->
    [];
var_list(Other) ->
    ret_abstr_err(Other, "bad variable list").

attribute_farity({cons, A, H, T}) ->
    {cons, A, attribute_farity(H), attribute_farity(T)};
attribute_farity({tuple, A, Args0}) ->
    Args = attribute_farity_list(Args0),
    {tuple, A, Args};
attribute_farity({map, A, Args0}) ->
    Args = attribute_farity_map(Args0),
    {map, A, Args};
attribute_farity({op, A, '/', {atom, _, _} = Name, {integer, _, _} = Arity}) ->
    {tuple, A, [Name, Arity]};
attribute_farity(Other) ->
    Other.

attribute_farity_list(Args) ->
    [attribute_farity(A) || A <- Args].

%% It is not meaningful to have farity keys.
attribute_farity_map(Args) ->
    [{Op, A, K, attribute_farity(V)} || {Op, A, K, V} <- Args].

-spec error_bad_decl(erl_parse_tree(), attributes()) -> no_return().

error_bad_decl(Abstr, S) ->
    ret_abstr_err(Abstr, io_lib:format("bad ~tw declaration", [S])).

farity_list({cons, _Ac, {op, _Ao, '/', {atom, _Aa, A}, {integer, _Ai, I}}, Tail}) ->
    [{A, I} | farity_list(Tail)];
farity_list({cons, _Ac, {op, _Ao, '/', {atom, _Aa, _A}, Other}, _Tail}) ->
    ret_abstr_err(Other, "bad function arity");
farity_list({cons, _Ac, {op, _Ao, '/', Other, _}, _Tail}) ->
    ret_abstr_err(Other, "bad function name");
farity_list({nil, _An}) ->
    [];
farity_list(Other) ->
    ret_abstr_err(Other, "bad Name/Arity").

record_tuple({tuple, _At, Fields}) ->
    record_fields(Fields);
record_tuple(Other) ->
    ret_abstr_err(Other, "bad record declaration").

record_fields([{atom, Aa, A} | Fields]) ->
    [{record_field, Aa, {atom, Aa, A}} | record_fields(Fields)];
record_fields([{match, _Am, {atom, Aa, A}, Expr} | Fields]) ->
    [{record_field, Aa, {atom, Aa, A}, Expr} | record_fields(Fields)];
record_fields([{typed, Expr, TypeInfo} | Fields]) ->
    [Field] = record_fields([Expr]),
    [{typed_record_field, Field, TypeInfo} | record_fields(Fields)];
record_fields([Other | _Fields]) ->
    ret_abstr_err(Other, "bad record field");
record_fields([]) ->
    [].

term(Expr) ->
    try
        normalise(Expr)
    catch
        _:_R -> ret_abstr_err(Expr, "bad attribute")
    end.

%% build_function([Clause]) -> {function,Anno,Name,Arity,[Clause]}

build_function(Cs) ->
    Name = element(3, hd(Cs)),
    Arity = length(element(4, hd(Cs))),
    {function, ?anno(hd(Cs), lists:last(Cs)), Name, Arity, check_clauses(Cs, Name, Arity)}.

%% build_fun(Anno, [Clause]) -> {'fun',Anno,{clauses,[Clause]}}.

build_fun(Anno, Cs) ->
    Name = element(3, hd(Cs)),
    Arity = length(element(4, hd(Cs))),
    CheckedCs = check_clauses(Cs, Name, Arity),
    case Name of
        'fun' ->
            {'fun', Anno, {clauses, CheckedCs}};
        Name ->
            {named_fun, Anno, Name, CheckedCs}
    end.

check_clauses(Cs, Name, Arity) ->
    [
        case C of
            {clause, A, N, As, G, B} when N =:= Name, length(As) =:= Arity ->
                {clause, A, As, G, B};
            {clause, A, _N, _As, _G, _B} ->
                ret_err(A, "head mismatch")
        end
     || C <- Cs
    ].

build_try(Try, Es, Scs, {Ccs, As, End}) ->
    {'try', ?anno(Try, End), Es, Scs, Ccs, As}.

-spec ret_err(_, _) -> no_return().
ret_err(Anno, S) ->
    return_error(Anno, S).

-spec ret_abstr_err(_, _) -> no_return().
ret_abstr_err(Abstract, S) ->
    return_error(?anno(Abstract), S).

%%  Convert between the abstract form of a term and a term.

-spec normalise(AbsTerm) -> Data when
    AbsTerm :: abstract_expr(),
    Data :: term().
normalise({char, _, C}) ->
    C;
normalise({integer, _, I}) ->
    I;
normalise({float, _, F}) ->
    F;
normalise({atom, _, A}) ->
    A;
normalise({string, _, S}) ->
    S;
normalise({nil, _}) ->
    [];
normalise({bin, _, Fs}) ->
    {value, B, _} =
        eval_bits:expr_grp(
            Fs,
            [],
            fun(E, _) ->
                {value, normalise(E), []}
            end
        ),
    B;
normalise({cons, _, Head, Tail}) ->
    [normalise(Head) | normalise(Tail)];
normalise({tuple, _, Args}) ->
    list_to_tuple(normalise_list(Args));
normalise({map, _, Pairs} = M) ->
    maps:from_list(
        lists:map(
            fun
                %% only allow '=>'
                ({map_field_assoc, _, K, V}) -> {normalise(K), normalise(V)};
                (_) -> erlang:error({badarg, M})
            end,
            Pairs
        )
    );
normalise({'fun', _, {function, {atom, _, M}, {atom, _, F}, {integer, _, A}}}) ->
    fun M:F/A;
%% Special case for unary +/-.
normalise({op, _, '+', {char, _, I}}) ->
    I;
normalise({op, _, '+', {integer, _, I}}) ->
    I;
normalise({op, _, '+', {float, _, F}}) ->
    F;
%Weird, but compatible!
normalise({op, _, '-', {char, _, I}}) ->
    -I;
normalise({op, _, '-', {integer, _, I}}) ->
    -I;
normalise({op, _, '-', {float, _, F}}) ->
    -F;
normalise(X) ->
    erlang:error({badarg, X}).

normalise_list([H | T]) ->
    [normalise(H) | normalise_list(T)];
normalise_list([]) ->
    [].

-spec abstract(Data) -> AbsTerm when
    Data :: term(),
    AbsTerm :: abstract_expr().
abstract(T) ->
    Anno = erl_anno:new(0),
    abstract(T, Anno, enc_func(epp:default_encoding())).

-type encoding_func() :: fun((non_neg_integer()) -> boolean()).

%%% abstract/2 takes line and encoding options
-spec abstract(Data, Options) -> AbsTerm when
    Data :: term(),
    Options :: Line | [Option],
    Option ::
        {encoding, Encoding}
        | {line, Line}
        | {location, Location},
    Encoding :: 'latin1' | 'unicode' | 'utf8' | 'none' | encoding_func(),
    Line :: erl_anno:line(),
    Location :: erl_anno:location(),
    AbsTerm :: abstract_expr().

abstract(T, Line) when is_integer(Line) ->
    Anno = erl_anno:new(Line),
    abstract(T, Anno, enc_func(epp:default_encoding()));
abstract(T, {SByte, EByte}) when is_integer(SByte), is_integer(EByte) ->
    abstract(T, {SByte, EByte}, enc_func(epp:default_encoding()));
abstract(T, Options) when is_list(Options) ->
    Encoding = proplists:get_value(encoding, Options, epp:default_encoding()),
    EncFunc = enc_func(Encoding),
    Location =
        case proplists:get_value(location, Options) of
            undefined ->
                proplists:get_value(line, Options, 0);
            Loc ->
                Loc
        end,
    Anno = erl_anno:new(Location),
    abstract(T, Anno, EncFunc).

-define(UNICODE(C),
    (C < 16#D800 orelse
        C > 16#DFFF andalso C < 16#FFFE orelse
        C > 16#FFFF andalso C =< 16#10FFFF)
).

enc_func(latin1) -> fun(C) -> C < 256 end;
enc_func(unicode) -> fun(C) -> ?UNICODE(C) end;
enc_func(utf8) -> fun(C) -> ?UNICODE(C) end;
enc_func(none) -> none;
enc_func(Fun) when is_function(Fun, 1) -> Fun;
enc_func(Term) -> erlang:error({badarg, Term}).

abstract(T, A, _E) when is_integer(T) -> {integer, A, T};
abstract(T, A, _E) when is_float(T) -> {float, A, T};
abstract(T, A, _E) when is_atom(T) -> {atom, A, T};
abstract([], A, _E) ->
    {nil, A};
abstract(B, A, _E) when is_bitstring(B) ->
    {bin, A, [abstract_byte(Byte, A) || Byte <- bitstring_to_list(B)]};
abstract([H | T], A, none = E) ->
    {cons, A, abstract(H, A, E), abstract(T, A, E)};
abstract(List, A, E) when is_list(List) ->
    abstract_list(List, [], A, E);
abstract(Tuple, A, E) when is_tuple(Tuple) ->
    {tuple, A, abstract_tuple_list(tuple_to_list(Tuple), A, E)};
abstract(Map, A, E) when is_map(Map) ->
    {map, A, abstract_map_fields(maps:to_list(Map), A, E)};
abstract(Fun, A, E) when is_function(Fun) ->
    case erlang:fun_info(Fun, type) of
        {type, external} ->
            Info = erlang:fun_info(Fun),
            {module, M} = lists:keyfind(module, 1, Info),
            {name, F} = lists:keyfind(name, 1, Info),
            {arity, Arity} = lists:keyfind(arity, 1, Info),
            {'fun', A, {function, abstract(M, A, E), abstract(F, A, E), abstract(Arity, A, E)}}
    end.

abstract_list([H | T], String, A, E) ->
    case is_integer(H) andalso H >= 0 andalso E(H) of
        true ->
            abstract_list(T, [H | String], A, E);
        false ->
            AbstrList = {cons, A, abstract(H, A, E), abstract(T, A, E)},
            not_string(String, AbstrList, A, E)
    end;
abstract_list([], String, A, _E) ->
    {string, A, lists:reverse(String)};
abstract_list(T, String, A, E) ->
    not_string(String, abstract(T, A, E), A, E).

not_string([C | T], Result, A, E) ->
    not_string(T, {cons, A, {integer, A, C}, Result}, A, E);
not_string([], Result, _A, _E) ->
    Result.

abstract_tuple_list([H | T], A, E) ->
    [abstract(H, A, E) | abstract_tuple_list(T, A, E)];
abstract_tuple_list([], _A, _E) ->
    [].

abstract_map_fields(Fs, A, E) ->
    [{map_field_assoc, A, abstract(K, A, E), abstract(V, A, E)} || {K, V} <- Fs].

abstract_byte(Byte, A) when is_integer(Byte) ->
    {bin_element, A, {integer, A, Byte}, default, default};
abstract_byte(Bits, A) ->
    Sz = bit_size(Bits),
    <<Val:Sz>> = Bits,
    {bin_element, A, {integer, A, Val}, {integer, A, Sz}, default}.

%%  Generate a list of tokens representing the abstract term.

-spec tokens(AbsTerm) -> Tokens when
    AbsTerm :: abstract_expr(),
    Tokens :: [token()].
tokens(Abs) ->
    tokens(Abs, []).

-spec tokens(AbsTerm, MoreTokens) -> Tokens when
    AbsTerm :: abstract_expr(),
    MoreTokens :: [token()],
    Tokens :: [token()].
tokens({char, A, C}, More) ->
    [{char, A, C} | More];
tokens({integer, A, N}, More) ->
    [{integer, A, N} | More];
tokens({float, A, F}, More) ->
    [{float, A, F} | More];
tokens({atom, Aa, A}, More) ->
    [{atom, Aa, A} | More];
tokens({var, A, V}, More) ->
    [{var, A, V} | More];
tokens({string, A, S}, More) ->
    [{string, A, S} | More];
tokens({nil, A}, More) ->
    [{'[', A}, {']', A} | More];
tokens({cons, A, Head, Tail}, More) ->
    [{'[', A} | tokens(Head, tokens_tail(Tail, More))];
tokens({tuple, A, []}, More) ->
    [{'{', A}, {'}', A} | More];
tokens({tuple, A, [E | Es]}, More) ->
    [{'{', A} | tokens(E, tokens_tuple(Es, ?anno(E), More))];
tokens({map, A, []}, More) ->
    [{'#', A}, {'{', A}, {'}', A} | More];
tokens({map, A, [P | Ps]}, More) ->
    [{'#', A}, {'{', A} | tokens(P, tokens_tuple(Ps, ?anno(P), More))];
tokens({map_field_assoc, A, K, V}, More) ->
    tokens(K, [{'=>', A} | tokens(V, More)]).

tokens_tail({cons, A, Head, Tail}, More) ->
    [{',', A} | tokens(Head, tokens_tail(Tail, More))];
tokens_tail({nil, A}, More) ->
    [{']', A} | More];
tokens_tail(Other, More) ->
    A = ?anno(Other),
    [{'|', A} | tokens(Other, [{']', A} | More])].

tokens_tuple([E | Es], Anno, More) ->
    [{',', Anno} | tokens(E, tokens_tuple(Es, ?anno(E), More))];
tokens_tuple([], Anno, More) ->
    [{'}', Anno} | More].

%% Give the relative precedences of operators.

inop_prec('=') -> {150, 100, 100};
inop_prec('!') -> {150, 100, 100};
inop_prec('orelse') -> {160, 150, 150};
inop_prec('andalso') -> {200, 160, 160};
inop_prec('==') -> {300, 200, 300};
inop_prec('/=') -> {300, 200, 300};
inop_prec('=<') -> {300, 200, 300};
inop_prec('<') -> {300, 200, 300};
inop_prec('>=') -> {300, 200, 300};
inop_prec('>') -> {300, 200, 300};
inop_prec('=:=') -> {300, 200, 300};
inop_prec('=/=') -> {300, 200, 300};
inop_prec('++') -> {400, 300, 300};
inop_prec('--') -> {400, 300, 300};
inop_prec('+') -> {400, 400, 500};
inop_prec('-') -> {400, 400, 500};
inop_prec('bor') -> {400, 400, 500};
inop_prec('bxor') -> {400, 400, 500};
inop_prec('bsl') -> {400, 400, 500};
inop_prec('bsr') -> {400, 400, 500};
inop_prec('or') -> {400, 400, 500};
inop_prec('xor') -> {400, 400, 500};
inop_prec('*') -> {500, 500, 600};
inop_prec('/') -> {500, 500, 600};
inop_prec('div') -> {500, 500, 600};
inop_prec('rem') -> {500, 500, 600};
inop_prec('band') -> {500, 500, 600};
inop_prec('and') -> {500, 500, 600};
inop_prec('#') -> {800, 700, 800};
inop_prec(':') -> {900, 800, 900};
inop_prec('.') -> {900, 900, 1000}.

-type pre_op() :: 'catch' | '+' | '-' | 'bnot' | 'not' | '#'.

-spec preop_prec(pre_op()) -> {0 | 600 | 700, 100 | 700 | 800}.

preop_prec('catch') -> {0, 100};
preop_prec('+') -> {600, 700};
preop_prec('-') -> {600, 700};
preop_prec('bnot') -> {600, 700};
preop_prec('not') -> {600, 700};
preop_prec('#') -> {700, 800}.

-spec func_prec() -> {800, 700}.

func_prec() -> {800, 700}.

-spec max_prec() -> 900.

max_prec() -> 900.

-type prec() :: non_neg_integer().

-type type_inop() ::
    '::'
    | '|'
    | '..'
    | '+'
    | '-'
    | 'bor'
    | 'bxor'
    | 'bsl'
    | 'bsr'
    | '*'
    | '/'
    | 'div'
    | 'rem'
    | 'band'.

-type type_preop() :: '+' | '-' | 'bnot' | '#'.

-spec type_inop_prec(type_inop()) -> {prec(), prec(), prec()}.

type_inop_prec('=') -> {150, 100, 100};
type_inop_prec('::') -> {150, 150, 160};
type_inop_prec('|') -> {180, 170, 170};
type_inop_prec('..') -> {300, 200, 300};
type_inop_prec('+') -> {400, 400, 500};
type_inop_prec('-') -> {400, 400, 500};
type_inop_prec('bor') -> {400, 400, 500};
type_inop_prec('bxor') -> {400, 400, 500};
type_inop_prec('bsl') -> {400, 400, 500};
type_inop_prec('bsr') -> {400, 400, 500};
type_inop_prec('*') -> {500, 500, 600};
type_inop_prec('/') -> {500, 500, 600};
type_inop_prec('div') -> {500, 500, 600};
type_inop_prec('rem') -> {500, 500, 600};
type_inop_prec('band') -> {500, 500, 600};
type_inop_prec('#') -> {800, 700, 800}.

-spec type_preop_prec(type_preop()) -> {prec(), prec()}.

type_preop_prec('+') -> {600, 700};
type_preop_prec('-') -> {600, 700};
type_preop_prec('bnot') -> {600, 700};
type_preop_prec('#') -> {700, 800}.

-type erl_parse_tree() ::
    abstract_clause()
    | abstract_expr()
    | abstract_form()
    | abstract_type().

-spec map_anno(Fun, Abstr) -> NewAbstr when
    Fun :: fun((Anno) -> NewAnno),
    Anno :: erl_anno:anno(),
    NewAnno :: erl_anno:anno(),
    Abstr :: erl_parse_tree() | form_info(),
    NewAbstr :: erl_parse_tree() | form_info().

map_anno(F0, Abstr) ->
    F = fun(A, Acc) -> {F0(A), Acc} end,
    {NewAbstr, []} = modify_anno1(Abstr, [], F),
    NewAbstr.

-spec fold_anno(Fun, Acc0, Abstr) -> Acc1 when
    Fun :: fun((Anno, AccIn) -> AccOut),
    Anno :: erl_anno:anno(),
    Acc0 :: term(),
    Acc1 :: term(),
    AccIn :: term(),
    AccOut :: term(),
    Abstr :: erl_parse_tree() | form_info().

fold_anno(F0, Acc0, Abstr) ->
    F = fun(A, Acc) -> {A, F0(A, Acc)} end,
    {_, NewAcc} = modify_anno1(Abstr, Acc0, F),
    NewAcc.

-spec mapfold_anno(Fun, Acc0, Abstr) -> {NewAbstr, Acc1} when
    Fun :: fun((Anno, AccIn) -> {NewAnno, AccOut}),
    Anno :: erl_anno:anno(),
    NewAnno :: erl_anno:anno(),
    Acc0 :: term(),
    Acc1 :: term(),
    AccIn :: term(),
    AccOut :: term(),
    Abstr :: erl_parse_tree() | form_info(),
    NewAbstr :: erl_parse_tree() | form_info().

mapfold_anno(F, Acc0, Abstr) ->
    modify_anno1(Abstr, Acc0, F).

-spec new_anno(Term) -> Abstr when
    Term :: term(),
    Abstr :: erl_parse_tree() | form_info().

new_anno(Term) ->
    F = fun(L, Acc) -> {erl_anno:new(L), Acc} end,
    {NewAbstr, []} = modify_anno1(Term, [], F),
    NewAbstr.

-spec anno_to_term(Abstr) -> term() when
    Abstr :: erl_parse_tree() | form_info().

anno_to_term(Abstract) ->
    F = fun(Anno, Acc) -> {erl_anno:to_term(Anno), Acc} end,
    {NewAbstract, []} = modify_anno1(Abstract, [], F),
    NewAbstract.

-spec anno_from_term(Term) -> erl_parse_tree() | form_info() when
    Term :: term().

anno_from_term(Term) ->
    F = fun(T, Acc) -> {erl_anno:from_term(T), Acc} end,
    {NewTerm, []} = modify_anno1(Term, [], F),
    NewTerm.

%% Forms.
modify_anno1({function, F, A}, Ac, _Mf) ->
    {{function, F, A}, Ac};
modify_anno1({function, M, F, A}, Ac, Mf) ->
    {M1, Ac1} = modify_anno1(M, Ac, Mf),
    {F1, Ac2} = modify_anno1(F, Ac1, Mf),
    {A1, Ac3} = modify_anno1(A, Ac2, Mf),
    {{function, M1, F1, A1}, Ac3};
modify_anno1({attribute, A, record, {Name, Fields}}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {Fields1, Ac2} = modify_anno1(Fields, Ac1, Mf),
    {{attribute, A1, record, {Name, Fields1}}, Ac2};
modify_anno1({attribute, A, spec, {Fun, Types}}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {Types1, Ac2} = modify_anno1(Types, Ac1, Mf),
    {{attribute, A1, spec, {Fun, Types1}}, Ac2};
modify_anno1({attribute, A, callback, {Fun, Types}}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {Types1, Ac2} = modify_anno1(Types, Ac1, Mf),
    {{attribute, A1, callback, {Fun, Types1}}, Ac2};
modify_anno1({attribute, A, type, {TypeName, TypeDef, Args}}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {TypeDef1, Ac2} = modify_anno1(TypeDef, Ac1, Mf),
    {Args1, Ac3} = modify_anno1(Args, Ac2, Mf),
    {{attribute, A1, type, {TypeName, TypeDef1, Args1}}, Ac3};
modify_anno1({attribute, A, opaque, {TypeName, TypeDef, Args}}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {TypeDef1, Ac2} = modify_anno1(TypeDef, Ac1, Mf),
    {Args1, Ac3} = modify_anno1(Args, Ac2, Mf),
    {{attribute, A1, opaque, {TypeName, TypeDef1, Args1}}, Ac3};
modify_anno1({attribute, A, Attr, Val}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {{attribute, A1, Attr, Val}, Ac1};
modify_anno1({warning, W}, Ac, _Mf) ->
    {{warning, W}, Ac};
modify_anno1({error, W}, Ac, _Mf) ->
    {{error, W}, Ac};
modify_anno1({eof, L}, Ac, _Mf) ->
    {{eof, L}, Ac};
%% Expressions.
modify_anno1({clauses, Cs}, Ac, Mf) ->
    {Cs1, Ac1} = modify_anno1(Cs, Ac, Mf),
    {{clauses, Cs1}, Ac1};
modify_anno1({typed_record_field, Field, Type}, Ac, Mf) ->
    {Field1, Ac1} = modify_anno1(Field, Ac, Mf),
    {Type1, Ac2} = modify_anno1(Type, Ac1, Mf),
    {{typed_record_field, Field1, Type1}, Ac2};
modify_anno1({Tag, A}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {{Tag, A1}, Ac1};
modify_anno1({Tag, A, E1}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {E11, Ac2} = modify_anno1(E1, Ac1, Mf),
    {{Tag, A1, E11}, Ac2};
modify_anno1({Tag, A, E1, E2}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {E11, Ac2} = modify_anno1(E1, Ac1, Mf),
    {E21, Ac3} = modify_anno1(E2, Ac2, Mf),
    {{Tag, A1, E11, E21}, Ac3};
modify_anno1({bin_element, A, E1, E2, TSL}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {E11, Ac2} = modify_anno1(E1, Ac1, Mf),
    {E21, Ac3} = modify_anno1(E2, Ac2, Mf),
    {{bin_element, A1, E11, E21, TSL}, Ac3};
modify_anno1({Tag, A, E1, E2, E3}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {E11, Ac2} = modify_anno1(E1, Ac1, Mf),
    {E21, Ac3} = modify_anno1(E2, Ac2, Mf),
    {E31, Ac4} = modify_anno1(E3, Ac3, Mf),
    {{Tag, A1, E11, E21, E31}, Ac4};
modify_anno1({Tag, A, E1, E2, E3, E4}, Ac, Mf) ->
    {A1, Ac1} = Mf(A, Ac),
    {E11, Ac2} = modify_anno1(E1, Ac1, Mf),
    {E21, Ac3} = modify_anno1(E2, Ac2, Mf),
    {E31, Ac4} = modify_anno1(E3, Ac3, Mf),
    {E41, Ac5} = modify_anno1(E4, Ac4, Mf),
    {{Tag, A1, E11, E21, E31, E41}, Ac5};
modify_anno1([H | T], Ac, Mf) ->
    {H1, Ac1} = modify_anno1(H, Ac, Mf),
    {T1, Ac2} = modify_anno1(T, Ac1, Mf),
    {[H1 | T1], Ac2};
modify_anno1([], Ac, _Mf) ->
    {[], Ac};
modify_anno1(E, Ac, _Mf) when not is_tuple(E), not is_list(E) -> {E, Ac}.

anno(First, Last) -> ?anno(First, Last).

%% vim: ft=erlang