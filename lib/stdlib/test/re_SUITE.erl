%%
%% %CopyrightBegin%
%%
%% SPDX-License-Identifier: Apache-2.0
%%
%% Copyright Ericsson AB 2008-2025. All Rights Reserved.
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
-module(re_SUITE).

-export([all/0, suite/0,groups/0,init_per_suite/1, end_per_suite/1, 
	 init_per_group/2,end_per_group/2, pcre2/1,compile_options/1,
         old_pcre1/1,
         pcre2_incompat/1,
	 run_options/1,combined_options/1,replace_autogen/1,
	 global_capture/1,replace_input_types/1,replace_with_fun/1,replace_return/1,
	 split_autogen/1,split_options/1,split_specials/1,
	 error_handling/1,pcre_cve_2008_2371/1,re_version/1,
	 pcre_compile_workspace_overflow/1,re_infinite_loop/1, 
	 re_backwards_accented/1,opt_dupnames/1,opt_all_names/1,inspect/1,
	 opt_no_start_optimize/1,opt_never_utf/1,opt_ucp/1,
	 match_limit/1,sub_binaries/1,copt/1,global_unicode_validation/1,
         yield_on_subject_validation/1, bad_utf8_subject/1,
         error_info/1, subject_is_sub_binary/1, pattern_is_sub_binary/1,

         last_test/1]).

-include_lib("common_test/include/ct.hrl").
-include_lib("kernel/include/file.hrl").

suite() ->
    [{ct_hooks,[ts_install_cth]},
     {timetrap,{minutes,3}}].

all() -> 
    [pcre2, compile_options, run_options, combined_options,
     old_pcre1,
     pcre2_incompat,
     replace_autogen, global_capture, replace_input_types,
     replace_with_fun, replace_return, split_autogen, split_options,
     split_specials, error_handling, pcre_cve_2008_2371,
     pcre_compile_workspace_overflow, re_infinite_loop, 
     re_backwards_accented, opt_dupnames, opt_all_names, 
     inspect, opt_no_start_optimize,opt_never_utf,opt_ucp,
     match_limit, sub_binaries, re_version, global_unicode_validation,
     yield_on_subject_validation, bad_utf8_subject,
     error_info, subject_is_sub_binary, pattern_is_sub_binary,

     last_test].

groups() -> 
    [].

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, Config) ->
    Config.


%% Run all applicable tests from the PCRE2 testsuites.
pcre2(Config) when is_list(Config) ->
    RootDir = proplists:get_value(data_dir, Config),
    Res = run_pcre_tests:test(RootDir),
    0 = lists:sum([ X || {X,_,_} <- Res ]),
    {comment,Res}.

%% Run tests from the old PCRE testsuites.
old_pcre1(Config) when is_list(Config) ->
    RootDir = proplists:get_value(data_dir, Config),
    Res = run_old_pcre1_tests:test(RootDir),
    0 = lists:sum([ X || {X,_,_} <- Res ]),
    {comment,Res}.

%% Test all documented compile options.
compile_options(Config) when is_list(Config) ->
    ok = ctest("ABDabcdABCD","abcd",[],true,{match,[{3,4}]}),
    ok = ctest("ABDabcdABCD","abcd",[anchored],true,nomatch),
    ok = ctest("ABDabcdABCD",".*abcd",[anchored],true,{match,[{0,7}]}),
    ok = ctest("ABCabcdABC","ABCD",[],true,nomatch),
    ok = ctest("ABCabcdABC","ABCD",[caseless],true,{match,[{3,4}]}),
    ok = ctest("abcdABC\n","ABC$",[],true,{match,[{4,3}]}),
    ok = ctest("abcdABC\n","ABC$",[dollar_endonly],true,nomatch),
    ok = ctest("abcdABC\n","ABC.",[],true,nomatch),
    ok = ctest("abcdABC\n","ABC.",[dotall],true,{match,[{4,4}]}),
    ok = ctest("abcdABCD","ABC .",[],true,nomatch),
    ok = ctest("abcdABCD","ABC .",[extended],true,{match,[{4,4}]}),
    ok = ctest("abcd\nABCD","ABC",[],true,{match,[{5,3}]}),
    ok = ctest("abcd\nABCD","ABC",[firstline],true,nomatch),
    ok = ctest("abcd\nABCD","^ABC",[],true,nomatch),
    ok = ctest("abcd\nABCD","^ABC",[multiline],true,{match,[{5,3}]}),
    ok = ctest("abcdABCD","(ABC)",[],true,{match,[{4,3},{4,3}]}),
    ok = ctest("abcdABCD","(ABC)",[no_auto_capture],true,{match,[{4,3}]}),
    ok = ctest(notused,"(?<FOO>ABC)|(?<FOO>DEF)",[],false,notused),
    ok = ctest("abcdABCD","(?<FOO>ABC)|(?<FOO>DEF)",[dupnames],true,{match,[{4,3},{4,3}]}),
    ok = ctest("abcdABCDabcABCD","abcd.*D",[],true,{match,[{0,15}]}),
    ok = ctest("abcdABCDabcABCD","abcd.*D",[ungreedy],true,{match,[{0,8}]}),
    ok = ctest("abcdABCabcABC\nD","abcd.*D",[],true,nomatch),
    ok = ctest("abcdABCabcABC\nD","abcd.*D",[{newline,cr}],true,{match,[{0,15}]}),
    ok = ctest("abcdABCabcABC\rD","abcd.*D",[],true,{match,[{0,15}]}),
    ok = ctest("abcdABCabcABC\rD","abcd.*D",[{newline,lf}],true,{match,[{0,15}]}),
    ok = ctest("abcdABCabcd\r\n","abcd$",[{newline,lf}],true,nomatch),
    ok = ctest("abcdABCabcd\r\n","abcd$",[{newline,cr}],true,nomatch),
    ok = ctest("abcdABCabcd\r\n","abcd$",[{newline,crlf}],true,{match,[{7,4}]}),

    ok = ctest("abcdABCabcd\r","abcd$",[{newline,crlf}],true,nomatch),
    ok = ctest("abcdABCabcd\n","abcd$",[{newline,crlf}],true,nomatch),
    ok = ctest("abcdABCabcd\r\n","abcd$",[{newline,anycrlf}],true,{match,[{7,4}]}),

    ok = ctest("abcdABCabcd\r","abcd$",[{newline,anycrlf}],true,{match,[{7,4}]}),
    ok = ctest("abcdABCabcd\n","abcd$",[{newline,anycrlf}],true,{match,[{7,4}]}),
    ok.

%% Test all documented run specific options.
run_options(Config) when is_list(Config) ->
    rtest("ABCabcdABC","abc",[],[], match),
    rtest("ABCabcdABC","abc",[anchored],[], nomatch),
    %% Anchored in run overrides unanchored in compilation
    rtest("ABCabcdABC","abc",[],[anchored], nomatch),

    rtest("","a?b?",[],[], match),
    rtest("","a?b?",[],[notempty], nomatch),

    rtest("abc","^a",[],[], match),
    rtest("abc","^a",[],[notbol], nomatch),
    rtest("ab\nc","^a",[multiline],[], match),
    rtest("ab\nc","^a",[multiline],[notbol], nomatch),
    rtest("ab\nc","^c",[multiline],[notbol], match),

    rtest("abc","c$",[],[], match),
    rtest("abc","c$",[],[noteol], nomatch),

    rtest("ab\nc","b$",[multiline],[], match),
    rtest("ab\nc","c$",[multiline],[], match),
    rtest("ab\nc","b$",[multiline],[noteol], match),
    rtest("ab\nc","c$",[multiline],[noteol], nomatch),

    rtest("abc","ab",[],[{offset,0}], match),
    rtest("abc","ab",[],[{offset,1}], nomatch),

    rtest("abcdABCabcABC\nD","abcd.*D",[],[], nomatch),
    rtest("abcdABCabcABC\rD","abcd.*D",[],[], match),
    rtest("abcdABCabcd\r\n","abcd$",[],[{newline,lf}], nomatch),

    {ok,MP} = re:compile(".*(abcd).*"),
    {match,[{0,10},{3,4}]} = re:run("ABCabcdABC",MP,[]),
    {match,[{0,10},{3,4}]} = re:run("ABCabcdABC",MP,[{capture,all}]),
    {match,[{0,10},{3,4}]} = re:run("ABCabcdABC",MP,[{capture,all,index}]),
    {match,["ABCabcdABC","abcd"]} = re:run("ABCabcdABC",MP,[{capture,all,list}]),
    {match,[<<"ABCabcdABC">>,<<"abcd">>]} = re:run("ABCabcdABC",MP,[{capture,all,binary}]),
    {match,[{0,10}]} = re:run("ABCabcdABC",MP,[{capture,first}]),
    {match,[{0,10}]} = re:run("ABCabcdABC",MP,[{capture,first,index}]),       {match,["ABCabcdABC"]} = re:run("ABCabcdABC",MP,[{capture,first,list}]),
    {match,[<<"ABCabcdABC">>]} = re:run("ABCabcdABC",MP,[{capture,first,binary}]),

    {match,[{3,4}]} = re:run("ABCabcdABC",MP,[{capture,all_but_first}]),
    {match,[{3,4}]} = re:run("ABCabcdABC",MP,[{capture,all_but_first,index}]),
    {match,["abcd"]} = re:run("ABCabcdABC",MP,[{capture,all_but_first,list}]),
    {match,[<<"abcd">>]} = re:run("ABCabcdABC",MP,[{capture,all_but_first,binary}]),

    match = re:run("ABCabcdABC",MP,[{capture,none}]),
    match = re:run("ABCabcdABC",MP,[{capture,none,index}]),
    match = re:run("ABCabcdABC",MP,[{capture,none,list}]),
    match = re:run("ABCabcdABC",MP,[{capture,none,binary}]),

    {ok,MP2} = re:compile(".*(?<FOO>abcd).*"),
    {match,[{3,4}]} = re:run("ABCabcdABC",MP2,[{capture,[1]}]),
    {match,[{3,4}]} = re:run("ABCabcdABC",MP2,[{capture,['FOO']}]),
    {match,[{3,4}]} = re:run("ABCabcdABC",MP2,[{capture,["FOO"]}]),
    {match,["abcd"]} = re:run("ABCabcdABC",MP2,[{capture,["FOO"],list}]),
    {match,[<<"abcd">>]} = re:run("ABCabcdABC",MP2,[{capture,["FOO"],binary}]),

    {match,[{-1,0}]} = re:run("ABCabcdABC",MP2,[{capture,[200]}]),
    {match,[{-1,0}]} = re:run("ABCabcdABC",MP2,[{capture,['BAR']}]),
    {match,[""]} = re:run("ABCabcdABC",MP2,[{capture,[200],list}]),
    {match,[""]} = re:run("ABCabcdABC",MP2,[{capture,['BAR'],list}]),
    {match,[<<>>]} = re:run("ABCabcdABC",MP2,[{capture,[200],binary}]),
    {match,[<<>>]} = re:run("ABCabcdABC",MP2,[{capture,['BAR'],binary}]),

    {ok, MP3} = re:compile(".*((?<FOO>abdd)|a(..d)).*"),
    {match,[{0,10},{3,4},{-1,0},{4,3}]} = re:run("ABCabcdABC",MP3,[]),
    {match,[{0,10},{3,4},{-1,0},{4,3}]} = re:run("ABCabcdABC",MP3,[{capture,all,index}]),
    {match,[<<"ABCabcdABC">>,<<"abcd">>,<<>>,<<"bcd">>]} = re:run("ABCabcdABC",MP3,[{capture,all,binary}]),
    {match,["ABCabcdABC","abcd",[],"bcd"]} = re:run("ABCabcdABC",MP3,[{capture,all,list}]),
    ok.


