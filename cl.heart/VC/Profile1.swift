import UIKit
import HealthKit
import RealmSwift


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
    
    let healthStore = HKHealthStore()
    private var isSyncing = false
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
        
        
        Logger.log(name: "profile_opened")
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
        guard !isSyncing else { return }
        isSyncing = true
        Logger.log(name: "profile_sync_health_tapped")

        // 1) Запросить доступ и загрузить все HR за последний месяц
        syncHeartRateLastMonth { [weak self] in
            DispatchQueue.main.async {
                self?.isSyncing = false
                Logger.log(name: "profile_sync_health_finished")
            }
        }
    }
    @IBAction func clickRate(_ sender: Any) {
        Logger.log(name: "profile_rate_us_tapped")
        UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appleId)")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func clickTerms(_ sender: Any) {
        Logger.log(name: "profile_terms_of_service_tapped")
        UIApplication.shared.open(URL(string: "https://drive.google.com/file/d/1vGGK40wnHJBeyck-6Qw1TTwCcbU10WkF/view")!, options: [:], completionHandler: nil)
    }
    @IBAction func clickPrivate(_ sender: Any) {
        Logger.log(name: "profile_privacy_policy_tapped")
        UIApplication.shared.open(URL(string: "https://drive.google.com/file/d/1vU_A7_nA0ISzHNaqVWBEF0purEbzI3Ve/view")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func clickShare(_ sender: Any) {
        Logger.log(name: "profile_share_tapped")
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
        Logger.log(name: "profile_closed")
        let vc = AIBot()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickMonitoring(_ sender: Any) {
        Logger.log(name: "profile_closed")
        let vc = Monitoring()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickIndicators(_ sender: Any) {
        Logger.log(name: "profile_closed")
        let vc = Indicator()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
    /// Показывает алерт с предложением открыть настройки, если нет доступа к Health
    private func showHealthPermissionsAlert() {
        let ac = UIAlertController(
            title: "Enable Health Access",
            message: "To sync your heart rate, allow read access for Heart Rate in the Health app (Settings → Privacy & Security → Health → HeartSense).",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        self.present(ac, animated: true, completion: nil)
    }
    
    /// Загружает все heart rate сэмплы за последний месяц, группирует в сессии и сохраняет в Realm без дублей
    private func syncHeartRateLastMonth(completion: (() -> Void)? = nil) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit недоступен на этом устройстве")
            DispatchQueue.main.async { [weak self] in
                self?.showHealthPermissionsAlert()
            }
            completion?()
            return
        }

        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion?(); return
        }

        // Запрашиваем разрешение только на чтение
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { [weak self] success, error in
            guard success, error == nil else {
                print("❌ Доступ к HealthKit не разрешён: \(error?.localizedDescription ?? "Неизвестно")")
                DispatchQueue.main.async { [weak self] in
                    self?.showHealthPermissionsAlert()
                }
                completion?()
                return
            }

            let now = Date()
            guard let startDate = Calendar.current.date(byAdding: .month, value: -1, to: now) else {
                completion?(); return
            }

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

            let query = HKSampleQuery(sampleType: heartRateType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [sort]) { [weak self] (_, samples, error) in
                guard let self = self else { completion?(); return }
                guard error == nil, let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                    if let error = error { print("❌ Ошибка получения пульса: \(error.localizedDescription)") }
                    completion?()
                    return
                }

                // Группируем сэмплы в измерения (сессии) по разрыву во времени
                let sessions = self.groupIntoSessions(samples: samples, gap: 30, minCount: 3)
                self.saveSessionsToRealm(sessions)
                completion?()
            }
            self?.healthStore.execute(query)
        }
    }

    /// Группирует последовательные сэмплы в логические "сессии" измерений (разрыв > gap секунд начинает новую сессию)
    private func groupIntoSessions(samples: [HKQuantitySample], gap: TimeInterval = 30, minCount: Int = 3) -> [[HKQuantitySample]] {
        guard !samples.isEmpty else { return [] }
        var sessions: [[HKQuantitySample]] = []
        var current: [HKQuantitySample] = []

        for s in samples {
            if let last = current.last {
                let dt = s.startDate.timeIntervalSince(last.startDate)
                if dt <= gap {
                    current.append(s)
                } else {
                    if current.count >= minCount { sessions.append(current) }
                    current = [s]
                }
            } else {
                current = [s]
            }
        }
        if current.count >= minCount { sessions.append(current) }
        return sessions
    }

    /// Сохраняет сессии в Realm как Pulse (без дублей по дате начала сессии)
    private func saveSessionsToRealm(_ sessions: [[HKQuantitySample]]) {
        let unit = HKUnit(from: "count/min")
        do {
            let realm = try Realm()
            try realm.write {
                for session in sessions {
                    guard let first = session.first else { continue }
                    let startDate = first.startDate

                    // Дедупликация: если уже есть запись с такой же датой создания — пропускаем
                    if realm.objects(Pulse.self).filter("date_created == %@", startDate).first != nil {
                        continue
                    }

                    let p = Pulse()
                    p.id = UUID().uuidString
                    p.date_created = startDate

                    for s in session {
                        let bpm = s.quantity.doubleValue(for: unit)
                        p.BPMLit.append(bpm)
                    }

                    realm.add(p)
                }
            }
        } catch {
            print("❌ Ошибка записи в базу: \(error.localizedDescription)")
        }
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
