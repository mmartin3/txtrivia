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

import Messages
import Foundation

extension Optional where Wrapped == TriviaGame {
  /**
   Instantiates the appropriate controller for the given game.
   
   - Parameter conversation: The game's conversation.
   - Parameter parent: The parent to which the controller will be added.
   
   - Returns: A view controller determined by the current state of the game.
   */
  func controller(_ conversation: MSConversation?, parent: MessagesViewController) -> UIViewController? {
    let controllerType: GameViewController.Type
    let autoStart = self?.mode is TurnBasedMode
    self?.addPlayers(in: conversation)
    self?.loadResponses()
    self?.emptyCache(ifOutdated: true)
    
    if self == nil {
      return CategorySelectViewController.createHierarchy(with: conversation, parent: parent)
    } else if self?.isComplete == true {
      controllerType = ResultsViewController.self
    } else if self?.isWaiting == true {
      controllerType = WaitingViewController.self
    } else {
      controllerType = QuestionViewController.self
      
      if self?.activePlayer?.id != self?.senderID && self?.currentIndex != 0 {
        self?.currentIndex -= 1
      }
    }
    
    return GameViewController.instantiate(controllerType,
                                          game: self,
                                          conversation: conversation,
                                          parent: parent,
                                          autoStart: autoStart)
  }
}