pcre2_incompat(Config) when is_list(Config) ->
    %% Not allowed to pass changed newline option to re:run/3
    rtest("abcdABCabcABC\nD", "abcd.*D", [], [{newline,cr}],  badarg),
    rtest("abcdABCabcd\r\n", "abcd$", [], [{newline,crlf}],  badarg),
    rtest("abcdABCabcd\r\n", "abcd$", [], [{newline,anycrlf}],  badarg),
    rtest("abcdABCabcd\r", "abcd$", [], [{newline,any}],  badarg),

    [rtest("abcdABCabcd\r", "abcd$", [{newline,C}], [{newline,R}],  badarg)
     || C <- [lf, cr, crlf, anycrlf, any],
        R <- [lf, cr, crlf, anycrlf, any],
        C =/= R],

    %% But we do allowed to pass an unchanged newline option to re:run/3
    rtest("abcdABCabcABC\rD", "abcd.*D", [], [{newline,lf}],  match),

    [rtest("abcABC", "abc", [{newline,NL}], [{newline,NL}],  match)
     || NL <- [lf, cr, crlf, anycrlf, any]],

    %% Not allowed to pass changed BSR option to re:run/3
    rtest("abcdABCabcABC\nD", "abcd.*D", [], [bsr_anycrlf],  badarg),
    rtest("abcdABCabcd\r", "abcd$", [bsr_unicode], [bsr_anycrlf], badarg),
    rtest("abcdABCabcd\r", "abcd$", [bsr_anycrlf], [bsr_unicode], badarg),

    %% But we do allowed an unchanged BSR option to re:run/3
    rtest("abcd\x{85}D", "abcd\\RD", [], [bsr_unicode],  match),
    rtest("abcd\x{85}D", "abcd\\RD", [bsr_unicode], [bsr_unicode],  match),
    rtest("abcd\r\nD", "abcd\\RD", [bsr_anycrlf], [bsr_anycrlf],  match),
    ok.

%% Test the version is returned correctly
re_version(_Config) ->
    Version = re:version(),
    {match,[Version]} = re:run(Version,
                               ~B"^\d{2}\.\d{2} 20\d{2}-\d{2}-\d{2}",
                               [{capture,all,binary}]),
    ok.

global_unicode_validation(Config) when is_list(Config) ->
    %% Test that unicode validation of the subject is not done
    %% for every match found...
    Bin = binary:copy(<<"abc\n">>,100000),
    {TimeAscii, _} = take_time(fun () ->
                                       re:run(Bin, <<"b">>, [global])
                               end),
    {TimeUnicode, _} = take_time(fun () ->
                                         re:run(Bin, <<"b">>, [unicode,global])
                                 end),
    if TimeAscii == 0; TimeUnicode == 0 ->
            {comment, "Not good enough resolution to compare results"};
       true ->
            %% The time the operations takes should be in the
            %% same order of magnitude. If validation of the
            %% whole subject occurs for every match, the unicode
            %% variant will take way longer time...
            true = TimeUnicode div TimeAscii < 10
    end.

take_time(Fun) ->
    Start = erlang:monotonic_time(nanosecond),
    Res = Fun(),
    End = erlang:monotonic_time(nanosecond),
    {End-Start, Res}.

yield_on_subject_validation(Config) when is_list(Config) ->
    Go = make_ref(),
    Bin = binary:copy(<<"abc\n">>,100000),
    {P, M} = spawn_opt(fun () ->
                               receive Go -> ok end,
                               {match,[{1,1}]} = re:run(Bin, <<"b">>, [unicode])
                       end,
                       [link, monitor]),
    1 = erlang:trace(P, true, [running]),
    P ! Go,
    N = count_re_run_trap_out(P, M),
    true = N >= 5,
    ok.

count_re_run_trap_out(P, M) when is_reference(M) ->
    receive {'DOWN',M,process,P,normal} -> ok end,
    TD = erlang:trace_delivered(P),
    receive {trace_delivered, P, TD} -> ok end,
    count_re_run_trap_out(P, 0);
count_re_run_trap_out(P, N) when is_integer(N) ->
    receive
        {trace,P,out,{erlang,re_run_trap,3}} ->
            count_re_run_trap_out(P, N+1)
    after 0 ->
            N
    end.

