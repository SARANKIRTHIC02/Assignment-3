%%% RPS.erl %%%

-module(rps).
-export([start_game/0, player/1, master/0]).

start_game() ->
    spawn(rps, master, []).

player(Choice) ->
    Master = whereis(master),
    GameID = make_ref(),
    Master ! {self(), GameID, Choice},
    receive
        {GameID, Winner} ->
            io:format("Player ~p: Winner ~p~n", [self(), Winner])
    end.

master() ->
    receive
        {Player1, GameID, Choice1} ->
            receive
                {Player2, GameID, Choice2} ->
                    Winner = determine_winner(Choice1, Choice2),
                    Player1 ! {GameID, Winner},
                    Player2 ! {GameID, Winner}
            end
    end.

determine_winner(rock, scissors) -> player1;
determine_winner(scissors, rock) -> player2;
determine_winner(paper, rock) -> player1;
determine_winner(rock, paper) -> player2;
determine_winner(scissors, paper) -> player1;
determine_winner(paper, scissors) -> player2;
determine_winner(_, _) -> draw.
