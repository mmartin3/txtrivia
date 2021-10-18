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

extension ResultsViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerBefore viewController: UIViewController) -> UIViewController? {
    return pvc(pageViewController,
               viewController: viewController,
               condition: { (questionNum, _) in
                return questionNum > 0
               }) { (qvc, questionNum) in
      qvc.displayQuestion = questionNum - 1
    }
  }
  
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerAfter viewController: UIViewController) -> UIViewController? {
    return pvc(pageViewController,
               viewController: viewController,
               condition: { (questionNum, max) in
                return questionNum < max
               }) { (qvc, questionNum) in
      qvc.displayQuestion = questionNum + 1
    }
  }
  
  private func pvc(_ pageViewController: UIPageViewController,
                                  viewController: UIViewController,
                                  condition: (QuestionNumber, QuestionNumber) -> (Bool),
                                  setter: (QuestionViewController, QuestionNumber) -> (Void)) -> UIViewController? {
    guard let qvc = viewController as? QuestionViewController,
          let mvc = delegate?.mvc,
          let questionNum = qvc.questionNum,
          let game = game,
          condition(questionNum, game.mode.numQuestions - 1),
          let gvc = GameViewController.instantiate(QuestionViewController.self,
                                                   game: game,
                                                   conversation: conversation,
                                                   parent: mvc) as? QuestionViewController else {
      return nil
    }
    
    setter(gvc, questionNum)
    gvc.pageViewController = pageViewController
    
    return gvc
  }
}
