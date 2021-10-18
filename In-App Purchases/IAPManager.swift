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

class IAPManager: NSObject {
  static let shared = IAPManager()
  var delegate: IAPDelegate?
  
  /// Enables or disables the button to trigger a purchase.
  var isActive = true
  
  var canMakePayments: Bool {
    return SKPaymentQueue.canMakePayments()
  }
  
  var removedAds: Bool {
    get {
      return UserDefaults.standard.bool(forKey: Constants.Keys.removedAds)
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: Constants.Keys.removedAds)
    }
  }
  
  private var request: SKProductsRequest {
    let products = Set(["com.mattmakesapps.txtrivia.ads"])
    let request = SKProductsRequest(productIdentifiers: products)
    request.delegate = self
    
    return request
  }
  
  private override init() {
    super.init()
  }
  
  func formatPrice(forProduct product: SKProduct?) -> String? {
    guard let product = product else {
      return nil
    }
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = product.priceLocale
    
    return formatter.string(from: product.price)
  }
  
  func startPurchase() {
    guard !removedAds else {
      return
    }
    
    request.start()
  }
  
  func removeAds(payment: SKPayment) {
    guard !removedAds else {
      return
    }
    
    SKPaymentQueue.default().add(payment)
  }
  
  func restorePurchases() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
}

// MARK: - SKProductsRequestDelegate

extension IAPManager: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest,
                       didReceive response: SKProductsResponse) {
    delegate?.promptToRemoveAds(product: response.products.first)
  }
}

// MARK: - SKPaymentTransactionObserver

extension IAPManager: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue,
                    updatedTransactions transactions: [SKPaymentTransaction]) {
    for t in transactions {
      let success = t.transactionState == .purchased || t.transactionState == .restored
      
      guard success || t.transactionState == .failed else {
        return
      }
      
      removedAds = success
      SKPaymentQueue.default().finishTransaction(t)
      delegate?.didCompleteTransaction(withResult: t.transactionState)
    }
  }
}
