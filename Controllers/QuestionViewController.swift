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
import SafariServices
import UIKit

class QuestionViewController: GameViewController {
  let animator = QuestionViewAnimator()
  var autoStart: Bool = true
  var constraints: QuestionViewConstraints?
  var displayQuestion: QuestionNumber?
  var isPreparing: Bool = false
  var isUpdating: Bool = false
  var pageViewController: UIPageViewController?
  let progressBar: TXTProgressBar = TXTProgressBar()
  private var timer: GameTimer?
  
  private var isValid: Bool {
    return readOnly || delegate?.validate(game, conversation: conversation) == true
  }
  
  private var question: Question? {
    if let displayQuestion = displayQuestion {
      return game?.questions[displayQuestion]
    } else {
      return game?.currentQuestion
    }
  }
  
  var questionNum: QuestionNumber? {
    if let displayQuestion = displayQuestion {
      return displayQuestion
    } else {
      return game?.currentIndex
    }
  }
  
  var readOnly: Bool {
    return displayQuestion != nil
  }
  
  var selectedByOpponents: [MessageBalloon] {
    guard let game = game,
          let questionNum = questionNum,
          game.mode is TurnBasedMode || readOnly else {
      return []
    }
    
    return optionViews().filter {
      game.inactivePlayers.compactMap {
        $0.responses[questionNum]
      }.contains($0.button?.option)
    }
  }
  
  var selectedByPlayer: MessageBalloon? {
    guard let questionNum = questionNum,
          let response = game?.activePlayer?.responses[questionNum] else {
      return nil
    }
    
    return optionViews().filter { $0.button?.option == response }.first
  }
  
  private let generator = MutableImpactFeedbackGenerator()
  
  @IBOutlet weak var optionA: MessageBalloon!
  @IBOutlet weak var optionB: MessageBalloon!
  @IBOutlet weak var optionC: MessageBalloon!
  @IBOutlet weak var optionD: MessageBalloon!
  @IBOutlet weak var opponentOption: MessageBalloon!
  @IBOutlet weak var numbering: UILabel!
  @IBOutlet weak var questionText: QuestionLabel!
  @IBOutlet weak var scoreLabel: ScoreLabel!
  @IBOutlet weak var correctButton: OptionButton!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var titleBar: UIView!
  @IBOutlet weak var scoreBackground: UIView!
  @IBOutlet weak var credits: UIStackView!
  @IBOutlet weak var settingsContainer: UIView!
  
