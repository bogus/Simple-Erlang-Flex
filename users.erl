-module(users).
-compile(export_all).
-include("bsse_records.hrl").

 
getData() ->
	F = fun() ->
                Query = qlc:q([{object, <<"User">>,[{username, M#user.username}, {name, M#user.realname}, {email, M#user.email}, {password, M#user.password}]} || M <- mnesia:table(user)]),
                Results = qlc:e(Query),
                Results
        end,
	storage_manager:get_objects(F).	

insertData(Object) ->
	erlang:display(Object).		

deleteData(Object) ->
	erlang:display(Object).		

updateData(Object) ->
	erlang:display(Object).

