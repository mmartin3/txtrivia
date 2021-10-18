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

import GoogleMobileAds
import UIKit

extension UIViewController: GADFullScreenContentDelegate {
  var background: UIView {
    view.translatesAutoresizingMaskIntoConstraints = false
    
    guard self as? UINavigationController == nil,
          let backgroundImage = UIImage(named: "background") else {
      return view
    }
    
    let background = UIImageView(image: backgroundImage)
    let ratio = backgroundImage.size.height / backgroundImage.size.width
    let margins = view.margins
    background.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .txtBackground
    view.insertSubview(background, at: 0)
    
    NSLayoutConstraint.activate([
      background.leftAnchor.constraint(equalTo: margins[0].rightAnchor),
      background.rightAnchor.constraint(equalTo: margins[1].leftAnchor),
      background.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      background.heightAnchor.constraint(equalTo: background.widthAnchor, multiplier: ratio)
    ])
    
    return view
  }
  
  func loadBannerAd() {
    guard let adManager = AdManager.shared,
          adManager.bannerView.adUnitID == nil else {
      return
    }
    
    adManager.bannerView.adUnitID = adManager.bannerAdID
    adManager.bannerView.rootViewController = self
    adManager.bannerView.isHidden = false
    adManager.bannerView.load(GADRequest())
  }
  
  func playInterstitial() {
    guard let adManager = AdManager.shared else {
      return
    }
    
    if let ad = adManager.interstitial {
      ad.fullScreenContentDelegate = self
      ad.present(fromRootViewController: self)
    } else {
      adManager.preloadInterstitial { [weak self] in
        self?.playInterstitial()
      }
    }
  }
  
  func playRewardedAd(completionHandler: @escaping () -> (Void)) {
    guard let adManager = AdManager.shared else {
      return
    }
    
    if let ad = adManager.rewardedAd {
      ad.fullScreenContentDelegate = self
      
      ad.present(fromRootViewController: self,
                 userDidEarnRewardHandler: completionHandler)
    } else {
      adManager.preloadRewardedAd { [weak self] in
        self?.playRewardedAd(completionHandler: completionHandler)
      }
    }
  }
}
