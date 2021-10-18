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

struct Answer: Codable {
  var c: Int    // correct flag
  var i: Int?   // optionNum
  var x: String // text
  
  var isCorrect: Bool {
    get {
      return c == 1
    }
    
    set {
      c = newValue == true ? 1 : 0
    }
  }
  
  var letter: String {
    return ["a", "b", "c", "d"][i ?? 0]
  }
  
  var numericText: Double? {
    return Double(x.replacingOccurrences(of: ",", with: ""))
  }
  
  var optionNum: Int? {
    get {
      return i
    }
    
    set {
      i = newValue
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
  
  static func correct(withText text: String) -> Answer {
    return Answer(c: 1, x: text)
  }
  
  static func incorrect(withText text: String) -> Answer {
    return Answer(c: 0, x: text)
  }
}

// MARK: - Equatable

extension Answer: Equatable {
  static func == (lhs: Answer, rhs: Answer) -> Bool {
    return lhs.text == rhs.text
  }
}
