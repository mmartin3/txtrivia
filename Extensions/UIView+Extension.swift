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

extension UIView {
  func gapFillers() -> [UIView] {
    let fillers = [UIView(), UIView()]
    
    for filler in fillers {
      filler.translatesAutoresizingMaskIntoConstraints = false
      filler.backgroundColor = .txtBackground
      insertSubview(filler, at: 1)
    }
    
    return fillers
  }
  
  func margins() -> [UIView] {
    let bars = [UIView(), UIView()]
    
    for bar in bars {
      bar.backgroundColor = UIColor.frame
      bar.translatesAutoresizingMaskIntoConstraints = false
      insertSubview(bar, at: 0)
      
      NSLayoutConstraint.activate([
        NSLayoutConstraint(item: bar, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: bar, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: bar, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: Constants.UI.margin, constant: 0)
      ])
    }
    
    NSLayoutConstraint.activate([
      bars[0].leftAnchor.constraint(equalTo: leftAnchor),
      bars[1].rightAnchor.constraint(equalTo: rightAnchor)
    ])
    
    return bars
  }
  
  func playerLabels() -> [PlayerLabel] {
    let labels = [PlayerLabel(n: 1), PlayerLabel(n: 2)]
    
    for label in labels {
      addSubview(label)
    }
    
    return labels
  }
  
  func scoreboard() -> UIView {
    let backdrop = UIView()
    backdrop.translatesAutoresizingMaskIntoConstraints = false
    backdrop.backgroundColor = UIColor.frame.withAlphaComponent(0.8)
    insertSubview(backdrop, belowSubview: subviews[subviews.count - 2])
    
    return backdrop
  }
  
  func applyBlur() {
    let blurEffect = UIBlurEffect(style: .light)
    let blur = UIVisualEffectView(effect: blurEffect)
    blur.isUserInteractionEnabled = false
    blur.translatesAutoresizingMaskIntoConstraints = false
    insertSubview(blur, at: 0)
    
    NSLayoutConstraint.activate([
      blur.heightAnchor.constraint(equalTo: heightAnchor),
      blur.widthAnchor.constraint(equalTo: widthAnchor)
    ])
  }
  
  /**
   Animates the text in the string provided.
   
   - Parameter text: The text to animate.
   - Parameter callback: The code to run after the animation is complete.
   */
  func jumpAnimation(text: String, completion callback: @escaping () -> (Void)) {
    let letters = Array(text)
    var completeCount = 0
    let duration = 0.2
    let height = frame.height
    let letterWidth = height * 0.75
    
    let completion: (Bool) -> (Void) = { _ in
      completeCount += 1
      
      if completeCount == letters.count {
        callback()
      }
    }
    
    for (i, letter) in letters.enumerated() {
      let label = UILabel()
      let multiplier = CGFloat(i)
      let x = center.x + letterWidth * (multiplier - 1)
      let y = center.y
      var delay = TimeInterval(multiplier / 4)
      label.text = String(letter)
      label.textAlignment = .center
      label.textColor = .txtDark
      label.alpha = 0.1
      label.bounds = CGRect(x: 0, y: 0, width: height, height: height)
      label.center = CGPoint(x: x, y: y + 50)
      label.font = .boldSystemFont(ofSize: height)
      label.layer.applyGlow()
      superview?.insertSubview(label, aboveSubview: self)
      
      UIView.animate(withDuration: duration, delay: delay, animations: {
        label.alpha = Constants.UI.opaque
        label.center = CGPoint(x: x, y: y - 100)
      })
      
      delay += duration
      
      UIView.animate(withDuration: duration, delay: delay, animations: {
        label.center = CGPoint(x: x, y: y)
      }, completion: completion)
    }
  }
}
