-module(item).
-export([start/0, insert/3, insert/4, insert_from_file/1, insert_from_dir/1, by_pubdate/1, all/0, ascending/1, descending/1, filter_tag/2, last/0]).

-include_lib("stdlib/include/qlc.hrl").
-include_lib("kernel/include/file.hrl").

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
  ok = mnesia:wait_for_tables([item],10000),
  ok.

insert(Pubdate, Title, Tags, Body) ->
  Item = #item{pubdate=Pubdate, title=Title, tags=Tags, body=Body},
  {atomic, ok} = mnesia:transaction(fun() -> mnesia:write(Item) end),
  Pubdate.

insert(Title, Tags, Body) ->
  insert(now(), Title, Tags, Body).

insert_from_file(File) ->
  {ok, Bin} = file:read_file(File),
  Text = binary_to_list(Bin),
  {Title, Rest1} = lists:splitwith(fun(Char) -> Char /= $\n end, Text),
  Rest2 = string:strip(Rest1,left,$\n),
  {Tagline, Rest3} = lists:splitwith(fun(Char) -> Char /= $\n end, Rest2),
  Tags = string:tokens(Tagline, " "),
  Body = string:strip(Rest3,left,$\n),
  case by_title(Title) of 
    [] ->
      insert(Title, Tags, Body);
    [Item] ->
      insert(Item#item.pubdate, Title, Tags, Body)
  end.

is_readable_file(File) ->
  {ok, Info} = file:read_file_info(File),
  (Info#file_info.type == regular) and ((Info#file_info.access == read) or (Info#file_info.access == read_write)).

insert_from_dir(Dir) ->
  {ok, Files} = file:list_dir(Dir),
  [ insert_from_file(File) || File <- Files, is_readable_file(File) ].

by_pubdate(Pubdate) ->
  {atomic, Items} = mnesia:transaction(fun () -> mnesia:read({item, Pubdate}) end),
  Items.

last() ->
  {atomic, [Item]} = mnesia:transaction(fun () -> mnesia:read({item, mnesia:last(item)}) end),
  Item.

by_title(Title) ->
  {atomic, Items} = mnesia:transaction(fun () -> mnesia:match_object(#item{pubdate=' ', title=Title, tags=' ', body=' '}) end),
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
