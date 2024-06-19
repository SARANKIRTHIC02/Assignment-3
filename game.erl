
-module(game).
-export([start/1]).

start(Args) ->
    PlayerFile = lists:nth(1, Args),
    {ok, PlayerInfo} = file:consult(PlayerFile),
    io:fwrite("Player info: ~p~n", [PlayerInfo]),
    MainMap = maps:from_list(PlayerInfo),
    io:fwrite("Main Map: ~p~n", [MainMap]),
    List_of_Keys = maps:keys(MainMap),
%     io:fwrite("List Of Keys: ~p~n", [List_of_Keys]),
%     Length_of_List = length(List_of_Keys),
%     Random_Number = rand:uniform(Length_of_List),
%     io:fwrite("Random Number: ~p~n", [Random_Number]),
%     Map_Check = lists:foldl(fun(X, AccMap) ->
%                                 Rest = lists:delete(X, List_of_Keys),
%                                 UpdatedMap = maps:put(X, Rest, AccMap),
%                                 UpdatedMap
%                             end, #{}, List_of_Keys),
%     io:fwrite("Final Map Check: ~p~n", [Map_Check]),
     Rand_Num = playerSelection(List_of_Keys),
    io:fwrite("** Rock, Paper Scissors World Championship **\n").



playerSelection(Keys) ->
     Random_Number = rand:uniform(length(Keys)),
     Random_Number_Two = rand:uniform(length(Keys)),
     io:fwrite("Random Number from func: ~p~n \n", [Random_Number]),
     io:fwrite("Random Number from func: ~p~n \n", [Random_Number_Two]),
     Random_Number.

