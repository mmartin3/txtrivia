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

import UIKit

struct QuestionViewConstraints {
  private var qvc: QuestionViewController
  private var creditsBottom: NSLayoutConstraint?
  private var creditsTop: NSLayoutConstraint?
  private var progressWidth: NSLayoutConstraint?
  private var questionBottom: NSLayoutConstraint?
  private var compactConstraints: [NSLayoutConstraint] = []
  private var portraitConstraints: [NSLayoutConstraint] = []
  private var landscapeConstraints: [NSLayoutConstraint] = []
  
  /// Constraints used in both portrait and landscape mode, but not for compact displays.
  private lazy var commonConstraints: [NSLayoutConstraint] = {
    return [
      qvc.titleBar.topAnchor.constraint(equalTo: qvc.view.topAnchor),
      qvc.numbering.topAnchor.constraint(greaterThanOrEqualTo: qvc.titleBar.topAnchor)
    ]
  }()
  
  /// Constraints to activate independent of device orientation/size.
  private lazy var globalConstraints: [NSLayoutConstraint] = {
    guard let startLabel = qvc.startButton.titleLabel, let numbering = qvc.numbering, let questionText = qvc.questionText else {
      return []
    }
    
    return [
      startLabel.heightAnchor.constraint(equalTo: startLabel.widthAnchor, multiplier: startLabel.frame.height / startLabel.frame.width),
      qvc.scoreLabel.widthAnchor.constraint(equalTo: qvc.scoreLabel.heightAnchor, multiplier: qvc.scoreLabel.frame.width / qvc.scoreLabel.frame.height, constant: 0),
      qvc.correctButton.centerXAnchor.constraint(equalTo: qvc.view.centerXAnchor),
      qvc.correctButton.heightAnchor.constraint(equalTo: qvc.optionA.heightAnchor),
      qvc.optionA.heightAnchor.constraint(greaterThanOrEqualTo: qvc.view.heightAnchor, multiplier: 0.12),
      qvc.optionB.heightAnchor.constraint(equalTo: qvc.optionA.heightAnchor),
      qvc.optionC.heightAnchor.constraint(equalTo: qvc.optionA.heightAnchor),
      qvc.optionD.heightAnchor.constraint(equalTo: qvc.optionA.heightAnchor),
      qvc.opponentOption.heightAnchor.constraint(equalTo: qvc.optionA.heightAnchor),
      qvc.opponentOption.widthAnchor.constraint(equalTo: qvc.optionA.widthAnchor),
      NSLayoutConstraint(item: questionText, attribute: .width, relatedBy: .equal, toItem: qvc.view, attribute: .width, multiplier: 0.86, constant: 0),
      NSLayoutConstraint(item: numbering, attribute: .centerY, relatedBy: .equal, toItem: qvc.titleBar, attribute: .centerY, multiplier: 1, constant: 0),
      qvc.questionText.centerXAnchor.constraint(equalTo: qvc.view.centerXAnchor),
      qvc.questionText.bottomAnchor.constraint(greaterThanOrEqualTo: qvc.view.topAnchor),
      qvc.progressBar.topAnchor.constraint(equalTo: qvc.scoreBackground.topAnchor),
      qvc.progressBar.heightAnchor.constraint(equalTo: qvc.scoreBackground.heightAnchor),
      qvc.questionText.heightAnchor.constraint(greaterThanOrEqualTo: qvc.view.heightAnchor, multiplier: 0.2),
      qvc.scoreLabel.centerXAnchor.constraint(equalTo: qvc.view.centerXAnchor)
    ] + scoringConstraints
  }()
  
  /// Global constraints related to the scoring bar.
  private lazy var scoringConstraints: [NSLayoutConstraint] = {
    if qvc.readOnly {
      return [
        qvc.scoreBackground.heightAnchor.constraint(equalToConstant: 0),
        qvc.scoreLabel.heightAnchor.constraint(equalToConstant: 0)
      ]
    } else {
      return [
        qvc.scoreBackground.heightAnchor.constraint(equalTo: qvc.titleBar.heightAnchor),
        qvc.scoreLabel.heightAnchor.constraint(equalTo: qvc.scoreBackground.heightAnchor, multiplier: 0.9)
      ]
    }
  }()
  
  init(controller: QuestionViewController) {
    qvc = controller
    
    guard let view = qvc.view, let numbering = qvc.numbering, let credits = qvc.credits else {
      return
    }
    
    portraitConstraints = [
      NSLayoutConstraint(item: numbering, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.58, constant: 0),
      qvc.questionText.topAnchor.constraint(equalTo: qvc.scoreBackground.bottomAnchor, constant: 10),
      qvc.scoreLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.18)
    ] + commonConstraints
    
