-module(f_include_1).

-feature(enable, unless_expr).

-ifdef(end_prefix).
-record(constant, {value = 42}).
-endif.

-ifdef(end_include).
-feature(enable, maybe_expr).
-endif.

-include("is_enabled.hrl").

-ifdef(end_include).
-feature(enable, ifnot_expr).
-endif.

%% At this point the prefix will definitely end, if it has not already
-export([foo/1]).

foo(1) -> one.