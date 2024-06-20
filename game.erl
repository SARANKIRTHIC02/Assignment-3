% -module(game).
% -export([start/1]).

% start(Args) ->
%     % Get the player file from the arguments
%     PlayerFile = lists:nth(1, Args),
%     {ok, PlayerInfo} = file:consult(PlayerFile),
%     io:fwrite("Player info: ~p~n", [PlayerInfo]),

%     MainMap = maps:from_list(PlayerInfo),
%     io:fwrite("Main Map: ~p~n", [MainMap]),

%     EligiblePlayersMap = create_eligible_players_map(MainMap, MainMap),
%     lists:foreach(
%         fun({Name, Credits}) ->
%             Pid = spawn(player, player_listener, [Name,Credits, maps:get(Name, EligiblePlayersMap), maps:get(Name, MainMap)],self()),
%             register(Name, Pid),
%             Worker_pid = whereis(Name)
%             % timer:sleep(200)
%         end,
%         PlayerInfo
%     ),
    
%     %   lists:foreach(
%     %     fun(Name) ->
%     %         Current_Name = Name,
%     %         io:fwrite("Main Map: ~p~n", [Name])
%     %         Initiate = "Initiate",
%     %         Current = whereis(Name),
%     %         Current ! {message, {Current_Name, Initiate}}
%     %     end,
%     %     maps:keys(MainMap)
%     % ).

%         lists:foreach(
%         fun(Name) ->
%             % Current_Name = Name,
%             io:fwrite("Current Player: ~p~n", [Name]),
%             Initiate = "Initiate",
%             Current = whereis(Name),
%             Current ! {message, {Name, Initiate}}
%         end,
%         maps:keys(MainMap)
%     ).

% create_eligible_players_map(MainMap, EligiblePlayersMap) ->
%     lists:foldl(
%         fun({Player, _}, Acc) ->
%             EligiblePlayers = lists:delete(Player, maps:keys(EligiblePlayersMap)),
%             maps:put(Player, EligiblePlayers, Acc)
%         end,
%         #{},
%         maps:to_list(MainMap)
%     ).
-module(game).
-export([start/1]).

start(Args) ->
    % Get the player file from the arguments
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
            Worker_pid = whereis(Name)
            % io:format("Worker PID for ~p: ~p~n", [Name, Worker_pid])
        end,
        PlayerInfo
    ),
    % io:fwrite("Main Map: ~p~n", [EligiblePlayersMap]),

    lists:foreach(
        fun(Name) ->
            % io:fwrite("Current Player: ~p~n", [Name]),
            Initiate = "Initiate",
            Current = whereis(Name),
            Current ! {message, {Name, Initiate}}
        end,
        maps:keys(MainMap)
    ).


create_eligible_players_map(MainMap, EligiblePlayersMap) ->
    lists:foldl(
        fun({Player, _}, Acc) ->
            EligiblePlayers = lists:delete(Player, maps:keys(EligiblePlayersMap)),
            maps:put(Player, EligiblePlayers, Acc)
        end,
        #{},
        maps:to_list(MainMap)
    ).
