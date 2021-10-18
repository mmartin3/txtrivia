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

extension UIImage {
  /**
   Initializes an image representing the given answer.
   
   - Parameter option: The option to represent as an image.
   
   - Returns: A `UIImage` representation of `option`.
   */
  convenience init?(option: Answer?) {
    let fontSize = TXTButton.defaultFontSize
    let iconChar = option?.letter ?? "minus"
    let iconName = "\(iconChar).square.fill"
    let config = UIImage.SymbolConfiguration(pointSize: fontSize)
    
    self.init(systemName: iconName, withConfiguration: config)
  }
}
