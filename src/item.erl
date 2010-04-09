-module(item).
-export([start/0, insert/4, insert/5, by_pubdate/1, all/0, ascending/1, descending/1, filter_tag/2]).

-include("/usr/lib/erlang/lib/stdlib-1.16.2/include/qlc.hrl").

-include("item.hrl").

start() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(item, 
    [ {disc_copies, [node()]}
    , {type, ordered_set}
    , {attributes, record_info(fields, item)}
    ]
  ),
  ok.

insert(Pubdate, Title, Subtitle, Tags, Body) ->
  Item = #item{pubdate=Pubdate, title=Title, subtitle=Subtitle, tags=Tags, body=Body},
  {atomic, ok} = mnesia:transaction(fun() -> mnesia:write(Item) end),
  Pubdate.

insert(Title, Subtitle, Tags, Body) ->
  insert(now(), Title, Subtitle, Tags, Body).

by_pubdate(Pubdate) ->
  {atomic, Items} = mnesia:transaction(fun () -> mnesia:read({item, Pubdate}) end),
  Items.

all() ->
  {atomic, Items} = 
    mnesia:transaction(fun () -> 
      qlc:e(mnesia:table(item))
    end),
  Items.

ascending(Items) ->
  Items.

descending(Items) ->
  lists:reverse(Items).

filter_tag(Tag, Items) ->
  [Item || Item <- Items, lists:member(Tag, Item#item.tags)].
