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

extension UIImageView {
  /**
   Initializes an image view with a tick mark representing the answer correctness provided.
   
   - Parameter isCorrect: The correctness of an answer.
   
   - Returns: A new image view with a green checkmark for a correct answer, or a red x for incorrect.
   */
  convenience init(isCorrect: Bool) {
    let systemName: String
    
    self.init()
    
    if isCorrect {
      systemName = "checkmark.circle.fill"
      tintColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: Constants.UI.opaque)
    } else {
      systemName = "x.circle.fill"
      tintColor = .red
    }
    
    image = UIImage(systemName: systemName)
  }
}
