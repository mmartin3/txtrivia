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

class ResponsesTableViewController: UITableViewController {
  var game: TriviaGame?
  var showDetails: ((IndexPath) -> (Void))?
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    tableView.setNeedsLayout()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let cells = tableView.visibleCells
    
    guard let firstContent = cells.first?.contentView.subviews else {
      return
    }
    
    for (i, cell) in cells.enumerated() {
      guard i > 0 else {
        continue
      }
      
      let content = cell.contentView.subviews
      
      guard content.count == firstContent.count else {
        break
      }
      
      for (left, right) in zip(firstContent, content) {
        right.widthAnchor.constraint(equalTo: left.widthAnchor).isActive = true
      }
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    guard let game = game else {
      return 0
    }
    
    if game.mode is RapidFireMode {
      return game.mode.numQuestions + 1
    } else {
      return game.mode.numQuestions
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.frame.height / CGFloat(numberOfSections(in: tableView) + 1)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let game = game else {
      return nil
    }
    
    if section < game.mode.numQuestions {
      return "\(section + 1)) \(game.questions[section].text.decodedFromBase64)"
    } else {
      return "Completion Time"
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return ResponsesCell(players: game?.players.sorted(),
                         indexPath: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let game = game, indexPath.section < game.mode.numQuestions else {
      return
    }
    
    showDetails?(indexPath)
  }
}
