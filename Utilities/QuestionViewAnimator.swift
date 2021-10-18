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

typealias AnimationCompletionHandler = () -> (Void)

struct QuestionViewAnimator {
  /**
   Presents the selected options in preparation to reveal the correct answer.
   
   - Parameter optionViews: The message balloons to animate.
   - Parameter answer: The selected answer.
   - Parameter callback: The code to execue upon completion.
   */
  func animate(_ optionViews: [MessageBalloon],
               answer: Answer?,
               completion callback: @escaping (Bool) -> (Void)) {
    let unselectedAlpha: CGFloat = 0
    let opponentView = optionViews.last
    let opponentAnswer = opponentView?.button?.option
    
    SE.processing.play()
    
    for view in optionViews {
      guard view != opponentView else {
        break
      }
      
      var newAlpha = unselectedAlpha
      
      if view.button?.option == answer {
        view.prepareToMove(relativeToView: optionViews[0])
        newAlpha = Constants.UI.opaque
      } else if view.button?.option == opponentAnswer {
        view.fromOpponent = true
        view.prepareToMove(relativeToView: optionViews[1])
        newAlpha = Constants.UI.opaque
      }
      
      if newAlpha == unselectedAlpha {
        view.prepareToMove(toX: view.frame.maxX)
      }
      
      UIView.animate(withDuration: SE.processing.duration, animations: {
        view.alpha = newAlpha
      })
    }
    
    opponentView?.xConstraint?.constant = 0
    
    UIView.animate(withDuration: SE.processing.duration, animations: { [weak opponentView] in
      opponentView?.superview?.layoutIfNeeded()
      opponentView?.alpha = Constants.UI.opaque
    }, completion: callback)
  }
  
  /**
   Animates a "progress bar" indicating the time remaining.
   
   - Parameter progressBar: The view to animate.
   - Parameter duration: The length of the animation.
   */
  func animate(_ progressBar: UIView, duration: TimeInterval?) {
    guard let duration = duration else {
      return
    }
    
    progressBar.layer.removeAllAnimations()
    progressBar.frame = progressBar.superview!.frame
    
    UIView.animate(withDuration: duration) { [weak progressBar] in
      guard let bar = progressBar else {
        return
      }
      
      let x = bar.frame.origin.x
      let y = bar.frame.origin.y
      let h = bar.frame.size.height
      bar.frame = CGRect(x: x, y: y, width: 0, height: h)
    }
  }
  
  /**
   Gets the start button ready to display and animate.
   
   - Parameter startButton: The button to animate.
   */
  func animate(_ startButton: UIButton) {
    let options: UIView.AnimationOptions = [.repeat, .autoreverse]
    startButton.applyBlur()
    startButton.titleLabel?.textAlignment = .center
    startButton.isHidden = false
    
    UIView.animate(withDuration: 1.0, delay: 0, options: options, animations: { [weak startButton] in
      guard let label = startButton?.titleLabel else {
        return
      }
      
      let w = label.bounds.width * 0.9
      let h = label.bounds.height * 0.9
      label.bounds = CGRect(x: 0, y: 0, width: w, height: h)
    }, completion: nil)
  }
  
  /**
   Introduces the option balloons on load.
   
   - Parameter optionViews: The message balloons to animate.
   - Parameter callback: The code to execute after animating.
   */
  func fadeIn(_ optionViews: [MessageBalloon],
              hasAnimated: Bool,
              completion callback: AnimationCompletionHandler? = nil) {
    let startAlpha: CGFloat = hasAnimated ? 1 : 0
    
    for (i, balloon) in optionViews.enumerated() {
      let delay = 0.2 * Double(i)
      balloon.alpha = startAlpha
      
      UIView.animate(withDuration: 0.4, delay: delay, animations: { [weak balloon] in
        balloon?.alpha = Constants.UI.opaque
      }, completion: { _ in
        guard let callback = callback else {
          return
        }
        
        if i == optionViews.count - 1 {
          callback()
        }
      })
    }
  }
  
  /**
   Fades out a start button that's been clicked.
   
   - Parameter startButton: The button to animate.
   */
  func fadeOut(_ startButton: UIButton) {
    startButton.titleLabel?.layer.removeAllAnimations()
    
    UIView.animate(withDuration: 1.0, animations: { [weak startButton] in
      startButton?.alpha = 0
    }, completion: { [weak startButton] _ in
      startButton?.isHidden = true
    })
  }
  
  /**
   Animates any changes to the given view's constraints.
   
   - Parameter view: The view to layout.
   - Parameter duration: The length of the animation.
   */
  func layout(view: UIView, withDuration duration: TimeInterval) {
    UIView.animate(withDuration: duration, animations: { [weak view] in
      view?.layoutIfNeeded()
    })
  }
  
  /**
   Triggers jump animation reading "SENT."
   
   - Parameter view: The view on which to animate the text.
   - Parameter callback: The code to execute when animation is complete.
   */
  func sentAnimation(focus view: UIView?,
                     messageBalloons: [MessageBalloon],
                     selection selectedByPlayer: MessageBalloon?,
                     completion callback: @escaping () -> (Void)) {
    SE.timer.stop()
    
    if let _ = selectedByPlayer {
      messageBalloons.filter {
        $0 != view
      }.forEach {
        $0.hideTail()
        $0.alpha = 0.8
      }
    }
    
    UIDevice.vibrate()
    view?.jumpAnimation(text: "SENT", completion: callback)
  }
  
  /**
   Freezes the progress bar provided.
   
   - Parameter progressBar: The view to animate.
   */
  func stopAnimating(_ progressBar: UIView?) {
    guard let progressBar = progressBar else {
      return
    }
    
    let x = progressBar.frame.origin.x
    let y = progressBar.frame.origin.y
    let w = progressBar.frame.size.width
    let h = progressBar.frame.size.height
    progressBar.widthAnchor.constraint(equalToConstant: w).isActive = true
    progressBar.layer.removeAllAnimations()
    progressBar.frame = CGRect(x: x, y: y, width: w, height: h)
  }
}
