
import UIKit
import UserNotifications

class NotificationAccess: UIViewController {

    
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
                    let vc = PayOnb()
                    self.navigationController?.setViewControllers([vc], animated: true)
                }
            }
        }
    }
    @IBAction func clickNext(_ sender: Any) {
        UIApplication.shared.registerForRemoteNotifications()
        let vc = Info1()
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    
}
