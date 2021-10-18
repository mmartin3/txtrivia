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

extension KeyedDecodingContainer {
  /**
   Decodes the specified data to a base 64 encoded string, then returns the string decoded.
   
   - Parameter type: The output type.
   - Parameter key: The key indicating which property to decode.
   
   - Returns: The specified data as a base 64 decoded string.
   */
  func decodeFromBase64(_ type: String.Type,
                        forKey key: KeyedDecodingContainer<K>.Key) throws -> String {
    return try decode(type, forKey: key).decodedFromBase64
  }
  
  /**
   Decodes the specified data as an array of base 64 encoded strings, then returns the strings decoded.
   
   - Parameter type: The output type.
   - Parameter key: The key indicating which property to decode.
   
   - Returns: The specified data as a decoded string array.
   */
  func decodeFromBase64(_ type: [String].Type,
                        forKey key: KeyedDecodingContainer<K>.Key) throws -> [String] {
    return try decode(type, forKey: key).map { $0.decodedFromBase64 }
  }
  
  /**
   Decodes the answer options for a question, orders them, and returns them in an array.
   
   - Parameter correctKey: The correct option coding key.
   - Parameter incorrectKey: The incorrect options coding key.
   
   - Returns: An array of decoded `Answer`s.
   */
  func decodeOptions(correctKey: KeyedDecodingContainer<K>.Key,
                     incorrectKey: KeyedDecodingContainer<K>.Key) throws -> [Answer] {
    let correct = try decodeFromBase64(String.self, forKey: correctKey)
    let incorrect = try decodeFromBase64([String].self, forKey: incorrectKey)
    var options: [Answer] = [.correct(withText: correct)]
    options += incorrect.map { .incorrect(withText: $0) }
    let numericAnswers = options.compactMap { $0.numericText }
    
    if numericAnswers.count == options.count {
      options.sort() { $0.numericText! < $1.numericText! }
    } else if correct == "False" {
      options.reverse()
    } else if correct != "True" {
      options.shuffle()
    }
    
    for (i, _) in options.enumerated() {
      options[i].optionNum = i
    }
    
    return options
  }
}
