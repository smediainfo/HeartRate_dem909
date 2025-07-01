
import UIKit
//import HealthKit


class Profile1: UIViewController {

    @IBOutlet weak var privateLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var syncLabel: UILabel!
    @IBOutlet weak var userProfileLabel: UILabel!
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var rateUsLabel: UILabel!
    @IBOutlet weak var sv2: UIStackView!
    @IBOutlet weak var sv1: UIStackView!
    @IBOutlet weak var titleL: UILabel!
    
//    let healthStore = HKHealthStore()
    override func viewDidLoad() {
        super.viewDidLoad()

        titleL.font = Font.semibold(size: 18)
        rateUsLabel.font = Font.semibold(size: 14)
        settingLabel.font = Font.semibold(size: 14)
        shareLabel.font = Font.semibold(size: 14)
        userProfileLabel.font = Font.semibold(size: 14)
        syncLabel.font = Font.semibold(size: 14)
        privateLabel.font = Font.semibold(size: 14)
        termsLabel.font = Font.semibold(size: 14)
        
        
        for v in sv1.arrangedSubviews {
            v.clipsToBounds = true
            v.layer.cornerRadius = 8
            v.layer.borderWidth = 1
            v.layer.borderColor = UIColor(named: "border")?.cgColor
        }
        for v in sv2.arrangedSubviews {
            v.clipsToBounds = true
            v.layer.cornerRadius = 8
            v.layer.borderWidth = 1
            v.layer.borderColor = UIColor(named: "border")?.cgColor
        }
    }

    @IBAction func clickProfile2(_ sender: Any) {
        let vc = Profile2()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickSync(_ sender: Any) {
//        syncHeartRateFromHealthKit { samples in
//            guard let samples = samples, let last = samples.first else { return }
//
//            let bpm = last.quantity.doubleValue(for: HKUnit(from: "count/min"))
//            print("❤️ Последний пульс: \(bpm) BPM")
//        }
    }
    @IBAction func clickRate(_ sender: Any) {
        UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appleId)")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func clickTerms(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://drive.google.com/file/d/1vGGK40wnHJBeyck-6Qw1TTwCcbU10WkF/view")!, options: [:], completionHandler: nil)
    }
    @IBAction func clickPrivate(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://drive.google.com/file/d/1vU_A7_nA0ISzHNaqVWBEF0purEbzI3Ve/view")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func clickShare(_ sender: Any) {
        let url = "https://apps.apple.com/us/app/heart-rate-pulse-monitor/id6746779084"
        var urlToShare = [Any]()
        urlToShare.append(url)
        let activityViewController = UIActivityViewController(activityItems: urlToShare, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = shareLabel.frame
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickAI(_ sender: Any) {
        let vc = AIBot()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickMonitoring(_ sender: Any) {
        let vc = Monitoring()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickIndicators(_ sender: Any) {
        let vc = Indicator()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
    
//    func syncHeartRateFromHealthKit(completion: @escaping ([HKQuantitySample]?) -> Void) {
//        guard HKHealthStore.isHealthDataAvailable() else {
//            print("❌ HealthKit недоступен на этом устройстве")
//            completion(nil)
//            return
//        }
//
//        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
//
//        // Запрос разрешений
//        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
//            if success {
//                let now = Date()
//                let startDate = Calendar.current.date(byAdding: .day, value: -1, to: now)!
//
//                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictEndDate)
//
//                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//
//                let query = HKSampleQuery(sampleType: heartRateType,
//                                          predicate: predicate,
//                                          limit: 100,
//                                          sortDescriptors: [sortDescriptor]) { (_, samples, error) in
//
//                    guard let samples = samples as? [HKQuantitySample], error == nil else {
//                        print("❌ Ошибка получения пульса: \(error?.localizedDescription ?? "Неизвестно")")
//                        completion(nil)
//                        return
//                    }
//
//                    DispatchQueue.main.async {
//                        completion(samples)
//                    }
//                }
//
//                self.healthStore.execute(query)
//            } else {
//                print("❌ Доступ к HealthKit не разрешён: \(error?.localizedDescription ?? "Неизвестно")")
//                completion(nil)
//            }
//        }
//    }
}
