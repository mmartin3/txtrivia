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

import Messages
import UIKit

class ModeSelectViewController: UITableViewController {
  var delegate: MessagingDelegate?
  var selectedCategory: Category?
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    title = "Game Mode"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    Category.clearSelection()
    super.viewWillDisappear(animated)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.frame.height / CGFloat(GameMode.list.count + 1)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return GameMode.list.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ModeRow")
    let mode = GameMode.list[indexPath.row]
    cell.textLabel?.text = mode.name
    cell.detailTextLabel?.text = mode.description
    cell.detailTextLabel?.numberOfLines = 0
    cell.detailTextLabel?.lineBreakMode = .byWordWrapping
    cell.imageView?.image = mode.iconImage
    cell.isAccessibilityElement = true
    cell.accessibilityLabel = "\(mode.name!) trivia game mode"
    cell.accessibilityValue = mode.description
    cell.accessibilityHint = "start a \(mode.name!) game"
    cell.accessibilityTraits = .button
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let selectedCategory = selectedCategory else {
      return
    }
    
    Category.clearSelection()
    parent?.view.isHidden = true
    delegate?.startGame(withCategory: selectedCategory.id, mode: indexPath.row)
  }
}
