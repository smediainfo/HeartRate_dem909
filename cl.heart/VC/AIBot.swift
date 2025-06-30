
import UIKit
import CryptoKit
import RealmSwift
import IMProgressHUD

class AIBot: UIViewController {

    @IBOutlet weak var stackViewWithMessages: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textDield: PaddedTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWithMessage: UIScrollView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    
    //hideWithChat
    @IBOutlet weak var yourRobotL: UILabel!
    @IBOutlet weak var robot: UIImageView!
    @IBOutlet weak var descL: UILabel!
    
    
    @IBOutlet weak var t2: NSLayoutConstraint!
    @IBOutlet weak var t1: NSLayoutConstraint!
    @IBOutlet weak var ai2: UIImageView!
    @IBOutlet weak var ai1: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var titleL: UILabel!
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var answerView: UIView!
    var isCheckAge = false
    var pulse: Pulse? = nil
    var question: String = ""
    
    @IBOutlet weak var w: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        titleL.font = Font.semibold(size: 18)
        yourRobotL.font = Font.bold(size: 24)
        descL.font = Font.semibold(size: 14)
        questionLabel.font = Font.medium(size: 16)
        answerLabel.font = Font.medium(size: 16)
        
        w.constant = UIScreen.main.bounds.width
        
        scrollViewWithMessage.isHidden = true
        for v in stackViewWithMessages.arrangedSubviews {
            for v2 in v.subviews {
                v2.clipsToBounds = true
                v2.layer.cornerRadius = 16
            }
        }
        
        if UIScreen.main.bounds.height < 670 {
            t1.constant = -20
            t2.constant = -20
            robot.transform = CGAffineTransform.init(scaleX: 0.6, y: 0.6)
        }
        
        textDield.font = Font.medium(size: 16)
        textDield.textColor = UIColor(named: "textPrimary")
        textDield.attributedPlaceholder = NSAttributedString(string: "What can I do to help?", attributes: [.font: Font.medium(size: 16), .foregroundColor: UIColor(named: "textSecondary")])
        
