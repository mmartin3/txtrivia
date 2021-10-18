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

class OptionButton: TXTButton {
  var option: Answer? {
    didSet {
      accessibilityValue = option?.x
      isEnabled = option != nil
      setTitle(option?.x, for: .normal)
      setImage(UIImage(option: option), for: .normal)
      
      if let letter = option?.letter {
        accessibilityLabel = "option \(letter)"
        accessibilityHint = "answers the question with option \(letter)"
      }
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    imageView?.tintColor = titleLabel?.textColor
    titleLabel?.textAlignment = .left
    contentHorizontalAlignment = .left
    contentEdgeInsets.left = 10
    titleEdgeInsets.left = 10
    imageView?.contentMode = .scaleAspectFit
    translatesAutoresizingMaskIntoConstraints = false
    isAccessibilityElement = true
    accessibilityTraits = .button
  }
  
  /**
   Updates the color of the button's text and image.
   
   - Parameter color: The new foreground color.
   */
  func setForeground(color: UIColor) {
    titleLabel?.textColor = color
    imageView?.tintColor = color
  }
}
