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

class GameViewController: UIViewController {
  var conversation: MSConversation?
  var delegate: MessagingDelegate?
  var game: TriviaGame?
  
  static func instantiate(_ type: GameViewController.Type,
                          game: TriviaGame?,
                          conversation: MSConversation?,
                          parent: MessagesViewController,
                          autoStart: Bool = true) -> GameViewController? {
    let className = String(describing: type)
    IAPManager.shared.isActive = autoStart
    let vc = parent.storyboard?.instantiateViewController(withIdentifier: className)
    let controller: GameViewController?
    
    if type == QuestionViewController.self {
      let qvc = vc as? QuestionViewController
      qvc?.autoStart = autoStart
      controller = qvc
      SE.processing.prepareToPlay()
    } else if type == WaitingViewController.self {
      controller = vc as? WaitingViewController
      AdManager.shared?.bannerView.isHidden = false
    } else if type == ResultsViewController.self {
      controller = vc as? ResultsViewController
    } else {
      controller = vc as? GameViewController
    }
    
    controller?.game = game
    controller?.conversation = conversation
    controller?.delegate = MessagingDelegate(mvc: parent)
    
    return controller
  }
}
