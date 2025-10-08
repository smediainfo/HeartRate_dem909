
import UIKit
import RealmSwift
import Adapty
import AdaptyUI

class Result: UIViewController, PayDelegate, AdaptyPaywallControllerDelegate {
    
    
    private func presentMainPaywall() {
        Task { @MainActor in
            do {
                let paywall = try await Adapty.getPaywall(placementId: "main")
                guard paywall.hasViewConfiguration else {
                    // Этот плейсмент не относится к Paywall Builder
                    return
                }
                let config = try await AdaptyUI.getPaywallConfiguration(forPaywall: paywall)
                let controller = try AdaptyUI.paywallController(with: config, delegate: self)
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true)
            } catch {
                print("Adapty main paywall error: \(error)")
            }
        }
    }
    
    // MARK: - AdaptyPaywallControllerDelegate
    func paywallController(_ controller: AdaptyPaywallController, didPerform action: AdaptyUI.Action) {
        switch action {
        case .close:
            controller.dismiss(animated: true)
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
        controller.dismiss(animated: true)
    }

    func paywallController(_ controller: AdaptyPaywallController, didFailPurchase product: AdaptyPaywallProduct, error: AdaptyError) {
        print("Adapty main purchase failed: \(error)")
    }

    func paywallController(_ controller: AdaptyPaywallController, didFinishRestoreWith profile: AdaptyProfile) {
        let active = profile.accessLevels["premium"]?.isActive ?? false
        do {
            let realm = try Realm()
            if let acc = realm.object(ofType: Account.self, forPrimaryKey: "main") {
                try realm.write { acc.isPro = active }
            }
        } catch {}
        controller.dismiss(animated: true)
    }

    func paywallController(_ controller: AdaptyPaywallController, didFailRestoreWith error: AdaptyError) {
        print("Adapty main restore failed: \(error)")
    }

    func paywallController(_ controller: AdaptyPaywallController, didFailRendering error: AdaptyError) {
        print("Adapty main rendering failed: \(error)")
    }

    
    func closeScreen() {
        tableView.reloadData()
    }
    
    weak var delegate: MonitoringDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleL: UILabel!
    
    var pulse: Pulse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleL.font = Font.semibold(size: 18)
        
        
        Logger.log(name: "insights_opened")
        
        tableView.contentInset.top = 8
        tableView.contentInset.bottom = 50
        
        tableView.register(UINib(nibName: "IndicatorCell", bundle: nil), forCellReuseIdentifier: "IndicatorCell")
        tableView.register(UINib(nibName: "HRVCell", bundle: nil), forCellReuseIdentifier: "HRVCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    

    @IBAction func clickClose(_ sender: Any) {
        Logger.log(name: "insights_closed")
        self.dismiss(animated: true)
    }
}

extension Result: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IndicatorCell", for: indexPath) as! IndicatorCell
            
            cell.didClickSave = {
                Logger.log(name: "measuring_record_saved")
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(self.pulse)
                    }
                    self.dismiss(animated: true)
                }
            }
            cell.didClickAnalize = {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(self.pulse)
                }
                self.dismiss(animated: true) {
                    self.delegate?.analizePulse(pulse: self.pulse)
                }
            }
            
            cell.settingCell(bpm: self.pulse, isHistory: false)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HRVCell", for: indexPath) as! HRVCell
            
            
            cell.settingHRV(bpm: self.pulse.BPM)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if !Account.m().isPro {
                self.presentMainPaywall()
            }
        }
    }
    
}
