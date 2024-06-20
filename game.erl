

-module(game).
-export([start/1,master_listener/2,create_eligible_players_map/2]).

start(Args) ->
    PlayerFile = lists:nth(1, Args),
    {ok, PlayerInfo} = file:consult(PlayerFile),
    io:fwrite("Player info: ~p~n", [PlayerInfo]),


    MainMap = maps:from_list(PlayerInfo),
    io:fwrite("Main Map: ~p~n", [MainMap]),

    EligiblePlayersMap = create_eligible_players_map(MainMap, MainMap),
    lists:foreach(
        fun({Name, Credits}) ->
            Pid = spawn(player, player_listener, [Name, Credits, maps:get(Name, EligiblePlayersMap), MainMap, self()]),
            register(Name, Pid),
            io:format("Worker PID for ~p: ~p~n", [Name, whereis(Name)])
        end,
        PlayerInfo
    ),

    lists:foreach(
        fun(Name) ->
            io:fwrite("Current Player: ~p~n", [Name]),
            Initiate = "Initiate",
            Current = whereis(Name),
            Current ! {message, {Name, Initiate}}
        end,
        maps:keys(MainMap)
    
    ),
    master_listener(MainMap,EligiblePlayersMap,0).

    

create_eligible_players_map(MainMap, EligiblePlayersMap) ->
    lists:foldl(
        fun({Player, _}, Acc) ->
            EligiblePlayers = lists:delete(Player, maps:keys(EligiblePlayersMap)),
            maps:put(Player, EligiblePlayers, Acc)
        end,
        #{},
        maps:to_list(MainMap)
    ).

master_listener(MainMap,EligiblePlayersMap, Game_id)->
    % Record = {GameId:{sam:"scissor", jill:"paper"}}
    receive
        {create_game, Name, Random_Player} ->
            New_gameId = Game_id +1,
            whereis(Name) ! {choose_coin, {New_gameId}},
            whereis(Random_Player) ! {choose_coin, {New_gameId}},
            io:format("~p Name ~p Random Player inside Master~n", [Name, Random_Player]),
            master_listener(MainMap,EligiblePlayersMap, New_gameId);

        {player_coin, {Game_id, Response, PlayerName}}
    end.
