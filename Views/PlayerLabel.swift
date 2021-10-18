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

class PlayerLabel: UIView {
  private var background = UIView()
  
  /**
   Initializes a round label representing the player.
   
   - Parameter n: The player number.
   */
  init(n: Int) {
    super.init(frame: CGRect.zero)
    
    let imgMultiplier: CGFloat = 0.98
    let labelMultiplier: CGFloat = 0.72
    let img = UIImageView(image: UIImage(named: "overlay"))
    let label = UILabel()
    backgroundColor = .white
    translatesAutoresizingMaskIntoConstraints = false
    background.backgroundColor = UIColor(playerNum: n)
    background.translatesAutoresizingMaskIntoConstraints = false
    img.translatesAutoresizingMaskIntoConstraints = false
    img.alpha = 0.2
    label.text = "P\(n)"
    label.baselineAdjustment = .alignCenters
    label.textAlignment = .center
    label.textColor = .white
    label.font = UIFont(name: "Menlo Bold", size: Constants.UI.maxFontSize)
    label.minimumScaleFactor = Constants.UI.minScale
    label.translatesAutoresizingMaskIntoConstraints = false
    label.adjustsFontSizeToFitWidth = true
    
    addSubview(background)
    addSubview(img)
    addSubview(label)
    
    NSLayoutConstraint.activate([
      background.widthAnchor.constraint(equalTo: widthAnchor),
      background.heightAnchor.constraint(equalTo: heightAnchor),
      label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: labelMultiplier),
      label.heightAnchor.constraint(equalTo: heightAnchor, multiplier: labelMultiplier),
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.centerYAnchor.constraint(equalTo: centerYAnchor),
      img.widthAnchor.constraint(equalTo: widthAnchor, multiplier: imgMultiplier),
      img.heightAnchor.constraint(equalTo: heightAnchor, multiplier: imgMultiplier),
      img.centerXAnchor.constraint(equalTo: centerXAnchor),
      img.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = bounds.width / 2
    background.layer.cornerRadius = layer.cornerRadius
  }
}
