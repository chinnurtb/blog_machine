-module(util).

-export([term_to_string/1]).

term_to_string(Term) ->
  io_lib:format("~p", [Term]).
