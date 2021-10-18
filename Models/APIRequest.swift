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

typealias APIRequestCompletionHandler = () -> (Void)

struct APIRequest {
  private var game: TriviaGame
  private var url: URL?
  
  /// The base components of the API request URL.
  private var urlComponents: URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "opentdb.com"
    components.path = "/api.php"
    components.queryItems = [URLQueryItem(name: "encode", value: "base64")]
    
    return components
  }
  
  /**
   Initialized a new request for the given game.
   
   - Parameter game: The game whose questions need to be populated from the API.
   
   - Returns: A request with a game to process and a URL to connect with the API based on its properties.
   */
  init(forGame game: TriviaGame) {
    self.game = game
    
    guard let questionCount = game.mode.numQuestions else {
      return
    }
    
    var components = urlComponents
    let amountParam = URLQueryItem(name: "amount", value: String(questionCount))
    components.queryItems?.append(amountParam)
    
    if let _ = Int(game.c) {
      let categoryParam = URLQueryItem(name: "category", value: game.c)
      components.queryItems?.append(categoryParam)
    }
    
    url = components.url
  }
  
  /**
   Sends the request and populates the game's questions with the results.
   
   - Parameter callback: The code to run after the questions are populated.
   */
  func send(callback: @escaping APIRequestCompletionHandler) {
    guard let url = url else {
      return
    }
    
    let populateQuestions: (Data) throws -> (Void) = { data in
      let decoder = JSONDecoder()
      let results = try decoder.decode(APIResponse.self, from: data).results
      let processed = try JSONEncoder().encode(results.sorted())
      self.game.questions = try decoder.decode([Question].self, from: processed)
    }
    
    URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
      guard let data = data, error == nil else {
        return
      }
      
      try? populateQuestions(data)
      callback()
    }.resume()
  }
  
  struct APIResponse: Decodable {
    var response_code: Int
    var results: [APIQuestion]
  }
}
