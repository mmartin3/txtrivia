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

typealias ModeID = Int

class GameMode: NSObject, Symbolizable {
  static let list: [GameMode] = [TurnBasedMode(), RapidFireMode()]
  var icon: String?
  var altIcon: String?
  var displayIcon: String?
  var name: String!
  var numQuestions: Int!
  var rules: String!
  var timeLimit: TimeInterval?
  
  override public var description: String {
    return rules
  }
  
  /**
   Returns the appropriate caption for a trivia game in progress.
   
   - Parameter game: The game in progress.
   - Parameter isChallenger: `true` if the active player sent the challenge, `false` if they're the recipient.
   
   - Returns: The caption text string.
   */
  func caption(_ game: TriviaGame?, isChallenger: Bool) -> String? {
    return nil
  }
  
  /**
   Returns the completeness of the game provided.
   
   - Parameter game: The game to evaluate.
   
   - Returns: `true` if the game is over, `false` otherwise.
   */
  func isComplete(_ game: TriviaGame) -> Bool {
    return false
  }
  
  /**
   Starts the given game running in the controller provided.
   
   - Parameter game: The game to start.
   - Parameter controller: The main view controller.
   */
  func start(_ game: TriviaGame, controller: MessagesViewController) {
    return
  }
}
