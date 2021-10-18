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

class CategorySelectViewController: UITableViewController {
  var conversation: MSConversation?
  var delegate: MessagingDelegate?
  var isRematch: Bool = false
  
  /// The categories grouped into sections.
  private lazy var categories: [[Category]] = {
    guard var list = Category.list, let randomCategory = list.randomElement() else {
      return []
    }
    
    var grouped: [[Category]] = []
    var randomGrouping = [randomCategory.randomized()]
    grouped.append(randomGrouping)
    
    if let recentCategories = recentCategories {
      grouped.append(recentCategories)
    }
    
    ["Entertainment", "Science", "Miscellaneous"].forEach { sectionName in
      grouped.append(list.filter { $0.grouping == sectionName })
    }
    
    return grouped
  }()
  
  private var recentCategories: [Category]? {
    let defaults = UserDefaults.standard
    
    guard let saved = defaults.stringArray(forKey: Constants.Keys.recentCategories) else {
      return nil
    }
    
    return saved.compactMap { id in
      Category.list?.filter { $0.id == id }.first
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Category"
    
    // Disable > 2 players for now
    guard conversation?.remoteParticipantIdentifiers.count == 1 else {
      invalidConversation()
      return
    }
    
    let defaults = UserDefaults.standard
    
    if let selection = defaults.array(forKey: Constants.Keys.selectedCategory) {
      let section = selection[0] as! Int
      let row = selection[1] as! Int
      let category = categories[section][row].unrandomized()
      selectMode(selectedCategory: category)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if isRematch {
      playInterstitial()
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return categories.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return CategoryCell(for: categories[indexPath.section][indexPath.row])
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Random"
    } else if section == 1 && categories.count > 4 {
      return "Recent topics"
    } else {
      return categories[section].first?.grouping
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = categories[indexPath.section][indexPath.row].unrandomized()
    let defaults = UserDefaults.standard
    let selection = [indexPath.section, indexPath.row]
    delegate?.compact()
    defaults.setValue(selection, forKey: Constants.Keys.selectedCategory)
    selectMode(selectedCategory: category)
  }
  
  /**
   Instantiates a navigation controller wrapping a category select controller inside.
   
   - Parameter conversation: The conversation to pass to the controller.
   - Parameter delegate: The delegate to assign to the category select controller.
   - Parameter isRematch: `true` if initiated by a rematch, `false` otherwise.
   
   - Returns: A navigation controller containing a category select controller.
   */
  static func createHierarchy(with: MSConversation?,
                              parent: MessagesViewController,
                              isRematch: Bool? = nil) -> UIViewController {
    let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "NavigationController")
    
    guard let nc = vc as? UINavigationController else {
      return vc
    }
    
    if let csvc = nc.topViewController as? CategorySelectViewController {
      csvc.conversation = with
      csvc.delegate = MessagingDelegate(mvc: parent)
      csvc.isRematch = isRematch ?? csvc.isRematch
    }
    
    return nc
  }
  
  private func selectMode(selectedCategory: Category) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "ModeSelectViewController")
    
    guard let controller = vc as? ModeSelectViewController else {
      return
    }
  
    controller.delegate = delegate
    controller.selectedCategory = selectedCategory
    navigationController?.pushViewController(controller, animated: true)
  }
  
  private func invalidConversation() {
    let message = "Challenging a group chat isn't supported just yet. Please start a game in a 1-on-1 conversation."
    
    let alert = UIAlertController(title: "Too Many Participants",
                                  message: message,
                                  preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
      self?.delegate?.abortGame()
    }))
  
    present(alert, animated: true)
  }
}
