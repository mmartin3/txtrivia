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
import UIKit

struct MessagingDelegate {
  var mvc: MessagesViewController
  
  var isOpen: Bool {
    return mvc.presentationStyle != .transcript && !mvc.expandedView.isHidden
  }
  
  /**
   Completes game setup and attaches it to a message.
   
   - Parameter category: The selected category's ID.
   - Parameter mode: The selected gameplay mode's index.
   */
  func startGame(withCategory category: CategoryID, mode: ModeID) {
    DispatchQueue.main.async {
      let spinner = UIActivityIndicatorView(style: .large)
      spinner.translatesAutoresizingMaskIntoConstraints = false
      mvc.expandedView.backgroundColor = .frame
      mvc.expandedView.insertSubview(spinner, at: 0)
      spinner.startAnimating()
      
      NSLayoutConstraint.activate([
        spinner.centerXAnchor.constraint(equalTo: mvc.view.centerXAnchor),
        spinner.centerYAnchor.constraint(equalTo: mvc.view.centerYAnchor, constant: -10)
      ])
    }
    
    let newGame = TriviaGame(withCategory: category, mode: mode)
    
    DispatchQueue.global().async {
      newGame.addPlayers(in: mvc.activeConversation)
    }
    
    DispatchQueue.global().async {
      newGame.updateRecentCategories()
    }
    
    APIRequest(forGame: newGame).send {
      GameMode.list[mode].start(newGame, controller: mvc)
    }
  }
  
  /**
   Sends the provided game in a message immediately.
   
   - Parameter game: The game to encode.
   - Parameter conversation: The conversation for the message.
   */
  func sendGame(_ game: TriviaGame?, conversation: MSConversation?) {
    game?.prepareToSend()
    
    let caption = Constants.Captions.ready
    let session = conversation?.selectedMessage?.session
    
    let message = mvc.composeMessage(with: game,
                                     caption: caption,
                                     session: session)
    
    conversation?.send(message)
    game?.emptyCache()
    game?.addPlayers(in: conversation) // Set the active player again.
  }
  
  
  /**
   Resends the game in a message to remind the opponent about it.
   
   - Parameter game: The game in progress.
   - Parameter conversation: The game's conversation.
   */
  func resendGame(_ game: TriviaGame?, conversation: MSConversation?) {
    guard let game = game else {
      return
    }
    
    game.sentTime = Date()
    game.nudgeIndex = game.currentIndex
    let caption = Constants.Captions.nudged
    let session = conversation?.selectedMessage?.session
    let message = mvc.composeMessage(with: game, caption: caption, session: session)
    conversation?.send(message)
  }
  
  /**
   Checks the validity of the game in progress.
   
   - Parameter game: The game in progress.
   - Parameter conversation: The game's conversation.
   
   - Returns: `true` if the game's state is valid, `false` if the controller has to update.
   */
  @discardableResult func validate(_ game: TriviaGame?,
                                   conversation: MSConversation?) -> Bool {
    guard let game = game else {
      return false
    }
    
    if game.isComplete {
      endGame(game, conversation: conversation)
    } else if game.isWaiting {
      wait(game: game, conversation: conversation)
    } else {
      return true
    }
    
    return false
  }
  
  /**
   Plays an ad if enabled and then shows the waiting scene.
   
   - Parameter game: The game in progress.
   - Parameter conversation: The conversation containing the game.
   */
  func wait(game: TriviaGame, conversation: MSConversation?) {
    if let vc = GameViewController.instantiate(WaitingViewController.self,
                                               game: game,
                                               conversation: conversation,
                                               parent: mvc) {
      mvc.addChild(vc)
    }
  }
  
  /**
   Displays the results controller.
   
   - Parameter game: The completed game.
   - Parameter conversation: The game's conversation.
   */
  func endGame(_ game: TriviaGame, conversation: MSConversation?) {
    if let vc = GameViewController.instantiate(ResultsViewController.self,
                                               game: game,
                                               conversation: conversation,
                                               parent: mvc) {
      mvc.addChild(vc)
    }
  }
  
  /**
   Displays the category select scene to make a new game.
   
   - Parameter conversation: The conversation from the previous game.
   */
  func rematch(_ conversation: MSConversation?) {
    mvc.addChild(CategorySelectViewController.createHierarchy(with: conversation,
                                                              parent: mvc,
                                                              isRematch: true))
  }
  
  /**
   Aborts game setup.
   */
  func abortGame() {
    mvc.dismiss()
  }
  
  /**
   Requests compacted main view.
   */
  func compact() {
    mvc.requestPresentationStyle(.compact)
  }
}
