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

class TailView: UIView {
  var color: UIColor? {
    didSet {
      setNeedsDisplay()
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    translatesAutoresizingMaskIntoConstraints = false
  }
  
  override func draw(_ rect: CGRect) {
    isOpaque = false
    
    super.draw(rect)
    
    guard let points = getPoints(inBounds: rect) else {
      return
    }
    
    let path = UIBezierPath()
    color?.set()
    path.move(to: CGPoint(x: points.x[0], y: rect.maxY))
    path.addCurve(to: CGPoint(x: points.x[1], y: rect.maxY * 0.5), controlPoint1: CGPoint(x: points.cx[0], y: rect.maxY), controlPoint2: CGPoint(x: points.cx[1], y: rect.maxY * 0.75))
    path.addLine(to: CGPoint(x: points.x[2], y: rect.maxY * 0.6))
    path.addCurve(to: CGPoint(x: points.x[0], y: rect.maxY), controlPoint1: CGPoint(x: points.cx[0], y: rect.maxY), controlPoint2: CGPoint(x: points.x[2], y: rect.maxY))
    color?.setFill()
    path.close()
    path.fill()
  }
  
  /**
   Returns the points for drawing the tail's path.
   
   - Returns: `nil`
   */
  func getPoints(inBounds rect: CGRect) -> TailPoints? {
    return nil
  }
  
  struct TailPoints {
    var x: [CGFloat]
    var cx: [CGFloat]
  }
}
