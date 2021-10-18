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

class ResponsesCell: UITableViewCell {
  /// If `false`, represents completion times instead of responses.
  var isResponse: Bool
  
  /// The spacing after a player label.
  let playerLabelMargin: CGFloat = 6
  
  /**
   Initializes a cell respresenting data corresponding to the index and player provided.
   
   - Parameter players: All players playing the game.
   - Parameter indexPath: Index in the parent table.
   
   - Returns: A new cell view representing the given players' data.
   */
  init(players: [Player]?, indexPath: IndexPath) {
    isResponse = indexPath.section != players?.first?.responses.count
    
    super.init(style: .default, reuseIdentifier: nil)
    
    guard let players = players else {
      return
    }
    
    contentView.addSubview(UIView())
    isUserInteractionEnabled = isResponse
    isAccessibilityElement = true
    accessibilityTraits = .staticText
    
    accessibilityValue = players.compactMap {
      guard let n = players.firstIndex(of: $0) else {
        return nil
      }
      
      if isResponse {
        return describeResponse($0.responses[indexPath.section], player: n)
      } else {
        return describeTime($0.completionTime, player: n)
      }
    }.joined()
    
    for (i, player) in players.enumerated() {
      addPlayer(player, index: i, question: indexPath.section)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /**
   Adds the given player's response or completion time.
   
   - Parameter player: The player to represent in this iteration.
   - Parameter playerNum: The player number.
   - Parameter i: The question index.
   */
  private func addPlayer(_ player: Player, index playerNum: Int, question i: Int) {
    let playerLabel = PlayerLabel(n: playerNum + 1)
    contentView.addSubview(playerLabel)
    
    NSLayoutConstraint.activate([
      playerLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: Constants.UI.paddedMultiplier),
      playerLabel.widthAnchor.constraint(equalTo: playerLabel.heightAnchor),
      playerLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    if playerNum > 0 {
      playerLabel.leftAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    } else {
      playerLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor,
                                        constant: playerLabelMargin).isActive = true
    }
    
    if isResponse {
      addResponse(player.responses[i])
    } else if let t = player.completionTime {
      addCompletionTime(t)
    }
  }
  
  /**
   Adds the given response to the cell.
   
   - Parameter response: The selected option for which to create a visual representation.
   */
  private func addResponse(_ response: Answer?) {
    guard let item = contentView.subviews.last else {
      return
    }
    
    let letterImage = UIImageView(image: UIImage(option: response))
    let tickImage = UIImageView(isCorrect: response?.isCorrect == true)
    let whiteImage = UIImageView(image: UIImage(systemName: "circle.fill"))
    whiteImage.tintColor = .white
    whiteImage.translatesAutoresizingMaskIntoConstraints = false
    letterImage.translatesAutoresizingMaskIntoConstraints = false
    tickImage.translatesAutoresizingMaskIntoConstraints = false
    
    if response == nil {
      letterImage.tintColor = .txtGray
      tickImage.isHidden = true
      whiteImage.isHidden = true
    }
    
    contentView.addSubview(letterImage)
    contentView.addSubview(whiteImage)
    contentView.addSubview(tickImage)
    
    NSLayoutConstraint.activate([
      tickImage.rightAnchor.constraint(equalTo: letterImage.rightAnchor),
      tickImage.topAnchor.constraint(equalTo: letterImage.topAnchor),
      tickImage.widthAnchor.constraint(equalTo: tickImage.heightAnchor),
      letterImage.leftAnchor.constraint(equalTo: item.rightAnchor, constant: playerLabelMargin),
      letterImage.heightAnchor.constraint(equalTo: item.heightAnchor),
      letterImage.centerYAnchor.constraint(equalTo: item.centerYAnchor),
      whiteImage.centerXAnchor.constraint(equalTo: tickImage.centerXAnchor),
      whiteImage.centerYAnchor.constraint(equalTo: tickImage.centerYAnchor),
      whiteImage.heightAnchor.constraint(equalTo: tickImage.heightAnchor),
      whiteImage.widthAnchor.constraint(equalTo: tickImage.widthAnchor),
      NSLayoutConstraint(item: letterImage, attribute: .width, relatedBy: .equal, toItem: item, attribute: .height, multiplier: 1.11, constant: 0),
      NSLayoutConstraint(item: tickImage, attribute: .height, relatedBy: .equal, toItem: letterImage, attribute: .height, multiplier: 0.28, constant: playerLabelMargin)
    ])
  }
  
  /**
   Adds the given completion time.
   
   - Parameter t: The completion time in seconds for which to create a visual representation.
   */
  private func addCompletionTime(_ t: TimeInterval) {
    guard let item = contentView.subviews.last else {
      return
    }
    
    let timeLabel = UILabel()
    timeLabel.text = formatTime(t)
    timeLabel.translatesAutoresizingMaskIntoConstraints = false
    timeLabel.adjustsFontSizeToFitWidth = true
    timeLabel.font = UIFont(name: "Pocket Calculator", size: frame.height)
    timeLabel.minimumScaleFactor = Constants.UI.minScale
    contentView.addSubview(timeLabel)
    
    NSLayoutConstraint.activate([
      timeLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.28),
      timeLabel.heightAnchor.constraint(equalTo: item.heightAnchor, multiplier: 0.96),
      timeLabel.leftAnchor.constraint(equalTo: item.rightAnchor, constant: playerLabelMargin * 1.2),
      timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    accessibilityLabel = "players' completion times"
  }
  
  /**
   Returns a string representation of the player at the index provided.
   
   - Parameter n: The player number.
   
   - Returns: A string representation of the indicated player.
   */
  private func describePlayer(atIndex n: Int) -> String {
    if n > 0 {
      return "Player \(n + 1)"
    } else {
      return "You"
    }
  }
  
  /**
   Returns a string representation of the provided response.
   
   - Parameter response: The response to describe.
   - Parameter n: The player number.
   
   - Returns: An optional containing a string representation of the response if adequate data is provided.
   */
  private func describeResponse(_ response: Answer?, player n: Int) -> String? {
    guard let response = response else {
      return nil
    }
    
    let answerDescription = response.isCorrect ? "correctly": "incorrectly"
    
    return "\(describePlayer(atIndex: n)) answered \(answerDescription) with option \(response.letter), \(response.x)."
  }
  
  /**
   Returns a string representation of the given completion time.
   
   - Parameter completionTime: The completion time in seconds.
   - Parameter n: The player number.
   */
  private func describeTime(_ completionTime: TimeInterval?, player n: Int) -> String? {
    guard let completionTime = completionTime else {
      return nil
    }
    
    let formattedTime = String(format: "%.2f", completionTime)
    
    return "\(describePlayer(atIndex: n)) finished in \(formattedTime) seconds."
  }
  
  /**
   Formats the given time interval.
   
   - Parameters t: The time to format.
   
   - Returns: The formatted time interval.
   */
  private func formatTime(_ t: TimeInterval?) -> String {
    var m = 0
    var s = t!
    
    while s > 60 {
      m += 1
      s -= 60
    }
    
    var formatted = "\(m):"
    
    if s < 10 {
      formatted += "0"
    }
    
    formatted += String(format: "%.2f", s)
    
    return formatted
  }
}