    landscapeConstraints = [
      NSLayoutConstraint(item: numbering, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.28, constant: 0),
      qvc.questionText.topAnchor.constraint(equalTo: qvc.scoreBackground.bottomAnchor),
      qvc.scoreLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1)
    ] + commonConstraints
    
    compactConstraints = [
      qvc.questionText.topAnchor.constraint(equalTo: view.topAnchor),
      qvc.titleBar.bottomAnchor.constraint(equalTo: view.topAnchor),
      qvc.scoreBackground.bottomAnchor.constraint(equalTo: view.topAnchor),
      qvc.progressBar.bottomAnchor.constraint(equalTo: view.topAnchor),
      qvc.numbering.bottomAnchor.constraint(equalTo: view.topAnchor),
      qvc.scoreLabel.widthAnchor.constraint(equalToConstant: 0)
    ]
    
    creditsBottom = NSLayoutConstraint(item: credits, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: qvc.view, attribute: .bottom, multiplier: 0.98, constant: 0)
    creditsBottom?.isActive = true
    
    NSLayoutConstraint.activate(globalConstraints +
      qvc.optionViews(includingOpponentOption: true).compactMap {
        $0.widthAnchor.constraint(equalTo: qvc.view.widthAnchor)
      })
    
    positionCredits()
  }
  
  /**
   Updates the constraints dependent on the device orientation.
   
   - Parameter size: The size of the superview.
   */
  mutating func resize(forSize size: CGSize) {
    if size.height <= 720 {
      NSLayoutConstraint.deactivate(portraitConstraints)
      NSLayoutConstraint.deactivate(landscapeConstraints)
      NSLayoutConstraint.activate(compactConstraints)
    } else if size.width > size.height {
      NSLayoutConstraint.deactivate(portraitConstraints)
      NSLayoutConstraint.deactivate(compactConstraints)
      NSLayoutConstraint.activate(landscapeConstraints)
    } else {
      NSLayoutConstraint.deactivate(compactConstraints)
      NSLayoutConstraint.deactivate(landscapeConstraints)
      NSLayoutConstraint.activate(portraitConstraints)
    }
    
    positionCredits()
  }
  
  /**
   Constrains the width of the progress bar.
   
   - Parameter percentComplete: A number between 0.0 and 1.0 indicating the bar proportions.
   */
  mutating func updateProgress(progress percentComplete: CGFloat?) {
    guard let percentComplete = percentComplete else {
      return
    }
    
    progressWidth?.isActive = false
    progressWidth = NSLayoutConstraint(item: qvc.progressBar, attribute: .width, relatedBy: .equal, toItem: qvc.view, attribute: .width, multiplier: percentComplete, constant: 0)
    progressWidth?.isActive = true
    qvc.animator.layout(view: qvc.progressBar, withDuration: 2)
  }
  
  /**
   Resets certain constraints when the question is updated.
   */
  mutating func reset() {
    qvc.opponentOption.xConstraint?.isActive = false
    qvc.opponentOption.yConstraint?.isActive = false
    qvc.opponentOption.xConstraint = qvc.opponentOption.rightAnchor.constraint(equalTo: qvc.view.leftAnchor)
    qvc.opponentOption.yConstraint = qvc.opponentOption.topAnchor.constraint(equalTo: qvc.optionB.topAnchor)
    qvc.opponentOption.xConstraint?.isActive = true
    qvc.opponentOption.yConstraint?.isActive = true
    positionQuestion()
    positionCredits()
  }
  
  /**
   Positions a message balloon provided after the specified view.
   
   - Parameter view: The message balloon.
   - Parameter i: The index of the option.
   - Parameter item: The previous view in the stack.
   */
  func positionOption(_ view: MessageBalloon, withIndex i: Int, after item: UIView?) {
    guard let item = item else {
      return
    }
    
    view.xConstraint?.isActive = false
    view.yConstraint?.isActive = false
    view.xConstraint = view.leftAnchor.constraint(equalTo: qvc.view.leftAnchor)
    view.yConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: item, attribute: .bottom, multiplier: 1, constant: Constants.UI.balloonMargin)
    view.xConstraint?.isActive = true
    view.yConstraint?.isActive = true
  }
  
  /**
   Positions the progress bar gap filler views.
   
   - Parameters fillers: An array containing the left and right side fillers.
   */
  func positionFillers(_ fillers: [UIView]) {
    for filler in fillers {
      NSLayoutConstraint.activate([
        filler.topAnchor.constraint(equalTo: qvc.scoreBackground.topAnchor),
        filler.bottomAnchor.constraint(equalTo: qvc.scoreBackground.bottomAnchor),
        NSLayoutConstraint(item: filler, attribute: .width, relatedBy: .equal, toItem: qvc.view, attribute: .width, multiplier: Constants.UI.margin, constant: 0)
      ])
    }
    
    NSLayoutConstraint.activate([
      fillers[0].leftAnchor.constraint(equalTo: qvc.view.leftAnchor),
      fillers[1].rightAnchor.constraint(equalTo: qvc.view.rightAnchor)
    ])
  }
  
  func positionScoreboard(_ backdrop: UIView, labels: [PlayerLabel]) {
    guard qvc.game?.mode is TurnBasedMode else {
      return
    }
    
    let c = UIScreen.main.bounds.width / 32
    
    NSLayoutConstraint.activate([
      labels[0].rightAnchor.constraint(equalTo: qvc.scoreLabel.leftAnchor, constant: c * -1),
      labels[1].leftAnchor.constraint(equalTo: qvc.scoreLabel.rightAnchor, constant: c),
      backdrop.leftAnchor.constraint(equalTo: labels[0].centerXAnchor),
      backdrop.rightAnchor.constraint(equalTo: labels[1].centerXAnchor),
      backdrop.topAnchor.constraint(equalTo: labels[0].topAnchor),
      backdrop.bottomAnchor.constraint(equalTo: labels[0].bottomAnchor)
    ] + labels.compactMap {
      $0.heightAnchor.constraint(equalTo: qvc.scoreBackground.heightAnchor, multiplier: 0.8)
    } + labels.compactMap {
      $0.widthAnchor.constraint(equalTo: $0.heightAnchor)
    } + labels.compactMap {
      $0.centerYAnchor.constraint(equalTo: qvc.scoreLabel.centerYAnchor)
    })
  }
  
  /**
   Positions the bottom of the question text.
   */
  mutating func positionQuestion() {
    questionBottom?.isActive = false
    questionBottom = qvc.questionText.bottomAnchor.constraint(equalTo: qvc.optionA.topAnchor, constant: Constants.UI.balloonMargin * -1)
    questionBottom?.isActive = true
  }
  
  /**
   Updates the positioning of the credits stack.
   */
  mutating func positionCredits() {
    guard let credits = qvc.credits else {
      return
    }
    
    let visibleBalloons = qvc.optionViews().filter { !$0.isHidden }
    creditsTop?.isActive = false
    
    guard let lastOption = visibleBalloons.last else {
      return
    }
    
    if visibleBalloons.count < 4 {
      creditsBottom?.constant = lastOption.bounds.height * -1
    } else {
      creditsBottom?.constant = 0
    }
    
    creditsTop?.isActive = false
    creditsTop = NSLayoutConstraint(item: credits, attribute: .top, relatedBy: .equal, toItem: lastOption, attribute: .bottom, multiplier: 1.02, constant: 0)
    creditsTop?.isActive = true
  }
  
  /**
   Positions the given exit button.
   
   - Parameter button: The close button.
   */
  func positionCloseButton(_ button: UIButton) {
    NSLayoutConstraint.activate([
      button.heightAnchor.constraint(equalTo: qvc.numbering.heightAnchor),
      button.widthAnchor.constraint(equalTo: qvc.numbering.heightAnchor),
      button.centerYAnchor.constraint(equalTo: qvc.numbering.centerYAnchor),
      button.rightAnchor.constraint(equalTo: qvc.view.rightAnchor, constant: -10)
    ])
  }
  
  /**
   Absolutizes the current positioning constraints to prepare for animation.
   */
  mutating func translate() {
    questionBottom?.isActive = false
    questionBottom = qvc.questionText.bottomAnchor.constraint(equalTo: qvc.view.topAnchor, constant: qvc.optionA.frame.origin.y - Constants.UI.balloonMargin)
    questionBottom?.isActive = true
    
    for balloon in qvc.optionViews() {
      let x = balloon.frame.origin.x
      let y = balloon.frame.origin.y
      balloon.xConstraint?.isActive = false
      balloon.yConstraint?.isActive = false
      balloon.xConstraint = balloon.leftAnchor.constraint(equalTo: qvc.view.leftAnchor, constant: x)
      balloon.yConstraint = balloon.topAnchor.constraint(equalTo: qvc.view.topAnchor, constant: y)
      balloon.xConstraint?.isActive = true
      balloon.yConstraint?.isActive = true
    }
    
    qvc.opponentOption.xConstraint?.isActive = false
    qvc.opponentOption.yConstraint?.isActive = false
    qvc.opponentOption.xConstraint = qvc.opponentOption.leftAnchor.constraint(equalTo: qvc.view.leftAnchor, constant: qvc.view.frame.size.width * -1)
    qvc.opponentOption.yConstraint = qvc.opponentOption.topAnchor.constraint(equalTo: qvc.view.topAnchor, constant: qvc.optionB.frame.origin.y)
    qvc.opponentOption.xConstraint?.isActive = true
    qvc.opponentOption.yConstraint?.isActive = true
    
    // Updates the correct button positioning accordingly.
    NSLayoutConstraint.activate([
      qvc.correctButton.widthAnchor.constraint(equalTo: qvc.optionA.button?.widthAnchor ?? qvc.optionA.widthAnchor),
      qvc.correctButton.topAnchor.constraint(equalTo: qvc.view.topAnchor, constant: qvc.optionC.frame.origin.y)
    ])
    
    qvc.view.layoutIfNeeded()
  }
}
