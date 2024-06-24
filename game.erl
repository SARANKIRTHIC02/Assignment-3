-module(game).
-export([start/1, master_listener/8, create_eligible_players_map/2]).

start(Args) ->
    PlayerFile = lists:nth(1, Args),
    {ok, PlayerInfo} = file:consult(PlayerFile),
    % io:fwrite("Player info: ~p~n", [PlayerInfo]),

    MainMap = maps:from_list(PlayerInfo),
    % io:fwrite("Main Map: ~p~n", [MainMap]),
    io:format("Starting Game Log...~n ~n"),

    EligiblePlayersMap = create_eligible_players_map(MainMap, MainMap),
    lists:foreach(
        fun({Name, Credits}) ->
            Pid = spawn(player, player_listener, [Name, Credits, maps:get(Name, EligiblePlayersMap),EligiblePlayersMap, MainMap, self()]),
            register(Name, Pid)
            % io:format("Worker PID for ~p: ~p~n", [Name, whereis(Name)])   
        end,
        PlayerInfo
    ),

    lists:foreach(
        fun(Name) ->
            % io:fwrite("Current Player: ~p~n", [Name]),,
            Current = whereis(Name),
            Current ! {message, {Name, initiate}}
        end,
        maps:keys(MainMap)
    ),
    timer:sleep(200),
    master_listener(MainMap, EligiblePlayersMap, 1, #{}, #{}, #{}, #{},false).

create_eligible_players_map(MainMap, EligiblePlayersMap) ->
    lists:foldl(
        fun({Player, _}, Acc) ->
            EligiblePlayers = lists:delete(Player, maps:keys(EligiblePlayersMap)),
            maps:put(Player, EligiblePlayers, Acc)
        end,
        #{},
        maps:to_list(MainMap)
    )
.

master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, Player_One_Map, Player_Two_Map, Player_Details_Map,Declared) ->
    receive
        {create_game, Name, Player2Name} ->
            New_gameId = Game_id + 1,
            Temp_id = Game_id,
            UpdatedPlayersMap = maps:put(Temp_id, [Name, Player2Name], Players_Map),
            whereis(Name) ! {choose_move, {Temp_id, Name}}, 
            whereis(Player2Name) ! {choose_move, {Temp_id, Player2Name}}, 
            UpdatedPlayersMap = maps:put(Temp_id, [Name, Player2Name], Players_Map),
            io:format("+ [~p] new game for ~p -> ~p ~n", [Temp_id,Name,Player2Name]),
            % io:format("Updated Players Map: ~p~n", [UpdatedPlayersMap]),
            master_listener(MainMap, EligiblePlayersMap, New_gameId, UpdatedPlayersMap, Player_One_Map, Player_Two_Map, Player_Details_Map,Declared);

    {player_response, {GameId, Move, PlayerName}} ->
        io:format("~p sssssssssssssssssssssssss ~n",[GameId]),
        % io:format("~p sssssssssssssssssssssssss ~n",[Players_Map]),
        io:format("~p sssssssssssssssssssssssss ~n",[PlayerName]),

    Players_List = maps:get(GameId, Players_Map),
    UpdatedPlayerOneMap = case {hd(Players_List), PlayerName} of
        {PlayerName, _} ->
            OldMovesOne = maps:get(GameId, Player_One_Map, []),
            NewMovesOne = OldMovesOne ++ [Move],
            maps:put(GameId, NewMovesOne, Player_One_Map);
        _ ->
            Player_One_Map
    end,
    UpdatedPlayerTwoMap = case {lists:last(Players_List), PlayerName} of
        {PlayerName, _} ->
            OldMovesTwo = maps:get(GameId, Player_Two_Map, []),
            NewMovesTwo = OldMovesTwo ++ [Move],
            maps:put(GameId, NewMovesTwo, Player_Two_Map);
        _ ->
            Player_Two_Map
    end,

    % io:format("~p playerones ~n",[UpdatedPlayerOneMap]),
    % io:format("~p playertrwo ~n",[UpdatedPlayerTwoMap]),

    PlayerOneRematch = hd(Players_List),
    PlayerTwoRematch =  lists:last(Players_List),
    % io:format("~p ~n",[PlayerOneRematch]),
    % io:format("~p ~n",[PlayerTwoRematch]),
    PlayerOneMoves = maps:get(GameId, UpdatedPlayerOneMap, []),
    % io:format("Player One Moves: ~p~n", [PlayerOneMoves]),
    % Get the list of moves for Player Two
    PlayerTwoMoves = maps:get(GameId, UpdatedPlayerTwoMap, []),
    % io:format("Player Two Moves: ~p~n", [PlayerTwoMoves]),
    
    if 
        length(PlayerOneMoves) == length(PlayerTwoMoves) ->
            OneLastMove = lists:last(PlayerOneMoves),
            TwoLastMove = lists:last(PlayerTwoMoves),
            if 
                (OneLastMove == 1 andalso TwoLastMove == 3) orelse (OneLastMove == 3 andalso TwoLastMove == 2) orelse (OneLastMove == 2 andalso TwoLastMove == 1) ->  
                % TwoPLayerCredit = maps:get(PlayerTwoRematch,MainMap),
                % io:format("~p ~n",[MainMap]),
                Current_Player_Two_Credits = maps:get(PlayerTwoRematch,MainMap)-1,
                Temp_Map = maps:put(PlayerTwoRematch,Current_Player_Two_Credits,MainMap),
                io:format("~p ~n player@Creditssssssss ~p",[Current_Player_Two_Credits,PlayerTwoRematch]),

                io:format("$ (~p) ~p:~p -> ~p:~p = ~p loses [~p credits left]~n",[GameId,PlayerOneRematch,OneLastMove,PlayerTwoRematch,TwoLastMove,PlayerTwoRematch,Current_Player_Two_Credits]),
                % io:format("~p ~n",[Current_Player_Two_Credits]),
                % io:format("~p ~n",[Temp_Map]),

                if 
                   Current_Player_Two_Credits ==0 ->
                   whereis(PlayerTwoRematch) ! {disqualify_player, PlayerTwoRematch},
                %    io:format("ascddvfevdfvsfbgbfgdbgbbgldvcnf ~p ~n",[Temp_Map]),
                   FilteredMap = maps:filter(fun(_Key, Value) -> Value > 0 end, Temp_Map),
                %    io:foxrmat(" asdfnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn~p ~n",[FilteredMap]),
                    Size = maps:size(FilteredMap),
                    % io:format(" ~p Size ~n",[Size]),
                   if 
                        Size == 1 ->
                            io:format("We have a Winner --------------------------------------~p ~n",[FilteredMap]);
                        true->
                            master_listener(Temp_Map, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,Declared)
                    end;
                   
                   true ->
                        master_listener(Temp_Map, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,Declared)

                end;

                (OneLastMove == 3 andalso TwoLastMove == 1) orelse (OneLastMove == 2 andalso TwoLastMove == 3) orelse (OneLastMove == 1 andalso TwoLastMove == 2) ->  
                % io:format("PLayer 2 Wins ~p ~n",[PlayerTwoRematch]),
                io:format("~p ~n",[MainMap]),
                Current_Player_One_Credits = maps:get(PlayerOneRematch,MainMap)-1,
                Temp_Map_Two = maps:put(PlayerOneRematch,Current_Player_One_Credits,MainMap),
                                io:format("PLayer Lost ~p ~n",[Current_Player_One_Credits]),
                % io:format("~p ~n",[Current_Player_One_Credits]),
                io:format("$ (~p) ~p:~p -> ~p:~p = ~p loses [~p credits left]~n",[GameId,PlayerTwoRematch,TwoLastMove,PlayerOneRematch,OneLastMove,PlayerOneRematch,Current_Player_One_Credits]),
                % io:format("~p ~n",[Temp_Map_Two]),

                if 
                   Current_Player_One_Credits ==0 ->
                        whereis(PlayerOneRematch) ! {disqualify_player, PlayerOneRematch},
                        Filtered_Map_Two = maps:filter(fun(_Key, Value) -> Value > 0 end, Temp_Map_Two),
                        Size_Two = maps:size(Filtered_Map_Two),
                %    io:format(" ~p Size ~n",[Size_Two]),
                        if 
                            Size_Two == 1 ->
                                io:format("We have a Winner  222222222222222222222222222--------------------------------------~p ~n",[Filtered_Map_Two]);

                            true->
                                master_listener(Temp_Map_Two, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,true)
                        end;


                   true ->
                    master_listener(Temp_Map_Two, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,true)
                end;
            
                (OneLastMove == 1 andalso TwoLastMove == 1) orelse (OneLastMove == 2 andalso TwoLastMove == 2) orelse (OneLastMove == 3 andalso TwoLastMove == 3) ->  
                    io:format(" {~p} Game Draw ~n",[GameId]),
                    whereis(PlayerOneRematch) ! {choose_move, {GameId,PlayerOneRematch }},
                    whereis(PlayerTwoRematch) ! {choose_move, {GameId,PlayerTwoRematch}},
                    master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,true);
                true ->
                    master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,true)
            end;   
        true ->
            master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,true)  
    end
end.