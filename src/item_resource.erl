-module(item_resource).
-export([init/1, content_types_provided/2, to_text/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) ->
  item:start(),
  {ok, undefined}.

content_types_provided(ReqData, Context) ->
   {[{"text/plain",to_text}], ReqData, Context}.

string_to_integer(String) ->
  {Integer, []} = string:to_integer(String),
  Integer.

% Order wants to always fire first?
handle_arg(Arg, Query) ->
  case Arg of
    {"order", "asc"} -> 
      item:ascending(Query);
    {"order", "desc"} -> 
      item:descending(Query);
    {"limit", N} ->
      item:limit(string_to_integer(N), Query);
    {"tag", Tag} ->
      item:filter_tag(Tag, Query);
    _ -> Query
  end. 

get_items(Reqdata) ->
  Tokens = wrq:path_tokens(Reqdata),
  case Tokens of
    [ "all" ] -> 
      item:eval_query( 
        fun () ->
          lists:foldl(
            fun (Arg,Query) -> handle_arg(Arg,Query) end, 
            item:all(), 
            wrq:req_qs(Reqdata)
          ) 
        end
      );
    [ "by_pubdate", Mega, One, Micro ] -> 
      Pubdate = {string_to_integer(Mega),string_to_integer(One),string_to_integer(Micro)},
      item:by_pubdate(Pubdate)
  end.

term_to_string(Term) ->
  io_lib:format("~p", [Term]).

to_text(Reqdata, Context) ->
  {term_to_string(get_items(Reqdata)), Reqdata, Context}.

