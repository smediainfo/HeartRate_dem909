

import UIKit
import Adapty
import AdaptyUI
import RealmSwift

class Info1: UIViewController, AdaptyPaywallControllerDelegate {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var textL: UILabel!
    @IBOutlet weak var tl: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        saveButton.clipsToBounds = true
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = Font.semibold(size: 14)
        
        
        tl.font = Font.bold(size: 22)
        titleL.font = Font.medium(size: 16)
        textL.font = Font.regular(size: 16)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    private func presentOnboardingPaywall() {
        Task { @MainActor in
            do {
                let paywall = try await Adapty.getPaywall(placementId: "onb")
                guard paywall.hasViewConfiguration else {
                    return
                }
                let config = try await AdaptyUI.getPaywallConfiguration(forPaywall: paywall)
                
                let controller = try AdaptyUI.paywallController(with: config, delegate: self)
                self.navigationController?.pushViewController(controller, animated: true)
            } catch {
                print("Adapty onb paywall error: \(error)")
            }
        }
    }

    @IBAction func clickNext(_ sender: Any) {
        presentOnboardingPaywall()
    }




    // MARK: - AdaptyPaywallControllerDelegate
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
        }
        
        let vc = Monitoring()
        self.navigationController?.setViewControllers([vc], animated: true)
    }

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

    func paywallController(_ controller: AdaptyPaywallController, didFailPurchase product: AdaptyPaywallProduct, error: AdaptyError) {
        print("Adapty onb purchase failed: \(error)")
    }

    func paywallController(_ controller: AdaptyPaywallController, didFailRestoreWith error: AdaptyError) {
        print("Adapty onb restore failed: \(error)")
    }
}
