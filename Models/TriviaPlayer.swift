/// Copyright (c) 2021 Matthew Martin
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
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

class Player: Codable {
  var id: String
  var active: Bool?
  var completionTime: TimeInterval?
  var responses: [Answer?]
  
  var score: Int {
    return responses.filter { $0?.isCorrect == true }.count
  }
  
  /**
   Initializes a new player with the provided identifier.
   
   - Parameter id: The participant identifier from the active conversation.
   - Parameter questionCount: The number of questions in the game this player is playing.
   
   - Returns: A player with the given id and an array for their responses `questionCount` long.
   */
  init(id: String, questionCount: Int) {
    self.id = id
    self.responses = Array(repeating: nil, count: questionCount)
  }
  
  /**
   Combines two players' responses.
   
   - Parameter player: The other player to merge with this one.
   */
  func mergeResponses(withPlayer player: Player?) {
    guard let otherPlayer = player else {
      return
    }
    
    var i = 0
    
    for (left, right) in zip(responses, otherPlayer.responses) {
      responses[i] = left ?? right
      i += 1
    }
  }
}

extension Player: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Player: Equatable {
  static func == (lhs: Player, rhs: Player) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Player: Comparable {
  static func < (lhs: Player, rhs: Player) -> Bool {
    return lhs.active ?? false
  }
}
