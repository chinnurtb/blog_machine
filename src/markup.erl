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
  Port = open_port({spawn, "simple_markup"},[{packet, 4}]),
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
  Response = case collect_response(State#state.port) of
    {ok, Html} -> {reply, Html, State}
  end,
  Response.

collect_response(Port) ->
  receive
    {Port, {data, Data}} -> {ok, Data}
  after 1000 -> timeout
  end.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

% external interface

to_html(Markup) ->
  gen_server:call(?SERVER, {to_html, Markup}, 2000).