%% Test compile options given directly to run.
combined_options(Config) when is_list(Config) ->
    ok = crtest("ABDabcdABCD","abcd",[],true,{match,[{3,4}]}),
    ok = crtest("ABDabcdABCD","abcd",[anchored],true,nomatch),
    ok = crtest("ABDabcdABCD",".*abcd",[anchored],true,{match,[{0,7}]}),
    ok = crtest("ABCabcdABC","ABCD",[],true,nomatch),
    ok = crtest("ABCabcdABC","ABCD",[caseless],true,{match,[{3,4}]}),
    ok = crtest("abcdABC\n","ABC$",[],true,{match,[{4,3}]}),
    ok = crtest("abcdABC\n","ABC$",[dollar_endonly],true,nomatch),
    ok = crtest("abcdABC\n","ABC.",[],true,nomatch),
    ok = crtest("abcdABC\n","ABC.",[dotall],true,{match,[{4,4}]}),
    ok = crtest("abcdABCD","ABC .",[],true,nomatch),
    ok = crtest("abcdABCD","ABC .",[extended],true,{match,[{4,4}]}),
    ok = crtest("abcd\nABCD","ABC",[],true,{match,[{5,3}]}),
    ok = crtest("abcd\nABCD","ABC",[firstline],true,nomatch),
    ok = crtest("abcd\nABCD","^ABC",[],true,nomatch),
    ok = crtest("abcd\nABCD","^ABC",[multiline],true,{match,[{5,3}]}),
    ok = crtest("abcdABCD","(ABC)",[],true,{match,[{4,3},{4,3}]}),
    ok = crtest("abcdABCD","(ABC)",[no_auto_capture],true,{match,[{4,3}]}),
    ok = crtest(notused,"(?<FOO>ABC)|(?<FOO>DEF)",[],false,notused),
    ok = crtest("abcdABCD","(?<FOO>ABC)|(?<FOO>DEF)",[dupnames],true,{match,[{4,3},{4,3}]}),
    ok = crtest("abcdABCDabcABCD","abcd.*D",[],true,{match,[{0,15}]}),
    ok = crtest("abcdABCDabcABCD","abcd.*D",[ungreedy],true,{match,[{0,8}]}),
    ok = ctest("abcdABCabcABC\nD","abcd.*D",[],true,nomatch),
    ok = crtest("abcdABCabcABC\nD","abcd.*D",[{newline,cr}],true,{match,[{0,15}]}),
    ok = crtest("abcdABCabcABC\rD","abcd.*D",[],true,{match,[{0,15}]}),
    ok = crtest("abcdABCabcABC\rD","abcd.*D",[{newline,lf}],true,{match,[{0,15}]}),
    ok = crtest("abcdABCabcd\r\n","abcd$",[{newline,lf}],true,nomatch),
    ok = crtest("abcdABCabcd\r\n","abcd$",[{newline,cr}],true,nomatch),
    ok = crtest("abcdABCabcd\r\n","abcd$",[{newline,crlf}],true,{match,[{7,4}]}),

    ok = crtest("abcdABCabcd\r","abcd$",[{newline,crlf}],true,nomatch),
    ok = crtest("abcdABCabcd\n","abcd$",[{newline,crlf}],true,nomatch),
    ok = crtest("abcdABCabcd\r\n","abcd$",[{newline,anycrlf}],true,{match,[{7,4}]}),

    ok = crtest("abcdABCabcd\r","abcd$",[{newline,anycrlf}],true,{match,[{7,4}]}),
    ok = crtest("abcdABCabcd\n","abcd$",[{newline,anycrlf}],true,{match,[{7,4}]}),

    ok = crtest("abcdABCabcd\r\n","abcd$",[{newline,anycrlf},{capture,all,list}],true,{match,["abcd"]}),

    ok = crtest("abcdABCabcd\r","abcd$",[{newline,anycrlf},{capture,all,list}],true,{match,["abcd"]}),

    ok = crtest("abcdABCabcd\n","abcd$",[{newline,anycrlf},{capture,all,list}],true,{match,["abcd"]}),

    ok = crtest("abcdABCabcd\r\n","abcd$",[{newline,anycrlf},{capture,all,binary}],true,{match,[<<"abcd">>]}),

    ok = crtest("abcdABCabcd\r","abcd$",[{newline,anycrlf},{capture,all,binary}],true,{match,[<<"abcd">>]}),
    ok = crtest("abcdABCabcd\n","abcd$",[{newline,anycrlf},{capture,all,binary}],true,{match,[<<"abcd">>]}),

    %% Check that unique run-options fail in compile only case:
    {'EXIT',{badarg,_}} = (catch re:compile("abcd$",[{newline,anycrlf},{capture,all,binary}])),
    {'EXIT',{badarg,_}} = (catch re:compile("abcd$",[{newline,anycrlf},{offset,3}])),
    {'EXIT',{badarg,_}} = (catch re:compile("abcd$",[{newline,anycrlf},notempty])),
    {'EXIT',{badarg,_}} = (catch re:compile("abcd$",[{newline,anycrlf},notbol])),
    {'EXIT',{badarg,_}} = (catch re:compile("abcd$",[{newline,anycrlf},noteol])),


    {match,_} = re:run("abcdABCabcd\r\n","abcd$",[{newline,crlf}]),
    nomatch = re:run("abcdABCabcd\r\nefgh","abcd$",[{newline,crlf}]),
    {match,_} = re:run("abcdABCabcd\r\nefgh","abcd$",[{newline,crlf},multiline]),
    nomatch = re:run("abcdABCabcd\r\nefgh","efgh$",[{newline,crlf},multiline,noteol]),
    {match,_} = re:run("abcdABCabcd\r\nefgh","abcd$",[{newline,crlf},multiline,noteol]),
    {match,_} = re:run("abcdABCabcd\r\nefgh","^abcd",[{newline,crlf},multiline,noteol]),
    nomatch = re:run("abcdABCabcd\r\nefgh","^abcd",[{newline,crlf},multiline,notbol]),
    {match,_} = re:run("abcdABCabcd\r\nefgh","^efgh",[{newline,crlf},multiline,notbol]),
    {match,_} = re:run("ABC\nD","[a-z]*",[{newline,crlf}]),
    nomatch = re:run("ABC\nD","[a-z]*",[{newline,crlf},notempty]),
    ok.

%% Test replace with autogenerated erlang module.
replace_autogen(Config) when is_list(Config) ->
    re_testoutput1_replacement_test:run(),
    ok.

