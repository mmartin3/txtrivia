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

extension UIColor {
  /// The lighter purple color in the TXTTrivia color scheme.
  class var txtPreview: UIColor {
    return UIColor(red: 0.45, green: 0.33, blue: 0.81, alpha: Constants.UI.opaque)
  }
  
  /// The color of the brain image used throughout the app.
  class var txtBrain: UIColor {
    return UIColor(red: 0.96, green: 0.66, blue: 0.76, alpha: Constants.UI.opaque)
  }
  
  /// The darker purple color in the TXTTrivia color scheme.
  class var txtDark: UIColor {
    return UIColor(red: 0.27, green: 0.20, blue: 0.48, alpha: Constants.UI.opaque)
  }
  
  /// The light gray color used throughout the app.
  class var txtGray: UIColor {
    return UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: Constants.UI.opaque)
  }
  
  /// The shade of green representing a correct answer.
  class var txtGreen: UIColor {
    return UIColor(red: 0.36, green: 0.82, blue: 0.34, alpha: Constants.UI.opaque)
  }
  
  /// The shade of green representing a correct answer by an opponent.
  class var txtPaleGreen: UIColor {
    return UIColor(red: 0.57, green: 0.80, blue: 0.57, alpha: Constants.UI.opaque)
  }
  
  /// The shade of red representing an incorrect answer by an opponent.
  class var txtPaleRed: UIColor {
    return UIColor(red: 0.80, green: 0.56, blue: 0.57, alpha: Constants.UI.opaque)
  }
  
  /// The shade of red representing an incorrect answer by player one.
  class var txtRed: UIColor {
    return UIColor(red: 0.82, green: 0.34, blue: 0.34, alpha: Constants.UI.opaque)
  }
  
  /// The pale color mostly used for text.
  class var txtTitle: UIColor {
    return UIColor(red: 0.42, green: 0.69, blue: 0.85, alpha: Constants.UI.opaque)
  }
  
  /// Color matching the expanded view background.
  class var txtBackground: UIColor {
    return UIColor(red: 0.55, green: 0.75, blue: 0.88, alpha: Constants.UI.opaque)
  }
  
  /// The color matching the frame of the app.
  class var frame: UIColor {
    return UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark:
        return .systemGray5
      default:
        return .white
      }
    }
  }
  
  /**
   Initializes a color representing the player number provided.
   
   - Parameter playerNum: The player number.
   
   - Returns: A new `UIColor` representing the player number.
   */
  convenience init(playerNum: Int) {
    let alpha: CGFloat = 0.6
    
    switch playerNum {
    case 1:
      self.init(red: 0.0, green: 0.6, blue: 0.0, alpha: alpha)
    case 2:
      self.init(red: 1.0, green: 0.0, blue: 0.0, alpha: alpha)
    default:
      self.init(red: 0.0, green: 0.0, blue: 1.0, alpha: alpha)
    }
  }
  
  /**
   Returns the color for an option button.
   
   - Parameter isActivePlayer: `false` if the button represents an option selected by the opponent.
   - Parameter isCorrect: The selected option's correctness.
   
   - Returns: A `UIColor` based on the player and correctness.
   */
  class func buttonColor(isActivePlayer: Bool, isCorrect: Bool? = nil) -> UIColor {
    guard let isCorrect = isCorrect else {
      return isActivePlayer ? .txtPreview : .txtGray
    }
    
    if isCorrect {
      return isActivePlayer ? .txtGreen : .txtPaleGreen
    } else {
      return isActivePlayer ? .txtRed : .txtPaleRed
    }
  }
}
