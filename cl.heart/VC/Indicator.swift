

import UIKit
import RealmSwift
import Adapty
import AdaptyUI

class Indicator: UIViewController, AdaptyPaywallControllerDelegate {
    
    
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

    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleL: UILabel!
    var pulses: [Pulse] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.log(name: "records_opened")
        titleL.font = Font.semibold(size: 18)
        
        let realm = try! Realm()
        self.pulses = Array(realm.objects(Pulse.self).sorted { $0.date_created > $1.date_created })
        
        
        tableView.contentInset.top = 8
        tableView.contentInset.bottom = 50
        
        tableView.register(UINib(nibName: "IndicatorCell", bundle: nil), forCellReuseIdentifier: "IndicatorCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Logger.log(name: "records_closed")
    }


    @IBAction func clickProfile(_ sender: Any) {
        let vc = Profile1()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickBot(_ sender: Any) {
        let vc = AIBot()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
    @IBAction func clickMonitor(_ sender: Any) {
        let vc = Monitoring()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
}

extension Indicator: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pulses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IndicatorCell", for: indexPath) as! IndicatorCell
        
        let p = self.pulses[indexPath.row]
        cell.didClickAnalize = {
            if !Account.m().isPro {
                self.presentMainPaywall()
            } else {
                let vc = AIBot()
                vc.pulse = p
                self.navigationController?.setViewControllers([vc], animated: false)
            }
        }
        
        
        cell.settingCell(bpm: p, isHistory: true)
        
        return cell
    }
    
}
