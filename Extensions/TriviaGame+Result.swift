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
  enum Result: String {
    case win, lose, draw, tbd
    
    /**
     Attempts to break a tie between the players provided.
     
     - Parameter winners: The top scoring players.
     
     - Returns: A `Result` with the final outcome.
     */
    static func breakTie(between winners: [Player]) -> Result {
      let fastestTime = winners.fastestTime
      let fastestPlayers = winners.filter { $0.completionTime == fastestTime }
      
      if fastestPlayers.count == 1 {
        let t = winners.filter { $0.isActive == true }.first?.completionTime
        
        return t == fastestTime ? .win : .lose
      }
      
      return .draw
    }
    
    var clip: MutableAudioPlayer? {
      return SE.result[self]
    }
  }
  
  var result: Result {
    guard isComplete else {
      return .tbd
    }
    
    let topScore = players.map({ $0.score }).max()
    
    guard topScore == activePlayer?.score else {
      return .lose
    }
    
    let winners = players.filter { $0.score == topScore }
    
    if winners.count == 1 {
      return .win
    } else if mode is TurnBasedMode {
      return .draw
    }
    
    return .breakTie(between: winners)
  }
}
