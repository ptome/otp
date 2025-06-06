%%
%% %CopyrightBegin%
%%
%% SPDX-License-Identifier: Apache-2.0
%%
%% Copyright Ericsson AB 2010-2025. All Rights Reserved.
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
-module(expand_test).

-export([a_fun_name/1,
	 a_less_fun_name/1,
	 b_comes_after_a/1,
         expand0arity_entirely/0]).

a_fun_name(X) ->
    X.

a_less_fun_name(X) ->
    X.

b_comes_after_a(X) ->
    X.

expand0arity_entirely () ->
    ok.
