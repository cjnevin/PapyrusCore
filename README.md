# PapyrusCore

![](https://reposs.herokuapp.com/?path=ChrisAU/PapyrusCore&style=flat)
![](https://travis-ci.org/ChrisAU/PapyrusCore.svg?branch=master)

Reusable library for playing Scrabble games.

### Example implementation of a 3 player game (1 human, 2 computers):

```swift

// NOTE: Rather than block the main thread, the 'Lookup' object should be created on a background thread
// this has been omitted to reduce complexity

// Create a dictionary object for determining and validating moves
let dictionary = AnagramDictionary(filename: "DICTIONARY")!

// Create players that will be challenging eachother
let human = Human()
let hardAI = Computer()
let easyAI = Computer(difficulty: .Easy)
let players = [human, hardAI, easyAI]

// Now we have everything configured, we can create a Game object
let game = Game.newGame(dictionary: dictionary, players: players) { event in 
  // Switch to main thread before updating UI...
  NSOperationQueue.mainQueue().addOperationWithBlock {
    switch event {
      case let .Over(winner):
        print("Winner: \(winner)")
      
      case .TurnStarted:
        // UI should be enabled if game.player is 'Human'
        print("Turn Started")
      
      case .TurnEnded:
        // UI should be disabled if game.player is 'Human'
        print("Turn Ended")
    
      case let .Move(solution):
        print("Word Played \(solution.word)")
      
      case let .DrewTiles(letters):
        print("Drew Tiles \(letters)")
      
      case .SwappedTiles:
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
The current board representation, can be configured based on different game types.

#### Game
Initialising a game of scrabble can be done using this class, simply call the newGame or restoreGame.

Once you've created a Game object you have access to various methods for 'Human' play (i.e. swapping tiles, skipping your turn, validation of play, shuffling your rack, submitting plays).

AI play will be handled automatically once 'nextTurn' is called.

Solver state will be restored using player information, however developer is responsible for restoring bag state.

#### Player
A player can be either a Human or a Computer, Computer's have a difficulty associated with them and are automated. Both have the solutions they have played, the tiles they have in their rack and their score.

### Dependencies

#### AnagramDictionary
Allows us to quickly look-up anagrams using lexicographically equivalent comparison.

### Thanks

Solving algorithm loosely based on [scrabble-solver](https://github.com/ipha/scrabble-solver) by [ipha](https://github.com/ipha)
