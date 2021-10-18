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

extension Array where Element == Player {
  /// The fastest completion time among the players.
  var fastestTime: TimeInterval? {
    return compactMap { $0.completionTime }.min()
  }
  
  /**
   Gets the player corresponding to the participant identifier string provided.
   
   - Parameter playerID: The participant identifier string.
   
   - Returns: An optional containing the player if they were found.
   */
  subscript(_ playerID: String?) -> Player? {
    if playerID == first?.id {
      return first
    } else if count > 1 {
      return last
    }
    
    return filter { $0.id == playerID }.first
  }
}
