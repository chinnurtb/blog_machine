-module(item_atom_resource).
-export([init/1, content_types_provided/2, to_atom/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) ->
  item:start(),
  {ok, undefined}.

content_types_provided(ReqData, Context) ->
   {[{"application/atom+xml",to_atom}], ReqData, Context}.

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

to_atom(Reqdata, Context) ->
  Items = get_items(Reqdata),
  ok = erltl:compile("src/item_atom_template.et"),
  Atom = item_atom_template:render(Items),
  {Atom, Reqdata, Context}.

