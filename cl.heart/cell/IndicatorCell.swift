

import UIKit
import DGCharts


class IndicatorCell: UITableViewCell {
    @IBOutlet weak var GeneralindicatorsLabel: UILabel!
    @IBOutlet weak var healthV: UIView!
    @IBOutlet weak var RateofcontractionL: UILabel!
    @IBOutlet weak var RateofcontractionV: UIView!
    @IBOutlet weak var textL: UILabel!
    @IBOutlet weak var aiAnalizeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var healthValue: UILabel!
    @IBOutlet weak var healthPercentL: UILabel!
    @IBOutlet weak var healthL: UILabel!
    @IBOutlet weak var stressValue: UILabel!
    @IBOutlet weak var EnergyValue: UILabel!
    @IBOutlet weak var EnergyV: UIView!
    @IBOutlet weak var EnergyPercentL: UILabel!
    @IBOutlet weak var EnergyL: UILabel!
    @IBOutlet weak var stressV: UIView!
    @IBOutlet weak var stressPercentL: UILabel!
    @IBOutlet weak var StressL: UILabel!
    @IBOutlet weak var GeneralindicatorsView: UIView!
    @IBOutlet weak var dateV: UIView!
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var infoV: UIView!
    @IBOutlet weak var RateofcontractionValueV: UIView!
    
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var BPML: UILabel!
    @IBOutlet weak var AVG_BPM_L: UILabel!
    @IBOutlet weak var v: UIView!
    @IBOutlet weak var RateofcontractionValue: UILabel!
    @IBOutlet weak var AVGL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    var didClickSave: (()->())? = nil
    var didClickAnalize: (()->())? = nil
    
