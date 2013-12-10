-module(rummy_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->

    Serializer = fun(X) -> base64:encode(bert:encode(X)) end,
    Deserializer = fun(X) -> bert:decode(base64:decode(X)) end,
    Bullet = [{"/rummy/:clientid", bullet_handler, [{handler, jacket},
                                                    {callbacks, rummy_endpoint},
                                                    {args, []},
                                                    {serializer, Serializer},
                                                    {deserializer, Deserializer}]}],
    Static = [{"/", cowboy_static, 
               {priv_file, rummy, "static/index.html"}},
              {"/[...]", cowboy_static,
               {priv_dir, rummy, "static", 
                [{mimetypes, cow_mimetypes, all}]}}
              ],
    Dispatch = cowboy_router:compile([{'_', Bullet++Static}]),
    cowboy:start_http(rummy_cowboy, 20,
                      [{port, 8080}],
                      [{env, [{dispatch, Dispatch}]}]),
    rummy_sup:start_link().

stop(_State) ->
    ok.
