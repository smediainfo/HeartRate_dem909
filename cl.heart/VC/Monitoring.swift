

import UIKit
import AVFoundation
import RealmSwift
import Adapty
import AdaptyUI


protocol MonitoringDelegate: class {
    func analizePulse(pulse: Pulse)
}

class Monitoring: UIViewController, MonitoringDelegate, AdaptyPaywallControllerDelegate {
    
    
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

    
    func analizePulse(pulse: Pulse) {
        if !Account.m().isPro {
            self.presentMainPaywall()
        } else {
            let vc = AIBot()
            vc.pulse = pulse
            self.navigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var titleL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        Logger.log(name: "home_opened")
        
        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickStart)))
        titleL.font = Font.semibold(size: 18)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Logger.log(name: "home_closed")
    }
    
    @objc func clickStart() {
        
        Logger.log(name: "home_pulse_tapped")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        if UserDefaults.standard.integer(forKey: dateString) == 0 || Account.m().isPro {
            UserDefaults.standard.set(1, forKey: dateString)
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                let vc = HeartRate()
                vc.delegate = self
                let navVC = UINavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                navVC.setNavigationBarHidden(true, animated: false)
                self.present(navVC, animated: true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        Logger.log(name: "Camera access granted", params: ["permission":granted ? "true" : "false"])
                        if granted {
                            
                            let vc = HeartRate()
                            vc.delegate = self
                            let navVC = UINavigationController(rootViewController: vc)
                            navVC.modalPresentationStyle = .fullScreen
                            navVC.setNavigationBarHidden(true, animated: false)
                            self.present(navVC, animated: true)
                        } else {
                            let vc = NotAllowScreen()
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                        }
                    }
                }
                
            case .denied, .restricted:
                
                let vc = NotAllowScreen()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
                
            @unknown default:
                let vc = NotAllowScreen()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        } else {
            self.presentMainPaywall()
        }
    }

    @IBAction func clickBot(_ sender: Any) {
        let vc = AIBot()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
    @IBAction func clickIndicators(_ sender: Any) {
        let vc = Indicator()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
    @IBAction func clickProfile(_ sender: Any) {
        let vc = Profile1()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
}
