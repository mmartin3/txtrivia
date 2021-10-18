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

class APIQuestion: Question {
  enum CodingKeys: String, CodingKey {
    case category
    case correctAnswer = "correct_answer"
    case incorrectAnswers = "incorrect_answers"
    case difficulty
    case question
    case type
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
    
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let difficulty = try values.decodeFromBase64(String.self, forKey: .difficulty)
    text = try values.decode(String.self, forKey: .question)
    options = try values.decodeOptions(correctKey: .correctAnswer, incorrectKey: .incorrectAnswers)
    difficultyLevel = ["easy", "medium", "hard"].firstIndex(of: difficulty)
  }
}
