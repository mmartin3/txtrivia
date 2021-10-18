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

class AdManager: NSObject {
  private static let instance = AdManager()
  let bannerView = GADBannerView()
  let bannerAdID = "ca-app-pub-3940256099942544/2934735716"
  let interstitialID = "ca-app-pub-3940256099942544/4411468910"
  let rewardedID = "ca-app-pub-3940256099942544/1712485313"
  var interstitial: GADInterstitialAd?
  var rewardedAd: GADRewardedAd?
  
  static var shared: AdManager? {
    if IAPManager.shared.removedAds {
      return nil
    } else {
      return .instance
    }
  }
  
  private override init() {
    super.init()
    
    let ads = GADMobileAds.sharedInstance()
    ads.start(completionHandler: nil)
    ads.requestConfiguration.testDeviceIdentifiers = [kGADSimulatorID as! String]
  }
  
  func addBanner(toView view: UIView) {
    guard !bannerView.isDescendant(of: view) else {
      return
    }
    
    let w: CGFloat = 320
    let h: CGFloat = 50
    let c: CGFloat = h - Constants.UI.bannerAdSpacing + 6
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(bannerView)
    
    NSLayoutConstraint.activate([
      bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: c),
      bannerView.widthAnchor.constraint(equalToConstant: w),
      bannerView.heightAnchor.constraint(equalToConstant: h)
    ])
  }
  
  func preloadInterstitial(completion callback: (() -> (Void))? = nil) {
    GADInterstitialAd.load(withAdUnitID: interstitialID,
                           request: GADRequest(),
                           completionHandler: { [self] ad, error in
      if let error = error {
        print(error.localizedDescription)
      }
      
      self.interstitial = ad
      callback?()
    })
  }
  
  func preloadRewardedAd(completion callback: (() -> (Void))? = nil) {
    GADRewardedAd.load(withAdUnitID: rewardedID,
                       request: GADRequest(),
                       completionHandler: { [self] ad, error in
      if let error = error {
        print(error.localizedDescription)
      }
      
      self.rewardedAd = ad
      callback?()
    })
  }
}
