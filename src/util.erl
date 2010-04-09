-module(util).

-export([term_to_string/1, string_to_integer/1]).

term_to_string(Term) ->
  io_lib:format("~p", [Term]).

string_to_integer(String) ->
  {Integer, []} = string:to_integer(String),
  Integer.
