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

typealias QuestionNumber = Int

class Question: NSObject, Codable {
  private var d: Int?      // difficultyLevel
  private var o: [Answer]! // options
  private var x: String!   // text
  
  var difficultyLevel: Int? {
    get {
      return d
    }
    
    set {
      d = newValue
    }
  }
  
  var options: [Answer] {
    get {
      return o
    }
    
    set {
      o = newValue
    }
  }
  
  var text: String {
    get {
      return x
    }
    
    set {
      x = newValue
    }
  }
}
