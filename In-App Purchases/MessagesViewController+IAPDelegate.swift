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

import StoreKit
import UIKit

// MARK: - IAPDelegate

extension MessagesViewController: IAPDelegate {
  func promptToRemoveAds(product: SKProduct?) {
    guard let price = IAPManager.shared.formatPrice(forProduct: product) else {
      return
    }
    
    let title = "Confirm Your In-App Purchase"
    let message = "Remove ads for \(price)?"
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Remove Ads", style: .default, handler: { _ in
      IAPManager.shared.removeAds(payment: SKPayment(product: product!))
    }))
    
    alert.addAction(UIAlertAction(title: "Restore Purchase", style: .default, handler: { _ in
      IAPManager.shared.restorePurchases()
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: true)
  }
  
  func didCompleteTransaction(withResult transactionState: SKPaymentTransactionState?) {
    let message: String
      
    switch transactionState {
    case .purchased:
      message = "Thank you for your purchase."
    case .restored:
      message = "Your purchase was restored."
    case .failed:
      message = "There was a problem with your purchase."
    default:
      return
    }
    
    let alert = UIAlertController(title: "You're all set", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true)
    
    if IAPManager.shared.removedAds {
      children.first?.didMove(toParent: self)
    }
  }
}
