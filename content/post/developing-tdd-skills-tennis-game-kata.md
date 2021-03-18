---
title: "Developing TDD skills using the Tennis Game Kata"
description: ""
date: 2021-02-20T15:54:12Z
tags: []
categories: []
draft: true
---


## Overview

Kata intro without spelling out the full description
<!--more-->

caveat that I did the refactoring kata first so implementation ideas "tainted" by that

## Areas of focus

### Testing Behaviours not implementation

### Using ZOMBIEs to choose what to test

## Test Cases

* Score is "Love-all" at start of game
* Scores is "Fifteen-Love" when player 1 scores the first point
* Scores is "Love-Fifteen" when player 2 scores the first point
* Score is "Forty-Fifteen" when player 1 has scored 3 points and player 2 has scored 1 point
* Score is "Fifteen-all" or "Thirty-all" when scores are tied and players have scored fewer than 3 points
* Score is "Deuce" when both players have scored 3 points
* Score is "Advantage player 1" when player 1 wins the point after Deuce
* Score is "Deuce" when both players have scored 3+ points and the score is tied
* Score is "Player 2 Won" when player 2 has 4+ points and the lead is at least two points

## First test: Love-all at start of game

#### Red

The start of the game marks our "zero" point. No points have been scored by either player so the score should be Love-all. Our first test quite simply initialises a TennisGame object with two players and immediately checks the score. 

```python
from tennis_game import TennisGame


def test_score_is_love_all_at_start_of_game():
    game = TennisGame("Federer", "Nadal")

    assert game.score() == "Love-all"
```

I had cheated a little bit and had the following skeleton to start with based on the refactoring kata, but it's simple enough for me to not be too concerned with the shortcut. It also omits any decision on how scoring should actually work which should allow enough space to experiment.

```python
class TennisGame:
    def __init__(self, player1_name, player2_name):
        self.player1_name = player1_name
        self.player2_name = player2_name

    def score(self):
        pass

    def won_point(self, player_name):
        pass
```

Netherless, the test fails:

```bash
============================================= test session starts ==============================================
platform darwin -- Python 3.8.5, pytest-6.2.2, py-1.10.0, pluggy-0.13.1
collected 1 item                                                                                               

tests/test_tennis_game.py F                                                                              [100%]

=================================================== FAILURES ===================================================
___________________________________ test_score_is_love_all_at_start_of_game ____________________________________

    def test_score_is_love_all_at_start_of_game():
        game = TennisGame("Federer", "Nadal")
    
>       assert game.score() == "Love-all"
E       AssertionError: assert None == 'Love-all'

```

It's really important to see your test fail to ensure that it has tried to check for a specific piece of functionality at some point in time.

#### Green

Getting our first test to pass when using TDD couldn't be easier. We're trying to write as little code as possible to ensure that all code paths are verified by tests as well as avoiding over-design. In this case we can simply return the hard-coded score of "Love-all", all other scores are impossible in our simplistic games-have-only-ever-just-started world.

```python
...
    def score(self):
        return "Love-all"
...
```



```bash
============================================= test session starts ==============================================
platform darwin -- Python 3.8.5, pytest-6.2.2, py-1.10.0, pluggy-0.13.1
collected 1 item                                                                                               

tests/test_tennis_game.py .                                                                              [100%]

============================================== 1 passed in 0.01s ===============================================
Name                 Stmts   Miss  Cover   Missing
--------------------------------------------------
src/tennis_game.py       8      1    88%   12
--------------------------------------------------
TOTAL                    8      1    88%

```

Our test passes and there's no particularly obvious refactoring at this stage, so we move on to the next requirement.

## Scores is "Fifteen-Love" when player 1 scores the first point

The three scenarios that follow are very similar. Once players have won some points we'd expect to see the score reflect that. These scenarios start to help us cross off the One and Many items to test when following the ZOMBIEs guide.

#### Red

In order to make this happen we now have to start to care about how points can be accrued.

We have a `won_point` method that takes the name of the player who won the point, but it's up to us to decide how to keep track of the points for each player internally. At this point in might be tempting to start to add tests that reach into your implemenation details in order to check that `won_point` does the basic job you've asked it to do. Perhaps you'd do that by writing a test that does something like the following:

```python
def test_won_point_increments_score_for_player_one():
    player1_name = "Federer"
    player2_name = "Nadal"
    game = TennisGame(player1_name, player2_name)

    game.won_point(player1_name)

    assert game.player1_points == 1
    assert game.player2_points == 0
```

However, the core idea behind testing behaviours encourages us NOT to do this and instead see the `score` method as the window through which we will observe changes to the internal state that player points represents.

More concretely in this scenario, instead of testing that the player's points have been incremented let us test that a player winning a point is reflected by the appropriate change to the score of the game.

```python
def test_score_fifteen_love_when_player_1_scores_first_point():
    player1_name = "Federer"
    player2_name = "Nadal"
    game = TennisGame(player1_name, player2_name)

    game.won_point(player1_name)

    assert game.score() == "Fifteen-Love"
```

WIth this approach we are treating our code as a bit more of a black box. We don't know and/or care about how the points are implemented, we **do** care about what the score is. This frees us to change how we keep track of points inside `TennisGame` without affecting the observable behaviour.

#### Green + Refactor

Back to getting our tests to pass. Solving this for the possible scores that each player can have isn't too taxing once we decide that we'll use integers for points and map those over to the text representation as part of the score method.

```python
...

def __init__(self, player1_name, player2_name):
    self.player1_name = player1_name
    self.player2_name = player2_name
    self.player1_points = 0
    self.player2_points = 0

    self.point_map = {
        0: "Love",
        1: "Fifteen",
        2: "Thirty",
        3: "Forty",
    }

def score(self):
    if self.player1_points == self.player2_points:
        return "Love-all"
    else:
        player1_score = self.point_map[self.player1_points]
        player2_score = self.point_map[self.player2_points]

        return f"{player1_score}-{player2_score}"
...
```

I failed to commit often enough at this point to capture the deltas between getting the tests to pass and refactoring. The point map may not have been extracted out as an attribute initially. It's also worth noting that we still only support a single case for a tied game (start of game).

With this implementation in place tests for 0-15 and 40-15 passed as soon as they were written. It was useful to mutate the point map and break the code in order to force them to fail, though. Just to make sure!

### Test refactoring

The biggest refactoring following these tests was to refactor the test code to remove duplication. Using `pytest` parameterisation helped reduce the footprint of the test cases:

```python
@pytest.mark.parametrize(
    "player1_score, player2_score, expected_score",
    [
        (1, 0, "Fifteen-Love"),
        (0, 1, "Love-Fifteen"),
        (3, 1, "Forty-Fifteen"),
    ]
)
def test_standard_in_game_scoring_scenarios(player1_score, player2_score, expected_score):
    player1_name = "Federer"
    player2_name = "Nadal"
    game = TennisGame(player1_name, player2_name)

    for point in range(max(player1_score, player2_score)):
        if point < player1_score:
            game.won_point(player1_name)
        if point < player2_score:
            game.won_point(player2_name)

    assert game.score() == expected_score
```

But I'm not sure if the initial readability has been well maintained by doing this. The for loop needs to be read to see what it's doing.

## Score is "Fifteen-all" or "Thirty-all" when scores are tied and players have scored fewer than 3 points



## Score is "Deuce" when both players have scored 3 points



## Score is "Advantage player 1" when player 1 wins the point after Deuce



## Score is "Deuce" when both players have scored 3+ points and the score is tied



## Score is "Player 2 Won" when player 2 has 4+ points and the lead is at least two points



## Reflection

Code on github