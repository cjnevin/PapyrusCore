# PapyrusCore
![](https://reposs.herokuapp.com/?path=ChrisAU/PapyrusCore)

Reusable library for playing Scrabble games.

## Papyrus
Initialising a game of scrabble can be done using this class, simply call the newGame method on an instance.

### Boundary 
A boundary is a representation of two positions which is used internally for a myriad of different tasks.

### Dawg
This module is essentially the word list, it provides a lookup method and a way of returning anagrams given a set of parameters.

### Move
This module determines possible moves on the current board for a player and dictionary. This is what the AI will use in determining the best possible play.

### Play
This module provides methods for submitting plays for Papyrus to validate and execute internally.

### Player
A player is an individual user playing in the current instance of Papyrus, they may be either human or AI and have a score and tiles associated with them.

### Position
A position represents a particular row, column and axis.

### Square
A square represents an individual square on the board providing context to its type, tile, and position.

### Tile
A tile represents an individual character/value pair in the game, its used extensively internally. Tiles have a placement property which provides context where it is in the flow of the game. Tiles may be owned by players and squares.
