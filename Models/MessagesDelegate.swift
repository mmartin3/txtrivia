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

import GoogleMobileAds
import Messages
import UIKit

struct MessagingDelegate {
  var controller: MessagesViewController
  
  /**
   Constructs a message with the trivia game provided encoded and attached.
   
   - Parameter game: The game to encode and attach to the message.
   - Parameter caption: Default caption to use in alternative layout.
   - Parameter session: The session for creating a message.
   
   - Returns: A message containing the trivia game.
   */
  func composeMessage(with game: TriviaGame?, caption: String, session: MSSession? = nil) -> MSMessage {
    var components = URLComponents()
    
    do {
      let gameData = try JSONEncoder().encode(game)
      let json = String(data: gameData, encoding: .utf8)
      components.queryItems = [URLQueryItem(name: "game", value: json)]
    } catch {
      fatalError("Game encoding failed")
    }
    
    let message = MSMessage(session: session ?? MSSession())
    let layout = MSMessageTemplateLayout()
    message.url = components.url
    layout.caption = caption
    
    if let categoryName = game?.category.name {
      layout.subcaption = "Category: \(categoryName)"
    }
    
    message.layout = MSMessageLiveLayout(alternateLayout: layout)
    
    return message
  }
  
  /**
   Completes game setup and attaches it to a message.
   
   - Parameter category: The category for the game's questions.
   - Parameter mode: The gameplay mode.
   */
  func startGame(withCategory category: Category, mode: GameMode) {
    let spinner = UIActivityIndicatorView(style: .large)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    controller.view.addSubview(spinner)
    
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
    ])
    
    spinner.startAnimating()
    let newGame = TriviaGame(withCategory: category, mode: mode)
    newGame.addPlayers(in: controller.activeConversation)
    
    APIRequest(forGame: newGame).populateQuestions() {
      newGame.prepareToSend()
      
      if newGame.mode is RapidFireMode {
        self.startAnswering(game: newGame)
      } else {
        self.addMessage(forGame: newGame)
      }
      
      spinner.stopAnimating()
    }
  }
  
  /**
   Aborts game setup.
   */
  func abortGame() {
    controller.dismiss()
  }
  
  /**
   Allows the player to start answering questions.
   
   - Parameter game: The game containing the questions to answer.
   */
  private func startAnswering(game: TriviaGame) {
    guard let conversation = controller.activeConversation else {
      return
    }
    
    if controller.presentationStyle == .expanded {
      let vc = TriviaViewController.instantiate(QuestionViewController.self, game: game, conversation: conversation, parent: controller)
      vc?.autoStart = false
      controller.controller = vc
    } else {
      controller.gameQueue.append(game)
      controller.requestPresentationStyle(.expanded)
    }
  }
  
  /**
   Creates a message containing the serialized trivia game.
   
   - Parameter game: The game to attach to the created message..
   */
  private func addMessage(forGame game: TriviaGame) {
    let caption = Constants.Captions.challenge
    let session = controller.activeConversation?.selectedMessage?.session
    let message = composeMessage(with: game, caption: caption, session: session)

    controller.activeConversation?.insert(message)
    controller.dismiss()
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
    let message = composeMessage(with: game, caption: caption, session: session)
    
    controller.updatePreview(for: conversation)
    conversation?.send(message)
    game?.emptyCache()
  }
  
  /**
   Plays an ad if enabled and then shows the waiting scene.
   
   - Parameter game: The game in progress.
   - Parameter conversation: The conversation containing the game.
   */
  func wait(game: TriviaGame, conversation: MSConversation?) {
    guard let conversation = conversation else {
      return
    }
    
    controller.updatePreview(for: conversation)
    controller.controller = TriviaViewController.instantiate(WaitingViewController.self, game: game, conversation: conversation, parent: controller)
    
    if !UserDefaults.standard.bool(forKey: "removedAds") {
      GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest(), completionHandler: { [self] ad, error in
        if let error = error {
          print(error.localizedDescription)
        }
        
        if let delegate = self.controller.controller as? WaitingViewController {
          ad?.fullScreenContentDelegate = delegate as GADFullScreenContentDelegate
          ad?.present(fromRootViewController: delegate)
        }
      })
    }
  }
  
  /**
   Displays the results controller.
   
   - Parameter game: The completed game.
   - Parameter conversation: The game's conversation.
   */
  func endGame(_ game: TriviaGame, conversation: MSConversation?) {
    controller.controller = TriviaViewController.instantiate(ResultsViewController.self, game: game, conversation: conversation, parent: controller)
  }
  
  /**
   Displays the category select scene to make a new game.
   
   - Parameter conversation: The conversation from the previous game.
   */
  func playAgain(conversation: MSConversation?) {
    controller.controller = controller.instantiateCategorySelectController(conversation: conversation)
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
    let message = composeMessage(with: game, caption: caption, session: session)
    conversation?.send(message)
  }
}
