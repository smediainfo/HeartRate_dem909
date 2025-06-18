

import UIKit
import RealmSwift

class Indicator: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleL: UILabel!
    var pulses: [Pulse] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        titleL.font = Font.semibold(size: 18)
        
        let realm = try! Realm()
        self.pulses = Array(realm.objects(Pulse.self).sorted { $0.date_created > $1.date_created })
        
        
        tableView.contentInset.top = 8
        tableView.contentInset.bottom = 50
        
        tableView.register(UINib(nibName: "IndicatorCell", bundle: nil), forCellReuseIdentifier: "IndicatorCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }


    @IBAction func clickProfile(_ sender: Any) {
        let vc = Profile1()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    @IBAction func clickBot(_ sender: Any) {
        let vc = AIBot()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
    @IBAction func clickMonitor(_ sender: Any) {
        let vc = Monitoring()
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
}

extension Indicator: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pulses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IndicatorCell", for: indexPath) as! IndicatorCell
        
        let p = self.pulses[indexPath.row]
        cell.didClickAnalize = {
            if !Account.m().isPro {
                let vc = Pay()
                vc.isStar = false
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            } else {
                let vc = AIBot()
                vc.pulse = p
                self.navigationController?.setViewControllers([vc], animated: false)
            }
        }
        
        
        cell.settingCell(bpm: p, isHistory: true)
        
        return cell
    }
    
}
