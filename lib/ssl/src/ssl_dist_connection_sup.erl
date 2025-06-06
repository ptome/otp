%%
%% %CopyrightBegin%
%%
%% SPDX-License-Identifier: Apache-2.0
%%
%% Copyright Ericsson AB 1998-2025. All Rights Reserved.
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

%%

-module(ssl_dist_connection_sup).
-moduledoc false.

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callback
-export([init/1]).

%%%=========================================================================
%%%  API
%%%=========================================================================

-spec start_link() -> {ok, pid()} | ignore | {error, term()}.
			
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%%=========================================================================
%%%  Supervisor callback
%%%=========================================================================
init([]) ->    
    SupFlags = #{strategy  => one_for_one, 
                 intensity =>   10,
                 period    => 3600
                },
    ChildSpecs = [tls_sup_child_spec()], 
    {ok, {SupFlags, ChildSpecs}}.

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------

tls_sup_child_spec() ->
    #{id       => tls_dist_sup,
      start    => {tls_dist_sup, start_link, []},
      restart  => permanent, 
      shutdown => 4000,
      modules  => [tls_dist_sup],
      type     => supervisor
     }.
