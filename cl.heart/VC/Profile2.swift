
import UIKit
import RealmSwift
import IMProgressHUD

import SwiftyStoreKit

class Profile2: UIViewController, PayDelegate {
    func closeScreen() {
        upd()
    }
    

    @IBOutlet weak var youHaveSub: UILabel!
    @IBOutlet weak var unitSegment: UISegmentedControl!
    @IBOutlet weak var mfSegment: UISegmentedControl!
    @IBOutlet weak var unitL: UILabel!
    @IBOutlet weak var yourSexL: UILabel!
    @IBOutlet weak var ageTextField: PaddedTextField!
    @IBOutlet weak var ageL: UILabel!
    @IBOutlet weak var nameTextField: PaddedTextField!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var sv2: UIStackView!
    @IBOutlet weak var profileSettings: UILabel!
    @IBOutlet weak var restoreL: UILabel!
    @IBOutlet weak var freeL: UILabel!
    @IBOutlet weak var sv1: UIStackView!
    @IBOutlet weak var subL: UILabel!
    
    @IBOutlet weak var titleL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleL.font = Font.semibold(size: 18)
        subL.font = Font.semibold(size: 14)
        freeL.font = Font.semibold(size: 14)
        restoreL.font = Font.semibold(size: 14)
        profileSettings.font = Font.semibold(size: 14)
        nameL.font = Font.semibold(size: 14)
        ageL.font = Font.semibold(size: 14)
        yourSexL.font = Font.semibold(size: 14)
        unitL.font = Font.semibold(size: 14)
        youHaveSub.font = Font.semibold(size: 14)
        youHaveSub.adjustsFontSizeToFitWidth = true
        
        for v in sv1.arrangedSubviews {
            v.clipsToBounds = true
            v.layer.cornerRadius = 12
            v.layer.borderWidth = 1
            v.layer.borderColor = UIColor(named: "border")?.cgColor
        }
        
        nameTextField.clipsToBounds = true
        nameTextField.layer.cornerRadius = 8
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor(named: "border")?.cgColor
        nameTextField.font = Font.medium(size: 16)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Your Name", attributes: [.font: Font.medium(size: 16), .foregroundColor: UIColor(named: "TextCaption")])
        nameTextField.delegate = self
        nameTextField.text = Account.m().name
        
        
        ageTextField.clipsToBounds = true
        ageTextField.layer.cornerRadius = 8
        ageTextField.layer.borderWidth = 1
        ageTextField.layer.borderColor = UIColor(named: "border")?.cgColor
        ageTextField.font = Font.medium(size: 16)
        ageTextField.attributedPlaceholder = NSAttributedString(string: "Your Age", attributes: [.font: Font.medium(size: 16), .foregroundColor: UIColor(named: "TextCaption")])
        ageTextField.delegate = self
        ageTextField.text = Account.m().age
        
        
        mfSegment.selectedSegmentIndex = Account.m().isMale ? 0 : 1
        unitSegment.selectedSegmentIndex = Account.m().isKG ? 0 : 1
        
        upd()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        upd()
        
    }
    
    @IBOutlet weak var restoreView: UIView!
    @IBOutlet weak var subRight: UIImageView!
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func upd() {
        restoreView.isHidden = Account.m().isPro
        subL.isHidden = Account.m().isPro
        subRight.isHidden = Account.m().isPro
        freeL.isHidden = Account.m().isPro
        youHaveSub.isHidden = !Account.m().isPro
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        upd()
        
    }
    
    @IBAction func clickSub(_ sender: Any) {
        if !Account.m().isPro {
            let vc = Pay()
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    @IBAction func clickRestore(_ sender: Any) {
        IMProgressHUD.show()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: autosubscribeKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: {result in
            IMProgressHUD.hide()
            switch result {
            case .success(let receipt):
                var currentId: String = ""
                let pendingRenewalInfo = receipt["pending_renewal_info"] as? [ReceiptInfo]
                if let prodctId = pendingRenewalInfo?[0]["product_id"] as? String {
                    currentId = prodctId
                }
                if currentId.count == 0 {
                    let ac = UIAlertController(title: nil, message: "Nothing to restore", preferredStyle: .alert)
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
                case .expired(_, _):
                    let realm = try! Realm()
                    try! realm.write {
                        Account.m().isPro = false
                    }
                    let ac = UIAlertController(title: nil, message: "Nothing to restore", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                    
                case .notPurchased:
                    let realm = try! Realm()
                    try! realm.write {
                        Account.m().isPro = false
                    }
                    let ac = UIAlertController(title: nil, message: "Nothing to restore", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                    
                }
            case .error:
                let realm = try! Realm()
                try! realm.write {
                    Account.m().isPro = false
                }
                let ac = UIAlertController(title: nil, message: "Nothing to restore", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
                return
            }
            self.upd()
        })
    }
    
    @IBAction func changeSex(_ sender: Any) {
        let realm = try! Realm()
        try! realm.write {
            Account.m().isMale = self.mfSegment.selectedSegmentIndex == 0
        }
    }
    @IBAction func changeUnit(_ sender: Any) {
        let realm = try! Realm()
        try! realm.write {
            Account.m().isKG = self.unitSegment.selectedSegmentIndex == 0
        }
    }
    @IBAction func clickMonitor(_ sender: Any) {
        let vc = Monitoring()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickAI(_ sender: Any) {
        let vc = AIBot()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickIndicators(_ sender: Any) {
        let vc = Indicator()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
}

extension Profile2: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        
        if textField == self.nameTextField {
            let realm = try! Realm()
            try! realm.write {
                Account.m().name = updatedText
            }
        } else if textField == self.ageTextField {
            let realm = try! Realm()
            try! realm.write {
                Account.m().age = updatedText
            }
        }
        
        return true
    }
    
}
class PaddedTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
