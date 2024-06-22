

-module(game).
-export([start/1, master_listener/7, create_eligible_players_map/2]).

start(Args) ->
    PlayerFile = lists:nth(1, Args),
    {ok, PlayerInfo} = file:consult(PlayerFile),
    % io:fwrite("Player info: ~p~n", [PlayerInfo]),

    MainMap = maps:from_list(PlayerInfo),
    % io:fwrite("Main Map: ~p~n", [MainMap]),

    EligiblePlayersMap = create_eligible_players_map(MainMap, MainMap),
    lists:foreach(
        fun({Name, Credits}) ->
            Pid = spawn(player, player_listener, [Name, Credits, maps:get(Name, EligiblePlayersMap), MainMap, self()]),
            register(Name, Pid)
            % io:format("Worker PID for ~p: ~p~n", [Name, whereis(Name)])
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
    master_listener(MainMap, EligiblePlayersMap, 1, #{}, #{}, #{}, #{}).

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


master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, Player_One_Map, Player_Two_Map, Player_Details_Map) ->
    receive
        {create_game, Name, Player2Name} ->
            New_gameId = Game_id + 1,
            Temp_id = Game_id,
            UpdatedPlayersMap = maps:put(Temp_id, [Name, Player2Name], Players_Map),
            whereis(Name) ! {choose_move, {Temp_id, Name}}, 
            whereis(Player2Name) ! {choose_move, {Temp_id, Player2Name}}, 
            % io:format("Created game with ID ~p~n", [Temp_id]),
            % io:format("Updated Players Map: ~p~n", [UpdatedPlayersMap]),
            master_listener(MainMap, EligiblePlayersMap, New_gameId, UpdatedPlayersMap, Player_One_Map, Player_Two_Map, Player_Details_Map);

    {player_response, {GameId, Move, PlayerName}} ->
    % io:format("Received Move for Game ID ~p: ~p from ~p~n", [GameId, Move, PlayerName]),
    Players_List = maps:get(GameId, Players_Map),
    % io:format("Players list: ~p ~n",[Players_List]),
    % io:format("Current Players in Game ID ~p: ~p~n", [GameId, Players_List]),

    UpdatedPlayerOneMap = case {hd(Players_List), PlayerName} of
        {PlayerName, _} ->
            OldMovesOne = maps:get(GameId, Player_One_Map, []),
            NewMovesOne = OldMovesOne ++ [Move],
            maps:put(GameId, NewMovesOne, Player_One_Map);
        _ ->
            Player_One_Map
    end,
    % io:format("Updated Player One Map: ~p~n", [UpdatedPlayerOneMap]),

    UpdatedPlayerTwoMap = case {lists:last(Players_List), PlayerName} of
        {PlayerName, _} ->
            OldMovesTwo = maps:get(GameId, Player_Two_Map, []),
            NewMovesTwo = OldMovesTwo ++ [Move],
            maps:put(GameId, NewMovesTwo, Player_Two_Map);
        _ ->
            Player_Two_Map
    end,

    
    PlayerOneRematch = hd(Players_List),
    PlayerTwoRematch =  lists:last(Players_List),
    io:format("~p ~n",[PlayerOneRematch]),
    io:format("~p ~n",[PlayerTwoRematch]),
    % io:format("Updated Player Two Map: ~p~n", [UpdatedPlayerTwoMap]),
    % Get the list of moves for Player One
    PlayerOneMoves = maps:get(GameId, UpdatedPlayerOneMap, []),
    % io:format("Player One Moves: ~p~n", [PlayerOneMoves]),
    % Get the list of moves for Player Two
    PlayerTwoMoves = maps:get(GameId, UpdatedPlayerTwoMap, []),
    % io:format("Player Two Moves: ~p~n", [PlayerTwoMoves]),

    
    if 
        length(PlayerOneMoves) == length(PlayerTwoMoves) ->
            % io:format("Fuck yes ~n"),
            % io:format("Player One Moves: ~p~n", [PlayerOneMoves]),
            % io:format("Player Two Moves: ~p~n", [PlayerTwoMoves]),
            % io:format("~p ~n",[PlayerOneMoves]),
            % io:format("~p ~n",[PlayerTwoMoves]),
            OneLastMove = lists:last(PlayerOneMoves),
            TwoLastMove = lists:last(PlayerTwoMoves),
            % io:format("Last Player One Move: ~p~n", [OneLastMove]),
            % io:format("Last Player Two Move: ~p~n", [TwoLastMove]),

            if 
                (OneLastMove == 1 andalso TwoLastMove == 3) orelse (OneLastMove == 3 andalso TwoLastMove == 2) orelse (OneLastMove == 2 andalso TwoLastMove == 1) ->  
                io:format("PLayer 1 Wins ~n"),
                Current_Player_Two_Credits = maps:get(PlayerTwoRematch,MainMap)-1,
                maps:put(GameId,Current_Player_Two_Credits,Player_Two_Map),
                io:format("PLayer 1 Wins ~p ~n",[Current_Player_Two_Credits]),


                if
                    Current_Player_Two_Credits == 0 ->
                    whereis(PlayerTwoRematch) ! {disqualify_player, PlayerTwoRematch};

                    true ->
                        io:format("Game Draw ~n")
                end;    

                (OneLastMove == 3 andalso TwoLastMove == 1) orelse (OneLastMove == 2 andalso TwoLastMove == 3) orelse (OneLastMove == 1 andalso TwoLastMove == 2) ->  
                io:format("PLayer 2 Wins ~n");

                (OneLastMove == 1 andalso TwoLastMove == 1) orelse (OneLastMove == 2 andalso TwoLastMove == 2) orelse (OneLastMove == 3 andalso TwoLastMove == 3) ->  
                io:format("Draw ~n"),
                whereis(PlayerOneRematch) ! {choose_move, {GameId,PlayerOneRematch }},
                whereis(PlayerTwoRematch) ! {choose_move, {GameId,PlayerTwoRematch}};

            
            true ->
                io:format("Game Draw ~n")
            end;   
            % io:format("Player One Moves: ~p~n", [lists:last(PlayerOneMoves)]),



        true ->
            ok
            
    end,
    % io:format("PLayer oneeeeeee movessssss ~p ~n",[lists:last(PlayerOneMoves)]),
    % io:format("Player twoooooo movessssssss ~p ~n",[lists:last(PlayerTwoMoves)]),
    master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map)
end.


