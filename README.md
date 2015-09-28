# PapyrusCore

Reusable library for playing Scrabble games.

## Papyrus
Initialising a game of scrabble can be done using this class, simply call the newGame method on an instance.

### Boundary 
A boundary is a representation of two positions which is used internally for a myriad of different tasks. AI uses this class to calculate possible words (beta).

### Dawg 
This module is essentially a wrapper for the word list, it provides a lookup method and a way of returning anagrams given a set of parameters. Dawg stands for directed acyclic word graph.

(Submodule - https://github.com/ChrisAU/Dawg)

### Move
This module determines possible moves on the current board for a player and dawg. This is what the AI will use in determining the best possible play.

### Player
A player is an individual user playing in the current instance of Papyrus, they may be either human or AI and have a score and tiles associated with them.

### Position
A position represents a particular row, column and axis.

### Square
A square represents an individual square on the board providing context to its type, tile, and position.

### Tile
A tile represents an individual character/value pair in the game, its used extensively internally. Tiles have a placement property which provides context where it is in the flow of the game. Tiles may be owned by players and squares.
