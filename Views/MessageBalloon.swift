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

class MessageBalloon: UIView {
  var button: OptionButton?
  private var incomingTail: IncomingTailView?
  private var outgoingTail: OutgoingTailView?
  private var tailConstraints: [NSLayoutConstraint]?
  var xConstraint: NSLayoutConstraint?
  var yConstraint: NSLayoutConstraint?
  
  var fromOpponent: Bool = false {
    didSet {
      incomingTail?.isHidden = !fromOpponent
      outgoingTail?.isHidden = fromOpponent
      
      if fromOpponent {
        setBackground(color: .txtGray)
      }
    }
  }
  
  required init?(coder: NSCoder) {
    button = OptionButton(coder: coder)
    incomingTail = IncomingTailView(coder: coder)
    outgoingTail = OutgoingTailView(coder: coder)
    fromOpponent = false
    
    super.init(coder: coder)
    
    guard let button = button, let incomingTail = incomingTail, let outgoingTail = outgoingTail else {
      return
    }
    
    accessibilityElements = [button]
    setBackground(color: .txtPreview)
    addSubview(button)
    insertSubview(incomingTail, at: 0)
    insertSubview(outgoingTail, at: 0)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    updateTailConstraints()
  }
  
  /**
   Hides the outgoing tail view.
   */
  func hideTail() {
    outgoingTail?.isHidden = true
  }
  
  /**
   Updates position constraints relative to the view provided.
   
   - Parameter view: The view to which this one should be positioned relatively.
   */
  func prepareToMove(relativeToView view: UIView) {
    prepareToMove(toX: view.frame.origin.x)
    prepareToMove(toY: view.frame.origin.y)
  }
  
  /**
   Updates x position constraint.
   
   - Parameter x: The new x coordinate.
   */
  func prepareToMove(toX x: CGFloat) {
    xConstraint?.constant += x - frame.origin.x
  }
  
  /**
   Updates y position constraint.
   
   - Parameter y: The new y coordinate.
   */
  func prepareToMove(toY y: CGFloat) {
    yConstraint?.constant += y - frame.origin.y
  }
  
  /**
   Updates the background color of all subviews.
   
   - Parameter color: The new background color.
   */
  func setBackground(color: UIColor) {
    button?.backgroundColor = color
    incomingTail?.color = color
    outgoingTail?.color = color
  }
  
  /**
   Sets the answer text and its font.
   
   - Parameter option: The answer this balloon will represent.
   - Parameter font: The font for this set of answers.
   
   - Returns: The message balloon itself.
   */
  func withOption(_ option: Answer, font: UIFont?) -> Self {
    isHidden = false
    fromOpponent = false
    button?.option = option
    button?.titleLabel?.font = font
    setBackground(color: .txtPreview)
    
    return self
  }
  
  /**
   Constrains the tail views.
   */
  private func updateTailConstraints() {
    guard tailConstraints == nil, let button = button, let incomingTail = incomingTail, let outgoingTail = outgoingTail else {
      return
    }
    
    let xo: CGFloat = 0.01
    let xm: CGFloat = 0.25
    let ym: CGFloat = 0.5
    
    tailConstraints = [
      NSLayoutConstraint(item: incomingTail, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: incomingTail, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: xm, constant: 0),
      NSLayoutConstraint(item: incomingTail, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: ym, constant: 0),
      NSLayoutConstraint(item: incomingTail, attribute: .right, relatedBy: .equal, toItem: button, attribute: .left, multiplier: 1 + xo, constant: 0),
      NSLayoutConstraint(item: outgoingTail, attribute: .bottom, relatedBy: .equal, toItem: incomingTail, attribute: .bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: outgoingTail, attribute: .width, relatedBy: .equal, toItem: incomingTail, attribute: .width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: outgoingTail, attribute: .height, relatedBy: .equal, toItem: incomingTail, attribute: .height, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: outgoingTail, attribute: .left, relatedBy: .equal, toItem: button, attribute: .right, multiplier: 1 - xo, constant: 0),
      button.heightAnchor.constraint(equalTo: heightAnchor),
      button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.UI.paddedMultiplier),
      button.centerXAnchor.constraint(equalTo: centerXAnchor)
    ]
    
    NSLayoutConstraint.activate(tailConstraints!)
  }
}
