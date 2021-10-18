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

import AVFoundation

class MutableAudioPlayer: AVAudioPlayer {
  /**
   Initializes an audio player that can be muted for the audio file indicated.
   
   - Parameter name: The audio file name.
   - Parameter ext: The audio file extension.
   
   - Returns: A mutable audio player for the audio file indicated.
   */
  convenience init(name: String?, ext: String? = nil) {
    guard let path = Bundle.main.path(forResource: name, ofType: ext) else {
      fatalError("File not found: \(name!).\(ext!)")
    }
    
    do {
      try self.init(contentsOf: URL(fileURLWithPath: path))
    } catch {
      self.init()
    }
    
    volume = 0.8
  }
  
  @discardableResult override func play() -> Bool {
    guard !isPlaying else {
      return false
    }
    
    let defaults = UserDefaults.standard
    
    if !defaults.bool(forKey: Constants.Keys.mute) {
      return super.play()
    }
    
    return false
  }
}

enum SE {
  static var processing = MutableAudioPlayer(name: "processing", ext: "wav")
  static var rightAnswer = MutableAudioPlayer(name: "correct", ext: "wav")
  static var wrongAnswer = MutableAudioPlayer(name: "incorrect", ext: "wav")
  static var timer = MutableAudioPlayer(name: "timer", ext: "mp3")
  
  static var result: [TriviaGame.Result: MutableAudioPlayer] = [
    .win: MutableAudioPlayer(name: TriviaGame.Result.win.rawValue, ext: "flac"),
    .lose: MutableAudioPlayer(name: TriviaGame.Result.lose.rawValue, ext: "wav"),
    .draw: MutableAudioPlayer(name: TriviaGame.Result.draw.rawValue, ext: "mp3")
  ]
  
  static func prepare(forAnswer answer: Answer?) {
    guard let answer = answer else {
      return
    }
    
    (answer.isCorrect ? Self.rightAnswer : Self.wrongAnswer).prepareToPlay()
  }
}
