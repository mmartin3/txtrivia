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

import SafariServices
import UIKit

class SettingsViewController: UIViewController {
  private let on: String = "on"
  private let off: String = "off"
  private let generator = MutableImpactFeedbackGenerator()
  
  private var buttons: [SettingButton] {
    let buttons: [SettingButton] = [premiumButton, deleteButton, soundButton, vibeButton]
    
    return buttons
  }
  
  private var isMuted: Bool {
    return UserDefaults.standard.bool(forKey: Constants.Keys.mute)
  }
  
  private var isVibrationDisabled: Bool {
    let key = Constants.Keys.vibrationDisabled
    
    return UserDefaults.standard.bool(forKey: key)
  }
  
  private var soundIcon: String {
    //Use speaker.wave.2 for ios 14
    return isMuted ? "speaker.slash" : "speaker"
  }
  
  private var vibeIcon: String {
    return "iphone.\(isVibrationDisabled ? "slash" : "radiowaves.left.and.right")"
  }
  
  @IBOutlet weak var deleteButton: SettingButton!
  @IBOutlet weak var soundButton: SettingButton!
  @IBOutlet weak var premiumButton: SettingButton!
  @IBOutlet weak var vibeButton: SettingButton!
  
  @IBAction func toggleSound(_ sender: SettingButton) {
    generator.impactOccurred()
    UserDefaults.standard.set(!isMuted, forKey: Constants.Keys.mute)
    sender.setImage(UIImage(systemName: soundIcon))
    sender.accessibilityValue = "sound is turned \(isMuted ? off: on)"
    sender.accessibilityHint = "turn sound \(isMuted ? on: off)"
  }
  
  @IBAction func toggleVibration(_ sender: SettingButton) {
    generator.impactOccurred()
    UserDefaults.standard.set(!isVibrationDisabled, forKey: Constants.Keys.vibrationDisabled)
    sender.setImage(UIImage(systemName: vibeIcon))
    sender.accessibilityValue = "vibration is turned \(isVibrationDisabled ? off: on)"
    sender.accessibilityHint = "turn vibration \(isVibrationDisabled ? on: off)"
  }
  
  @IBAction func deletionInfo(_ sender: UIButton) {
    let urlString = "https://support.apple.com/en-us/HT206906"
    
    guard let url = URL(string: urlString) else {
      return
    }
    
    generator.impactOccurred()
    present(SFSafariViewController(url: url), animated: true)
  }
  
  @IBAction func removeAds(_ sender: UIButton) {
    generator.impactOccurred()
    IAPManager.shared.startPurchase()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let iapm = IAPManager.shared
    let defaults = UserDefaults.standard
    let hidKey = Constants.Keys.hidVibrationControl
    
    if !iapm.isActive || iapm.removedAds || !iapm.canMakePayments {
      premiumButton.isHidden = true
    }
    
    if !iapm.isActive {
      deleteButton.isHidden = true
    }
    
    if #available(iOS 14.0, *) {
      if defaults.bool(forKey: hidKey) { resetVibration() }
    } else {
      let disableVibesKey = Constants.Keys.vibrationDisabled
      vibeButton.isHidden = true
      defaults.set(true, forKey: disableVibesKey)
      defaults.set(true, forKey: hidKey)
    }
    
    soundButton.accessibilityLabel = "sound effects toggle"
    deleteButton.accessibilityLabel = "iMessage info"
    deleteButton.accessibilityHint = "learn how to manage and delete iMessage extensions"
    premiumButton.accessibilityLabel = "remove ads button"
    premiumButton.accessibilityHint = "make an in-app purchase to remove ads or restore a previous purchase"
    
    positionButtons()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    var config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
    let buttonColor: UIColor
    
    super.viewDidAppear(animated)
    
    if let _ = parent as? QuestionViewController {
      buttonColor = .txtTitle
    } else {
      buttonColor = .txtPreview
    }
    
    buttons.forEach {
      $0.backgroundColor = buttonColor
    }
    
    soundButton.setImage(UIImage(systemName: soundIcon, withConfiguration: config))
    deleteButton.setImage(UIImage(systemName: "info", withConfiguration: config))
    premiumButton.setImage(UIImage(named: "noads"))
    
    if #available(iOS 14.0, *) {
      config = UIImage.SymbolConfiguration(pointSize: 20)
      vibeButton.setImage(UIImage(systemName: vibeIcon, withConfiguration: config))
    }
  }
  
  /**
   Constrains the visible settings buttons.
   */
  private func positionButtons() {
    let c: CGFloat = UIScreen.main.bounds.width / 150
    let buttonsLeft = buttons.first?.leftAnchor
    let buttonsRight = buttons.last?.rightAnchor
    var neighbor: UIView?
    buttonsLeft?.constraint(greaterThanOrEqualTo: view.leftAnchor).isActive = true
    buttonsRight?.constraint(equalTo: view.rightAnchor).isActive = true
    
    for button in buttons.reversed() {
      guard !button.isHidden else {
        continue
      }
      
      let constr = [button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    button.widthAnchor.constraint(equalTo: button.heightAnchor),
                    button.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
                    button.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)]
      
      let right = button.rightAnchor
      neighbor?.leftAnchor.constraint(equalTo: right, constant: c).isActive = true
      neighbor?.widthAnchor.constraint(equalTo: button.widthAnchor).isActive = true
      neighbor?.heightAnchor.constraint(equalTo: button.heightAnchor).isActive = true
      neighbor = button
      
      NSLayoutConstraint.activate(constr)
    }
  }
  
  /**
   Resets vibration user defaults. Called when they were hidden programatically.
   */
  private func resetVibration() {
    for key in [Constants.Keys.vibrationDisabled,
                Constants.Keys.hidVibrationControl] {
      UserDefaults.standard.removeObject(forKey: key)
    }
  }
}
