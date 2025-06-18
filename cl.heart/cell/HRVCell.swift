
import UIKit

class HRVCell: UITableViewCell {
    @IBOutlet weak var v: UIView!
    @IBOutlet weak var hrvView: UIView!
    @IBOutlet weak var textL: UILabel!
    
    @IBOutlet weak var hrvBlock: UIImageView!
    @IBOutlet weak var blur: UIVisualEffectView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    func settingHRV(bpm: Int) {
        v.clipsToBounds = true
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(named: "border")?.cgColor
        hrvView.clipsToBounds = true
        hrvView.layer.cornerRadius = 8
        
        
        textL.font = Font.regular(size: 15)
        blur.isHidden = Account.m().isPro
        hrvBlock.isHidden = Account.m().isPro
        
        if bpm < 51 {
            textL.text = "Your heart rate is very low, which may indicate deep rest, high-quality recovery, or exceptional cardiovascular fitness. If you’re feeling relaxed and calm, this is a great sign of parasympathetic activity and overall balance in your body."
        } else if bpm < 90 {
            textL.text = "Your heart rate is within the normal resting range. This suggests that your nervous system is in balance and your body is likely operating efficiently. HRV data in this range typically reflects a good balance between stress and recovery processes."
        } else {
            textL.text = "Your heart rate is elevated, which may be caused by physical exertion, emotional stress, or lack of rest. A consistently high heart rate can reduce HRV and signal increased sympathetic activity, suggesting your body may be under pressure or in need of recovery."
        }
        
        let blurEffectStyle: UIBlurEffect.Style = traitCollection.userInterfaceStyle == .dark ? .dark : .light
        blur.effect = UIBlurEffect(style: blurEffectStyle)
        
        
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let blurEffectStyle: UIBlurEffect.Style = traitCollection.userInterfaceStyle == .dark ? .dark : .light
        blur.effect = UIBlurEffect(style: blurEffectStyle)
    }
    
}
