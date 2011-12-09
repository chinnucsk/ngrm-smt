%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% ФУНКЦИИ ФОРМАТИРОВАННОГО ВЫВОДА В СТРОКУ
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(format).
-export([
            s/2,
            test/0
        ]
).

% ---------------------------------------------------------------------------
% Работает так же как io:format но выводит резудьтат в строку

s(Pattern, Values) ->
    lists:flatten(io_lib:format(Pattern, Values)).

% ===========================================================================

-include_lib("eunit/include/eunit.hrl").
test()->
    % S
    % ----------------------------------
    ?assertEqual("1",               s("~p", [1])),
    ?assertEqual("12",              s("~p~p", [1, 2])),
    ?assertEqual("[1,2]",           s("~p", [[1, 2]])),
    ?assertEqual("formats",         s("~s", ["formats"])),
    ?assertEqual("мама мыла раму",  s("~s", ["мама мыла раму"])),
    ?assertEqual("мама мыла раму",  s("~ts", ["мама мыла раму"])),
    ok.
