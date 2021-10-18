/// Copyright (c) 2021 Matthew Martin
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Messages

typealias GameID = String

class TriviaGame: NSObject, Codable {
  static let maxPlayers: Int = 2
  var id: GameID = UUID().compressedString
  var c: CategoryID         // category ID
  var i: QuestionNumber = 0 // currentIndex
  var m: ModeID = 0         // mode index
  var n: QuestionNumber?    // nudgeIndex
  var p: [Player] = []      // players
  var q: [Question] = []    // questions
  var t: Date = Date()      // sentTime
  var r: TimeInterval?      // timeRemaining
  var s: PlayerID?          // senderID
  
  var category: Category? {
    return Category.list?.filter {
      $0.id == c
    }.first
  }
  
  var initialIndex: QuestionNumber {
    guard let player = activePlayer,
          let lastReveal = player.lastReveal,
          var i = mode.numQuestions else {
      return currentIndex
    }
    
    while i > lastReveal && i > 0 {
      i -= 1
      
      guard let _ = player.responses[i] else {
        continue
      }
      
      break
    }
    
    return i
  }
  
  var isComplete: Bool {
    return GameMode.list[m].isComplete(self)
  }
  
  var isWaiting: Bool {
    guard inactivePlayers.isEmpty || !haveAnswered(players: inactivePlayers) else {
      return false
    }
    
    return hasAnswered(player: activePlayer)
  }
  
  var mode: GameMode {
    get {
      return GameMode.list[m]
    }
    
    set {
      m = GameMode.list.firstIndex(of: newValue) ?? m
    }
  }
  
  var sentTime: Date {
    get {
      return t
    }
    
    set {
      t = newValue
    }
  }
  
  var timeRemaining: TimeInterval? {
    get {
      return r
    }
    
    set {
      r = newValue
    }
  }
  
  /**
   Initialized a new game with the category and mode provided.
   
   - Parameter category: The ID for the questions' category.
   - Parameter mode: The gameplay mode's index.
   
   - Returns: A new game that will be populated with questions from the given category.
   */
  init(withCategory category: CategoryID, mode: ModeID) {
    c = category
    m = mode
    super.init()
  }
  
  /**
   Returns a condensed copy of the game for encoding as a URL.
   
   - Returns: A minified trivia game.
   */
  func compressed() throws -> TriviaGame {
    let encoded = try JSONEncoder().encode(self)
    let condensedGame = try JSONDecoder().decode(TriviaGame.self, from: encoded)
    
    for player in condensedGame.players {
      player.compressResponses()
    }
    
    return condensedGame
  }
  
  /**
   Prepares the game to be serialized and attached to a message.
   */
  func prepareToSend() {
    sentTime = Date()
    senderID = activePlayer?.id
    timeRemaining = nil
    activePlayer = nil
    
    guard mode is RapidFireMode else {
      return
    }
    
    timeRemaining = nil
    
    if !isComplete {
      currentIndex = 0
    }
  }
  
  /**
   Sets time remaining to the maximum time for the game mode.
   */
  func resetTime() {
    if timeRemaining == nil, let maxTime = mode.timeLimit {
      timeRemaining = maxTime
    }
  }
  
  /**
   Decodes a trivia game from the message provided.
   
   - Parameter message: The message to decode.
   
   - Returns: A game read from the message URL.
   */
  static func decode(from message: MSMessage?) -> TriviaGame? {
    guard let messageURL = message?.url else {
      return nil
    }
    
    let components = URLComponents(url: messageURL, resolvingAgainstBaseURL: false)
    let encoded = components?.queryItems?.first?.value
    
    guard let gameData = encoded?.data(using: .utf8) else {
      return nil
    }
    
    let game = try? JSONDecoder().decode(TriviaGame.self, from: gameData)
    IAPManager.shared.isActive = game?.mode is TurnBasedMode
    
    game?.players.forEach { player in
      player.restoreResponses(toQuestions: game?.questions)
    }
    
    return game
  }
}
