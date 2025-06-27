

import UIKit

class Info2: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.font = Font.medium(size: 16)
        textView.isEditable = false
        textView.dataDetectorTypes = [.link]
        textView.backgroundColor = .clear
        
        
        
        let text = """
        How We Measure Your Heart Rate
        Our app uses the photoplethysmography (PPG) technique to estimate your heart rate by analyzing subtle changes in your fingertip’s color using your phone’s camera and flashlight.
        This method is non-invasive, reliable, and commonly used in fitness and wellness applications to monitor cardiovascular activity.

        ⸻

        🔬 Scientific References
        
            •    Allen, J. (2007). Photoplethysmography and its application in clinical physiological measurement. Physiological Measurement, 28(3), R1–R39. https://doi.org/10.1088/0967-3334/28/3/R01
        
            •    Poh, M.-Z., McDuff, D. J., & Picard, R. W. (2010). Non-contact, automated cardiac pulse measurements using video imaging and blind source separation. Optics Express, 18(10), 10762–10774. https://doi.org/10.1364/OE.18.010762
        
            •    Maeda, Y., Sekine, M., & Tamura, T. (2011). The advantages of wearable green reflected photoplethysmography. Journal of Medical Systems, 35, 829–834. https://doi.org/10.1007/s10916-010-9506-z
        """
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [.font: Font.regular(size: 14), .foregroundColor: UIColor(named: "textPrimary")!])
        let links = [
            "https://doi.org/10.1088/0967-3334/28/3/R01",
            "https://doi.org/10.1364/OE.18.010762",
            "https://doi.org/10.1007/s10916-010-9506-z"
        ]
        let bolds = [
            "How We Measure Your Heart Rate",
            "Scientific References"
        ]
        for link in links {
            let nsRange = (text as NSString).range(of: link)
            if nsRange.location != NSNotFound {
                attributedString.addAttribute(.link, value: link, range: nsRange)
            }
        }
        for bold in bolds {
            let nsRange = (text as NSString).range(of: bold)
            if nsRange.location != NSNotFound {
                attributedString.addAttributes([.font: Font.bold(size: 15)], range: nsRange)
            }
        }
        
        textView.attributedText = attributedString
    }


    
    @IBAction func clickClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
