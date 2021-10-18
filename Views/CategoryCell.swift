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

class CategoryCell: UITableViewCell {
  /**
   Initializes a cell representing the category provided.
   
   - Parameter category: The category represented by the table row.
   
   - Returns: A category cell listing the category provided.
   */
  init(for category: Category) {
    super.init(style: .default, reuseIdentifier: nil)
    
    textLabel?.text = category.description
    imageView?.image = category.iconImage
    isAccessibilityElement = true
    accessibilityLabel = "trivia category"
    accessibilityValue = category.description
    accessibilityHint = "start a new game with the category \(category.description)"
    accessibilityTraits = .button
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
