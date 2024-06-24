-module(game).
-export([start/1, master_listener/8, create_eligible_players_map/2]).

start(Args) ->
    PlayerFile = lists:nth(1, Args),
    {ok, PlayerInfo} = file:consult(PlayerFile),
    % io:fwrite("Player info: ~p~n", [PlayerInfo]),

    MainMap = maps:from_list(PlayerInfo),
    % io:fwrite("Main Map: ~p~n", [MainMap]),
    io:format("\n"),
    io:format("** Rock, Paper Scissors World Championship ** ~n"),
    io:format("~n"),

    io:format("Starting Game Log...~n ~n"),
    DuplicateMainMap = MainMap,
    EligiblePlayersMap = create_eligible_players_map(MainMap, MainMap),
    lists:foreach(
        fun({Name, Credits}) ->
            Pid = spawn(player, player_listener, [Name, Credits, maps:get(Name, EligiblePlayersMap),EligiblePlayersMap, MainMap, self()]),
            register(Name, Pid)
            % io:format("Worker PID for ~p: ~p~n", [Name, whereis(Name)])   
        end,
        PlayerInfo
    ),
    

    % PlayersAdditionMap = lists:foldl(
    %     fun({Name, Credits}, Acc) ->
    %         maps:put(Name, {0, Credits}, Acc)
    %     end,
    %     #{},
    %     PlayerInfo),
        % io:format("~p PlayersAdd ~n",[PlayersAdditionMap]),
    lists:foreach(
        fun(Name) ->
            % io:fwrite("Current Player: ~p~n", [Name])
            Current = whereis(Name),
            Current ! {message, {Name, initiate}}
        end,
        maps:keys(MainMap)
    ),
    timer:sleep(200),
    master_listener(MainMap, EligiblePlayersMap, 1, #{}, #{}, #{}, #{},DuplicateMainMap).
    

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

master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, Player_One_Map, Player_Two_Map, Player_Details_Map,DuplicateMap) ->
    receive
        {create_game, Name, Player2Name} ->
            New_gameId = Game_id + 1,
            Temp_id = Game_id,
            UpdatedPlayersMap = maps:put(Temp_id, [Name, Player2Name], Players_Map),
            whereis(Name) ! {choose_move, {Temp_id, Name}}, 
            whereis(Player2Name) ! {choose_move, {Temp_id, Player2Name}}, 
            UpdatedPlayersMap = maps:put(Temp_id, [Name, Player2Name], Players_Map),
            io:format("+ [~p] new game for ~p -> ~p ~n", [Temp_id,Name,Player2Name]),
            master_listener(MainMap, EligiblePlayersMap, New_gameId, UpdatedPlayersMap, Player_One_Map, Player_Two_Map, Player_Details_Map,DuplicateMap);

    {player_response, {GameId, Move, PlayerName}} ->
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
    
    PlayerOneRematch = hd(Players_List),
    PlayerTwoRematch =  lists:last(Players_List),
    PlayerOneMoves = maps:get(GameId, UpdatedPlayerOneMap, []),
    PlayerTwoMoves = maps:get(GameId, UpdatedPlayerTwoMap, []),
    
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
                % List_Of_Addition = maps:get(PlayerTwoRematch,DuplicateMap),
            
                % UpdatedUsedCredits = element(1,List_Of_Addition)+1,
                % UpdatedRemainingCredits = element(2,List_Of_Addition)-1,
                % UpdatedPlayerMapAddition = maps:put(PlayerOneRematch, {UpdatedUsedCredits, UpdatedRemainingCredits}, DuplicateMap),
                % io:format("~p player@Creditssssssss ~n",[UpdatedPlayerMapAddition]),
                 if 
                    OneLastMove == 1 ->
                        OneLastMovePrintOne = rock;
                    OneLastMove == 2 ->
                        OneLastMovePrintOne = paper;
                    OneLastMove == 3 ->
                        OneLastMovePrintOne = scissors;
                    true ->
                        OneLastMovePrintOne = OneLastMove
                end,

                if 
                    TwoLastMove == 1 ->
                        TwoLastMovePrintOne = rock;
                    TwoLastMove == 2 ->
                        TwoLastMovePrintOne = paper;
                    TwoLastMove == 3 ->
                        TwoLastMovePrintOne = scissors;
                    true ->
                        TwoLastMovePrintOne = TwoLastMove
                end,
        
                io:format("$ (~p) ~p:~p -> ~p:~p = ~p loses [~p credits left]~n",[GameId,PlayerOneRematch,OneLastMovePrintOne,PlayerTwoRematch,TwoLastMovePrintOne,PlayerTwoRematch,Current_Player_Two_Credits]),
                if 
                   Current_Player_Two_Credits ==0 ->
                   whereis(PlayerTwoRematch) ! {disqualify_player, PlayerTwoRematch},
                   io:format("- Player Disqualified : ~p ~n",[PlayerTwoRematch]),
                   FilteredMap = maps:filter(fun(_Key, Value) -> Value > 0 end, Temp_Map),
                   Size = maps:size(FilteredMap),

                   if 
                        Size == 1 ->
                            ResultMapOne = maps:fold(
                                    fun(Key, Value, Acc) ->
                                        case maps:is_key(Key, Acc) of
                                            true ->
                                                NewValue = maps:get(Key, Acc) - Value,
                                                maps:put(Key, NewValue, Acc);
                                            false ->
                                                maps:put(Key, -Value, Acc)
                                        end
                                    end,
                                    DuplicateMap,
                                     Temp_Map
                                ),
                            io:format("\nWe have a Winner...~n"),
                            io:format("** Tournament Report ** ~n"),
                            io:format("~n"),
                            io:format("Players: ~n"),  
                            io:format("~n"),
                            % io:format("~p ~n",[ResultMapOne]),
                            % io:format("~p ~n",[Temp_Map]),
                            % io:format("~p ~n",[DuplicateMap]),
                            OneKeys = maps:keys(ResultMapOne),
                            lists:foreach(
                                fun(Key) ->
                                    CreditsUsed = maps:get(Key, ResultMapOne),
                                    CreditsRemaining = maps:get(Key, Temp_Map),
                                    io:format("~s: credits used: ~p, credits remaining: ~p~n", [Key, CreditsUsed, CreditsRemaining])
                                end,
                                OneKeys
                                ),
                                io:format("\n"),
                            io:format("Total Games:~p ~n \n",[GameId]),
                            io:format("Winner ~p ~n \n",[maps:keys(FilteredMap)]),
                            io:format("See You Next Year... \n ~n");
                        true->
                            master_listener(Temp_Map, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,DuplicateMap)
                    end;
                   
                   true ->
                        master_listener(Temp_Map, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,DuplicateMap)

                end;

                (OneLastMove == 3 andalso TwoLastMove == 1) orelse (OneLastMove == 2 andalso TwoLastMove == 3) orelse (OneLastMove == 1 andalso TwoLastMove == 2) ->  
                Current_Player_One_Credits = maps:get(PlayerOneRematch,MainMap)-1,
                Temp_Map_Two = maps:put(PlayerOneRematch,Current_Player_One_Credits,MainMap),

                % List_Of_Addition_Two = maps:get(PlayerOneRematch,DuplicateMap),
                % UpdatedUsedCreditsTwo = element(1,List_Of_Addition_Two)+1,
                % UpdatedRemainingCreditsTwo = element(2,List_Of_Addition_Two)-1,
                % UpdatedPlayerMapAdditionTwo = maps:put(PlayerTwoRematch, {UpdatedUsedCreditsTwo, UpdatedRemainingCreditsTwo}, DuplicateMap),
                % io:format("~p player@Creditssssssss ~n",[UpdatedPlayerMapAdditionTwo]),
                if 
                    OneLastMove == 1 ->
                        OneLastMovePrint = rock;
                    OneLastMove == 2 ->
                        OneLastMovePrint = paper;
                    OneLastMove == 3 ->
                        OneLastMovePrint = scissors;
                    true ->
                        OneLastMovePrint = OneLastMove
                end,
                if 
                    TwoLastMove == 1 ->
                        TwoLastMovePrint = rock;
                    TwoLastMove == 2 ->
                        TwoLastMovePrint = paper;
                    TwoLastMove == 3 ->
                        TwoLastMovePrint = scissors;
                    true ->
                        TwoLastMovePrint = TwoLastMove
                end,

                io:format("$ (~p) ~p:~p -> ~p:~p = ~p loses [~p credits left]~n",[GameId,PlayerTwoRematch,TwoLastMovePrint,PlayerOneRematch,OneLastMovePrint,PlayerOneRematch,Current_Player_One_Credits]),

                if 
                   Current_Player_One_Credits ==0 ->
                        whereis(PlayerOneRematch) ! {disqualify_player, PlayerOneRematch},
                                
                        io:format("- Player Disqualified : ~p ~n",[PlayerOneRematch]),
                        Filtered_Map_Two = maps:filter(fun(_Key, Value) -> Value > 0 end, Temp_Map_Two),
                        Size_Two = maps:size(Filtered_Map_Two),
                        if 
                            Size_Two == 1 ->
                                 ResultMap = maps:fold(
                                    fun(Key, Value, Acc) ->
                                        case maps:is_key(Key, Acc) of
                                            true ->
                                                NewValue = maps:get(Key, Acc) - Value,
                                                maps:put(Key, NewValue, Acc);
                                            false ->
                                                maps:put(Key, -Value, Acc)
                                        end
                                    end,
                                    DuplicateMap,
                                      Temp_Map_Two
                                ),
                                Keys = maps:keys(ResultMap),
                                io:format("~n"),
                                io:format(" We have a Winner...~n"),
                                io:format("** Tournament Report ** ~n"),
                                io:format("\n"),
                                io:format("Players: ~n"),
                                io:format("~n"),
                                % io:format("~p ~n",[Temp_Map_Two]),
                                % io:format("~p ~n",[DuplicateMap]),
                                    % io:format("~p~n", [ResultMap]),
                                    % io:format("~p~n", [Temp_Map_Two]),
                                lists:foreach(
                                fun(Key) ->
                                    CreditsUsed = maps:get(Key, ResultMap),
                                    CreditsRemaining = maps:get(Key, Temp_Map_Two),
                                    io:format("~s: credits used: ~p, credits remaining: ~p~n", [Key, CreditsUsed, CreditsRemaining])
                                end,
                                Keys
                                ),
                                % io:format("~p~n", [DuplicateMap]),                                
                                io:format("\n Total Games:~p ~n \n",[GameId]),
                                io:format("Winner ~p ~n \n",[maps:keys(Filtered_Map_Two)]),
                                io:format("See You Next Year... \n ~n");

                            true->
                                master_listener(Temp_Map_Two, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,DuplicateMap)
                        end;
                   true ->
                    master_listener(Temp_Map_Two, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,DuplicateMap)
                end;
            
                (OneLastMove == 1 andalso TwoLastMove == 1) orelse (OneLastMove == 2 andalso TwoLastMove == 2) orelse (OneLastMove == 3 andalso TwoLastMove == 3) -> 
                     if 
                    OneLastMove == 1 ->
                        OneLastMovePrintTwo = rock;
                    OneLastMove == 2 ->
                        OneLastMovePrintTwo = paper;
                    OneLastMove == 3 ->
                        OneLastMovePrintTwo = scissors;
                    true ->
                        OneLastMovePrintTwo = OneLastMove
                end,
 
                    io:format("* {~p} Game Draw, Players chose -> ~p ~n",[GameId,OneLastMovePrintTwo]),
                    whereis(PlayerOneRematch) ! {choose_move, {GameId,PlayerOneRematch }},
                    whereis(PlayerTwoRematch) ! {choose_move, {GameId,PlayerTwoRematch}},
                    master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,DuplicateMap);
                true ->
                    master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,DuplicateMap)
            end;   
        true ->
            master_listener(MainMap, EligiblePlayersMap, Game_id, Players_Map, UpdatedPlayerOneMap, UpdatedPlayerTwoMap, Player_Details_Map,DuplicateMap)  
    end
end.