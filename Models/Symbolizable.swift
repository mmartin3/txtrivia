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

protocol Symbolizable {
  var icon: String? { get }
  var altIcon: String? { get }
  var displayIcon: String? { get set }
}

extension Symbolizable {
  private var defaultIcon: String {
    return "questionmark"
  }
  
  var iconImage: UIImage? {
    var img: UIImage? = nil
    var attempt = 0
    
    while img == nil {
      switch attempt {
      case 0:
        if let displayIcon = self.displayIcon {
          img = UIImage(systemName: displayIcon)
        }
      case 1:
        img = UIImage(systemName: icon ?? defaultIcon)
      case 2:
        if let altIcon = self.altIcon {
          img = UIImage(systemName: altIcon)
        }
      default:
        break
      }
      
      attempt += 1
    }
    
    return img
  }
}