  override func viewDidLoad() {
    guard isValid, let questionNum = questionNum else {
      return
    }
    
    opponentOption.isHidden = game?.mode is RapidFireMode
    settingsContainer.isHidden = readOnly
    progressBar.background = scoreBackground
    constraints = QuestionViewConstraints(controller: self)
    optionViews().setHidden(true)
    game?.addPlayers(in: conversation)
    constraints?.positionScoreboard(view.scoreboard(), labels: view.playerLabels())
    SE.prepare(forAnswer: game?.activePlayer?.responses[questionNum])
    updateQuestion()
    constraints?.resize(forSize: view.frame.size)
    
    if !autoStart {
      animator.animate(startButton)
    }
    
    guard !readOnly else {
      addCloseButton()
      view.backgroundColor = .white
      return
    }
    
    for button in optionViews().compactMap({ $0.button }) {
      button.addTarget(self,
                       action: #selector(selectOption(_:)),
                       for: .touchUpInside)
    }
    
    scoreLabel.update(game: game, round: questionNum)
    (game?.mode as? RapidFireMode)?.ready()
    (game?.mode as? TurnBasedMode)?.ready(game)
    constraints?.positionFillers(view.gapFillers())
    super.viewDidLoad()
  }
  
  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
    constraints?.resize(forSize: size)
    super.viewWillTransition(to: size, with: coordinator)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if !readOnly {
      AdManager.shared?.preloadInterstitial()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    timer?.invalidate()
    timer = nil
    constraints = nil
    pageViewController = nil
    super.viewWillDisappear(animated)
    dismiss(animated: false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard game?.mode is RapidFireMode && !readOnly else {
      return
    }
    
    if game?.activePlayer?.completionTime == nil {
      animator.animate(progressBar, duration: game?.mode.timeLimit)
    }
  }
  
  /**
   Returns the option button wrappers/message balloons.
   
   - Parameter includingOpponentOption: If `true` the view for the opponent's answer will be included.
   
   - Returns: An array of `OptionButtonWrapper`s.
   */
  func optionViews(includingOpponentOption: Bool = false) -> [MessageBalloon] {
    var views = [optionA, optionB, optionC, optionD]
    
    if (game?.mode is TurnBasedMode || readOnly) && includingOpponentOption {
      views.append(opponentOption)
    }
    
    return views.compactMap { $0 }
  }
  
  /**
   Updates the question displayed.
   */
  func updateQuestion() {
    guard !isUpdating,
          let game = game,
          let question = question,
          let questionNum = questionNum,
          let totalQuestions = game.mode.numQuestions else {
      return
    }
    
    let messageBalloons = optionViews()
    isUpdating = true
    numbering.text = "Question \(questionNum + 1) of \(totalQuestions)"
    questionText.text = question.text.decodedFromBase64
    questionText.accessibilityLabel = "question \(questionNum + 1)"
    scoreLabel.isHidden = game.mode is RapidFireMode || readOnly
    let font = messageBalloons.scaleFont(options: question.options)
    
    for (i, option) in question.options.enumerated() {
      let view = messageBalloons[i].withOption(option, font: font)
      let prev = i == 0 ? questionText : messageBalloons[i - 1]
      constraints?.positionOption(view, withIndex: i, after: prev)
      
      if view.button?.option?.isCorrect == true {
        correctButton.option = view.button?.option
      }
    }
    
    opponentOption.button?.titleLabel?.font = font
    correctButton.titleLabel?.font = font
    
    // Always leave space for a third option, even if choice C is hidden.
    if optionC.isHidden {
      constraints?.positionOption(optionC, withIndex: 2, after: optionB)
    }
    
    opponentOption.isHidden = true
    correctButton.isHidden = true
    credits.isHidden = false
    constraints?.reset()
    messageBalloons.setEnabled(true)
    
    guard game.mode is TurnBasedMode || readOnly else {
      isUpdating = false
      return
    }
    
    animator.fadeIn(messageBalloons, hasAnimated: game.allPlayersAnswered || readOnly) { [weak self] in
      QuestionViewCallbacks.onUpdate(self, percentComplete: CGFloat((questionNum + 1) / totalQuestions))
    }
  }
  
  /**
   Starts the trivia game.
   */
  @IBAction func start() {
    guard game?.mode is RapidFireMode else {
      return
    }
    
    game?.resetTime()
    timer = .scheduledTimer(controller: self)
    startButton.isUserInteractionEnabled = false
    animator.fadeOut(startButton)
    
    if !autoStart {
      animator.animate(progressBar, duration: game?.mode.timeLimit)
    }
  }
  
  /**
   Answers the current question.
   
   - Parameter sender: The option button selected.
   */
  @objc func selectOption(_ sender: Any) {
    guard !readOnly,
          let game = game,
          let questionNum = questionNum,
          game.activePlayer?.completionTime == nil else {
      return
    }
    
    if !game.hasNextQuestion {
      timer?.stop(game: game, animator: animator, progressBar: progressBar)
    }
    
    let answer = game.activePlayer?.responses[questionNum]
    
    guard answer == nil, let button = sender as? OptionButton else {
      return
    }
    
    optionViews().setEnabled(false)
    generator.impactOccurred()
    game.activePlayer?.responses[questionNum] = button.option
    game.cacheResponses()
    SE.prepare(forAnswer: button.option)
    
    if game.mode is RapidFireMode {
      reveal(selectedButton: button)
    } else if game.allPlayersAnswered {
      prepareToReveal(selected: button)
    } else if game.activePlayer == game.challenger && game.currentIndex == 0 {
      delegate?.wait(game: game, conversation: conversation)
    } else {
      sendWithAnimation(focus: button.superview)
    }
  }
  
  /**
   Carries out animation and other tasks that precede revealing the answer in turn-based mode.
   
   - Parameter selected: The button that triggered the process.
   */
  func prepareToReveal(selected: OptionButton?) {
    guard !readOnly, !isPreparing else {
      return
    }
    
    [opponentOption].setOptions(players: game?.inactivePlayers,
                                questionNum: questionNum,
                                selectedAnswer: selected?.option)
    
    credits.isHidden = true
    isPreparing = true
    constraints?.translate()
    
    animator.animate(optionViews(includingOpponentOption: true),
                     answer: selected?.option) { [weak self, weak selected] _ in
      QuestionViewCallbacks.preparedToReveal(self, selected: selected)
    }
  }
  
  /**
   Reveals the correct answer.
   
   - Parameter selectedButton: The button chosen by the player.
   */
  func reveal(selectedButton: OptionButton?) {
    guard let selectedButton = selectedButton,
          let hasNextQuestion = game?.hasNextQuestion,
          delegate?.isOpen == true else {
      return
    }
    
    let answeredCorrectly = selectedButton.option?.isCorrect == true
    var processOptions = [selectedButton.superview as! MessageBalloon]
    isPreparing = false
    isUpdating = false
    optionViews().withoutButton(selectedButton).hideTails()
    selectedByOpponents.withoutButton(selectedButton).setFromOpponent(true)
    
    if game?.mode is TurnBasedMode || readOnly {
      processOptions += selectedByOpponents.withoutButton(selectedButton)
    }
    
    if !answeredCorrectly && (game?.mode is RapidFireMode || readOnly) {
      processOptions += optionViews().correct
    }
    
    let correctAnswerSelected = processOptions.reveal(correct: answeredCorrectly)
    let isCorrect = opponentOption.button?.option?.isCorrect
    let oppColor = UIColor.buttonColor(isActivePlayer: false, isCorrect: isCorrect)
    opponentOption.setBackground(color: oppColor)
    
    guard !readOnly else {
      return
    }
    
    game?.activePlayer?.lastReveal = game?.currentIndex
    
    if hasNextQuestion {
      game?.currentIndex += 1
    }
    
    scoreLabel.update(game: game, round: questionNum)
    UIDevice.vibrate()
    
    if !correctAnswerSelected && game?.mode is TurnBasedMode {
      correctButton.backgroundColor = .buttonColor(isActivePlayer: true, isCorrect: true)
      correctButton.isHidden = false
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      QuestionViewCallbacks.onTurnOver(self,
                                       hasNextQuestion: hasNextQuestion,
                                       focus: selectedButton.superview)
    }
  }
  
  /**
   Plays an animation indicating the player's response was sent.
   
   - Parameter view: The view on which to animate the text.
   */
  func sendWithAnimation(focus view: UIView?) {
    delegate?.sendGame(game, conversation: conversation)
    
    animator.sentAnimation(focus: view,
                           messageBalloons: optionViews(),
                           selection: selectedByPlayer) { [weak self] in
      QuestionViewCallbacks.onSent(self)
    }
  }
  
  /**
   Adds a close button to exit read-only mode.
   */
  private func addCloseButton() {
    let button = UIButton()
    let config = UIImage.SymbolConfiguration(pointSize: 48)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
    button.tintColor = .txtGray
    view.addSubview(button)
    constraints?.positionCloseButton(button)
    
    button.addTarget(self,
                     action: #selector(closeDetails(_:)),
                     for: .touchUpInside)
  }
  
  /**
   Closes question details.
   
   - Parameter sender: The close button.
   */
  @objc func closeDetails(_ sender: Any) {
    pageViewController?.dismiss(animated: true)
    pageViewController = nil
  }
  
  /**
   Opens the API's website.
   
   - Parameter sender: The button selected.
   */
  @IBAction func sourceDetails(_ sender: UIButton) {
    guard timer?.isValid == false,
          let url = URL(string: "https://opentdb.com/") else {
      return
    }
    
    present(SFSafariViewController(url: url), animated: true)
  }
  
  /**
   Opens the license details.
   
   - Parameter sender: The button selected.
   */
  @IBAction func licenseDetails(_ sender: UIButton) {
    guard timer?.isValid == false,
          let url = URL(string: "https://creativecommons.org/licenses/by-sa/4.0/") else {
      return
    }
    
    present(SFSafariViewController(url: url), animated: true)
  }
}
