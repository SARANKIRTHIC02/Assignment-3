


-module(player).
-export([player_listener/5]).

player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId) ->
    receive
        {message, {Name, "Initiate"}} ->
            % io:format("~s received 'Initiate' message~n", [Name]),
            % io:fwrite("~p received 'Initiate' message~n", [self()]),
            self() ! {request_to_play, Name},
            % io:fwrite("~p After message~n", [self()]),
            player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId);
        
        {request_to_play, Name} ->
            % io:format("~s REQUEST TO PLAY~n", [Name]),
            Random_Ind = rand:uniform(length(EligiblePlayers)),
            Player2 = lists:nth(Random_Ind, EligiblePlayers),
            % io:fwrite("~p Current Name~n", [Name]),
            % io:fwrite("~p INDEXXXXXXXX~n", [Random_Ind]),
            % io:fwrite("~p Random Player Selected~n", [Random_Player]),
            %TODO: Check for 
            whereis(Player2) ! {accept, {Name}},
            player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId);
        
        {accept, {Player1Name}} -> 
            % io:fwrite("~p The Random PLayer sent~n", [Player1Name]),

            NameValue = maps:get(Name, MainMap),
            if 
                NameValue > 0 ->
                    whereis(Player1Name)! {message_player_2, Name};
                true ->
                    io:format("Invalid player or MainMap value~n")  
            end,
            player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId);

            % Send back to Player 1
        {message_player_2, Player2Name} ->
            % io:fwrite("Inside message player 2\n"),
            RandomValue = maps:get(Name, MainMap),
            if
                RandomValue > 0 ->
                    MasterId ! {create_game,Name,Player2Name},
                    io:format("~p Name ~p Random Player inside Create~n", [Name, Player2Name]);

                true ->
                    io:format("Invalid player or MainMap value~n")
            end,
            player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId);

        {choose_move, {Temp_id, PlayerName}} ->
            Move = rand:uniform(3),
            % io:format("Reached The Choose Move ~n"),
            MasterId ! {player_response, {Temp_id, Move, PlayerName}},
            io:format("Move Sent To Master ~p ~n",[Move]),

            player_listener(Name, Credits, EligiblePlayers, MainMap, MasterId)
        
    
        % _->
        %     player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId)


        
        end.

