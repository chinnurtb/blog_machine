-module(item_resource).
-export([init/1, content_types_provided/2, to_html/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) ->
  item:start(),
  {ok, undefined}.

content_types_provided(ReqData, Context) ->
   {[{"text/html",to_html}], ReqData, Context}.

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

to_html(Reqdata, Context) ->
  ok = erltl:compile("src/item_template.et"),
  Body = item_template:render(get_items(Reqdata)),
  ok = erltl:compile("src/blog_template.et"),
  Html = blog_template:render(Body),
  {Html, Reqdata, Context}.

