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

class TurnBasedMode: GameMode {
  override init() {
    super.init()
    
    icon = "arrow.triangle.2.circlepath"
    altIcon = "arrow.up.arrow.down"
    name = "Trivia duel"
    numQuestions = 4
    rules = "Take turns answering \(numQuestions!) questions with no time limit"
  }
  
  /**
   Returns the appropriate caption for a trivia game in progress.
   
   - Parameter game: The game in progress.
   - Parameter isChallenger: `true` if the active player sent the challenge, `false` if they're the recipient.
   
   - Returns: The caption text string.
   */
  override func caption(_ game: TriviaGame?, isChallenger: Bool) -> String? {
    game?.loadResponses()
    
    let selfAnswered = game?.hasAnswered(player: game?.activePlayer) == true
    let othersAnswered = game?.haveAnswered(players: game?.inactivePlayers) == true
    
    if selfAnswered && !othersAnswered {
      return "Waiting on opponent..."
    } else if !selfAnswered && game?.nudgeIndex == game?.currentIndex {
      return Constants.Captions.nudged
    } else if game?.currentIndex == 0 && !selfAnswered && !othersAnswered {
      return isChallenger ? "Your challenge was sent - tap to start" : Constants.Captions.challenge
    } else {
      return Constants.Captions.ready
    }
  }
  
  /**
   Returns the completeness of the game provided.
   
   - Parameter game: The game to evaluate.
   
   - Returns: `true` if the game is over, `false` otherwise.
   */
  override func isComplete(_ game: TriviaGame) -> Bool {
    return !game.hasNextQuestion && game.allPlayersAnswered
  }
  
  /**
   Start the given game running in the controller provided.
   
   - Parameter game: The game to start.
   - Parameter controller: The main view controller.
   */
  override func start(_ game: TriviaGame, controller: MessagesViewController) {
    game.prepareToSend()
    let caption = Constants.Captions.challenge
    let session = controller.activeConversation?.selectedMessage?.session
    let message = controller.composeMessage(with: game, caption: caption, session: session)
    controller.activeConversation?.insert(message)
    controller.dismiss()
  }
  
  /**
   Completes loading procedures for turn-based play.
   
   - Parameter game: The game to update.
   */
  func ready(_ game: TriviaGame?) {
    guard let initialIndex = game?.initialIndex else {
      return
    }
    
    game?.currentIndex = initialIndex
  }
}
