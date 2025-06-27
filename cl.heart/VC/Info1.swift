
import UIKit

class Info1: UIViewController {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var textL: UILabel!
    @IBOutlet weak var tl: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        saveButton.clipsToBounds = true
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = Font.semibold(size: 14)
        
        
        tl.font = Font.bold(size: 22)
        titleL.font = Font.medium(size: 16)
        textL.font = Font.regular(size: 16)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func clickNext(_ sender: Any) {
        let vc = PayOnb()
        self.navigationController?.setViewControllers([vc], animated: true)
    }
}


