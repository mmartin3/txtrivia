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

extension TriviaGame {
  var questions: [Question] {
    get {
      return q
    }
    
    set {
      q = newValue
    }
  }
  
  var currentQuestion: Question {
    return questions[currentIndex]
  }
  
  var currentIndex: QuestionNumber {
    get {
      return i
    }
    
    set {
      i = newValue
    }
  }
  
  var hasNextQuestion: Bool {
    return currentIndex + 1 < mode.numQuestions
  }
  
  var nudgeIndex: QuestionNumber? {
    get {
      return n
    }
    
    set {
      n = newValue
    }
  }
}
