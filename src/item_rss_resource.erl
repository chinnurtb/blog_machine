-module(item_rss_resource).
-export([init/1, content_types_provided/2, to_rss/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) ->
  item:start(),
  {ok, undefined}.

content_types_provided(ReqData, Context) ->
   {[{"application/rss+xml",to_rss}], ReqData, Context}.

handle_arg(Arg, Items) ->
  case Arg of
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

to_rss(Reqdata, Context) ->
  Items = lists:reverse(get_items(Reqdata)),
  ok = erltl:compile("src/item_rss_template.et"),
  Rss = item_rss_template:render(Items),
  {Rss, Reqdata, Context}.

