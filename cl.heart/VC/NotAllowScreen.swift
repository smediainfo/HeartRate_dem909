

import UIKit

class NotAllowScreen: UIViewController {

    @IBOutlet weak var openSettingButton: UIButton!
    @IBOutlet weak var tl: UILabel!
    @IBOutlet weak var titleL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        titleL.font = Font.semibold(size: 18)
        tl.font = Font.semibold(size: 18)
        
        openSettingButton.clipsToBounds = true
        openSettingButton.layer.cornerRadius = 8
        openSettingButton.titleLabel?.font = Font.semibold(size: 14)
        
    }


    @IBAction func clickOpenSetting(_ sender: Any) {
        Logger.log(name: "measuring_link_opened")
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    @IBAction func clickClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}


