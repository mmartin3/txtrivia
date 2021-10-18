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

class RapidFireMode: GameMode {
  override init() {
    super.init()
    
    icon = "hourglass"
    name = "Rapid-fire"
    numQuestions = 6
    timeLimit = TimeInterval(10 * numQuestions)
    rules = "Answer \(numQuestions!) questions in a row within \(Int(timeLimit!)) seconds, then challenge your opponent to do the same."
  }
  
  /**
   Returns the appropriate caption for a trivia game in progress.
   
   - Parameter game: The game in progress.
   - Parameter isChallenger: `true` if the active player sent the challenge, `false` if they're the recipient.
   
   - Returns: The caption text string.
   */
  override func caption(_ game: TriviaGame?, isChallenger: Bool) -> String? {
    guard let challenger = game?.challenger else {
      return nil
    }
    
    let score = "\(challenger.score)/\(challenger.responses.count)"
    
    switch isChallenger {
    case true:
      return "Challenge sent. Your score: \(score)"
    default:
      return "Can you beat my score of \(score)?"
    }
  }
  
  /**
   Returns the completeness of the game provided.
   
   - Parameter game: The game to evaluate.
   
   - Returns: `true` if the game is over, `false` otherwise.
   */
  override func isComplete(_ game: TriviaGame) -> Bool {
    guard game.players.count > 1 else {
      return false
    }
    
    return game.players.compactMap {
      $0.completionTime
    }.count == game.players.count
  }
  
  /**
   Start the given game running in the controller provided.
   
   - Parameter game: The game to start.
   - Parameter controller: The main view controller.
   */
  override func start(_ game: TriviaGame, controller: MessagesViewController) {
    controller.gameQueue.append(game)
    controller.requestPresentationStyle(.expanded)
  }
  
  /**
   Completes loading procedures for rapid-fire mode.
   */
  func ready() {
    SE.timer.prepareToPlay()
  }
}
