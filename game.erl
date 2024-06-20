

-module(game).
-export([start/1,master_listener/3,create_eligible_players_map/2]).

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
    Records = {},
    Players=[],
    receive
        {create_game, Name, Random_Player} ->
            New_gameId = Game_id +1,
            Players = [Name,Random_Player],
            whereis(Name) ! {choose_move, {New_gameId,Name}},
            whereis(Random_Player) ! {choose_move, {New_gameId,Random_Player}},
            io:format("~p Name ~p Random Player inside Master~n", [Name, Random_Player]),
            master_listener(MainMap,EligiblePlayersMap, New_gameId);

        {player_response, {Game_id, Response, PlayerName}} ->
            io:format("Game ID: ~p, Response: ~p, Player Name: ~p~n", [Game_id, Response, PlayerName]),
            if PlayerName == hd(Players) ->
                 io:format("Match");
            true ->
                io:format("NO Match")
            end,
            master_listener(MainMap,EligiblePlayersMap, Game_id)

            % if 
            %     PlayerName == hd(Players),
            %     maps:put(Game_id, maps:put(Player1, Name, Records), Records);
            %     master_listener(MainMap,EligiblePlayersMap, Game_id)
    end.

% master_listener(MainMap, EligiblePlayersMap, Game_id) ->
%     Records = #{},
%     receive
%         {create_game, Name, Random_Player} ->
%             New_gameId = Game_id + 1,
%             Players = [Name, Random_Player],
%             whereis(Name) ! {choose_move, {New_gameId, Name}},
%             whereis(Random_Player) ! {choose_move, {New_gameId, Random_Player}},
%             io:format("~p Name ~p Random Player inside Master~n", [Name, Random_Player]),
%             master_listener(MainMap, EligiblePlayersMap, New_gameId);

%         {player_response, {Game_id, Response, PlayerName}} ->
%             io:format("Game ID: ~p, Response: ~p, Player Name: ~p~n", [Game_id, Response, PlayerName]),
%             NewRecords = case maps:is_key(Game_id, Records) of
%                              true ->
%                                  OldList = maps:get(Game_id, Records),
%                                  maps:put(Game_id, [{PlayerName, Response} | OldList], Records),
%                                 io:format("Records: ~p~n", [Records]);
                                 
%                              false ->
%                                  maps:put(Game_id, [{PlayerName, Response}], Records)
%                          end,
%             master_listener(MainMap, EligiblePlayersMap, Game_id)
%     end.

