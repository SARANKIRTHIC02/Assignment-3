

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

% master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, Player_One_Map, Player_Two_Map, Player_Details_Map) ->
%     receive
%         {create_game, Name, Player2Name} ->
%             New_gameId = Game_id + 1,
%             Temp_id = Game_id,
%             UpdatedPlayersMap = maps:put(Temp_id, [Name, Player2Name], Players_Map),
%             io:format("~p Map: ~n",[UpdatedPlayersMap]),
%             whereis(Name) ! {choose_move, {Temp_id, Name}}, 
%             whereis(Player2Name) ! {choose_move, {Temp_id, Player2Name}}, 
%             io:format("Created game with ID ~p~n", [Temp_id]),
%             master_listener(MainMap, EligiblePlayersMap, New_gameId, UpdatedPlayersMap, Player_One_Map, Player_Two_Map, Player_Details_Map);

%          {player_response,  {GameId,CurrentMove, CurrentPlayerName}} ->
%             io:format("Received Move for Game ID ~p: ~p from ~p~n", [GameId, CurrentMove, CurrentPlayerName]),
%             UpdatedPlayersMap = maps:get(GameId, Players_Map),
%             io:format(" Map:~p ~n",[UpdatedPlayersMap]),
%             master_listener(MainMap, EligiblePlayersMap, Game_id,UpdatedPlayersMap, Player_One_Map, Player_Two_Map, Player_Details_Map);
            

%         Other ->
%             io:format("Received unexpected message: ~p~n", [Other]),
%             master_listener(MainMap, EligiblePlayersMap, Game_id, UpdatedPlayersMap, Player_One_Map, Player_Two_Map, Player_Details_Map)
%     end.

% master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, Player_One_Map, Player_Two_Map, Player_Details_Map) ->
%     receive
%         {create_game, Name, Player2Name} ->
%             New_gameId = Game_id + 1,
%             Temp_id = Game_id,
%             UpdatedPlayersMap = maps:put(Temp_id, [Name, Player2Name], Players_Map),
%             whereis(Name) ! {choose_move, {Temp_id, Name}}, 
%             whereis(Player2Name) ! {choose_move, {Temp_id, Player2Name}}, 
%             io:format("Created game with ID ~p~n", [Temp_id]),
%             io:format("Updated Players Map: ~p~n", [UpdatedPlayersMap]),
%             master_listener(MainMap, EligiblePlayersMap, Game_id, UpdatedPlayersMap, Player_One_Map, Player_Two_Map , Player_Details_Map);

%          {player_response, {GameId, Move, PlayerName}} ->
%             io:format("PLayer Name : ~p ~p ~p ~n",[GameId,Move,PlayerName]),
%             master_listener(MainMap, EligiblePlayersMap, Game_id, UpdatedPlayersMap, Player_One_Map, Player_Two_Map , Player_Details_Map)

%         % Other ->
%         %     io:format("Received unexpected message: ~p~n", [Other]),
%         %     master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, Player_One_Map, Player_Two_Map, Player_Details_Map)
%     end.


% master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, Player_One_Map, Player_Two_Map, Player_Details_Map) ->
%     receive
%         {create_game, Name, Player2Name} ->
%             New_gameId = Game_id + 1,
%             Temp_id = Game_id,
%             UpdatedPlayersMap = maps:put(Temp_id, [Name, Player2Name], Players_Map),
%             whereis(Name) ! {choose_move, {Temp_id, Name}}, 
%             whereis(Player2Name) ! {choose_move, {Temp_id, Player2Name}}, 
%             io:format("Created game with ID ~p~n", [Temp_id]),
%             master_listener(MainMap, EligiblePlayersMap, New_gameId, UpdatedPlayersMap, Player_One_Map, Player_Two_Map, Player_Details_Map);

%         {player_response, {GameId, Move, PlayerName}} ->
%             io:format("Received Move for Game ID ~p: ~p from ~p~n", [GameId, Move, PlayerName]),
%             Players_List = maps:get(GameId, Players_Map),
%             io:format("Current Players in Game ID ~p: ~p~n", [GameId, Players_List]),
%             % io:format("Name : ~p ~n",[PlayerName]),

%             % case Players_List of
%             %     [First | _] when PlayerName == First ->
%             %         io:format("First element in Players_List: ~p~n", [First]);

%             %     _List ->
%             %         Last = lists:last(Players_List),
%             %         io:format("Last element in Players_List: ~p~n", [Last])
%             % end,

