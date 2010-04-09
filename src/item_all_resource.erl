-module(item_all_resource).
-export([init/1, content_types_provided/2, to_html/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) ->
  item:start(),
  {ok, undefined}.

content_types_provided(ReqData, Context) ->
   {[{"text/html",to_html}], ReqData, Context}.

% Order wants to always fire first?
handle_arg(Arg, Items) ->
  case Arg of
    {"order", "asc"} -> 
      item:ascending(Items);
    {"order", "desc"} -> 
      item:descending(Items);
    {"tag", Tag} ->
      item:filter_tag(Tag, Items);
    _ -> Items
  end. 

get_items(Reqdata) ->
  lists:foldl(
    fun handle_arg/2, 
    item:all(), 
    wrq:req_qs(Reqdata)
  ).

to_html(Reqdata, Context) ->
  Items = get_items(Reqdata),
  ok = erltl:compile("src/item_template.et"),
  Body = item_template:render(Items),
  ok = erltl:compile("src/blog_template.et"),
  Html = blog_template:render(Body),
  {Html, Reqdata, Context}.

