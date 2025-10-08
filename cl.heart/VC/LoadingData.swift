import UIKit
//import SwiftyStoreKit
//import ApphudSDK
import Adapty
import AdaptyUI
import RealmSwift


class LoadingData: UIViewController, AdaptyPaywallControllerDelegate {
    
    // MARK: - AdaptyPaywallControllerDelegate
    func paywallController(_ controller: AdaptyPaywallController, didFinishRestoreWith profile: AdaptyProfile) {
        
        let active = profile.accessLevels["premium"]?.isActive ?? false
        do {
            let realm = try Realm()
            if let acc = realm.object(ofType: Account.self, forPrimaryKey: "main") {
                try realm.write { acc.isPro = active }
            }
        } catch {}
        let vc = Monitoring()
        self.navigationController?.setViewControllers([vc], animated: true)
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didFinishPurchase product: AdaptyPaywallProductWithoutDeterminingOffer,
                           purchaseResult: AdaptyPurchaseResult) {
        if case let .success(profile, _) = purchaseResult {
            let active = profile.accessLevels["premium"]?.isActive ?? false
            do {
                let realm = try Realm()
                if let acc = realm.object(ofType: Account.self, forPrimaryKey: "main") {
                    try realm.write { acc.isPro = active }
                }
            } catch {}
            let vc = Monitoring()
            self.navigationController?.setViewControllers([vc], animated: true)
        }
    }

    func paywallController(_ controller: AdaptyPaywallController, didFailPurchase product: AdaptyPaywallProduct, error: AdaptyError) {
        print("Adapty paywall purchase failed: \(error)")
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didFailRestoreWith error: AdaptyError) {
        print("Adapty restore failed: \(error)")
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didPerform action: AdaptyUI.Action) {
        switch action {
        case .close:
            let vc = Monitoring()
            self.navigationController?.setViewControllers([vc], animated: true)
        case let .openURL(url):
            UIApplication.shared.open(url, options: [:])
        case .custom(_):
            break
        }
    }

    
    private func presentAdaptyPaywall(placementId: String) {
        Task { @MainActor in
            do {
                let paywall = try await Adapty.getPaywall(placementId: placementId)
                guard paywall.hasViewConfiguration else {
                    return
                }
                let config = try await AdaptyUI.getPaywallConfiguration(forPaywall: paywall)
                let controller = try AdaptyUI.paywallController(with: config, delegate: self)
                self.navigationController?.pushViewController(controller, animated: true)
            } catch {
                print("Adapty paywall error (\(placementId)): \(error)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        Adapty.getProfile { [weak self] result in
            var isPro = false
            switch result {
            case .success(let profile):
                let active = profile.accessLevels["premium"]?.isActive ?? false
                isPro = active

                do {
                    let realm = try Realm()
                    if let acc = realm.object(ofType: Account.self, forPrimaryKey: "main") {
                        try realm.write { acc.isPro = active }
                    }
                } catch {

                }
            case .failure(_):
                isPro = Account.m().isPro
            }

            DispatchQueue.main.async {
                if Account.m().onb {
                    let vc = Onboarding()
                    self?.navigationController?.setViewControllers([vc], animated: true)
                } else if isPro {
                    let vc = Monitoring()
                    self?.navigationController?.setViewControllers([vc], animated: true)
                } else {
                    self?.presentAdaptyPaywall(placementId: "main")
                }
            }
        }
    }
}
