-module(item_one_resource).
-export([init/1, content_types_provided/2, resource_exists/2, to_html/2]).

-include_lib("webmachine/include/webmachine.hrl").

-record(context,{item}).

init([]) ->
  item:start(),
  {ok, #context{item=undefined}}.

content_types_provided(ReqData, Context) ->
   {[{"text/html",to_html}], ReqData, Context}.

resource_exists(Reqdata, Context) ->
  Tokens = wrq:path_tokens(Reqdata),
  case Tokens of
    [ Mega, One, Micro ] -> 
      Pubdate = {util:string_to_integer(Mega),util:string_to_integer(One),util:string_to_integer(Micro)},
      case item:by_pubdate(Pubdate) of
        [Item] -> 
          {true, Reqdata, Context#context{item=Item}};
        _ -> 
          {false, Reqdata, Context}
      end;
    _ ->
      {false, Reqdata, Context}
  end.

to_html(Reqdata, Context) ->
  ok = erltl:compile("src/item_template.et"),
  Body = item_template:render({[Context#context.item], false, false}),
  ok = erltl:compile("src/blog_template.et"),
  Html = blog_template:render(Body),
  {Html, Reqdata, Context}.

