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

class ScoreLabel: UILabel {
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    font = font.withSize(Constants.UI.maxFontSize)
  }
  
  /**
   Updates the score label text.
   */
  func update(game: TriviaGame?, round: QuestionNumber?) {
    guard game?.mode is TurnBasedMode,
          let questionNum = round,
          var scores = game?.players.sorted().compactMap({
            $0.responses[0..<questionNum].answeredCorrectly.count
          }) else {
      return
    }
    
    if scores.count == 1 {
      scores.append(0)
    }
    
    guard let firstScore = scores.first else {
      return
    }
    
    var scoresDescription = "your current score is \(firstScore)"
    
    for i in 1..<scores.count {
      scoresDescription += "player \(i + 1)'s current score is \(scores[i])"
    }
    
    text = scores.map { String($0) }.joined(separator: " - ")
    isAccessibilityElement = true
    accessibilityLabel = "player scores"
    accessibilityValue = scoresDescription
  }
}
