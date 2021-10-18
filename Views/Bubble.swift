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

class Bubble: UIView {
  private static let strokeWidth = 8
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    UIColor.white.setFill()
    UIColor.black.setStroke()
    UIBezierPath(ovalIn: rect).fill()
    
    for i in 0...Bubble.strokeWidth {
      let margin = CGFloat(i)
      let w = rect.width - margin * 2
      let h = rect.height - margin * 2
      let innerBounds = CGRect(x: margin, y: margin, width: w, height: h)
      UIBezierPath(ovalIn: innerBounds).stroke()
    }
  }
}
