-module(storage_manager).

-include_lib("stdlib/include/qlc.hrl").

-compile([export_all]).
-define(SERVER, storage_manager).

%%
%% API Functions
%%

-record(user, {username, realname, email, password}).

save_user(Username, Realname, Email, Password) ->
	global:send(?SERVER, {save_user, Username, Realname, Email, Password}).

find_users() ->
	global:send(?SERVER, {find_users, self()}),
	receive
		{ok, Users} ->
			Users
	end.

delete_user(Username, Realname, Email) ->
        global:send(?SERVER, {del_user, Username, Realname, Email}).

get_users() ->
	F = fun() ->
		Query = qlc:q([{object, <<"User">>,[{username, M#user.username}, {name, M#user.realname}, {email, M#user.email}, {password, M#user.password}]} || M <- mnesia:table(user)]),
		Results = qlc:e(Query),
		Results 
	end,
	{atomic, Users} = mnesia:transaction(F),
	Users.

erase_user(Username, Realname, Email) ->
        F = fun() ->
                Query = qlc:q([M || M <- mnesia:table(user), M#user.username=:=Username, M#user.realname=:=Realname, M#user.email=:=Email]),
                Results = qlc:e(Query),
		lists:foreach(fun(User) -> mnesia:delete_object(User) end, Results)
        end,
	mnesia:transaction(F).

store_user(Username, Realname, Email, Password) ->
	F = fun() ->
		mnesia:write(#user{username=Username, realname=Realname, email=Email, password=Password}) 
	end,
	mnesia:transaction(F).
	

init_store() ->
	mnesia:create_schema([node()]),
	mnesia:start(),
	try
		mnesia:table_info(user, type)
	catch
		exit: _->
			mnesia:create_table(user,[{attributes, record_info(fields, user)},
								{type, bag},
								{disc_copies, [node()]}])
	end.

start() ->
	server_util:start(?SERVER, {storage_manager, run, [true]}).

stop() ->
	server_util:stop(?SERVER).

run(FirstTime) ->
	if 
		FirstTime == true ->
		   init_store(),
		   run(false);
		true ->
			receive 
				{save_user, Username, Realname, Email, Password} ->
					store_user(Username, Realname, Email, Password),
					run(FirstTime);
				{del_user, Username, Realname, Email} ->
					erase_user(Username, Realname, Email),
					run(FirstTime);
				{find_users, Pid} ->
					Users = get_users(),
					Pid ! {ok, Users},
					run(FirstTime);
				shutdown ->
					mnesia:stop(),
					io:format("Shutting down.. ~n")
		end
	end.
