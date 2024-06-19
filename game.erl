
% -module(game).
% -export([start/1]).

% start(Args) ->
%     PlayerFile = lists:nth(1, Args),
%     {ok, PlayerInfo} = file:consult(PlayerFile),
%     io:fwrite("Player info: ~p~n", [PlayerInfo]),
%     MainMap = maps:from_list(PlayerInfo),
%     io:fwrite("Main Map: ~p~n", [MainMap]),
% %     List_of_Keys = maps:keys(MainMap),
%     io:fwrite("** Rock, Paper Scissors World Championship **\n"),
% %     process_Resgister(List_of_Keys),

% Pid = spawn(fun() -> io:format("Hello from a new process~n") end),
% register("first",Pid),
% WorkerPid = whereis("first"),
% io:format("Worker PID: ~p~n", [WorkerPid]).

% -module(game).
% -export([start/1]).

% start(Args) ->
%     % Get the player file from the arguments
%     PlayerFile = lists:nth(1, Args),
    
%     % Read the player information from the file
%     {ok, PlayerInfo} = file:consult(PlayerFile),
%     io:fwrite("Player info: ~p~n", [PlayerInfo]),
    
%     % Convert the player information to a map
%     MainMap = maps:from_list(PlayerInfo),
%     io:fwrite("Main Map: ~p~n", [MainMap]),
    
%     % Print the header
%     io:fwrite("** Rock, Paper Scissors World Championship **\n"),
    
%     Spawn_Player(MainMap).



% Spawn_Player(Map)->
%     lists:foreach(
%         fun(Key) ->
%             Pid = spawn(fun() -> io:format("Hello from a new process~n") end),
%             register(Key, Pid),
%             WorkerPid = whereis(Key),
%             io:format("Worker PID for ~p: ~p~n", [Key, WorkerPid])
%         end,
%         maps:keys(Map)).
  
% -module(game).
% -export([start/1, spawn_player/1]).

% start(Args) ->
%     % Get the player file from the arguments
%     PlayerFile = lists:nth(1, Args),
    
%     % Read the player information from the file
%     case file:consult(PlayerFile) of
%         {ok, PlayerInfo} ->
%             io:fwrite("Player info: ~p~n", [PlayerInfo]),
            
%             % Convert the player information to a map
%             MainMap = maps:from_list(PlayerInfo),
%             io:fwrite("Main Map: ~p~n", [MainMap]),
            
%             % Print the header
%             io:fwrite("** Rock, Paper Scissors World Championship **\n"),
            
%             spawn_player(MainMap);
%         {error, Reason} ->
%             io:fwrite("Error reading player file: ~p~n", [Reason])

%     end,
%     io:format("Check PID for ~p: ~p~n", [sam, whereis(sam)]).

% spawn_player(Map) ->
%     lists:foreach(
%         fun(Key) ->
%             % Pid = spawn(fun() -> 
%             %     timer:sleep(200)
%             %     % io:format("Hello from a new process~n")
%             Pid = spawn(player,player_listener,Key)
%             end),
%             register(Key, Pid),
%             WorkerPid = whereis(Key),
%             io:format("Worker PID for ~p: ~p~n", [Key, WorkerPid])
%         end,
%         maps:keys(Map)).






  
-module(game).
-export([start/1]).

start(Args) ->
    PlayerFile = lists:nth(1, Args),
        case file:consult(PlayerFile) of
        {ok, PlayerInfo} ->
            io:fwrite("Player info: ~p~n", [PlayerInfo]),            
            MainMap = maps:from_list(PlayerInfo),
            io:fwrite("Main Map: ~p~n", [MainMap]),
            % Print the header
            io:fwrite("** Rock, Paper Scissors World Championship **\n").
    %         spawn_player(MainMap);
    %     {error, Reason} ->
    %         io:fwrite("Error reading player file: ~p~n", [Reason])

    % end,
    % io:format("Check PID for ~p: ~p~n", [sam, whereis(sam)]).