    func settingCell(bpm: Pulse, isHistory: Bool) {
        v.clipsToBounds = true
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(named: "border")?.cgColor
        infoV.clipsToBounds = true
        infoV.layer.cornerRadius = 12
        infoV.layer.borderWidth = 1
        infoV.layer.borderColor = UIColor(named: "border")?.cgColor
        
        
        dateV.clipsToBounds = true
        dateV.layer.cornerRadius = 8
        dateV.layer.borderWidth = 1
        dateV.layer.borderColor = UIColor(named: "border")?.cgColor
        
        GeneralindicatorsView.clipsToBounds = true
        GeneralindicatorsView.layer.cornerRadius = 8
        stressV.clipsToBounds = true
        stressV.layer.cornerRadius = 8
        healthV.clipsToBounds = true
        healthV.layer.cornerRadius = 8
        EnergyV.clipsToBounds = true
        EnergyV.layer.cornerRadius = 8
        RateofcontractionV.clipsToBounds = true
        RateofcontractionV.layer.cornerRadius = 8
        RateofcontractionValueV.clipsToBounds = true
        RateofcontractionValueV.layer.cornerRadius = 8
        aiAnalizeButton.clipsToBounds = true
        aiAnalizeButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        saveButton.layer.cornerRadius = 8
        
        
        
        
        GeneralindicatorsLabel.font = Font.medium(size: 12)
        dateL.font = Font.medium(size: 12)
        StressL.font = Font.semibold(size: 10)
        EnergyL.font = Font.semibold(size: 10)
        healthL.font = Font.semibold(size: 10)
        stressPercentL.font = Font.semibold(size: 18)
        EnergyPercentL.font = Font.semibold(size: 18)
        healthPercentL.font = Font.semibold(size: 18)
        stressValue.font = Font.medium(size: 12)
        EnergyValue.font = Font.medium(size: 12)
        healthValue.font = Font.medium(size: 12)
        RateofcontractionL.font = Font.medium(size: 12)
        RateofcontractionValue.font = Font.medium(size: 12)
        AVGL.font = Font.regular(size: 14)
        BPML.font = Font.regular(size: 12)
        AVG_BPM_L.font = Font.bold(size: 26)
        textL.font = Font.regular(size: 15)
        aiAnalizeButton.titleLabel?.font = Font.semibold(size: 14)
        saveButton.titleLabel?.font = Font.semibold(size: 14)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        dateL.text = dateFormatter.string(from: bpm.date_created)
        
        saveButton.isHidden = isHistory
        textL.isHidden = isHistory
        
        if bpm.BPM < 35 {
            stressValue.text = "Low"
            stressPercentL.text = "9%"
            stressValue.textColor = #colorLiteral(red: 0.04705882353, green: 0.04705882353, blue: 0.04705882353, alpha: 1)
            stressV.backgroundColor = #colorLiteral(red: 1, green: 0.9882352941, blue: 0.3215686275, alpha: 1)
        } else if bpm.BPM < 71 {
            stressValue.text = "Normal"
            stressPercentL.text = "44%"
            stressValue.textColor = UIColor(named: "white")
            stressV.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.7529411765, blue: 0.3411764706, alpha: 1)
        } else {
            stressValue.text = "High"
            stressPercentL.text = "72%"
            stressValue.textColor = UIColor(named: "white")
            stressV.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.02352941176, blue: 0.07450980392, alpha: 1)
        }
        if bpm.BPM < 41 {
            EnergyValue.text = "Low"
            EnergyPercentL.text = "23%"
            EnergyValue.textColor = #colorLiteral(red: 0.04705882353, green: 0.04705882353, blue: 0.04705882353, alpha: 1)
            EnergyV.backgroundColor = #colorLiteral(red: 1, green: 0.9882352941, blue: 0.3215686275, alpha: 1)
            
            healthValue.text = "Low"
            healthPercentL.text = "34%"
            healthValue.textColor = #colorLiteral(red: 0.04705882353, green: 0.04705882353, blue: 0.04705882353, alpha: 1)
            healthV.backgroundColor = #colorLiteral(red: 1, green: 0.9882352941, blue: 0.3215686275, alpha: 1)
        } else if bpm.BPM < 71 {
            EnergyValue.text = "Normal"
            EnergyPercentL.text = "53%"
            EnergyValue.textColor = UIColor(named: "white")
            EnergyV.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.7529411765, blue: 0.3411764706, alpha: 1)
            
            healthValue.text = "Normal"
            healthPercentL.text = "75%"
            healthValue.textColor = UIColor(named: "white")
            healthV.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.7529411765, blue: 0.3411764706, alpha: 1)
            
        } else {
            EnergyValue.text = "High"
            EnergyPercentL.text = "74%"
            EnergyValue.textColor = UIColor(named: "white")
            EnergyV.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.02352941176, blue: 0.07450980392, alpha: 1)
            healthValue.text = "High"
            healthPercentL.text = "96%"
            healthValue.textColor = UIColor(named: "white")
            healthV.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.02352941176, blue: 0.07450980392, alpha: 1)
        }
        
        if bpm.BPM < 60 {
            RateofcontractionValue.text = "Low"
            RateofcontractionValue.textColor = #colorLiteral(red: 0.04705882353, green: 0.04705882353, blue: 0.04705882353, alpha: 1)
            RateofcontractionValueV.backgroundColor = #colorLiteral(red: 1, green: 0.9882352941, blue: 0.3215686275, alpha: 1)
            textL.text = "A low heart rate (below 60 beats per minute) is usually called bradycardia. It can be normal during sleep or in professional athletes, but sometimes indicates health problems. If you feel dizzy, tired or weak, it is better to consult your doctor."
        } else if bpm.BPM < 101 {
            RateofcontractionValue.text = "Normal"
            RateofcontractionValue.textColor = UIColor(named: "white")
            RateofcontractionValueV.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.7529411765, blue: 0.3411764706, alpha: 1)
            textL.text = "Your heart rate is within the normal range (60-100 beats/min). This indicates that your body is in good health. It may change due to stress, physical activity, or medications."
        } else {
            RateofcontractionValue.text = "High"
            RateofcontractionValue.textColor = UIColor(named: "white")
            RateofcontractionValueV.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.02352941176, blue: 0.07450980392, alpha: 1)
            textL.text = "A high heart rate (more than 100 beats per minute) is called tachycardia. It is most often a normal reaction to exercise or stress. If a rapid pulse appears regularly and without reason, it is a reason to consult a specialist."
        }
        
        AVG_BPM_L.text = "\(bpm.BPM)"
        
        setupChart(with: Array(bpm.BPMLit))
    }
    
    func setupChart(with values: [Double]) {
        var entries: [ChartDataEntry] = []

        for (index, value) in values.enumerated() {
            let entry = ChartDataEntry(x: Double(index), y: value)
            entries.append(entry)
        }

        let dataSet = LineChartDataSet(entries: entries)
        
        dataSet.colors = [#colorLiteral(red: 0.768627451, green: 0.03137254902, blue: 0.07450980392, alpha: 1)]
        dataSet.circleRadius = 3
        dataSet.circleColors = [#colorLiteral(red: 0.768627451, green: 0.03137254902, blue: 0.07450980392, alpha: 1)]
        dataSet.lineWidth = 2
        dataSet.drawValuesEnabled = false
        dataSet.mode = .cubicBezier

        let data = LineChartData(dataSet: dataSet)
        chartView.data = data

        chartView.xAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = Font.regular(size: 10)
        chartView.leftAxis.labelTextColor = UIColor(named: "Light500")!
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        chartView.chartDescription.enabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.isUserInteractionEnabled = false
    }
    @IBAction func clickAIAnalize(_ sender: Any) {
        didClickAnalize?()
    }
    @IBAction func clickSave(_ sender: Any) {
        didClickSave?()
    }
}
