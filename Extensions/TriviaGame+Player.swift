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

extension TriviaGame {
  var players: [Player] {
    get {
      return p
    }
    
    set {
      p = newValue
    }
  }
  
  var activePlayer: Player? {
    get {
      return players.filter { $0.isActive == true }.first
    }
    
    set {
      players.forEach { $0.isActive = $0 == newValue }
    }
  }
  
  var allPlayersAnswered: Bool {
    return haveAnswered(players: players, min: TriviaGame.maxPlayers)
  }
  
  var challenger: Player? {
    return players.first
  }
  
  var inactivePlayers: [Player] {
    return players.filter { $0.isActive != true }
  }
  
  var senderID: PlayerID? {
    get {
      return s
    }
    
    set {
      s = newValue
    }
  }
  
  /**
   Populates the players using conversation participant data.
   
   - Parameter conversation: The active conversation.
   */
  func addPlayers(in conversation: MSConversation?) {
    guard let conversation = conversation else {
      return
    }
    
    let playerID = conversation.localParticipantIdentifier.compressedString
    
    if players.count < TriviaGame.maxPlayers && players[playerID] == nil {
      players.append(Player(id: playerID, questionCount: mode.numQuestions))
    }
    
    activePlayer = players[playerID]
  }
  
  /**
   Returns a boolean indicating whether the given player has answered the current question.
   
   - Parameter player: An optional for the player whose responses should be checked.
   
   - Returns: `true` if `player` is not `nil` and their answer is not `nil`, `false` otherwise.
   */
  func hasAnswered(player: Player?) -> Bool {
    return player?.responses[currentIndex] != nil
  }
  
  /**
   Returns a boolean indicating whether the list of players provided have all answered the current question.
   
   - Parameter players: The array of players to check.
   - Parameter min: The minimum number of players that should be in `players`
   
   - Returns: `true` if `players` contains at least `min` players and all of them have answered, `false` otherwise.
   */
  func haveAnswered(players: [Player]?, min: Int = 1) -> Bool {
    guard let players = players else {
      return false
    }
    
    return players.count >= min && players.filter {
      hasAnswered(player: $0)
    }.count == players.count
  }
}
