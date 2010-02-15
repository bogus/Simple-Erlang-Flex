%%%-------------------------------------------------------------------
%%% @author Burak OGUZ <burak@medratech.com>
%%% @copyright 2010, Burak OGUZ
%%% @doc Storage Manager for BSSE Web Application.
%%% @end
%%%-------------------------------------------------------------------
-module(storage_manager).
-author("burak@medratech.com").
-behaviour(gen_server).

%% API
-export([start_link/0, 
	stop/0,
	get_objects/1,
	run_transaction/1,
	insert_object/1,
	update_object/1,
	delete_object/1]).

%% gen_server callbacks
-export([init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-include("bsse_records.hrl").

-record(state, {id=0}).

start_link() -> 
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
    	gen_server:call({local,?MODULE}, stop).

get_objects(Function) ->
        gen_server:call(?MODULE, {get_objects, Function}).
run_transaction(Function) ->
        gen_server:call(?MODULE, {run_transaction, Function}).
insert_object(Function) ->
        gen_server:call(?MODULE, {run_transaction, Function}).
update_object(Function) ->
        gen_server:call(?MODULE, {run_transaction, Function}).
delete_object(Function) ->
        gen_server:call(?MODULE, {run_transaction, Function}).

init([]) ->
	mnesia:create_schema([node()]),
        mnesia:start(),
        try
                mnesia:table_info(user, type)
        catch
                exit: _->
                        mnesia:create_table(user,[{attributes, record_info(fields, user)},
                                                                {type, bag},
                                                                {disc_copies, [node()]}])
        end,	
    	{ok, #state{}}.

handle_call({get_objects, Function}, _From, State) ->
	{atomic, Users} = mnesia:transaction(Function),
	{reply, Users, State};

handle_call({run_transaction, Function}, _From, State) ->
	mnesia:transaction(Function),
	{reply, [], State};		

handle_call(stop, _From, State) ->
    	{stop, normalStop, State}.

handle_cast(_Msg, State) ->
    	{noreply, State}.

handle_info(_Msg, State) -> 
	{noreply, State}.

terminate(_Reason, _State) ->
    	ok.

code_change(_OldVsn, State, _Extra) ->
    	{ok, State}.