        textDield.clipsToBounds = true
        textDield.layer.cornerRadius = 12
        textDield.layer.borderWidth = 1
        textDield.layer.borderColor = UIColor(named: "border")?.cgColor
        textDield.delegate = self
        
        
        ai1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickAI1)))
        ai2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickAI2)))
        
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tapGesture.cancelsTouchesInView = false
//        view.addGestureRecognizer(tapGesture)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !question.isEmpty {
            self.robot.isHidden = true
            self.yourRobotL.isHidden = true
            self.descL.isHidden = true
            self.scrollView.isHidden = true
            self.sendButton.isHidden = true
            self.textDield.isHidden = true
            self.scrollViewWithMessage.isHidden = false
            IMProgressHUD.showIndicator(.circle)
            self.questionLabel.text = self.question
            self.answerView.isHidden = true
            sendHeartRequest(prompt: self.question) { text in
                IMProgressHUD.hide()
                if text.isEmpty {
                    let alert = UIAlertController(title: "Error", message: "Something went wrong, please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        let vc = AIBot()
                        self.navigationController?.setViewControllers([vc], animated: false)
                    })
                    self.present(alert, animated: true)
                } else {
                    self.answerView.isHidden = false
                    self.answerLabel.text = "\(text)\n\nThe information is advisory in nature. For any medical advice, it is recommended to consult specialists."
                }
            }
        }
        
        if let pulse = pulse {
            self.robot.isHidden = true
            self.yourRobotL.isHidden = true
            self.descL.isHidden = true
            self.scrollView.isHidden = true
            self.sendButton.isHidden = true
            self.textDield.isHidden = true
            self.scrollViewWithMessage.isHidden = false
            self.questionLabel.text = self.question
            self.answerView.isHidden = true
            
            if Account.m().age.isEmpty {
                self.sendButton.isHidden = false
                self.textDield.isHidden = false
                self.textDield.keyboardType = .numberPad
                self.questionView.isHidden = true
                self.answerView.isHidden = false
                self.answerLabel.text = "Please enter your age so we can better assess your BPM."
                textDield.attributedPlaceholder = NSAttributedString(string: "Enter your age:", attributes: [.font: Font.medium(size: 16), .foregroundColor: UIColor(named: "textSecondary")])
                textDield.becomeFirstResponder()
            } else {
                self.questionView.isHidden = true
                self.answerView.isHidden = true
             
                if pulse.ai.isEmpty {
                    let q = "Evaluate the resting heart rate of a user based on the following data:Age: \(Account.m().age), BPM: \(pulse.BPM). Provide health assessment and whether this BPM is considered low, normal, or high for their age."
                    IMProgressHUD.showIndicator(.circle)
                    sendHeartRequest(prompt: q) { text in
                        IMProgressHUD.hide()
                        if text.isEmpty {
                            let alert = UIAlertController(title: "Error", message: "Something went wrong, please try again", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                let vc = AIBot()
                                self.navigationController?.setViewControllers([vc], animated: false)
                            })
                            self.present(alert, animated: true)
                        } else {
                            self.answerView.isHidden = false
                            self.answerLabel.text = "\(text)\n\nThe information is advisory in nature. For any medical advice, it is recommended to consult specialists."
                            let realm = try! Realm()
                            try! realm.write {
                                self.pulse?.ai = "\(text)\n\nThe information is advisory in nature. For any medical advice, it is recommended to consult specialists."
                            }
                        }
                    }
                } else {
                    self.answerView.isHidden = false
                    self.answerLabel.text = pulse.ai
                }
            }
        }
        
    }
    
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        self.robot.isHidden = true
        self.yourRobotL.isHidden = true
        self.descL.isHidden = true
        self.scrollView.isHidden = true
         if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

             let keyboardHeight = keyboardFrame.height
             UIView.animate(withDuration: duration) {
                 self.bottomConstraint.constant = keyboardHeight - 60
                 self.view.layoutIfNeeded()
             }
         }
     }

     @objc private func keyboardWillHide(_ notification: Notification) {
         
//         self.robot.isHidden = false
//         self.yourRobotL.isHidden = false
//         self.descL.isHidden = false
//         self.scrollView.isHidden = false
//         
         if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
             UIView.animate(withDuration: duration) {
                 self.bottomConstraint.constant = 16
                 self.view.layoutIfNeeded()
             }
         }
     }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    @objc func clickAI1() {
        textDield.endEditing(true)
        if !Account.m().isPro {
            let vc = Pay()
            vc.isStar = false
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        } else {
            let vc = AIBot()
            vc.question = "How do you lower persistently high blood pressure?"
            self.navigationController?.setViewControllers([vc], animated: false)
        }
    }
    @objc func clickAI2() {
        textDield.endEditing(true)
        if !Account.m().isPro {
            let vc = Pay()
            vc.isStar = false
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        } else {
            let vc = AIBot()
            vc.question = "Analyzing my performance for the year with nutritional tips"
            self.navigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    @IBAction func clickAIBot(_ sender: Any) {
        let vc = AIBot()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickMonitor(_ sender: Any) {
        let vc = Monitoring()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickIndicator(_ sender: Any) {
        let vc = Indicator()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickProfile(_ sender: Any) {
        let vc = Profile1()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
    @IBAction func clickSend(_ sender: Any) {
        
        if !question.isEmpty {
            
            textDield.endEditing(true)
            if !Account.m().isPro {
                let vc = Pay()
                vc.isStar = false
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }  else {
                
                if let pulse = pulse {
                    if Account.m().age.isEmpty {
                        let realm = try! Realm()
                        try! realm.write {
                            Account.m().age = self.question
                        }
                        let vc = AIBot()
                        vc.pulse = self.pulse
                        self.navigationController?.setViewControllers([vc], animated: false)
                    }
                } else {
                    send()
                }
            }
        }
    }
    
    
    func send() {
        textDield.endEditing(true)
        if !Account.m().isPro {
            let vc = Pay()
            vc.isStar = false
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        } else {
            let vc = AIBot()
            vc.question = self.question
            self.navigationController?.setViewControllers([vc], animated: false)
        }
    }
}

extension AIBot: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        if !question.isEmpty {
            send()
        }
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        self.question = updatedText

        return true
    }

    
}



func generateSig(model: String, prompt: String, exid: String, salt: String) -> String {
    let baseString = "\(model)|\(prompt)|\(exid)|\(salt)"
    let hash = SHA256.hash(data: Data(baseString.utf8))

    let sig = hash.prefix(16).map { String(format: "%02x", $0) }.joined()
    return sig.lowercased()
}
func sendHeartRequest(prompt: String, completion: @escaping ((_ text: String)->())) {
    let model = "heartrate"
    let salt = "d0f7E!pR#3x@Z9qL^M$uBnC8&"
    
    var exid = UserDefaults.standard.string(forKey: "exid") ?? ""
    if exid.isEmpty {
        let id = UUID().uuidString
        exid = id
        UserDefaults.standard.set(id, forKey: "exid")
    }
    
    
    let sig = generateSig(
        model: model,
        prompt: prompt,
        exid: exid,
        salt: salt
    )
    let body: [String: Any] = [
        "model": model,
        "prompt": prompt,
        "exid": exid,
        "sig": sig
    ]
    
    guard let url = URL(string: "http://chat.heartpulse.app/api/v1/chat/request"),
          let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
        print("❌ Invalid URL or body")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = httpBody

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            
            DispatchQueue.main.async {
                completion("")
                print("❌ Error: \(error)")
            }
            return
        }

        if let data = data {
            do {
                let response = try JSONDecoder().decode(HeartResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.text)
                    print("✅ Ответ: \(response.text)")
                }
            } catch {
                DispatchQueue.main.async {
                    completion("")
                    print("❌ Ошибка парсинга: \(error)")
                }
            }
        }
    }

    task.resume()
}
struct HeartResponse: Decodable {
    let text: String
}
