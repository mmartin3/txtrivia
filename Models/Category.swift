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

import Foundation

typealias CategoryID = String

struct Category: Codable, Symbolizable {
  var id: CategoryID
  var altIcon: String?
  var displayIcon: String?
  var grouping: String?
  var icon: String?
  var displayName: String?
  var name: String
  
  /// A flat list of all available categories.
  static var list: [Category]? {
    return try? { categoriesURL in
      guard let url = categoriesURL else {
        return nil
      }
      
      let data = try Data(contentsOf: url)
      
      return try JSONDecoder().decode([Category].self, from: data)
    }(Bundle.main.url(forResource: "Categories", withExtension: "json"))
  }
  
  /**
   Creates a copy of a category with the icon and name overriden.
   
   - Parameter displayIcon: The icon name to replace the current icon name.
   - Parameter displayName: The category name to replace the current name.
   
   - Returns: A copy of the category that will display the specified icon and name.
   */
  private func withDisplayData(displayIcon: String?, displayName: String?) -> Category {
    var copy = self
    
    copy.displayIcon = displayIcon
    copy.displayName = displayName
    copy.grouping = nil
    
    return copy
  }
  
  /**
   Returns a copy of a category the will hide its actual data and display as a random category.
   
   - Returns: A copy of the category that will display as a random category.
   */
  func randomized() -> Category {
    return withDisplayData(displayIcon: "questionmark", displayName: "Random")
  }
  
  /**
   Returns a copy of a category that will display its actual icon and title.
   
   - Returns: A copy of a category that will display its actual icon and title.
   */
  func unrandomized() -> Category {
    return withDisplayData(displayIcon: nil, displayName: nil)
  }
  
  /**
   Removes stored category selection.
   */
  static func clearSelection() {
    UserDefaults.standard.removeObject(forKey: Constants.Keys.selectedCategory)
  }
}

// MARK: - CustomStringConvertible

extension Category: CustomStringConvertible {
  var description: String { 
    return displayName ?? name 
  }
}
