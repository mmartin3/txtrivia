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

class ResultsViewController: GameViewController {
  private let generator = MutableImpactFeedbackGenerator()
  private var banner: UIView = UIView()
  private var gradient: CAGradientLayer = CAGradientLayer()
  private var gameResult: TriviaGame.Result?
  private var topLabelConstraint: NSLayoutConstraint?
  private var bottomLabelConstraint: NSLayoutConstraint?
  private var tableConstraint: NSLayoutConstraint?
  
  @IBOutlet weak var topLabel: UILabel!
  @IBOutlet weak var bottomLabel: UILabel!
  @IBOutlet weak var tableContainer: UIView!
  @IBOutlet weak var playAgainButton: TXTButton!
  @IBOutlet weak var settingsContainer: UIView!
  
  required init?(coder: NSCoder) {
    IAPManager.shared.isActive = true
    super.init(coder: coder)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    guard let tableVC = segue.destination as? ResponsesTableViewController else {
      return
    }
    
    gameResult = game?.result
    tableVC.game = game
    
    tableVC.showDetails = { [weak self] indexPath in
      self?.showDetails(initialIndex: indexPath.section)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let boldFont = UIFont.boldSystemFont(ofSize: Constants.UI.maxFontSize)
    let regularFont = UIFont(name: "Damascus", size: Constants.UI.maxFontSize)
    let bannerColors: [CGColor]
    let topLabelY: CGFloat
    let bottomLabelY: CGFloat
    let tableTop: CGFloat
    topLabel.textColor = .txtDark
    bottomLabel.textColor = .txtDark
    topLabel.translatesAutoresizingMaskIntoConstraints = false
    bottomLabel.translatesAutoresizingMaskIntoConstraints = false
    playAgainButton.isAccessibilityElement = true
    playAgainButton.accessibilityTraits = .button
    playAgainButton.accessibilityLabel = "play again button"
    playAgainButton.accessibilityHint = "start another game"
    
    switch gameResult {
    case .win:
      topLabel.text = "CONGRATULATIONS"
      topLabel.font = regularFont
      bottomLabel.text = Constants.Captions.win
      bottomLabel.font = boldFont
      bannerColors = [UIColor.txtPaleGreen.cgColor, UIColor.txtGreen.cgColor]
      topLabelY = 0.165
      bottomLabelY = 0.24
      tableTop = 0.32
    case .draw:
      topLabel.text = "DRAW"
      topLabel.font = boldFont
      bottomLabel.text = Constants.Captions.tie
      bottomLabel.font = regularFont
      bannerColors = [UIColor.txtBrain.cgColor, UIColor.txtPreview.cgColor]
      topLabelY = 0.2
      bottomLabelY = 0.35
      tableTop = 0.4
    default:
      topLabel.text = Constants.Captions.lose
      topLabel.font = boldFont
      bottomLabel.text = "Better luck next time!"
      bottomLabel.font = regularFont
      bannerColors = [UIColor.txtPaleRed.cgColor, UIColor.txtRed.cgColor]
      topLabelY = 0.175
      bottomLabelY = 0.265
      tableTop = 0.32
    }
    
    addBanner(withColors: bannerColors)
    
    NSLayoutConstraint.activate([
      NSLayoutConstraint(item: tableContainer!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.8, constant: 0),
      NSLayoutConstraint(item: playAgainButton!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.98, constant: 0),
      NSLayoutConstraint(item: playAgainButton!, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.1, constant: 0),
      NSLayoutConstraint(item: tableContainer!, attribute: .bottom, relatedBy: .equal, toItem: playAgainButton, attribute: .top, multiplier: 0.98, constant: 0),
      NSLayoutConstraint(item: settingsContainer!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: settingsContainer!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 0.99, constant: 0),
      NSLayoutConstraint(item: topLabel!, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: topLabelY, constant: 0),
      NSLayoutConstraint(item: bottomLabel!, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: bottomLabelY, constant: 0),
      NSLayoutConstraint(item: tableContainer!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: tableTop, constant: 0),
      topLabel.widthAnchor.constraint(equalTo: tableContainer.widthAnchor),
      topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bottomLabel.widthAnchor.constraint(equalTo: topLabel.widthAnchor),
      tableContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      playAgainButton.widthAnchor.constraint(equalTo: tableContainer.widthAnchor),
      playAgainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      banner.widthAnchor.constraint(equalTo: view.widthAnchor),
      banner.topAnchor.constraint(equalTo: settingsContainer.bottomAnchor, constant: 10),
      banner.bottomAnchor.constraint(equalTo: tableContainer.topAnchor, constant: -10)
    ])
    
    game?.emptyCache()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    AdManager.shared?.preloadInterstitial()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    topLabelConstraint?.isActive = false
    bottomLabelConstraint?.isActive = false
    topLabelConstraint?.isActive = false
    bottomLabelConstraint?.isActive = false
    UIDevice.vibrate()
    gameResult?.clip?.play()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.removeFromSuperview()
    removeFromParent()
    didMove(toParent: nil)
  }
  
  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
    for subview in [banner, topLabel, bottomLabel] {
      subview?.isHidden = size.height <= 400
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    gradient.frame = banner.bounds
  }
  
  /**
   Presents details for a selected question.
   
   - Parameter initialIndex: The index of the question to detail.
   */
  private func showDetails(initialIndex: QuestionNumber) {
    guard let mvc = delegate?.mvc else {
      return
    }
    
    let pvc = UIPageViewController(transitionStyle: .scroll,
                                   navigationOrientation: .horizontal)
    
    let vc = GameViewController.instantiate(QuestionViewController.self,
                                            game: game,
                                            conversation: conversation,
                                            parent: mvc) as! QuestionViewController
    
    vc.displayQuestion = initialIndex
    vc.pageViewController = pvc
    pvc.setViewControllers([vc], direction: .forward, animated: true)
    pvc.dataSource = self
    present(pvc, animated: true)
  }
  
  /**
   Adds a gradient banner background behind the result message.
   
   - Parameter colors: The gradient colors.
   */
  private func addBanner(withColors colors: [CGColor]) {
    banner.alpha = 0.9
    banner.translatesAutoresizingMaskIntoConstraints = false
    gradient.colors = colors
    gradient.frame = banner.bounds
    view.insertSubview(banner, at: 1)
    banner.layer.insertSublayer(gradient, at: 0)
  }
  
  /**
   Opens the category select menu to start a new game, after playing an ad if enabled.
   
   - Parameter sender: The play again button.
   */
  @IBAction func playAgain(_ sender: Any) {
    MutableImpactFeedbackGenerator().impactOccurred()
    delegate?.rematch(conversation)
  }
}
