# PapyrusCore

![](https://reposs.herokuapp.com/?path=ChrisAU/PapyrusCore&style=flat)
![](https://travis-ci.org/ChrisAU/PapyrusCore.svg?branch=swift-3.0)

Reusable library for playing Scrabble games.

### Example implementation of a 3 player game (1 human, 2 computers):

```swift

// NOTE: Rather than block the main thread, your 'Dictionary' object should be created on a background thread
// this has been omitted to reduce complexity

// Create a dictionary object for determining and validating moves
// Dictionary must conform to 'Lookup' protocol (like my AnagramDictionary)
let dictionary = AnagramDictionary(filename: "DICTIONARY")!

// Create players that will be challenging eachother
let human = Human()
let hardAI = Computer()
let easyAI = Computer(difficulty: .easy)
let players = [human, hardAI, easyAI]

// Path to configuration file
let configFileURL = ...

// Now we have everything configured, we can create a Game object
let game = Game(config: configFileURL, dictionary: dictionary, players: players) { event in 
  // Switch to main thread before updating UI...
  Dispatch.main.async() {
    switch event {
      case let .over(game, winner):
        print("Winner: \(winner)")
      
      case let .turnStarted(game):
        // UI should be enabled if game.player is 'Human'
        print("Turn Started")
      
      case let .turnEnded(game):
        // UI should be disabled if game.player is 'Human'
        print("Turn Ended")
    
      case let .move(game, solution):
        print("Word Played \(solution.word)")
      
      case let .drewTiles(game, letters):
        print("Drew Tiles \(letters)")
      
      case let .swappedTiles(game):
        print("Swapped Tiles")
    }
  }
}

// Finally, when you're ready to start the game you can call
game.start()
```

### Object Types

#### Bag
The tile bag, provides methods for drawing and replacing tiles in a distribution.

#### Board
The current board representation.

#### Game
Main class responsible for gameplay, handles saving and restoring game state (via `save(to:)` and `Game(restoring:)` methods).

Exposes various actions that a Human player may want to take including: move validation, shuffling and rearranging your rack, skipping, submitting moves, suggested moves, and swapping tiles. AI play will be handled automatically once `nextTurn` is called.

#### Player
A player can be either a Human or a Computer, Computer's have a difficulty associated with them and are automated. Both have the solutions they have played, the tiles they have in their rack and their score.

### Dependencies

#### Lookup
Protocol for dictionary lookup.

### Thanks

Solving algorithm loosely based on [scrabble-solver](https://github.com/ipha/scrabble-solver) by [ipha](https://github.com/ipha)
