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

class OutgoingTailView: TailView {
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    color = .txtPreview
  }
  
  /**
  Returns the points for drawing the tail's path.
  
  - Returns: A `TailPoints` object.
  */
  override func getPoints(inBounds rect: CGRect) -> TailPoints? {
    return TailPoints(x: [rect.maxX * 0.9, rect.minX, rect.minX - rect.maxX * 0.25],
                      cx: [rect.maxX * 0.25, rect.minX])
  }
}
