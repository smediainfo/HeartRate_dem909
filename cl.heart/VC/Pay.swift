
import UIKit
import RealmSwift
import SwiftyStoreKit
import IMProgressHUD
import StoreKit


protocol PayDelegate: class {
    func closeScreen()
}

class Pay: UIViewController {


    weak var delegate: PayDelegate?
    @IBOutlet weak var moneyL: UILabel!
    @IBOutlet weak var WeeklyAccess: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var autoLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    var id = "com.heartrate.week"
    var isStar = false
    override func viewDidLoad() {
        super.viewDidLoad()

        Logger.log(name: "In App Paywall Opened")
        
        id = mainID
        
        privateButton.titleLabel?.font = Font.regular(size: 10)
        restoreButton.titleLabel?.font = Font.regular(size: 10)
        WeeklyAccess.font = Font.regular(size: 12)
        termsButton.titleLabel?.font = Font.regular(size: 10)
        buyButton.titleLabel?.font = Font.semibold(size: 14)
        buyButton.clipsToBounds = true
        buyButton.layer.cornerRadius = 8
        autoLabel.font = Font.regular(size: 10)
        autoLabel.text = "Auto-renewing weekly subscription for \(subsListMoney[self.id] ?? "-") until cancelled"
        
        if (subsListInfo[id]?.subscriptionPeriod?.numberOfUnits ?? 0) > 0 {
            let fullText = "3 Days Free, then \(subsListMoney[self.id] ?? "-")/week"
            let attributed = NSMutableAttributedString(string: fullText)

            // Атрибуты для "3 Days Free"
            let boldBlueAttrs: [NSAttributedString.Key: Any] = [
                .font: Font.medium(size: 13),
                .foregroundColor: #colorLiteral(red: 0.2431372549, green: 0.4274509804, blue: 0.9450980392, alpha: 1)
            ]

            // Атрибуты для "then 11.99 USD/week"
            let normalGrayAttrs: [NSAttributedString.Key: Any] = [
                .font: Font.medium(size: 13),
                .foregroundColor: #colorLiteral(red: 0.04705882353, green: 0.04705882353, blue: 0.04705882353, alpha: 1)
            ]

            // Заменяем нужные диапазоны
            if let range1 = fullText.range(of: "3 Days Free") {
                let nsRange1 = NSRange(range1, in: fullText)
                attributed.setAttributes(boldBlueAttrs, range: nsRange1)
            }

            if let range2 = fullText.range(of: "then \(subsListMoney[self.id] ?? "-")/week") {
                let nsRange2 = NSRange(range2, in: fullText)
                attributed.setAttributes(normalGrayAttrs, range: nsRange2)
            }
            moneyL.attributedText = attributed
        } else {
            let fullText = "\(subsListMoney[self.id] ?? "-")/week"
            let attributed = NSMutableAttributedString(string: fullText)


            // Атрибуты для "then 11.99 USD/week"
            let normalGrayAttrs: [NSAttributedString.Key: Any] = [
                .font: Font.medium(size: 13),
                .foregroundColor: #colorLiteral(red: 0.04705882353, green: 0.04705882353, blue: 0.04705882353, alpha: 1)
            ]

            
            if let range2 = fullText.range(of: "\(subsListMoney[self.id] ?? "-")/week") {
                let nsRange2 = NSRange(range2, in: fullText)
                attributed.setAttributes(normalGrayAttrs, range: nsRange2)
            }
            moneyL.attributedText = attributed
        }
        
        
        
        infoView.clipsToBounds = true
        infoView.layer.cornerRadius = 10
        infoView.layer.borderWidth = 3
        infoView.layer.borderColor = #colorLiteral(red: 0.2431372549, green: 0.4274509804, blue: 0.9450980392, alpha: 1).cgColor
        
    }


    
    private func classifyPurchaseError(_ error: Error) -> (kind: String, ns: NSError) {
        let ns = error as NSError
        if ns.domain == SKErrorDomain, let sk = SKError.Code(rawValue: ns.code) {
            switch sk {
            case .paymentCancelled:
                return ("cancelled", ns)
            case .paymentInvalid, .paymentNotAllowed:
                // Treat as declined/insufficient funds or payment not permitted
                return ("declined", ns)
            default:
                break
            }
        }
        return ("error", ns)
    }

