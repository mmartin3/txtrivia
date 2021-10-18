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

extension Array where Element == MessageBalloon {
  var correct: Self {
    return filter {
      $0.button?.option?.isCorrect == true
    }
  }
  
  func setEnabled(_ isEnabled: Bool) {
    forEach {
      $0.button?.isUserInteractionEnabled = isEnabled
    }
  }
  
  func setHidden(_ hide: Bool) {
    forEach {
      $0.isHidden = hide
    }
  }
  
  func setFromOpponent(_ fromOpponent: Bool) {
    forEach {
      $0.fromOpponent = fromOpponent
    }
  }
  
  func setOptions(players: [Player]?, questionNum: QuestionNumber?, selectedAnswer: Answer?) {
    guard let questionNum = questionNum, let players = players else {
      return
    }
    
    for (opponentOption, inactivePlayer) in zip(self, players) {
      let opponentAnswer = inactivePlayer.responses[questionNum]
      opponentOption.button?.option = opponentAnswer
      opponentOption.isHidden = true
      
      guard opponentAnswer == selectedAnswer else {
        continue
      }
      
      opponentOption.isHidden = false
      opponentOption.fromOpponent = true
    }
  }
  
  func hideTails() {
    forEach {
      $0.hideTail()
    }
  }
  
  func scaleFont(options: [Answer]) -> UIFont? {
    let maxLen = options.maxLength
    let newSize = TXTButton.defaultFontSize - CGFloat(maxLen)
    
    guard let fontSize = [newSize, 18].max() else {
      return nil
    }
    
    return first?.button?.titleLabel?.font.withSize(fontSize)
  }
  
  func reveal(correct: Bool) -> Bool {
    var correctAnswerSelected = correct
    
    for (i, view) in enumerated() {
      if view.button?.option?.isCorrect == true {
        correctAnswerSelected = true
      }
      
      let isCorrect = view.button?.option?.isCorrect
      view.setBackground(color: .buttonColor(isActivePlayer: i == 0, isCorrect: isCorrect))
      
      guard i == 0 else {
        continue
      }
      
      (isCorrect == true ? SE.rightAnswer : SE.wrongAnswer).play()
    }
    
    return correctAnswerSelected
  }
  
  func withoutButton(_ button: OptionButton?) -> Self {
    return filter {
      $0.button != button
    }
  }
}
