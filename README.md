# PapyrusCore
![](https://reposs.herokuapp.com/?path=ChrisAU/PapyrusCore)

Reusable library for playing Scrabble games.

Example implementation of a 2 player AI game:
```swift
// Create a serial queue for game actions to be processed on
// This ensures we don't block the main queue while performing calculations
let gameQueue = NSOperationQueue()
gameQueue.maxConcurrentOperationCount = 1

var game: Game!
gameQueue.addOperationWithBlock { [weak self] in
  guard let strongSelf = weakSelf else { return }
  // Load Dawg dictionary file
  let dictionary = Dawg.load(NSBundle.mainBundle().pathForResource("sowpods", ofType: "bin")!)!
  // Create some players
  let computer = Computer()
  // You can also specify difficulty...
  let computer2 = Computer(difficulty: .Easy)
  // You can also create Human players here
  // let human = Human()
  // Setup game
  strongSelf.game = Game.newGame(dictionary, bag: Bag(), players: [computer, computer2], eventHandler: { (event) in
    NSOperationQueue.mainQueue().addOperationWithBlock {
      // TODO: Update UI
      print(event)         
  })
  // Start
  strongSelf.game.start()
}
```

### Bag
The tile bag, provides methods for drawing and replacing tiles.

### Board
The current board representation.

### Dawg
This module is essentially a wrapper for the word list, it provides a lookup method and a way of returning anagrams given a set of parameters. Dawg stands for directed acyclic word graph.

### Game
Initialising a game of scrabble can be done using this class, simply call the newGame or restoreGame.

Once you've created a Game object you have access to various methods for 'Human' play (i.e. swapping tiles, skipping your turn, validation of play, shuffling your rack, submitting plays).

AI play will be handled automatically once 'nextTurn' is called.

Solver state will be restored using player information, however developer is responsible for restoring bag state.

### Player
A player can be either a Human or a Computer, Computer's have a difficulty associated with them and are automated. Both have the solutions they have played, the tiles they have in their rack and their score.

Solving algorithm loosely based on [scrabble-solver](https://github.com/ipha/scrabble-solver) by [ipha](https://github.com/ipha)
