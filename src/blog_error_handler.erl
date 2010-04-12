-module(blog_error_handler).

-export([render_error/3]).

render_error(Code, Req, Reason) ->
    case Req:has_response_body() of
        {true,_} -> Req:response_body();
        {false,_} -> render_error_body(Code, Req:trim_state(), Reason)
    end.

render_error_body(404, Req, _Reason) ->
    {ok, ReqState} = Req:add_response_header("Content-Type", "text/html"),
    {<<"<HTML><HEAD><TITLE>404 Not Found</TITLE></HEAD><body><center><center><H1>Not Found</H1>The requested document was not found on this server.<P><HR><ADDRESS>mochiweb+webmachine web server</ADDRESS></center></body></HTML>">>, ReqState};

render_error_body(500, Req, Reason) ->
    {ok, ReqState} = Req:add_response_header("Content-Type", "text/html"),
    {Path,_} = Req:path(),
    error_logger:error_msg("webmachine error: path=~p~n~p~n", [Path, Reason]),
    ErrorStart = "<html><head><title>500 Internal Server Error</title></head><body><center><h1>Internal Server Error</h1>The server encountered an error while processing this request.",
    ErrorEnd = "<P><HR><ADDRESS>mochiweb+webmachine web server</ADDRESS></center></body></html>",
    ErrorIOList = [ErrorStart,ErrorEnd],
    {erlang:iolist_to_binary(ErrorIOList), ReqState};

render_error_body(501, Req, _Reason) ->
    {ok, ReqState} = Req:add_response_header("Content-Type", "text/html"),
    {Method,_} = Req:method(),
    error_logger:error_msg("Webmachine does not support method ~p~n",
                           [Method]),
    ErrorStr = io_lib:format("<html><head><title>501 Not Implemented</title>"
                             "</head><body><center><h1>Internal Server Error</h1>"
                             "The server does not support the ~p method.<br>"
                             "<P><HR><ADDRESS>mochiweb+webmachine web server"
                             "</ADDRESS></center></body></html>",
                             [Method]),
    {erlang:iolist_to_binary(ErrorStr), ReqState};

render_error_body(503, Req, _Reason) ->
    {ok, ReqState} = Req:add_response_header("Content-Type", "text/html"),
    error_logger:error_msg("Webmachine cannot fulfill"
                           " the request at this time"),
    ErrorStr = "<html><head><title>503 Service Unavailable</title>"
               "</head><body><center><h1>Service Unavailable</h1>"
               "The server is currently unable to handle "
               "the request due to a temporary overloading "
               "or maintenance of the server.<br>"
               "<P><HR><ADDRESS>mochiweb+webmachine web server"
               "</ADDRESS></center></body></html>",
    {list_to_binary(ErrorStr), ReqState}.