    private func presentRetryAlert(message: String) {
        Logger.log(name: "pop_up_fail_rebuy_open")
        let ac = UIAlertController(title: "Purchase failed", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            Logger.log(name: "pop_up_fail_rebuy_close")
            ac.dismiss(animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            Logger.log(name: "pop_up_fail_rebuy_retry")
            self?.startPurchase()
        }))
        self.present(ac, animated: true, completion: nil)
    }

    private func startPurchase() {
        Logger.log(name: "purchase_started")
        IMProgressHUD.show()
        Logger.log(name: "purchase_start")
        SwiftyStoreKit.purchaseProduct(self.id, atomically: true) { result in
            DispatchQueue.main.async {
                IMProgressHUD.hide()
                switch result {
                case .success(let purchase):
                    Logger.log(name: "purchase_completed")
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    let realm = try! Realm()
                    try! realm.write {
                        Account.m().isPro = true
                    }
                    Logger.log(name: "purchase_close")
                    self.close()
                case .error(let error):
                    let classification = self.classifyPurchaseError(error)
                    switch classification.kind {
                    case "cancelled":
                        Logger.log(name: "purchase_failed")
                        self.presentRetryAlert(message: "Your payment was declined. Please check your payment method and try again.")
                    case "declined":
                        Logger.log(name: "purchase_failed")
                        self.presentRetryAlert(message: "Your payment was declined. Please check your payment method and try again.")
                    default:
                        Logger.log(name: "purchase_failed")
                        self.presentRetryAlert(message: "Something went wrong. Please try again.")
                    }
                    let realm = try! Realm()
                    try! realm.write {
                        Account.m().isPro = false
                    }
                    Logger.log(name: "purchase_close")
                case .deferred(purchase: _):
                    Logger.log(name: "purchase_close")
                    let ac = UIAlertController(title: "Pending approval", message: "Your purchase is pending approval. We will complete it once it is approved.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
    }
    

    @IBAction func clickBuy(_ sender: Any) {
        startPurchase()
    }
    @IBAction func clickPrivate(_ sender: Any) {
        Logger.log(name: "paywall_privacy_tapped")
        UIApplication.shared.open(URL(string: "https://drive.google.com/file/d/1vU_A7_nA0ISzHNaqVWBEF0purEbzI3Ve/view")!, options: [:], completionHandler: nil)
    }
    @IBAction func clickRestore(_ sender: Any) {
        IMProgressHUD.show()
        Logger.log(name: "restore_started")
        verifyReceipt { result in
            IMProgressHUD.hide()
            switch result {
            case .success(let receipt):
                var currentId: String = ""
                let pendingRenewalInfo = receipt["pending_renewal_info"] as? [ReceiptInfo]
                if let prodctId = pendingRenewalInfo?[0]["product_id"] as? String {
                    currentId = prodctId
                }
                if currentId.count == 0 {
                    let ac = UIAlertController(title: "Sorry", message: "Nothing to restore", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                    return
                }
                let restoreResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable,
                                                                      productId: currentId,
                                                                      inReceipt: receipt,
                                                                      validUntil: Date())
                switch restoreResult {
                case .purchased(_, _):
                    let realm = try! Realm()
                    try! realm.write {
                        Account.m().isPro = true
                    }
                    
                    Logger.log(name: "restore_completed")
                    let ac = UIAlertController(title: nil, message: "Your subscription has been successfully restored", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                            self.close()
                        })
                    }))
                    self.present(ac, animated: true, completion: nil)
                    
                case .expired(_, _):
                    Logger.log(name: "restore_failed")
                    let realm = try! Realm()
                    try! realm.write {
                        Account.m().isPro = false
                    }
                    let ac = UIAlertController(title: "Sorry", message: "Nothing to restore", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                case .notPurchased:
                    Logger.log(name: "restore_failed")
                    let realm = try! Realm()
                    try! realm.write {
                        Account.m().isPro = false
                    }
                    let ac = UIAlertController(title: "Sorry", message: "Nothing to restore", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
            case .error:
                Logger.log(name: "restore_failed")
                let ac = UIAlertController(title: "Sorry", message: "Nothing to restore", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
                return
            }
        }
    }
    @IBAction func clickterms(_ sender: Any) {
        Logger.log(name: "paywall_terms_tapped")
        UIApplication.shared.open(URL(string: "https://drive.google.com/file/d/1vGGK40wnHJBeyck-6Qw1TTwCcbU10WkF/view")!, options: [:], completionHandler: nil)
    }
    @IBAction func clickClose(_ sender: Any) {
        close()
    }
    
    func close() {
        
        Logger.log(name: Account.m().isPro ? "In App Paywall Closed [successfully]" : "In App Paywall Closed [unsuccessfully]")
        
        if isStar {
            let vc = Monitoring()
            self.navigationController?.setViewControllers([vc], animated: true)
        } else {
            self.dismiss(animated: true) {
                self.delegate?.closeScreen()
            }
        }
    }
}
