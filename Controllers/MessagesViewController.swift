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

import AVFoundation
import Messages
import UIKit

class MessagesViewController: MSMessagesAppViewController {
  /// Rapid-fire games are queued here upon creation.
  var gameQueue: [TriviaGame] = []
  
  var expandedView: UIView = UIView()
  private var childViewBottom: NSLayoutConstraint?
  private var topTConstraint: NSLayoutConstraint?
  private var bottomTConstraint: NSLayoutConstraint?
  private var captionConstraint: NSLayoutConstraint?
  private let previewSize = CGSize(width: 270, height: 200)
  
  private var isCreating: Bool {
    guard let _ = children.first as? UINavigationController else {
      return false
    }
    
    return presentationStyle == .compact
  }
  
  private var bottomMargin: CGFloat {
    if IAPManager.shared.removedAds || isCreating {
      return 0
    } else {
      return Constants.UI.bannerAdSpacing * -1
    }
  }
  
  @IBOutlet weak var messageImage: UIImageView!
  @IBOutlet weak var messageCaption: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var previewBackground: UIView!
  @IBOutlet weak var topT: UILabel!
  @IBOutlet weak var bottomT: UILabel!
  
  required init?(coder: NSCoder) {
    try? AVAudioSession.sharedInstance().setCategory(.ambient)
    try? AVAudioSession.sharedInstance().setActive(true)
    Category.clearSelection()
    
    super.init(coder: coder)
    
    expandedView.backgroundColor = .frame
    expandedView.translatesAutoresizingMaskIntoConstraints = false
    IAPManager.shared.delegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    previewBackground.backgroundColor = .txtPreview
    view.backgroundColor = .txtGray
    topTConstraint = topT.centerXAnchor.constraint(equalTo: view.rightAnchor)
    bottomTConstraint = bottomT.centerXAnchor.constraint(equalTo: view.leftAnchor)
    captionConstraint = messageCaption.leftAnchor.constraint(equalTo: view.leftAnchor)
    topTConstraint?.isActive = true
    bottomTConstraint?.isActive = true
    captionConstraint?.isActive = true
    
    view.addSubview(expandedView)
    
    NSLayoutConstraint.activate([
      expandedView.leftAnchor.constraint(equalTo: view.leftAnchor),
      expandedView.rightAnchor.constraint(equalTo: view.rightAnchor),
      expandedView.topAnchor.constraint(equalTo: view.topAnchor),
      expandedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      previewBackground.topAnchor.constraint(equalTo: view.topAnchor),
      previewBackground.bottomAnchor.constraint(equalTo: messageCaption.topAnchor),
      messageImage.topAnchor.constraint(equalTo: view.topAnchor),
      messageCaption.bottomAnchor.constraint(equalTo: view.topAnchor, constant: previewSize.height),
      messageCaption.heightAnchor.constraint(equalToConstant: 28),
      messageCaption.widthAnchor.constraint(equalTo: view.widthAnchor),
      categoryLabel.bottomAnchor.constraint(equalTo: messageCaption.topAnchor),
      categoryLabel.heightAnchor.constraint(equalTo: messageCaption.heightAnchor),
      categoryLabel.widthAnchor.constraint(equalTo: messageCaption.widthAnchor)
    ])
  }
  
  override func willBecomeActive(with conversation: MSConversation) {
    super.willBecomeActive(with: conversation)
    
    if presentationStyle != .transcript {
      presentViewController(for: conversation)
    }
    
    // Only do this part once!
    guard let caption = messageCaption.text,
       caption.isEmpty,
       children.first as? UINavigationController == nil else {
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      self?.updatePreview(for: conversation)
    }
  }
  
  override func willResignActive(with conversation: MSConversation) {
    toggleSubviews(for: .transcript)
    SE.processing.stop()
    super.willResignActive(with: conversation)
  }
  
  override func didReceive(_ message: MSMessage, conversation: MSConversation) {
    guard let vc = children.first as? GameViewController,
          let game = vc.game,
          vc as? ResultsViewController == nil,
          vc.conversation == conversation else {
      return
    }
    
    TriviaGame.decode(from: message)?.players.forEach { receivedPlayer in
      let existingPlayer = game.players[receivedPlayer.id]
      existingPlayer?.mergeResponses(withPlayer: receivedPlayer)
    }
    
    if game.allPlayersAnswered {
      vc.delegate?.validate(game, conversation: conversation)
    }
  }
  
  override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
    super.didTransition(to: presentationStyle)
    
    guard let conversation = activeConversation else {
      return
    }
    
