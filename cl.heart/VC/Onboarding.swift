

import UIKit
import RealmSwift
import ApphudSDK

class Onboarding: UIViewController {

    @IBOutlet weak var tl: UILabel!
    @IBOutlet weak var dl: UILabel!
    @IBOutlet weak var pc: UIPageControl!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    var p: Int = 0 {
        didSet {
            pc.currentPage = p
            UIView.transition(with: self.img, duration: 0.3, options: [.transitionCrossDissolve]) {
                self.img.image = UIImage(named: "onb\(self.p+1)")
            }
            UIView.transition(with: self.dl, duration: 0.3, options: [.transitionCrossDissolve]) {
                self.dl.text = self.dText[self.p]
            }
            UIView.transition(with: self.tl, duration: 0.3, options: [.transitionCrossDissolve]) {
                self.tl.text = self.tText[self.p]
            }
        }
    }
    
    
    let tText = ["Welcome to HeartMonitor!", "Track your progress", "Your AI health assistant"]
    let dText = ["Find out how your heart beats right now and start the journey to better shape.", "Smart graphs will show you the growth of your results day by day.\nEach achievement is closer to a healthy and energized self.", "A personal bot analyzes data 24/7, warns you of risks and tells you when to speed up or rest.\nTrust an algorithm trained on millions of data."]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextButton.clipsToBounds = true
        nextButton.layer.cornerRadius = 8
        nextButton.titleLabel?.font = Font.semibold(size: 14)
        
        dl.font = Font.bold(size: 18)
        tl.font = Font.bold(size: 44)
        
        self.dl.text = self.dText[0]
        self.tl.text = self.tText[0]
        
        
        
    }


    @IBAction func clickNext(_ sender: Any) {
        if p >= 2 {
            let realm = try! Realm()
            try! realm.write {
                Account.m().onb = false
            }
            let vc = NotificationAccess()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            p += 1
        }
    }

}
