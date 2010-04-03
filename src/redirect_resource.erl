-module(redirect_resource).
-export([init/1, resource_exists/2, moved_temporarily/2, previously_existed/2]).
 
-include_lib("webmachine/include/webmachine.hrl").
 
init([Redirect_to]) -> {ok, Redirect_to}.
 
resource_exists(ReqData, Context) -> {false, ReqData, Context}.
 
previously_existed(ReqData, Context) -> {true, ReqData, Context}.
 
moved_temporarily(ReqData, Redirect_to) ->
  {{true, Redirect_to}, ReqData, Redirect_to}.