    if presentationStyle == .compact, let _ = children.first as? GameViewController {
      toggleSubviews(for: .transcript)
      dismiss()
    } else if presentationStyle == .expanded,
       let _ = UserDefaults.standard.array(forKey: Constants.Keys.selectedCategory) {
      requestPresentationStyle(.compact)
    } else {
      presentViewController(for: conversation)
      toggleSubviews(for: presentationStyle)
    }
  }
  
  override func contentSizeThatFits(_ size: CGSize) -> CGSize {
    return previewSize
  }
  
  override func addChild(_ childController: UIViewController) {
    for child in children {
      child.willMove(toParent: nil)
      child.view.removeFromSuperview()
      child.removeFromParent()
      child.didMove(toParent: nil)
    }
    
    let childView = childController.background
    super.addChild(childController)
    expandedView.addSubview(childView)
    childController.didMove(toParent: self)
    childViewBottom?.isActive = false
    childViewBottom = childView.bottomAnchor.constraint(equalTo: expandedView.bottomAnchor,
                                                        constant: bottomMargin)
    
    NSLayoutConstraint.activate([
      childView.leftAnchor.constraint(equalTo: expandedView.leftAnchor),
      childView.rightAnchor.constraint(equalTo: expandedView.rightAnchor),
      childView.topAnchor.constraint(equalTo: expandedView.topAnchor),
      childViewBottom!
    ])
  }
  
  /**
   Updates the interface according to the conversation provided and the current presentation style.
   
   - Parameter conversation: The conversation received from the message app controller.
   */
  private func presentViewController(for conversation: MSConversation?) {
    let vc: UIViewController?
    AdManager.shared?.addBanner(toView: expandedView)
    
    if presentationStyle == .expanded {
      loadBannerAd()
    }
    
    if let game = gameQueue.popLast() {
      vc = GameViewController.instantiate(QuestionViewController.self,
                                          game: game,
                                          conversation: conversation,
                                          parent: self,
                                          autoStart: false)
    } else {
      let game = TriviaGame.decode(from: conversation?.selectedMessage)
      vc = game.controller(conversation, parent: self)
    }
    
    guard let newController = vc else {
      return
    }
    
    addChild(newController)
    newController.didMove(toParent: self)
    childViewBottom?.constant = bottomMargin
    expandedView.layoutIfNeeded()
  }
  
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
      let gameData = try JSONEncoder().encode(game?.compressed())
      let json = String(data: gameData, encoding: .utf8)
      components.queryItems = [URLQueryItem(name: "g", value: json)]
    } catch {
      fatalError("Game encoding failed")
    }
    
    let message = MSMessage(session: session ?? MSSession())
    let layout = MSMessageTemplateLayout()
    message.url = components.url
    layout.caption = caption
    
    if let categoryName = game?.category?.name {
      layout.subcaption = "Category: \(categoryName)"
    }
    
    message.layout = MSMessageLiveLayout(alternateLayout: layout)
    
    return message
  }
  
  /**
   Updates the transcript layout caption for the conversation and the state of the game decoded from it.
   
   - Parameter conversation: The conversation to decode.
   */
  func updatePreview(for conversation: MSConversation?) {
    guard let message = conversation?.selectedMessage,
          let game = TriviaGame.decode(from: message),
          let categoryName = game.category?.name else {
      return
    }
    
    let id = conversation?.localParticipantIdentifier.compressedString
    var caption: String?
    messageImage.image = game.category?.iconImage
    game.addPlayers(in: conversation)
    
    for subview in view.subviews {
      subview.isHidden = false
    }
    
    if message.isPending {
      caption = Constants.Captions.challenge
    }
    
    if message.isPending || game.senderID == game.players[id]?.id {
      topTConstraint?.constant = -8
      bottomTConstraint?.constant = 2
      captionConstraint?.constant = 10
    } else {
      topTConstraint?.constant = -2
      bottomTConstraint?.constant = 8
      captionConstraint?.constant = 16
    }
    
    switch game.result {
    case .win:
      caption = Constants.Captions.win
    case .lose:
      caption = Constants.Captions.lose
    case .draw:
      caption = Constants.Captions.tie
    default:
      let playerID = conversation?.localParticipantIdentifier.compressedString
      let isChallenger = playerID == game.challenger?.id
      let mode = GameMode.list[game.m]
      caption = caption ?? mode.caption(game, isChallenger: isChallenger)
    }
    
    messageCaption.text = caption
    message.accessibilityLabel = messageCaption.text
    categoryLabel.text = "Category: \(categoryName)"
    toggleSubviews(for: presentationStyle)
  }
  
  private func toggleSubviews(for presentationStyle: MSMessagesAppPresentationStyle) {
    let bannerAd = AdManager.shared?.bannerView
    
    switch presentationStyle {
    case .expanded:
      expandedView.isHidden = false
      bannerAd?.isHidden = false
    case .compact:
      guard isCreating else {
        return
      }
      
      expandedView.isHidden = false
      bannerAd?.isHidden = true
    default:
      expandedView.isHidden = true
    }
  }
  
  @IBAction func handleTap() {
    requestPresentationStyle(.expanded)
  }
}
