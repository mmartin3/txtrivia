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

typealias GameTimer = Timer

extension GameTimer {
  class func scheduledTimer(controller: QuestionViewController) -> GameTimer {
    return Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { gameTimer in
      guard let game = controller.game,
            let t = game.timeRemaining else {
        return
      }
      
      if t > 0.0 {
        // Plays the clock ticking sound effect if time is running out.
        if SE.timer.isPlaying == false, t <= 10 {
          controller.scoreLabel.textColor = .red
          SE.timer.play()
        }
        
        game.timeRemaining = max(0, t - gameTimer.timeInterval)
        controller.scoreLabel.text = String(format: "%.2f", game.timeRemaining!)
      } else {
        gameTimer.stop(game: controller.game,
                       animator: controller.animator,
                       progressBar: controller.progressBar)
        
        controller.sendWithAnimation(focus: controller.optionViews().first!)
      }
    }
  }
  
  /**
   Sets the active player's completion time in rapid-fire mode.
   */
  func recordTime(game: TriviaGame?) {
    guard let game = game,
          let t = game.timeRemaining,
          let maxTime = game.mode.timeLimit else {
      return
    }
    
    let div = pow(10, 2.0)
    let time = maxTime - t
    game.activePlayer?.completionTime = TimeInterval((time * div).rounded() / div)
  }
  
  /**
   Stops the timer in rapid-fire mode.
   */
  func stop(game: TriviaGame?, animator: QuestionViewAnimator, progressBar: UIView?) {
    recordTime(game: game)
    invalidate()
    animator.stopAnimating(progressBar)
  }
}
