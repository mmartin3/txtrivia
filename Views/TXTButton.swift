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

class TXTButton: UIButton {
  static let defaultBackground = UIColor.txtPreview
  static let defaultForeground = UIColor.white
  static let defaultFontSize: CGFloat = 48
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    layer.cornerRadius = 16
    backgroundColor = Self.defaultBackground
    imageView?.tintColor = Self.defaultForeground
    titleLabel?.font = .systemFont(ofSize: TXTButton.defaultFontSize)
    titleLabel?.textColor = Self.defaultForeground
    titleLabel?.minimumScaleFactor = Constants.UI.minScale
    titleLabel?.numberOfLines = 1
    titleLabel?.adjustsFontSizeToFitWidth = true
  }
}
