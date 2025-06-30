
import UIKit

class HeartRateError: UIViewController {

    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        previewButton.clipsToBounds = true
        previewButton.layer.cornerRadius = 8
        previewButton.titleLabel?.font = Font.semibold(size: 14)
        titleL.font = Font.semibold(size: 18)
        errorLabel.font = Font.bold(size: 24)
    }

    @IBAction func clickTry(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBAction func clickClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

