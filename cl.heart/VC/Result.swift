
import UIKit
import RealmSwift

class Result: UIViewController, PayDelegate {
    func closeScreen() {
        tableView.reloadData()
    }
    
    weak var delegate: MonitoringDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleL: UILabel!
    
    var pulse: Pulse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleL.font = Font.semibold(size: 18)
        
        
        Logger.log(name: "insights_opened")
        
        tableView.contentInset.top = 8
        tableView.contentInset.bottom = 50
        
        tableView.register(UINib(nibName: "IndicatorCell", bundle: nil), forCellReuseIdentifier: "IndicatorCell")
        tableView.register(UINib(nibName: "HRVCell", bundle: nil), forCellReuseIdentifier: "HRVCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    

    @IBAction func clickClose(_ sender: Any) {
        Logger.log(name: "insights_closed")
        self.dismiss(animated: true)
    }
}

extension Result: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IndicatorCell", for: indexPath) as! IndicatorCell
            
            cell.didClickSave = {
                Logger.log(name: "measuring_record_saved")
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(self.pulse)
                    }
                    self.dismiss(animated: true)
                }
            }
            cell.didClickAnalize = {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(self.pulse)
                }
                self.dismiss(animated: true) {
                    self.delegate?.analizePulse(pulse: self.pulse)
                }
            }
            
            cell.settingCell(bpm: self.pulse, isHistory: false)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HRVCell", for: indexPath) as! HRVCell
            
            
            cell.settingHRV(bpm: self.pulse.BPM)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if !Account.m().isPro {
                let vc = Pay()
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
    
}
