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
  private var storageKey: String? {
    guard let playerID = activePlayer?.id else {
      return nil
    }
    
    return "\(id)\(playerID)"
  }
  
  /**
   Caches the active player's responses recorded prior to being sent in a message.
   */
  func cacheResponses() {
    guard let player = activePlayer, let key = storageKey else {
      return
    }
    
    let answers = player.responses.compactMap { $0 }
    
    let condensedResponseData: [Int] = zip(questions, answers).compactMap { (q, a) in
      q.options.firstIndex(of: a)
    }
    
    UserDefaults.standard.set(condensedResponseData, forKey: key)
  }
  
  /**
   Clears cached response data.
   
   - Parameter ifOutdated: If `true` the cache should only be cleared if the data is outdated.
   */
  func emptyCache(ifOutdated: Bool? = false) {
    guard let player = activePlayer, let key = storageKey else {
      return
    }
    
    let defaults = UserDefaults.standard
    
    if ifOutdated == true {
      let answeredCount = player.responses.compactMap { $0 }.count
      let cacheLen = defaults.array(forKey: key)?.count ?? 0
      
      guard cacheLen < answeredCount else {
        return
      }
    }
    
    defaults.removeObject(forKey: key)
  }
  
  /**
   Loads cached response data.
   */
  func loadResponses() {
    let defaults = UserDefaults.standard
    
    guard let key = storageKey, let cachedResponseData = defaults.array(forKey: key) else {
      return
    }
    
    for (i, a) in cachedResponseData.enumerated() {
      guard activePlayer?.responses[i] == nil, let answer = a as? Int else {
        continue
      }
      
      activePlayer?.responses[i] = questions[i].options[answer]
    }
  }
  
  /**
   Saves this game's category to list of quickstart categories.
   */
  func updateRecentCategories() {
    let maxRecentCategories = 5
    let defaults = UserDefaults.standard
    var recent = defaults.stringArray(forKey: Constants.Keys.recentCategories) ?? []
    
    recent = recent.filter {
      $0 != c
    }
    
    if recent.count == maxRecentCategories {
      recent.removeLast()
    }
    
    recent.insert(c, at: 0)
    defaults.set(recent, forKey: Constants.Keys.recentCategories)
  }
}
