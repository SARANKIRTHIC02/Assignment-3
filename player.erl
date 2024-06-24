
-module(player).
-export([player_listener/6]).

player_listener(Name, Credits, EligiblePlayers,EligiblePlayersMap, MainMap, MasterId) ->
    receive
        {message, {Name, initiate}} ->
            self() ! {request_to_play, Name},
            player_listener(Name, Credits, EligiblePlayers,EligiblePlayersMap, MainMap, MasterId);

        {request_to_play, Name} ->
            NamePLayerCredits = maps:get(Name,MainMap),
            if 
            NamePLayerCredits > 0 ->
            Random_Ind = rand:uniform(length(EligiblePlayers)),
            Player2 = lists:nth(Random_Ind, EligiblePlayers),
            whereis(Player2) ! {accept, {Name}},
            timer:send_after(100, self(),  {request_to_play, Name});
            true ->
                ok

            end,
            player_listener(Name, Credits, EligiblePlayers, EligiblePlayersMap,MainMap, MasterId);

        {accept, {Player1Name}} ->
            NameValue = maps:get(Name, MainMap),
            if
                NameValue > 0 ->
                    whereis(Player1Name) ! {message_player_2, Name};
                true ->
                    ok
            end,
            player_listener(Name, Credits, EligiblePlayers, EligiblePlayersMap,MainMap, MasterId);

        {player_2_accpeted, Player2Name} ->
            MasterId ! {create_game, Name, Player2Name},
            player_listener(Name, Credits, EligiblePlayers, EligiblePlayersMap,MainMap, MasterId);
        
        {player_2_rejected, Player2Name}->
            List_To_Change = maps:get(Name,EligiblePlayers),
            NewList = lists:delete(Player2Name,List_To_Change),
            Add_To_Eligible_Map = maps:put(Name,NewList,EligiblePlayers),
            player_listener(Name, Credits, EligiblePlayers, Add_To_Eligible_Map,MainMap, MasterId);

        {message_player_2, Player2Name} ->
            RandomValue = maps:get(Name, MainMap),
            if
                RandomValue > 0 ->
                    whereis(Name) ! {player_2_accpeted, Player2Name};
                true ->
                    ok                  
            end,
            player_listener(Name, Credits, EligiblePlayers, EligiblePlayersMap,MainMap, MasterId);

        {choose_move, {Temp_id, PlayerName}} ->
            Move = rand:uniform(3),
            MasterId ! {player_response, {Temp_id, Move, PlayerName}},
            player_listener(Name, Credits, EligiblePlayers,EligiblePlayersMap ,MainMap, MasterId);

        {disqualify_player, PlayerNameDisqualify} ->
            % io:format(" xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ~p ~n",[PlayerNameDisqualify]),
            Edited_Main_Map = maps:put(PlayerNameDisqualify,0,MainMap),
            player_listener(Name, Credits, EligiblePlayers,EligiblePlayersMap ,Edited_Main_Map, MasterId)
    end.
