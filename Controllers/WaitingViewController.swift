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

class WaitingViewController: GameViewController {
  private var timer: Timer?
  private var counter: Int = 0
  private var playedAd: Bool = false
  private let enableNudgeAfter: TimeInterval = 600
  
  @IBOutlet weak var smallBubble: UIImageView!
  @IBOutlet weak var mediumBubble: UIImageView!
  @IBOutlet weak var bigBubble: UIImageView!
  @IBOutlet weak var waitLabel: UILabel!
  @IBOutlet weak var nudgeButton: TXTButton!
  @IBOutlet weak var waitImage: UIImageView!
  @IBOutlet weak var settingsContainer: UIView!
  
  required init?(coder: NSCoder) {
    IAPManager.shared.isActive = true
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    nudgeButton.imageEdgeInsets = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: 0,
                                               right: nudgeButton.bounds.width * 0.1)
    
    nudgeButton.backgroundColor = .txtPreview
    nudgeButton.isAccessibilityElement = true
    nudgeButton.accessibilityTraits = .button
    nudgeButton.accessibilityHint = "remind opponent to continue the game"
    nudgeButton.accessibilityLabel = "nudge opponent button"
    waitLabel.adjustsFontSizeToFitWidth = true
    
    timer = Timer.scheduledTimer(timeInterval: 1,
                                 target: self,
                                 selector: #selector(updateTimer),
                                 userInfo: nil,
                                 repeats: true)
    
    if IAPManager.shared.removedAds {
      nudgeButton.imageView?.isHidden = true
    }
    
    NSLayoutConstraint.activate([
      NSLayoutConstraint(item: nudgeButton!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.99, constant: 0),
      NSLayoutConstraint(item: nudgeButton!, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.1, constant: 24),
      NSLayoutConstraint(item: nudgeButton!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: Constants.UI.paddedMultiplier, constant: 0),
      NSLayoutConstraint(item: waitImage!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.8, constant: 100),
      NSLayoutConstraint(item: waitImage!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .centerY, multiplier: 0.5, constant: 0),
      NSLayoutConstraint(item: waitLabel!, attribute: .width, relatedBy: .equal, toItem: bigBubble, attribute: .width, multiplier: 0.8, constant: 0),
      NSLayoutConstraint(item: mediumBubble!, attribute: .height, relatedBy: .lessThanOrEqual, toItem: bigBubble, attribute: .height, multiplier: 0.2, constant: 0),
      NSLayoutConstraint(item: smallBubble!, attribute: .height, relatedBy: .equal, toItem: mediumBubble, attribute: .height, multiplier: 0.8, constant: 0),
      waitImage.bottomAnchor.constraint(greaterThanOrEqualTo: nudgeButton.topAnchor),
      waitImage.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
      waitImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      waitImage.topAnchor.constraint(greaterThanOrEqualTo: view.centerYAnchor),
      waitLabel.widthAnchor.constraint(lessThanOrEqualTo: bigBubble.widthAnchor),
      nudgeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bigBubble.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 8),
      bigBubble.topAnchor.constraint(lessThanOrEqualTo: settingsContainer.bottomAnchor),
      bigBubble.bottomAnchor.constraint(lessThanOrEqualTo: mediumBubble.topAnchor),
      bigBubble.bottomAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor),
      bigBubble.widthAnchor.constraint(lessThanOrEqualTo: nudgeButton.widthAnchor),
      bigBubble.heightAnchor.constraint(equalTo: waitImage.heightAnchor),
      mediumBubble.centerYAnchor.constraint(greaterThanOrEqualTo: bigBubble.bottomAnchor),
      mediumBubble.bottomAnchor.constraint(lessThanOrEqualTo: smallBubble.topAnchor),
      smallBubble.bottomAnchor.constraint(greaterThanOrEqualTo: waitImage.topAnchor),
      smallBubble.bottomAnchor.constraint(lessThanOrEqualTo: waitImage.centerYAnchor)
    ])
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AdManager.shared?.preloadRewardedAd()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !playedAd {
      playInterstitial()
      playedAd = true
    }
  }
  
  /**
   Updates the timer that controls the waiting animation and nudge button activation.
   */
  @objc func updateTimer() {
    if counter > 4 {
      counter = 0
      smallBubble.isHidden = true
      mediumBubble.isHidden = true
      bigBubble.isHidden = true
    }
    
    switch counter {
    case 1:
      smallBubble.isHidden = false
    case 2:
      mediumBubble.isHidden = false
    case 3:
      bigBubble.isHidden = false
    default:
      break
    }
    
    guard game?.nudgeIndex != game?.currentIndex,
          let t = game?.sentTime else {
      return
    }
    
    waitLabel.isHidden = bigBubble.isHidden
    counter += 1
    nudgeButton.isHidden = !(Date().timeIntervalSince(t) >= enableNudgeAfter)
  }
  
  @IBAction func nudge(_ sender: UIButton) {
    game?.sentTime = Date()
    sender.isHidden = true
    MutableImpactFeedbackGenerator().impactOccurred()
    
    guard !IAPManager.shared.removedAds else {
      delegate?.resendGame(game, conversation: conversation)
      return
    }
    
    playRewardedAd { [weak self] in
      self?.delegate?.resendGame(self?.game, conversation: self?.conversation)
    }
  }
}
