import UIKit
import SwiftyStoreKit
import ApphudSDK

class LoadingData: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        

        Apphud.fetchPlacements { placements, error in
            print(error)
            print(placements)
            for p in placements {
                if let paywall = p.paywall {
                    if let product = paywall.products.first {
                        print(product.productId)
                        subsList.append(product.productId)
                        if paywall.identifier == "BestOnboardingPaywall" {
                            onbID = product.productId
                        } else {
                            mainID = product.productId
                        }
                    }
                }
            }
            SwiftyStoreKit.retrieveProductsInfo(Set(subsList)) { result in
                result.retrievedProducts.forEach { product in
                    subsListMoney[product.productIdentifier] = product.localizedPrice ?? "-"
                    subsListInfo[product.productIdentifier] = product
                }
                DispatchQueue.main.async {
                    if Account.m().onb {
                        let vc = Onboarding()
                        self.navigationController?.setViewControllers([vc], animated: true)
                    } else {
                        if Account.m().isPro {
                            let vc = Monitoring()
                            self.navigationController?.setViewControllers([vc], animated: true)
                        } else {
                            let vc = Pay()
                            vc.isStar = true
                            self.navigationController?.setViewControllers([vc], animated: true)
                        }
                    }
                }
            }
        }
        
    }

}
