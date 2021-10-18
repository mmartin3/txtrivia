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

class QuestionViewCallbacks: NSObject {
  static func onSent(_ controller: QuestionViewController?) {
    guard let game = controller?.game,
          let conversation = controller?.conversation else {
      return
    }
    
    if game.isComplete {
      DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
        controller?.delegate?.endGame(game, conversation: conversation)
      })
    } else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
        controller?.delegate?.wait(game: game, conversation: conversation)
      })
    }
  }
  
  static func onTurnOver(_ controller: QuestionViewController?,
                  hasNextQuestion: Bool,
                  focus view: UIView?) {
    guard let isOpen = controller?.delegate?.isOpen, isOpen else {
      return
    }
    
    if hasNextQuestion {
      controller?.optionViews().forEach { $0.isHidden = true }
      controller?.updateQuestion()
    } else {
      controller?.sendWithAnimation(focus: view)
    }
  }
  
  static func onUpdate(_ controller: QuestionViewController?, percentComplete: CGFloat) {
    controller?.view.layoutIfNeeded()
    controller?.isUpdating = false
    controller?.constraints?.updateProgress(progress: percentComplete)
    
    if controller?.readOnly == true {
      controller?.reveal(selectedButton: controller?.selectedByPlayer?.button)
    } else if controller?.game?.allPlayersAnswered == true {
      controller?.prepareToReveal(selected: controller?.selectedByPlayer?.button)
    }
  }
  
  static func preparedToReveal(_ controller: QuestionViewController?,
                               selected: OptionButton?) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak controller, weak selected] in
      guard let isOpen = controller?.delegate?.isOpen, isOpen else {
        return
      }
      
      controller?.reveal(selectedButton: selected)
    }
  }
}
