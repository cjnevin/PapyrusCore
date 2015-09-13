# PapyrusCore
![](https://reposs.herokuapp.com/?path=ChrisAU/PapyrusCore)

Reusable library for playing Scrabble games.

## Papyrus
Initialising a game of scrabble can be done using this class, simply call the newGame method on an instance.

### Boundary 
A boundary is a representation of two positions which is used internally for a myriad of different tasks.

### Intelligence
This module (currently defunct) should return possible plays given a specific boundary and tile array.

### Lexicon
This module is essentially the dictionary, but naming it that would have been confusing in Swift, it provides a lookup method and a way of returning anagrams given a set of parameters. 

Currently using a Trie (proposed by Appel & Guy "The World's Fastest Scrabble Algorithm", 1988) but there is a plan to change to a modified GADDAG (proposed by Steven Gordon, 1994) to provide bidirectional lookup, reduce memory consumption and download size.

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