%             if 
%                 hd(Players_List) == PlayerName ->
%                     io:format("Name CORRECTTTTTTTT: ~p ~n",[PlayerName]),
%                     maps:put(GameId,Move,Player_One_Map);
                
%                 true ->
%                     io:format("Name TRUEEEEEEEEEEEEÉ: ~p ~n",[PlayerName])
%             end,


%             master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, Updated_Player_One_Map, Player_Two_Map, Player_Details_Map)
%     end.
% %   

% {player_response, {GameId, Move, PlayerName}} ->
%             io:format("Received Move for Game ID ~p: ~p from ~p~n", [GameId, Move, PlayerName]),
%             Players_List = maps:get(GameId, Players_Map),
%             io:format("Current Players in Game ID ~p: ~p~n", [GameId, Players_List]),

%             UpdatedPlayerOneMap = case {hd(Players_List), PlayerName} of
%                 {PlayerName, _} ->
%                     maps:put(GameId, [Move], Player_One_Map);
%                 _ ->
%                     Player_One_Map
%             end,

%             UpdatedPlayerTwoMap = case {lists:last(Players_List), PlayerName} of
%                 {PlayerName, _} ->
%                     maps:put(GameId, [Move], Player_Two_Map);
%                 _ ->
%                     Player_Two_Map
%             end,

%             master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map)
%     end.


master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, Player_One_Map, Player_Two_Map, Player_Details_Map) ->
    receive
        {create_game, Name, Player2Name} ->
            New_gameId = Game_id + 1,
            Temp_id = Game_id,
            UpdatedPlayersMap = maps:put(Temp_id, [Name, Player2Name], Players_Map),
            whereis(Name) ! {choose_move, {Temp_id, Name}}, 
            whereis(Player2Name) ! {choose_move, {Temp_id, Player2Name}}, 
            io:format("Created game with ID ~p~n", [Temp_id]),
            io:format("Updated Players Map: ~p~n", [UpdatedPlayersMap]),
            master_listener(MainMap, EligiblePlayersMap, New_gameId, UpdatedPlayersMap, Player_One_Map, Player_Two_Map, Player_Details_Map);

        {player_response, {GameId, Move, PlayerName}} ->
    io:format("Received Move for Game ID ~p: ~p from ~p~n", [GameId, Move, PlayerName]),
    Players_List = maps:get(GameId, Players_Map),
    io:format("Current Players in Game ID ~p: ~p~n", [GameId, Players_List]),

    UpdatedPlayerOneMap = case {hd(Players_List), PlayerName} of
        {PlayerName, _} ->
            OldMovesOne = maps:get(GameId, Player_One_Map, []),
            NewMovesOne = OldMovesOne ++ [Move],
            maps:put(GameId, NewMovesOne, Player_One_Map);
        _ ->
            Player_One_Map
    end,
    io:format("Updated Player One Map: ~p~n", [UpdatedPlayerOneMap]),

    UpdatedPlayerTwoMap = case {lists:last(Players_List), PlayerName} of
        {PlayerName, _} ->
            OldMovesTwo = maps:get(GameId, Player_Two_Map, []),
            NewMovesTwo = OldMovesTwo ++ [Move],
            maps:put(GameId, NewMovesTwo, Player_Two_Map);
        _ ->
            Player_Two_Map
    end,
    io:format("Updated Player Two Map: ~p~n", [UpdatedPlayerTwoMap]),

     % Get the list of moves for Player One
    PlayerOneMoves = maps:get(GameId, UpdatedPlayerOneMap, []),
    % io:format("Player One Moves: ~p~n", [PlayerOneMoves]),

    % Get the list of moves for Player Two
    PlayerTwoMoves = maps:get(GameId, UpdatedPlayerTwoMap, []),
    % io:format("Player Two Moves: ~p~n", [PlayerTwoMoves]),
    if 
        length(PlayerOneMoves) == length(PlayerTwoMoves) ->
            io:format("Fuck yes ~n"),
            io:format("Player One Moves: ~p~n", [PlayerOneMoves]),
            io:format("Player Two Moves: ~p~n", [PlayerTwoMoves]);
            
            % io:format("Player One Moves: ~p~n", [lists:last(PlayerOneMoves)]),


        true ->
             io:format("Fuck NO ~n")
    end,
    % io:format("PLayer oneeeeeee movessssss ~p ~n",[lists:last(PlayerOneMoves)]),
    % io:format("Player twoooooo movessssssss ~p ~n",[lists:last(PlayerTwoMoves)]),

    master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map)
end.


