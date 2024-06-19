
% % -module(player).
% % -export([start/0, player_listener/3]).

% % start() ->
% %     spawn(player, player_listener, player_map).

% % player_listener(Name, EligiblePlayers, MainMap) ->
% %     receive
% %         {message, {Name,  Initiate }} ->
% %             io:format("~s received 'Initiate' message  ~n", [Name]),
% %             % io:format("Second line \n"),
% %             io:fwrite("~p received 'Initiate' message~n", [whereis(Name)]),
% %             % io:format("Third line \n")
% %             self() ! {request_to_play, Name},
% %             io:fwrite("~p After message~n", [whereis(Name)]);

% %         {request_to_play, Name} ->
% %             io:format("~s REQUEST TO PLAY~n", [Name]),
% %             Random_Ind = rand:uniform(length(EligiblePlayers)),
% %             Random_Player = lists:nth(Random_Ind, EligiblePlayers)
% %             % whereis(Random_Player) ! {accept, {Random_Player}}


% %         % {accept, {Random_Player}} -> 
% %         %     MapValue = maps:get(Random_Player, MainMap),
% %         %     io:format("~s ACCEPT~n", [Name]),
% %         %     if
% %         %         MapValue > 0 ->
% %         %             io:format("~s PLAYER~n", [Random_Player]);
% %         %         true ->
% %         %             io:format("Invalid player or MainMap value~n")
% %         %     end,
% %         %     player_listener(Name, EligiblePlayers, MainMap);
% %         % _ ->
% %         %     player_listener(Name, EligiblePlayers, MainMap)
% %     end.


% -module(player).
% -export([start/0, player_listener/5]).

% start() ->
%     spawn(player, player_listener, []).

% player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId) ->
%     receive
%         {message, {Name, "Initiate"}} ->
%             % io:format("~s received 'Initiate' message~n", [Name]),
%             % io:fwrite("~p received 'Initiate' message~n", [self()]),
%             self() ! {request_to_play, Name},
%             % io:fwrite("~p After message~n", [self()]),
%             player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId);
        
%         {request_to_play, Name} ->
%             io:format("~s REQUEST TO PLAY~n", [Name]),
%             Random_Ind = rand:uniform(length(EligiblePlayers)),
%             Random_Player = lists:nth(Random_Ind, EligiblePlayers),
%             % io:fwrite("~p Current Name~n", [Name]),
%             % io:fwrite("~p INDEXXXXXXXX~n", [Random_Ind]),
%             % io:fwrite("~p Random Player Selected~n", [Random_Player]),
%             whereis(Random_Player) ! {accept, {Random_Player}},
%             player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId);
        
%         {accept, {Random_Player}} -> 
%             io:fwrite("~p The Random PLayer sent~n", [Random_Player]),

%             MapValue = maps:get(Random_Player, MainMap),
%             io:format("~s ACCEPT~n", [Name]),
%             if
%                 MapValue > 0 ->
%                     io:format("~s PLAYER~n", [Random_Player]);
%                 true ->
%                     io:format("Invalid player or MainMap value~n")
%             end,
%             player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId);
        
%         _ ->
%             player_listener(Name,Credits, EligiblePlayers, MainMap,MasterId)
%     end.


-module(player).
-export([start/0, player_listener/5, flush/0]).

start() ->
    spawn(player, player_listener, ["Alice", 100, ["Bob", "Charlie"], #{"Alice" => 100, "Bob" => 200, "Charlie" => 300}, self()]).

player_listener(Name, Credits, EligiblePlayers, MainMap, MasterId) ->
    receive
        {message, {Name, "Initiate"}} ->
            io:format("~s received 'Initiate' message~n", [Name]),
            io:fwrite("~p received 'Initiate' message~n", [self()]),
            self() ! {request_to_play, Name},
            io:fwrite("~p After message~n", [self()]),
            player_listener(Name, Credits, EligiblePlayers, MainMap, MasterId);
        
        {request_to_play, Name} ->
            io:format("~s REQUEST TO PLAY~n", [Name]),
            Random_Ind = rand:uniform(length(EligiblePlayers)),
            Random_Player = lists:nth(Random_Ind, EligiblePlayers),
            io:fwrite("~p Current Name~n", [Name]),
            io:fwrite("~p INDEXXXXXXXX~n", [Random_Ind]),
            io:fwrite("~p Random Player Selected~n", [Random_Player]),
            whereis(Random_Player) ! {accept, {Random_Player}},
            player_listener(Name, Credits, EligiblePlayers, MainMap, MasterId);
        
        {accept, {Random_Player}} -> 
            io:fwrite("~p The Random Player sent~n", [Random_Player]),
            MapValue = maps:get(Random_Player, MainMap),
            io:format("~s ACCEPT~n", [Name]),
            if
                MapValue > 0 ->
                    io:format("~s PLAYER~n", [Random_Player]);
                true ->
                    io:format("Invalid player or MainMap value~n")
            end,
            player_listener(Name, Credits, EligiblePlayers, MainMap, MasterId);
        
        _ ->
            player_listener(Name, Credits, EligiblePlayers, MainMap, MasterId)
    end.

flush() ->
    receive
        _ -> flush()
    after 0 ->
        ok
    end.
