# PapyrusCore
![](https://reposs.herokuapp.com/?path=ChrisAU/PapyrusCore)

Reusable library for playing Scrabble games.

### Bag
The tile bag, provides methods for drawing and replacing tiles.

### Board
The current board representation.

### Dawg
This module is essentially a wrapper for the word list, it provides a lookup method and a way of returning anagrams given a set of parameters. Dawg stands for directed acyclic word graph.

## Game
Initialising a game of scrabble can be done using this class, simply call the newGame or restoreGame.

Solver state will be restored using player information, however developer is responsible for restoring bag state.

### Player
A player can be either a Human or a Computer, Computer's have a difficulty associated with them and are automated. Both have the solutions they have played, the tiles they have in their rack and their score.

Solving algorithm loosely based on [scrabble-solver](https://github.com/ipha/scrabble-solver) by [ipha](https://github.com/ipha)
