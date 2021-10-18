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

typealias PlayerID = String

class Player: NSObject, Codable {
  var id: PlayerID
  var isActive: Bool?
  private var t: TimeInterval?   // completionTime
  private var l: QuestionNumber? // lastReveal
  private var m: [Int] = []      // minResponses
  private var r: [Answer?]?      // responses
  
  var completionTime: TimeInterval? {
    get {
      return t
    }
    
    set {
      t = newValue
    }
  }
  
  var lastReveal: QuestionNumber? {
    get {
      return l
    }
    
    set {
      l = newValue
    }
  }
  
  var responses: [Answer?] {
    get {
      return r ?? []
    }
    
    set {
      r = newValue
    }
  }
  
  private var minResponses: [Int] {
    get {
      return m
    }
    
    set {
      m = newValue
    }
  }
  
  var score: Int {
    return responses.answeredCorrectly.count
  }
  
  /**
   Initializes a new player with the provided identifier.
   
   - Parameter id: The participant identifier from the active conversation.
   - Parameter questionCount: The number of questions in the game this player is playing.
   
   - Returns: A player with the given id and an array for their responses `questionCount` long.
   */
  init(id: PlayerID, questionCount: Int) {
    self.id = id
    r = Array(repeating: nil, count: questionCount)
  }
  
  /**
   Reduces the response data for sending in a message.
   */
  func compressResponses() {
    minResponses = responses.compactMap {
      $0?.optionNum
    }
    
    r = nil
    isActive = nil
  }
  
  /**
   Restores the full response data from a decoded game.
   
   - Parameter questions: The questions from which to extract response data.
   */
  func restoreResponses(toQuestions questions: [Question]?) {
    guard let questions = questions else {
      return
    }
    
    responses = Array(repeating: nil, count: questions.count)
    
    for (i, q) in questions.enumerated() {
      guard i < minResponses.count else {
        break
      }
      
      responses[i] = q.options[minResponses[i]]
    }
  }
  
  /**
   Combines two players' responses.
   
   - Parameter player: The other player to merge with this one.
   */
  func mergeResponses(withPlayer player: Player?) {
    guard let otherPlayer = player else {
      return
    }
    
    let zipped = zip(responses, otherPlayer.responses)
    
    for (i, (left, right)) in zipped.enumerated() {
      responses[i] = left ?? right
    }
  }
}

// MARK: - Comparable

extension Player: Comparable {
  static func < (lhs: Player, rhs: Player) -> Bool {
    return lhs.isActive ?? false
  }
}
