-module(markup).

-behaviour(gen_server).

-export([start_link/0, to_html/1]).

% gen_server
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,terminate/2, code_change/3]).

-record(state,{port}).
-define(SERVER, ?MODULE).

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

% state handlers

init([]) ->
  Port = open_port({spawn, "simple_markup"},[stream, {line, 1024}]),
  {ok, #state{port=Port}}.

terminate(_Reason, State) ->
  port_close(State#state.port),
  ok.

code_change(_OldVsn, State, _Extra) ->
  terminate(code_change, State),
  init([]).

% replies

handle_call({to_html, Markup}, _From, State) ->
  true = port_command(State#state.port, Markup),
  % Hack around the fact that erlang ports cant send eof
  true = port_command(State#state.port, "\nEOF\n"),
  Response = case collect_response(State#state.port) of
    {response, Html} -> {reply, Html, State}
  end,
  Response.

collect_response(Port) ->
  collect_response(Port, [], []).

collect_response(Port, RespAcc, LineAcc) ->
  receive
    {Port, {data, {_, "EOF"}}} ->
      {response, lists:reverse(RespAcc)};
    {Port, {data, {eol, Result}}} ->
      Line = lists:reverse([Result | LineAcc]),
      collect_response(Port, [Line | RespAcc], []);
    {Port, {data, {noeol, Result}}} ->
      collect_response(Port, RespAcc, [Result | LineAcc])
  after 1000 -> {timeout, RespAcc, LineAcc}
  end.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

% external interface

to_html(Markup) ->
  gen_server:call(?SERVER, {to_html, Markup}, 2000).