%% Test capture options together with global searching.
global_capture(Config) when is_list(Config) ->
    {match,[{3,4}]} = re:run("ABCabcdABC",".*(?<FOO>abcd).*",[{capture,[1]}]),
    {match,[{10,4}]} = re:run("ABCabcdABCabcdA",".*(?<FOO>abcd).*",[{capture,[1]}]),
    {match,[[{10,4}]]} = re:run("ABCabcdABCabcdA",".*(?<FOO>abcd).*",[global,{capture,[1]}]),
    {match,[{3,4}]} = re:run("ABCabcdABC",".*(?<FOO>abcd).*",[{capture,['FOO']}]),
    {match,[{10,4}]} = re:run("ABCabcdABCabcdA",".*(?<FOO>abcd).*",[{capture,['FOO']}]),
    {match,[[{10,4}]]} = re:run("ABCabcdABCabcdA",".*(?<FOO>abcd).*",[global,{capture,['FOO']}]),
    {match,[[{3,4},{3,4}],[{10,4},{10,4}]]} = re:run("ABCabcdABCabcdA","(?<FOO>abcd)",[global]),
    {match,[[{3,4},{3,4}],[{10,4},{10,4}]]} = re:run("ABCabcdABCabcdA","(?<FOO>abcd)",[global,{capture,all}]),
    {match,[[{3,4},{3,4}],[{10,4},{10,4}]]} = re:run("ABCabcdABCabcdA","(?<FOO>abcd)",[global,{capture,all,index}]),
    {match,[[{3,4}],[{10,4}]]} = re:run("ABCabcdABCabcdA","(?<FOO>abcd)",[global,{capture,first}]),
    {match,[[{3,4}],[{10,4}]]} = re:run("ABCabcdABCabcdA","(?<FOO>abcd)",[global,{capture,all_but_first}]),
    {match,[[<<"bcd">>],[<<"bcd">>]]} = re:run("ABCabcdABCabcdA","a(?<FOO>bcd)",[global,{capture,all_but_first,binary}]),
    {match,[["bcd"],["bcd"]]} = re:run("ABCabcdABCabcdA","a(?<FOO>bcd)",[global,{capture,all_but_first,list}]),
    {match,[["abcd","bcd"],["abcd","bcd"]]} = re:run("ABCabcdABCabcdA","a(?<FOO>bcd)",[global,{capture,all,list}]),
    {match,[[<<"abcd">>,<<"bcd">>],[<<"abcd">>,<<"bcd">>]]} = re:run("ABCabcdABCabcdA","a(?<FOO>bcd)",[global,{capture,all,binary}]),
    {match,[[{3,4},{4,3}],[{10,4},{11,3}]]} = re:run("ABCabcdABCabcdA","a(?<FOO>bcd)",[global,{capture,all,index}]),
    match = re:run("ABCabcdABCabcdA","a(?<FOO>bcd)",[global,{capture,none,index}]),
    match = re:run("ABCabcdABCabcdA","a(?<FOO>bcd)",[global,{capture,none,binary}]),
    match = re:run("ABCabcdABCabcdA","a(?<FOO>bcd)",[global,{capture,none,list}]),
    {match,[[<<195,133,98,99,100>>,<<"bcd">>],[<<"abcd">>,<<"bcd">>]]} = re:run("ABCÅbcdABCabcdA",".(?<FOO>bcd)",[global,{capture,all,binary},unicode]),
    {match,[["Åbcd","bcd"],["abcd","bcd"]]} = re:run(<<"ABC",8#303,8#205,"bcdABCabcdA">>,".(?<FOO>bcd)",[global,{capture,all,list},unicode]),
    {match,[["Åbcd","bcd"],["abcd","bcd"]]} = re:run("ABCÅbcdABCabcdA",".(?<FOO>bcd)",[global,{capture,all,list},unicode]),
    {match,[[{3,5},{5,3}],[{11,4},{12,3}]]} = re:run("ABCÅbcdABCabcdA",".(?<FOO>bcd)",[global,{capture,all,index},unicode]),
    ok.

%% Test replace with different input types.
replace_input_types(Config) when is_list(Config) ->
    <<"abcd">> = re:replace("abcd","Z","X",[{return,binary},unicode]),
    <<"abcd">> = re:replace("abcd","\x{400}","X",[{return,binary},unicode]),
    <<"a",208,128,"cd">> = re:replace(<<"abcd">>,"b","\x{400}",[{return,binary},unicode]),
    ok.

%% Test replace with a replacement function.
replace_with_fun(Config) when is_list(Config) ->
    <<"ABCD">> = re:replace("abcd", ".", fun(<<C>>, []) -> <<(C - $a + $A)>> end, [global, {return, binary}]),
    <<"AbCd">> = re:replace("abcd", ".", fun(<<C>>, []) when (C - $a) rem 2 =:= 0 -> <<(C - $a + $A)>>; (C, []) -> C end, [global, {return, binary}]),
    <<"b-ad-c">> = re:replace("abcd", "(.)(.)", fun(_, [A, B]) -> <<B/binary, $-, A/binary>> end, [global, {return, binary}]),
    <<"#ab-B#cd">> = re:replace("abcd", ".(.)", fun(Whole, [<<C>>]) -> <<$#, Whole/binary, $-, (C - $a + $A), $#>> end, [{return, binary}]),
    <<"#ab#cd">> = re:replace("abcd", ".(x)?(.)", fun(Whole, [<<>>, _]) -> <<$#, Whole/binary, $#>> end, [{return, binary}]),
    <<"#ab#cd">> = re:replace("abcd", ".(.)(x)?", fun(Whole, [_]) -> <<$#, Whole/binary, $#>> end, [{return, binary}]),
    ok.

%% Test return options of replace together with global searching.
replace_return(Config) when is_list(Config) ->
    {'EXIT',{badarg,_}} = (catch re:replace("na","(a","")),
    ok = replacetest(<<"nisse">>,"i","a",[{return,binary}],<<"nasse">>),
    ok = replacetest("ABC\305abcdABCabcdA","a(?<FOO>bcd)","X",[global,{return,binary}],<<"ABCÅXABCXA">>),
    ok = replacetest("ABCÅabcdABCabcdA","a(?<FOO>bcd)","X",[global,{return,iodata}],[<<"ABCÅ">>,<<"X">>,<<"ABC">>,<<"X">>|<<"A">>]),
    ok = replacetest("ABCÅabcdABCabcdA","a(?<FOO>bcd)","X",[global,{return,list},unicode],"ABCÅXABCXA"),
    ok = replacetest("ABCÅabcdABCabcdA","a(?<FOO>bcd)","X",[global,{return,binary},unicode],<<65,66,67,195,133,88,65,66,67,88,65>>),
    ok = replacetest("ABCÅabcdABCabcdA","a(?<FOO>bcd)","X",[{return,binary},unicode],<<65,66,67,195,133,88,65,66,67,97,98,99,100,65>>),
    ok = replacetest("abcdefghijk","(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)","\\9X",[{return,binary}],<<"iXk">>),
    ok = replacetest("abcdefghijk","(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)","\\10X",[{return,binary}],<<"jXk">>),
    ok = replacetest("abcdefghijk","(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)","\\11X",[{return,binary}],<<"Xk">>),
    ok = replacetest("12345678901","(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)","\\g9X",[{return,binary}],<<"9X1">>),
    ok = replacetest("12345678901","(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)","\\g10X",[{return,binary}],<<"0X1">>),
    ok = replacetest("12345678901","(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)","\\g11X",[{return,binary}],<<"X1">>),
    ok = replacetest("12345678901","(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)","\\g{9}7",[{return,binary}],<<"971">>),
    ok = replacetest("12345678901","(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)","\\g{10}7",[{return,binary}],<<"071">>),
    ok = replacetest("12345678901","(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)","\\g{11}7",[{return,binary}],<<"71">>),
    ok = replacetest("a\x{400}bcd","d","X",[global,{return,list},unicode],"a\x{400}bcX"),
    ok = replacetest("a\x{400}bcd","d","X",[global,{return,binary},unicode],<<"a",208,128,"bcX">>),
    ok = replacetest("a\x{400}bcd","Z","X",[global,{return,list},unicode],"a\x{400}bcd"),
    ok = replacetest("a\x{400}bcd","Z","X",[global,{return,binary},unicode],<<"a",208,128,"bcd">>),
    ok.

rtest(Subj, RE, Copt, Ropt, match) ->
    {ok,MP} = re:compile(RE,Copt), 
    {match,_} = re:run(Subj,MP,Ropt),
    ok;
rtest(Subj, RE, Copt, Ropt, nomatch) ->
    {ok,MP} = re:compile(RE,Copt), 
    nomatch = re:run(Subj,MP,Ropt),
    ok;
rtest(Subj, RE, Copt, Ropt, badarg) ->
    {ok,MP} = re:compile(RE,Copt),
    ok = try
             re:run(Subj,MP,Ropt),
             error
         catch
             error:badarg -> ok
         end.

ctest(_,RE,Options,false,_) ->
    case re:compile(RE,Options) of
	{ok,_} ->
	    error;
	{error,_} ->
	    ok
    end;
ctest(Subject,RE,Options,true,Result) ->
    {ok, Prog} = re:compile(RE,Options),
    Result = re:run(Subject,Prog,[]),
    ok.

crtest(_,RE,Options,false,_) ->
    case (catch re:run("",RE,Options)) of
	{'EXIT',{badarg,_}} ->
	    ok;
	_ ->
	    error
    end;
crtest(Subject,RE,Options,true,Result) ->
    try
	Result = re:run(Subject,RE,Options),
	ok
    catch
	_:_ ->
	    error
    end.

replacetest(Subject,RE,Replacement,Options,Result) ->
    Result = re:replace(Subject,RE,Replacement,Options),
    {CompileOptions,ReplaceOptions} = lists:partition(fun copt/1, Options),
    {ok,MP} = re:compile(RE,CompileOptions),
    Result = re:replace(Subject,MP,Replacement,ReplaceOptions),
    ok.

splittest(Subject,RE,Options,Result) ->
    Result = re:split(Subject,RE,Options),
    {CompileOptions,SplitOptions} = lists:partition(fun copt/1, Options),
    {ok,MP} = re:compile(RE,CompileOptions),
    Result = re:split(Subject,MP,SplitOptions),
    ok.

copt(caseless) -> true;
copt(no_start_optimize) -> true;
copt(never_utf) -> true;
copt(ucp) -> true;
copt(dollar_endonly) -> true;
copt(dotall) -> true;
copt(extended) -> true;
copt(firstline) -> true;
copt(multiline) -> true;
copt(no_auto_capture) -> true;
copt(dupnames) -> true;
copt(ungreedy) -> true;
copt(unicode) -> true;
copt(_) -> false.

%% Test split with autogenerated erlang module.
split_autogen(Config) when is_list(Config) ->
    re_testoutput1_split_test:run(),
    ok.

%% Test special options to split.
split_options(Config) when is_list(Config) ->
    ok = splittest("", "", [trim], []),
    ok = splittest("", " ", [trim], []),
    ok = splittest("", "()", [group, trim], []),
    ok = splittest("", "( )", [group, trim], []),
    ok = splittest("a b c ","( )",[group,trim],[[<<"a">>,<<" ">>],[<<"b">>,<<" ">>],[<<"c">>,<<" ">>]]),
    ok = splittest("a b c ","( )",[group,{parts,0}],[[<<"a">>,<<" ">>],[<<"b">>,<<" ">>],[<<"c">>,<<" ">>]]),
    ok = splittest("a b c ","( )",[{parts,infinity},group],[[<<"a">>,<<" ">>],[<<"b">>,<<" ">>],[<<"c">>,<<" ">>],[<<>>]]),
    ok = splittest("a b c ","( )",[group],[[<<"a">>,<<" ">>],[<<"b">>,<<" ">>],[<<"c">>,<<" ">>],[<<>>]]),
    ok = splittest(" a b c d ","( +)",[group,trim],[[<<>>,<<" ">>],[<<"a">>,<<" ">>],[<<"b">>,<<" ">>],[<<"c">>,<<" ">>],[<<"d">>,<<" ">>]]),
    ok = splittest(" a b c d ","( +)",[{parts,0},group],[[<<>>,<<" ">>],[<<"a">>,<<" ">>],[<<"b">>,<<" ">>],[<<"c">>,<<" ">>],[<<"d">>,<<" ">>]]),
    ok = splittest(" a b c d ","( +)",[{parts,infinity},group],[[<<>>,<<" ">>],[<<"a">>,<<" ">>],[<<"b">>,<<" ">>],[<<"c">>,<<" ">>],[<<"d">>,<<" ">>],[<<>>]]),
    ok = splittest("a b c d","( +)",[{parts,2},group],[[<<"a">>,<<" ">>],[<<"b c d">>]]),
    ok = splittest([967]++" b c d","( +)",[{parts,2},group,{return,list},unicode],[[[967]," "],["b c d"]]),
    ok = splittest([967]++" b c d","( +)",[{parts,2},group,{return,binary},unicode],[[<<207,135>>,<<" ">>],[<<"b c d">>]]),
    {'EXIT',{badarg,_}} = (catch re:split([967]++" b c d","( +)",[{parts,2},group,{return,binary}])),
    {'EXIT',{badarg,_}} = (catch re:split("a b c d","( +)",[{parts,-2}])),
    {'EXIT',{badarg,_}} = (catch re:split("a b c d","( +)",[{parts,banan}])),
    {'EXIT',{badarg,_}} = (catch re:split("a b c d","( +)",[{capture,all}])),
    {'EXIT',{badarg,_}} = (catch re:split("a b c d","( +)",[{capture,[],binary}])),
    %% Parts 0 is equal to no parts specification (implicit strip)
    ok = splittest("a b c d","( *)",[{parts,0},{return,list}],["a"," ","b"," ","c"," ","d"]),
    ok.

join([]) -> [];
join([A]) -> [A];
join([H|T]) -> [H,<<":">>|join(T)].

%% Some special cases of split that are easy to get wrong.
split_specials(Config) when is_list(Config) ->
    %% More or less just to remember these icky cases
    <<"::abd:f">> =
	iolist_to_binary(join(re:split("abdf","^(?!(ab)de|x)(abd)(f)",[trim]))),
    <<":abc2xyzabc3">> =
	iolist_to_binary(join(re:split("abc1abc2xyzabc3","\\Aabc.",[trim]))),
    ok.


%% Test that errors are handled correctly by the erlang code.
error_handling(_Config) ->
    %% This test checks the exception tuples manufactured in the erlang
    %% code to hide the trapping from the user at least when it comes to errors

    %% The malformed precomiled RE is detected after
    %% the trap to re:grun from grun, in the grun function clause
    %% that handles precompiled expressions
    {'EXIT',{badarg,[{re,run,["apa",{1,2,3,4},[global]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:run("apa",{1,2,3,4},[global])),
    %% An invalid capture list will also cause a badarg late,
    %% but with a non pre compiled RE, the exception should be thrown by the
    %% grun function clause that handles RE's compiled implicitly by
    %% the run/3 BIF before trapping.
    {'EXIT',{badarg,[{re,run,["apa","p",[{capture,[1,{a}]},global]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:run("apa","p",[{capture,[1,{a}]},global])),
    %% And so the case of a precompiled expression together with
    %% a compile-option (binary and list subject):
    {ok,RE} = re:compile("(p)"),
    {match,[[{1,1},{1,1}]]} = re:run(<<"apa">>,RE,[global]),
    {match,[[{1,1},{1,1}]]} = re:run("apa",RE,[global]),
    {'EXIT',{badarg,[{re,run,
		      [<<"apa">>,
		       {re_pattern,1,0,_,_},
		       [global,unicode]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:run(<<"apa">>,RE,[global,unicode])),
    {'EXIT',{badarg,[{re,run,
		      ["apa",
		       {re_pattern,1,0,_,_},
		       [global,unicode]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:run("apa",RE,[global,unicode])),
    {'EXIT',{badarg,_}} = (catch re:run("apa","(p",[])),
    {error, {compile, {_,_}}} = re:run("apa","(p",[report_errors]),
    {'EXIT',{badarg,_}} = (catch re:run("apa","(p",[global])),
    {error, {compile, {_,_}}} = re:run("apa","(p",[report_errors,global]),
    %% Badly formed options
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,["global"])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{offset,-1}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{offset,ett}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{captore,[1,2],binary}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{capture,[1,2],binary,list}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{capture,[1,2],bunary}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{capture,{1,2},binary}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{newline,3}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{newline,apa}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{njuline,cr}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{<<"newline">>,cr}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[global|dupnames])),
    {'EXIT',{badarg,_}} = (catch re:run([<<"ap">>|$a],RE,[])), % Not an IO-list
    {'EXIT',{badarg,_}} = (catch re:compile([<<"ap">>|$a],[])), % Not an IO-list
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,[{capture,[0|1],binary}])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,
					[{capture,[<<"apa">>|1],binary}])), 
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,RE,
					[{capture,[[<<"ap">>|$a]],binary}])), 
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,[<<"(p">>|41],[])), 
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,{re_pattern,3,0,0,[]},[])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,{re_pattern,3,0,0,<<"apa">>},[])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa">>,{re_pattern,3,0,0,<<"apa",3:2>>},[])),
    {'EXIT',{badarg,_}} = (catch re:run(<<"apa",2:2>>,<<"(p)">>,[{capture,[0,1],binary}])), 
    <<_:4,Temp:3/binary,_:4>> = <<38,23,6,18>>,
    {match,[{1,1},{1,1}]} = re:run(Temp,<<"(p)">>,[]), % Unaligned works 
    %% The replace errors:
    {'EXIT',{badarg,[{re,replace,["apa",{1,2,3,4},"X",[]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:replace("apa",{1,2,3,4},"X",[])),
    {'EXIT',{badarg,[{re,replace,["apa",{1,2,3,4},"X",[global]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:replace("apa",{1,2,3,4},"X",[global])),
    {'EXIT',{badarg,[{re,replace,
		      ["apa",
		       {re_pattern,1,0,_,_},
		       "X",
		       [unicode]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:replace("apa",RE,"X",[unicode])),
    <<"aXa">> = iolist_to_binary(re:replace("apa","p","X",[])),
    {'EXIT',{badarg,[{re,replace,
		      ["apa","p","X",[report_errors]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch iolist_to_binary(re:replace("apa","p","X",
					   [report_errors]))),
    {'EXIT',{badarg,[{re,replace,
		      ["apa","p","X",[{capture,all,binary}]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch iolist_to_binary(re:replace("apa","p","X",
					   [{capture,all,binary}]))),
    {'EXIT',{badarg,[{re,replace,
		      ["apa","p","X",[{capture,all}]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch iolist_to_binary(re:replace("apa","p","X",
					   [{capture,all}]))),
    {'EXIT',{badarg,[{re,replace,
		      ["apa","p","X",[{return,banana}]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch iolist_to_binary(re:replace("apa","p","X",
					   [{return,banana}]))),
    {'EXIT',{badarg,_}} = (catch re:replace("apa","(p","X",[])),
    %% Badarg, not compile error.
    {'EXIT',{badarg,[{re,replace,
		      ["apa","(p","X",[{return,banana}]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch iolist_to_binary(re:replace("apa","(p","X",
					   [{return,banana}]))),
    %% And the split errors:
    [<<"a">>,<<"a">>] = (catch re:split("apa","p",[])),
    [<<"a">>,<<"p">>,<<"a">>] = (catch re:split("apa",RE,[])),
    {'EXIT',{badarg,[{re,split,["apa","p",[report_errors]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:split("apa","p",[report_errors])),
    {'EXIT',{badarg,[{re,split,["apa","p",[global]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:split("apa","p",[global])),
    {'EXIT',{badarg,[{re,split,["apa","p",[{capture,all}]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:split("apa","p",[{capture,all}])),
    {'EXIT',{badarg,[{re,split,["apa","p",[{capture,all,binary}]],_},
                     {?MODULE, ?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:split("apa","p",[{capture,all,binary}])),
    {'EXIT',{badarg,[{re,split,["apa",{1,2,3,4}],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:split("apa",{1,2,3,4})),
    {'EXIT',{badarg,[{re,split,["apa",{1,2,3,4},[]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:split("apa",{1,2,3,4},[])),
    {'EXIT',{badarg,[{re,split,
		      ["apa",
		       RE,
		       [unicode]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:split("apa",RE,[unicode])),
    {'EXIT',{badarg,[{re,split,
		      ["apa",
		       RE,
		       [{return,banana}]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:split("apa",RE,[{return,banana}])),
    {'EXIT',{badarg,[{re,split,
		      ["apa",
		       RE,
		       [banana]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:split("apa",RE,[banana])),
    {'EXIT',{badarg,_}} = (catch re:split("apa","(p")),
    %%Exception on bad argument, not compilation error
    {'EXIT',{badarg,[{re,split,
		      ["apa",
		       "(p",
		       [banana]],_},
                     {?MODULE,?FUNCTION_NAME,?FUNCTION_ARITY,_} | _]}} =
	(catch re:split("apa","(p",[banana])),
    ok.

%% Fix as in http://vcs.pcre.org/viewvc?revision=360&view=revision
pcre_cve_2008_2371(Config) when is_list(Config) ->
    %% Make sure it doesn't crash the emulator.
    re:compile(<<"(?i)[\xc3\xa9\xc3\xbd]|[\xc3\xa9\xc3\xbdA]">>, [unicode]),
    ok.

%% Patch from
%% http://vcs.pcre.org/viewvc/code/trunk/pcre_compile.c?r1=504&r2=505&view=patch
pcre_compile_workspace_overflow(Config) when is_list(Config) ->
    N = 1180,
    ExpStr = "Got expected error: ",
    case re:compile([lists:duplicate(N, $(), lists:duplicate(N, $))]) of
        {error, {"regular expression is too complicated" = Str,2360}} ->
            {comment, ExpStr ++ Str};
        {error, {"parentheses are too deeply nested (stack check)" = Str, _No}} ->
            {comment, ExpStr ++ Str};
        Other ->
            ct:fail({unexpected, Other})
    end.

%% Make sure matches that really loop infinitely actually fail.
re_infinite_loop(Config) when is_list(Config) ->
    Str =
        "http:/www.flickr.com/slideShow/index.gne?group_id=&user_id=69845378@N0",
    EMail_regex = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+"
        ++ "(\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*"
        ++ "@.*([a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+"
        ++ "([a-zA-Z]{2}|com|org|net|gov|mil"
        ++ "|biz|info|mobi|name|aero|jobs|museum)",
    nomatch = re:run(Str, EMail_regex),
    nomatch = re:run(Str, EMail_regex, [global]),
    {error,match_limit} = re:run(Str, EMail_regex,[report_errors]),
    {error,match_limit} = re:run(Str, EMail_regex,[report_errors,global]),
    ok.

%% Check for nasty bug where accented graphemes can make PCRE back
%% past beginning of subject.
re_backwards_accented(Config) when is_list(Config) ->
    match = re:run(<<65,204,128,65,204,128,97,98,99>>,
		   <<"\\X?abc">>,
		   [unicode,{capture,none}]),
    ok.

%% Check correct handling of dupnames option to re.
opt_dupnames(Config) when is_list(Config) ->
    Days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"],
    _ = [ begin
	      Short = lists:sublist(Day,3),
	      {match,[Short]} =
		  re:run(Day,
			 "(?<DN>Mon|Fri|Sun)(?:day)?|(?<DN>Tue)(?:sday)?|"
			 "(?<DN>Wed)(?:nesday)?|(?<DN>Thu)(?:rsday)?|"
			 "(?<DN>Sat)(?:urday)?",
			 [dupnames, {capture, ['DN'], list}])
	  end || Day <- Days ],
    _ = [ begin
	      Short = list_to_binary(lists:sublist(Day,3)),
	      {match,[Short]} =
		  re:run(Day,
			 "(?<DN>Mon|Fri|Sun)(?:day)?|(?<DN>Tue)(?:sday)?|"
			 "(?<DN>Wed)(?:nesday)?|(?<DN>Thu)(?:rsday)?|"
			 "(?<DN>Sat)(?:urday)?",
			 [dupnames, {capture, ['DN'], binary}])
	  end || Day <- Days ],
    _ = [ begin
	      {match,[{0,3}]} =
		  re:run(Day,
			 "(?<DN>Mon|Fri|Sun)(?:day)?|(?<DN>Tue)(?:sday)?|"
			 "(?<DN>Wed)(?:nesday)?|(?<DN>Thu)(?:rsday)?|"
			 "(?<DN>Sat)(?:urday)?",
			 [dupnames, {capture, ['DN'], index}])
	  end || Day <- Days ],
    {match,[{0,1},{1,3},{7,1}]} = re:run("SMondayX","(?<Skrap>.)(?<DN>Mon|Fri|Sun)(?:day)?(?<Skrap2>.)|"
					 "(?<DN>Tue)(?:sday)?|(?<DN>Wed)nesday|(?<DN>Thu)(?:rsday)?|"
					 "(?<DN>Sat)(?:urday)?",
					 [dupnames, {capture, ['Skrap','DN','Skrap2'],index}]),
    {match,[{-1,0},{0,3},{-1,0}]} = re:run("Wednesday","(?<Skrap>.)(?<DN>Mon|Fri|Sun)(?:day)?(?<Skrap2>.)|"
					   "(?<DN>Tue)(?:sday)?|(?<DN>Wed)nesday|(?<DN>Thu)(?:rsday)?|"
					   "(?<DN>Sat)(?:urday)?",
					   [dupnames, {capture, ['Skrap','DN','Skrap2'],index}]),
    nomatch = re:run("Wednsday","(?<Skrap>.)(?<DN>Mon|Fri|Sun)(?:day)?(?<Skrap2>.)|"
		     "(?<DN>Tue)(?:sday)?|(?<DN>Wed)nesday|(?<DN>Thu)(?:rsday)?|"
		     "(?<DN>Sat)(?:urday)?",
		     [dupnames, {capture, ['Skrap','DN','Skrap2'],index}]),
    {match,[<<>>]} = re:run("Subject","b",[dupnames,{capture,['B'],binary}]),
    {match,[<<"S">>,<<"u">>,<<"b">>,<<"j">>,<<"e">>,<<"c">>,
	    <<"t">>,<<"I">>,<<"s">>,<<"M">>,<<"o">>,<<"r">>,<<"e">>,
	    <<"T">>,<<"h">>,<<"a">>,<<"n">>,<<"T">>,<<"e">>,<<"n">>]} =
	re:run("SubjectIsMoreThanTen",
	       "(?<S>S)(?<u>u)(?<b>b)(?<j>j)(?<e>e)(?<c>c)(?<t>t)"
	       "(?<I>I)(?<s>s)(?<M>M)(?<o>o)(?<r>r)(?<e>e)(?<T>T)"
	       "(?<h>h)(?<a>a)(?<n>n)(?<T>T)(?<e>e)(?<n>n)",
	       [dupnames,{capture,['S','u','b','j','e','c','t',
				   'I','s','M','o','r','e','T',
				   'h','a','n','T','e','n'],binary}]),
    {match,[<<"S">>,<<"u">>,<<"b">>,<<"j">>,<<"e">>,<<"c">>,
	    <<"t">>,<<"I">>,<<"s">>,<<"M">>,<<"o">>,<<"r">>,<<"e">>,
	    <<"T">>,<<"h">>,<<"a">>,<<"n">>,<<"T">>,<<"e">>,<<"n">>]} =
	re:run("SubjectIsMoreThanTen",
	       "(?<S>S)(?<u>u)(?<b>b)(?<j>j)(?<e>e)(?<c>c)(?<t>t)"
	       "(?<I>I)(?<s>s)(?<M>M)(?<o>o)(?<r>r)(?<e>e)(?<T>T)"
	       "(?<h>h)(?<a>a)(?<n>n)(?<T>T)(?<e>e)(?<n>n)",
	       [dupnames,
		{capture,all_but_first,list},
		{capture,['S','u','b','j','e','c','t',
			  'I','s','M','o','r','e','T',
			  'h','a','n','T','e','n'],binary}]),
    {match,[<<"S">>,<<"u">>,<<"b">>,<<"j">>,<<"e">>,<<"c">>,
	    <<"t">>,<<"I">>,<<"s">>,<<"M">>,<<"o">>,<<"r">>,<<"e">>,
	    <<"T">>,<<"h">>,<<"a">>,<<"n">>,<<"T">>,<<"e">>,<<"n">>]} =
	re:run("SubjectIsMoreThanTen",
	       "(?<S>S)(?<u>u)(?<b>b)(?<j>j)(?<e>e)(?<c>c)(?<t>t)"
	       "(?<I>I)(?<s>s)(?<M>M)(?<o>o)(?<r>r)(?<e>e)(?<T>T)"
	       "(?<h>h)(?<a>a)(?<n>n)(?<T>T)(?<e>e)(?<n>n)",
	       [dupnames,
		{capture,["S","u","b","j","e","c","t",
			  "I","s","M","o","r","e","T",
			  "h","a","n","T","e","n"],binary}]), 
    {match,[<<"S">>,<<"u">>,<<"b">>,<<"j">>,<<"e">>,<<"c">>,
	    <<"t">>,<<"I">>,<<"s">>,<<"M">>,<<"o">>,<<"r">>,<<"e">>,
	    <<"T">>,<<"h">>,<<"a">>,<<"n">>,<<"T">>,<<"e">>,<<"n">>]} =
	re:run("SubjectIsMoreThanTen",
	       "(?<S>S)(?<u>u)(?<b>b)(?<j>j)(?<e>e)(?<c>c)(?<t>t)"
	       "(?<I>I)(?<s>s)(?<M>M)(?<o>o)(?<r>r)(?<e>e)(?<T>T)"
	       "(?<h>h)(?<a>a)(?<n>n)(?<T>T)(?<e>e)(?<then>n)",
	       [dupnames,
		{capture,["S","u","b","j","e","c","t",
			  "I","s","M","o","r","e","T",
			  "h","a","n","T","e","then"],binary}]), 
    ok.

%% Test capturing of all_names.
opt_all_names(Config) when is_list(Config) ->
    Days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"],
    {match,[{1,3},{0,1},{7,1}]} = re:run("SMondayX","(?<Skrap>.)(?<DN>Mon|Fri|Sun)(?:day)?(?<Skrap2>.)|"
					 "(?<DN>Tue)(?:sday)?|(?<DN>Wed)nesday|(?<DN>Thu)(?:rsday)?|"
					 "(?<DN>Sat)(?:urday)?",
					 [dupnames, {capture, all_names,index}]),
    {match,[{0,3},{-1,0},{-1,0}]} = re:run("Wednesday","(?<Skrap>.)(?<DN>Mon|Fri|Sun)(?:day)?(?<Skrap2>.)|"
					   "(?<DN>Tue)(?:sday)?|(?<DN>Wed)nesday|(?<DN>Thu)(?:rsday)?|"
					   "(?<DN>Sat)(?:urday)?",
					   [dupnames, {capture, all_names,index}]),

    _ = [ begin
	      {match,[{0,3}]} =
		  re:run(Day,
			 "(?<DN>Mon|Fri|Sun)(?:day)?|(?<DN>Tue)(?:sday)?|"
			 "(?<DN>Wed)(?:nesday)?|(?<DN>Thu)(?:rsday)?|"
			 "(?<DN>Sat)(?:urday)?",
			 [dupnames, {capture, all_names, index}])
	  end || Day <- Days ],
    _ = [ begin
	      match =
		  re:run(Day,
			 "(Mon|Fri|Sun)(?:day)?|(Tue)(?:sday)?|"
			 "(Wed)(?:nesday)?|(Thu)(?:rsday)?|"
			 "(Sat)(?:urday)?",
			 [dupnames, {capture, all_names, index}])
	  end || Day <- Days ],
    {match,[{0,1},{-1,0},{-1,0}]} = re:run("A","(?<A>A)|(?<B>B)|(?<C>C)",[{capture, all_names, index}]),
    {match,[{-1,0},{0,1},{-1,0}]} = re:run("B","(?<A>A)|(?<B>B)|(?<C>C)",[{capture, all_names, index}]),
    {match,[{-1,0},{-1,0},{0,1}]} = re:run("C","(?<A>A)|(?<B>B)|(?<C>C)",[{capture, all_names, index}]),
    {match,[<<"A">>,<<>>,<<>>]} = re:run("A","(?<A>A)|(?<B>B)|(?<C>C)",[{capture, all_names, binary}]),
    {match,[<<>>,<<"B">>,<<>>]} = re:run("B","(?<A>A)|(?<B>B)|(?<C>C)",[{capture, all_names, binary}]),
    {match,[<<>>,<<>>,<<"C">>]} = re:run("C","(?<A>A)|(?<B>B)|(?<C>C)",[{capture, all_names, binary}]),
    {match,["A",[],[]]} = re:run("A","(?<A>A)|(?<B>B)|(?<C>C)",[{capture, all_names, list}]),
    {match,[[],"B",[]]} = re:run("B","(?<A>A)|(?<B>B)|(?<C>C)",[{capture, all_names, list}]),
    {match,[[],[],"C"]} = re:run("C","(?<A>A)|(?<B>B)|(?<C>C)",[{capture, all_names, list}]),
    {match,[{-1,0},{-1,0},{0,1}]} = re:run("A","(?<C>A)|(?<B>B)|(?<A>C)",[{capture, all_names, index}]),
    {match,[{-1,0},{0,1},{-1,0}]} = re:run("B","(?<C>A)|(?<B>B)|(?<A>C)",[{capture, all_names, index}]),
    {match,[{0,1},{-1,0},{-1,0}]} = re:run("C","(?<C>A)|(?<B>B)|(?<A>C)",[{capture, all_names, index}]),
    {match,[<<>>,<<>>,<<"A">>]} = re:run("A","(?<C>A)|(?<B>B)|(?<A>C)",[{capture, all_names, binary}]),
    {match,[<<>>,<<>>,<<"A">>]} = re:run("A","(?<C>A)|(?<B>B)|(?<A>C)",[{capture, all_but_first, binary},{capture, all_names, binary}]),
    {match,[<<>>,<<"B">>,<<>>]} = re:run("B","(?<C>A)|(?<B>B)|(?<A>C)",[{capture, all_names, binary}]),
    {match,[<<"C">>,<<>>,<<>>]} = re:run("C","(?<C>A)|(?<B>B)|(?<A>C)",[{capture, all_names, binary}]),
    {match,[[],[],"A"]} = re:run("A","(?<C>A)|(?<B>B)|(?<A>C)",[{capture, all_names, list}]),
    {match,[[],"B",[]]} = re:run("B","(?<C>A)|(?<B>B)|(?<A>C)",[{capture, all_names, list}]),
    {match,["C",[],[]]} = re:run("C","(?<C>A)|(?<B>B)|(?<A>C)",[{capture, all_names, list}]),
    {match,[[<<>>,<<>>,<<"C">>],
	    [<<>>,<<>>,<<"C">>],
	    [<<>>,<<>>,<<"C">>]]} = re:run("CCC","(?<A>A)|(?<B>B)|(?<C>C)",
					   [global,{capture, all_names, binary}]),
    {match,[[<<"C">>,<<>>],
	    [<<>>,<<"B">>],
	    [<<"C">>,<<>>]]} = re:run("CBC","(?<A>A)|(?<B>B)|(?<A>C)",
				      [global,dupnames,{capture, all_names, binary}]),
    {match,[[]]} = re:run("ABCE","(?<A>D)|(?<B>E)|(?<A>F)",[dupnames,{capture,['A'],list}]),
    {match,["D"]} = re:run("ABCDE","(?<A>D)|(?<B>E)|(?<A>F)",[dupnames,{capture,['A'],list}]),
    {match,["F"]} = re:run("ABCFE","(?<A>D)|(?<B>E)|(?<A>F)",[dupnames,{capture,['A'],list}]),
    {match,["F",[]]} = re:run("ABCFE","(?<A>D)|(?<B>E)|(?<A>F)",[dupnames,{capture,['A','B'],list}]),
    {match,[[],"E"]} = re:run("ABCE","(?<A>D)|(?<B>E)|(?<A>F)",[dupnames,{capture,['A','B'],list}]),
    {match,[[],"E"]} = re:run("ABCE","(?<A>D)|(?<B>E)|(?<A>F)",[dupnames,{capture,all_names,list}]),
    {match,[{-1,0},{3,1}]}  = re:run("ABCE","(?<A>D)|(?<B>E)|(?<A>F)",[dupnames,{capture,all_names,index}]),
    match = re:run("Subject","b",[dupnames,{capture,all_names,binary}]),
    {match,[<<"I">>,<<"M">>,<<"S">>,<<"T">>,<<"a">>,<<"b">>,              
	    <<"c">>,<<"e">>,<<"h">>,<<"j">>,<<"n">>,<<"o">>,<<"r">>,
	    <<"s">>,<<"t">>,<<"u">>]} =
	re:run("SubjectIsMoreThanTen","(?<S>S)(?<u>u)(?<b>b)(?<j>j)"
	       "(?<e>e)(?<c>c)(?<t>t)(?<I>I)(?<s>s)(?<M>M)(?<o>o)(?<r>r)"
	       "(?<e>e)(?<T>T)(?<h>h)(?<a>a)(?<n>n)(?<T>T)(?<e>e)(?<n>n)",
	       [dupnames,{capture,all_names,binary}]),
    ok.

%% Test the minimal inspect function.
inspect(Config) when is_list(Config)->
    {ok,MP} = re:compile("(?<A>A)|(?<B>B)|(?<C>C)."),
    {namelist,[<<"A">>,<<"B">>,<<"C">>]} = re:inspect(MP,namelist),
    {ok,MPD} = re:compile("(?<A>A)|(?<B>B)|(?<A>C).",[dupnames]),
    {namelist,[<<"A">>,<<"B">>]} = re:inspect(MPD,namelist),
    {ok,MPN} = re:compile("(A)|(B)|(C)."),
    {namelist,[]} = re:inspect(MPN,namelist),
    {'EXIT',{badarg,_}} = (catch re:inspect(MPD,namelistk)),
    {'EXIT',{badarg,_}} = (catch re:inspect({re_pattern,3,0,0,<<"kalle">>},namelist)),
    {'EXIT',{badarg,_}} = (catch re:inspect({re_pattern,3,0,0,<<"kalle",2:2>>},namelist)),
    ok.

%% Test that the no_start_optimize compilation flag works.
opt_no_start_optimize(Config) when is_list(Config) ->
    {match, [{3,3}]} = re:run("DEFABC","(*COMMIT)ABC",[]), % Start optimization makes this result wrong!
    nomatch = re:run("DEFABC","(*COMMIT)ABC",[no_start_optimize]), % This is the correct result...
    ok.

%% Check that the never_utf option works.
opt_never_utf(Config) when is_list(Config) ->
    {match,[{0,3}]} = re:run("ABC","ABC",[never_utf]),
    {match,[{0,3}]} = re:run("ABC","(*UTF)ABC",[]),
    {ok,_} = re:compile("(*UTF)ABC"),
    {ok,_} = re:compile("(*UTF)ABC",[unicode]),
    {ok,_} = re:compile("(*UTF8)ABC"),
    {'EXIT',{badarg,_}} = (catch re:run("ABC","ABC",[unicode,never_utf])),
    {'EXIT',{badarg,_}} = (catch re:run("ABC","(*UTF)ABC",[never_utf])),
    {'EXIT',{badarg,_}} = (catch re:run("ABC","(*UTF8)ABC",[never_utf])),
    {error,_} = (catch re:compile("ABC",[unicode,never_utf])),
    {error,_} = (catch re:compile("(*UTF)ABC",[never_utf])),
    {error,_} = (catch re:compile("(*UTF8)ABC",[never_utf])),
    ok.

%% Check that the ucp option is passed to PCRE.
opt_ucp(Config) when is_list(Config) ->
    {match,[{0,1}]} = re:run([$a],"\\w",[unicode]),
    nomatch = re:run([229],"\\w",[unicode]), % Latin1 do not work without UCP anymore, ASCII is default
    nomatch = re:run([1024],"\\w",[unicode]), % and neither do non Latin1 code points.
    {match,[{0,2}]} = re:run([229],"\\w",[unicode,ucp]),  % Need ucp for Latin1
    {match,[{0,2}]} = re:run([1024],"\\w",[unicode,ucp]), % Any Unicode word character works with 'ucp'
    ok.

%% Check that the match_limit and match_limit_recursion options work.
match_limit(Config) when is_list(Config) ->
    nomatch = re:run("aaaaaaaaaaaaaz","(a+)*zz",[]),
    nomatch = re:run("aaaaaaaaaaaaaz","(a+)*zz",[{match_limit,3000}]),
    nomatch = re:run("aaaaaaaaaaaaaz","(a+)*zz",[{match_limit_recursion,10}]),
    nomatch = re:run("aaaaaaaaaaaaaz","(a+)*zz",[report_errors]),
    {error,match_limit} = re:run("aaaaaaaaaaaaaz","(a+)*zz",[{match_limit,3000},
							     report_errors]),
    {error,match_limit_recursion} = 
	re:run("aaaaaaaaaaaaaz","(a+)*zz",[{match_limit_recursion,10},
					   report_errors]),
    {error,match_limit} = re:run("aaaaaaaaaaaaaz","(a+)*zz",[{match_limit,3000},
							     report_errors,global]),
    {error,match_limit_recursion} = 
	re:run("aaaaaaaaaaaaaz","(a+)*zz",[{match_limit_recursion,10},
					   report_errors,global]),
    ["aaaaaaaaaaaaaz"] = re:split("aaaaaaaaaaaaaz","(a+)*zz",
				  [{match_limit_recursion,10},{return,list}]),
    ["aaaaaaaaaaaaaz"] = re:split("aaaaaaaaaaaaaz","(a+)*zz",
				  [{match_limit,3000},{return,list}]),
    "aaaaaaaaaaaaaz" = re:replace("aaaaaaaaaaaaaz","(a+)*zz","!",
				  [{match_limit_recursion,10},{return,list}]),
    "aaaaaaaaaaaaaz" = re:replace("aaaaaaaaaaaaaz","(a+)*zz","!",
				  [{match_limit,3000},{return,list}]),
    {'EXIT', {badarg,_}} = (catch re:replace("aaaaaaaaaaaaaz","(a+)*zz","!",
					     [{match_limit_recursion,-1},{return,list}])),
    {'EXIT', {badarg,_}} = (catch re:replace("aaaaaaaaaaaaaz","(a+)*zz","!",
					     [{match_limit,-1},{return,list}])),
    {'EXIT', {badarg,_}} = (catch re:run("aaaaaaaaaaaaaz","(a+)*zz",
					 [{match_limit_recursion,-1},
					  report_errors,global])),
    {'EXIT', {badarg,_}} = (catch re:run("aaaaaaaaaaaaaz","(a+)*zz",
					 [{match_limit,-1},
					  report_errors,global])),
    ok.
%% Test that we get sub-binaries if subject is a binary and we capture
%% binaries.
sub_binaries(Config) when is_list(Config) ->
    %% The GC can auto-convert tiny sub-binaries to heap binaries, so we
    %% extract large sequences to make the test more stable.
    Bin = << <<I>> || I <- lists:seq(1, 4096) >>,
    {match,[B,C]}=re:run(Bin,"a(.+)$",[{capture,all,binary}]),
    true = byte_size(B) =/= byte_size(C),
    4096 = binary:referenced_byte_size(B),
    4096 = binary:referenced_byte_size(C),
    {match,[D]}=re:run(Bin,"a(.+)$",[{capture,[1],binary}]),
    4096 = binary:referenced_byte_size(D),
    ok.

bad_utf8_subject(Config) when is_list(Config) ->
    %% OTP-16553: re:run() did not badarg
    %% if both pattern and subject was binaries
    %% even though subject contained illegal
    %% utf8...

    %% OTP-19015: re:run() ended up in an infinite loop
    %% if both pattern and subject was binaries and
    %% subject was long enough to trigger a yield.

    nomatch = re:run(<<255,255,255>>, <<"a">>, []),
    nomatch = re:run(<<255,255,255>>, "a", []),
    nomatch = re:run(<<"aaa">>, <<255>>, []),
    nomatch = re:run(<<"aaa">>, [255], []),
    {match,[{0,1}]} = re:run(<<255,255,255>>, <<255>>, []),
    {match,[{0,1}]} = re:run(<<255,255,255>>, [255], []),
    [
     begin
         %% Badarg on illegal utf8 in subject as of OTP 23...
         try
             re:run(<<Prefix/binary, 255,255,255>>, <<"a">>, [unicode]),
             error(unexpected)
         catch
             error:badarg ->
                 ok
         end,
         try
             re:run(<<Prefix/binary, 255,255,255>>, "a", [unicode]),
             error(unexpected)
         catch
             error:badarg ->
                 ok
         end,
         try
             re:run(<<Prefix/binary, "aaa">>, <<255>>, [unicode]),
             error(unexpected)
         catch
             error:badarg ->
                 ok
         end,
         nomatch = re:run(<<Prefix/binary, "aaa">>, [255], [unicode]),
         try
             re:run(<<Prefix/binary, 255,255,255>>, <<255>>, [unicode]),
             error(unexpected)
         catch
             error:badarg ->
                 ok
         end,
         try
             re:run(<<Prefix/binary, 255,255,255>>, [255], [unicode]),
             error(unexpected)
         catch
             error:badarg ->
                 ok
         end
     end || Prefix <- [<<>>, iolist_to_binary(lists:duplicate(100000, $a))]],
    ok.

error_info(_Config) ->
    BadRegexp = {re_pattern,0,0,0,<<"xyz">>},
    BadErr = "neither an iodata term",
    {ok,GoodRegexp} = re:compile(".*"),
    InvalidRegexp = <<"(.*))">>,
    InvalidErr = "could not parse regular expression\n.*unmatched closing parenthesis.*",

    L = [{compile, [not_iodata]},
         {compile, [not_iodata, not_list],[{1,".*"},{2,".*"}]},
         {compile, [<<".*">>, [a|b]]},
         {compile, [<<".*">>, [bad_option]]},
         {compile, [{a,b}, [bad_option]],[{1,".*"},{2,".*"}]},

         {grun, 3},                             %Internal.

         {inspect,[BadRegexp, namelist]},
         {inspect,["", namelist]},
         {inspect,[GoodRegexp, 999]},
         {inspect,[GoodRegexp, bad_inspect_item]},

         {internal_run, 4},                     %Internal.

         {replace, [{a,b}, {x,y}, {z,z}],[{1,".*"},{2,".*"},{3,".*"}]},
         {replace, [{a,b}, BadRegexp, {z,z}],[{1,".*"},{2,BadErr},{3,".*"}]},
         {replace, [{a,b}, InvalidRegexp, {z,z}],[{1,".*"},{2,InvalidErr},{3,".*"}]},

         {replace, [{a,b}, {x,y}, {z,z}, [a|b]],[{1,".*"},{2,".*"},{3,".*"},{4,".*"}]},
         {replace, [{a,b}, BadRegexp, [bad_option]],[{1,".*"},{2,BadErr},{3,".*"}]},
         {replace, [{a,b}, InvalidRegexp, [bad_option]],[{1,".*"},{2,InvalidErr},{3,".*"}]},
         {replace, ["", "", {z,z}, not_a_list],[{3,".*"},{4,".*"}]},

         {run, [{a,b}, {x,y}],[{1,".*"},{2,".*"}]},
         {run, [{a,b}, ".*"]},
         {run, ["abc", {x,y}]},
         {run, ["abc", BadRegexp],[{2,BadErr}]},
         {run, ["abc", InvalidRegexp],[{2,InvalidErr}]},

         {run, [{a,b}, {x,y}, []],[{1,".*"},{2,".*"}]},
         {run, ["abc", BadRegexp, []],[{2,BadErr}]},
         {run, ["abc", InvalidRegexp, []],[{2,InvalidErr}]},
         {run, [{a,b}, {x,y}, [a|b]],[{1,".*"},{2,".*"},{3,".*"}]},
         {run, [{a,b}, ".*", bad_options],[{1,".*"},{3,".*"}]},
         {run, ["abc", {x,y}, [bad_option]],[{2,".*"},{3,".*"}]},
         {run, ["abc", BadRegexp, 9999],[{2,BadErr},{3,".*"}]},
         {run, ["abc", InvalidRegexp, 9999],[{2,InvalidErr},{3,".*"}]},

         {split, ["abc", BadRegexp],[{2,BadErr}]},
         {split, ["abc", InvalidRegexp],[{2,InvalidErr}]},
         {split, [{a,b}, ".*"]},

         {split, ["abc", BadRegexp, [a|b]],[{2,BadErr},{3,".*"}]},
         {split, ["abc", InvalidRegexp, [a|b]],[{2,InvalidErr},{3,".*"}]},
         {split, [{a,b}, ".*", [bad_option]]},

         {ucompile, 2},                         %Internal.
         {urun, 3}                              %Internal.
        ],
    error_info_lib:test_error_info(re, L).

pattern_is_sub_binary(Config) when is_list(Config) ->
    %% Aligned sub binary - will not copy the binary
    Bin = <<"pattern = ^((:|(0?|([1-9a-f][0-9a-f]{0,3}))):)((0?|([1-9a-f][0-9a-f]{0,3})):){0,6}(:|(0?|([1-9a-f][0-9a-f]{0,3})))$">>,
    Subject = <<"::1">>,
    {_,RE} = split_binary(Bin, 10),
    {ok,REC} = re:compile(RE),
    match = re:run(Subject, REC, [{capture, none}]),
    match = re:run(Subject, RE, [{capture, none}]),
    nomatch = re:run(Subject, Bin, [{capture, none}]),
    %% Unaligned sub binary - will result in a copy operation
    <<0:1, RE2/binary>> = Bin2 = <<0:1, "^((:|(0?|([1-9a-f][0-9a-f]{0,3}))):)((0?|([1-9a-f][0-9a-f]{0,3})):){0,6}(:|(0?|([1-9a-f][0-9a-f]{0,3})))$">>,
    {ok,REC2} = re:compile(RE2),
    match = re:run(Subject, REC2, [{capture, none}]),
    match = re:run(Subject, RE2, [{capture, none}]),
    ok = try
        _ = re:run(Subject, Bin2, [{capture, none}])
    catch error:badarg ->
        %% *** argument 2: neither an iodata term nor a compiled regular expression
        ok
    end.

subject_is_sub_binary(Config) when is_list(Config) ->
    %% Aligned subject sub binary
    Bin = <<"subject = ::1">>,
    RE = <<"^((:|(0?|([1-9a-f][0-9a-f]{0,3}))):)((0?|([1-9a-f][0-9a-f]{0,3})):){0,6}(:|(0?|([1-9a-f][0-9a-f]{0,3})))$">>,
    {_,Subject} = split_binary(Bin, 10),
    {ok,REC} = re:compile(RE),
    match = re:run(Subject, REC, [{capture, none}]),
    match = re:run(Subject, RE, [{capture, none}]),
    nomatch = re:run(Bin, RE, [{capture, none}]),
    %% Unaligned subject sub binary
    <<0:1, Subject2/binary>> = Bin2 = <<0:1,"::1">>,
    match = re:run(Subject2, REC, [{capture, none}]),
    match = re:run(Subject2, RE, [{capture, none}]),
    ok = try
        _ = re:run(Bin2, RE, [{capture, none}])
    catch error:badarg ->
        %% *** argument 1: not an iodata term
        ok
    end.

last_test(Config) when is_list(Config) ->
    erts_debug:set_internal_state(available_internal_state, true),
    Res = case erts_debug:get_internal_state(re_yield_coverage) of
              undefined ->
                  case erlang:system_info(build_type) of
                      Type when Type =/= debug ->
                          {skip, {"No yield coverage in",Type}}
                  end;
              Coverage ->
                  io:format("re_yield_coverage = ~p\n", [Coverage]),
                  ok = check_yield_coverage(Coverage, ok)
          end,
    erts_debug:set_internal_state(available_internal_state, false),
    Res.

check_yield_coverage([], Err) ->
    Err;
check_yield_coverage([Tuple | Tail], Err0) ->
    Err1 =
        case Tuple of
            {Line, 0, 0} ->
                io:format("COST_CHK at line ~p never visited", [Line]),
                error;
            {Line, Visits, 0} ->
                io:format("COST_CHK at line ~p visited ~p times but never yielded",
                          [Line, Visits]),
                error;
            {Line, 0, Yields} ->
                io:format("COST_CHK at line ~p never visited but has yielded ~p times ????",
                          [Line, Yields]),
                error;
            {_,_,_} ->
                Err0
        end,
    check_yield_coverage(Tail, Err1).
