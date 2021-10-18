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

class SettingButton: UIButton {
  /**
   Sets the button image for all button states.
   
   - Parameter image: The new button image.
   */
  func setImage(_ image: UIImage?) {
    imageView?.tintColor = TXTButton.defaultForeground
    
    setImage(image, for: .normal)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    isAccessibilityElement = true
    accessibilityTraits = .button
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = bounds.width / 2
  }
}
