-module(users).
-export([get/0, add/4, del/3]).
 
get() ->
	storage_manager:find_users().

add(Username, Realname, Email, Password) ->
	storage_manager:save_user(Username, Realname, Email, Password),
	storage_manager:find_users().

del(Username, Realname, Email) ->
	storage_manager:delete_user(Username, Realname, Email),
	storage_manager:find_users().
