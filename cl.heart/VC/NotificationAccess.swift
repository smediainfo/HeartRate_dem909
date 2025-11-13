
import UIKit
import UserNotifications
import Adapty
import AdaptyUI
import RealmSwift

class NotificationAccess: UIViewController, AdaptyPaywallControllerDelegate {

    
    @IBOutlet weak var sw: UISwitch!
    @IBOutlet weak var motiveDesc: UILabel!
    @IBOutlet weak var motiveTitle: UILabel!
    @IBOutlet weak var tl: UILabel!
    @IBOutlet weak var notNowButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        saveButton.clipsToBounds = true
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = Font.semibold(size: 14)
        notNowButton.clipsToBounds = true
        notNowButton.layer.cornerRadius = 8
        notNowButton.titleLabel?.font = Font.semibold(size: 14)
        notNowButton.layer.borderColor = #colorLiteral(red: 0, green: 0.007843137255, blue: 0.07450980392, alpha: 0.09).cgColor
        notNowButton.layer.borderWidth = 1.5
        
        
        tl.font = Font.bold(size: 22)
        motiveTitle.font = Font.medium(size: 16)
        motiveDesc.font = Font.regular(size: 16)
    }


    @IBAction func clickSave(_ sender: Any) {
        if sw.isOn {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                DispatchQueue.main.async {
                    Logger.log(name: "User notification permission granted", params: ["permission": granted ? "true" : "false" ])
                    UIApplication.shared.registerForRemoteNotifications()
                    self.presentOnboardingPaywall()

                }
            }
        }
    }
    
    
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
        UIApplication.shared.registerForRemoteNotifications()
        let vc = Info1()
        self.navigationController?.setViewControllers([vc], animated: true)
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
