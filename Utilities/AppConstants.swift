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

import UIKit

enum Constants {
  enum UI {
    static let bannerAdSpacing: CGFloat = 72
    static let balloonMargin = UIScreen.main.bounds.height / 64
    static let opaque: CGFloat = 1
    static let paddedMultiplier: CGFloat = 0.94
    static let margin: CGFloat = 0.06
    static let maxFontSize: CGFloat = 256
    static let minFontSize = UIScreen.main.bounds.width / 32
    static let minScale: CGFloat = 0.01
  }
  
  enum Keys {
    static let hidVibrationControl = "a"
    static let mute = "b"
    static let recentCategories = "c"
    static let removedAds = "d"
    static let selectedCategory = "e"
    static let vibrationDisabled = "f"
  }
  
  enum Captions {
    static let challenge = "I challenge you to a game of trivia!"
    static let ready = "Your turn to answer."
    static let nudged = "Don't forget about our game!"
    static let win = "You win!"
    static let lose = "GAME OVER"
    static let tie = "It's a tie!"
  }
}
