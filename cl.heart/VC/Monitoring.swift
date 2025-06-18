

import UIKit
import AVFoundation


protocol MonitoringDelegate: class {
    func analizePulse(pulse: Pulse)
}

class Monitoring: UIViewController, MonitoringDelegate {

    
    func analizePulse(pulse: Pulse) {
        if !Account.m().isPro {
            let vc = Pay()
            vc.isStar = false
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
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

        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickStart)))
        titleL.font = Font.semibold(size: 18)
    }
    
    
    @objc func clickStart() {
        
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
            let vc = Pay()
            vc.isStar = false
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
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
