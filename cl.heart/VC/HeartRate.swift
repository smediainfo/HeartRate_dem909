
import UIKit
import Pulsator
import UICircularProgressRing
import AVFoundation
import RealmSwift

class HeartRate: UIViewController, AVCapturePhotoCaptureDelegate, BPMDetectionManagerDelegate {

    weak var delegate: MonitoringDelegate?
    
    //измерение
    @IBOutlet weak var stackViewInfo: UIStackView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var heart: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var ring: UICircularProgressRing!
    
    //начало
    @IBOutlet weak var cameraEmptyText: UILabel!
    @IBOutlet weak var cameraEmpty: UIImageView!
    @IBOutlet weak var finger: UIImageView!
    
    
    @IBOutlet weak var b: NSLayoutConstraint!
    
    @IBOutlet weak var bpmNameLabel: UILabel!
    @IBOutlet weak var bpmLabel: UILabel!
    var isEnd = false
    var time = 0
    var backFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice!
    var stillImageOutput: AVCapturePhotoOutput!
    var stillImage: UIImage?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    let captureSession = AVCaptureSession()
    var heartRateModel = BPMDetectionManager()
    var bpmArray : [Double] = []
    var bpmValue: CGFloat = 0
    var startDateDetect: Double = 0.0
    var timer: Timer?
    var isError = false
    
    let count: Double = 15
    
    @IBOutlet weak var titleL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        if UIScreen.main.bounds.height < 670 {
            b.constant = -100
        }
        Logger.log(name: "measuring_opened")
        heart.isHidden = true
        cameraView.isHidden = true
        ring.isHidden = true
        stackViewInfo.isHidden = true
        pulsatorView.isHidden = true
        
        titleL.font = Font.semibold(size: 18)
        cameraEmptyText.font = Font.semibold(size: 18)
        bpmLabel.font = Font.bold(size: 60)
        bpmNameLabel.font = Font.bold(size: 20)
        
        cameraView.clipsToBounds = true
        cameraView.layer.cornerRadius = 46
  
    }
    
    
    @IBOutlet weak var pulsatorView: UIView!
    let pulsator = Pulsator()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        pulsator.backgroundColor = UIColor.red.cgColor
        pulsator.numPulse = 4
        pulsator.radius = 140

        pulsatorView.layer.addSublayer(pulsator)

        
        heartRateModel.delegate = self
        self.heartRateModel.runDetection(Int32(self.count))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        heart.isHidden = true
        cameraView.isHidden = true
        ring.isHidden = true
        stackViewInfo.isHidden = true
        pulsatorView.isHidden = true
        
        
        finger.isHidden = false
        cameraEmpty.isHidden = false
        cameraEmptyText.isHidden = false
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pulsator.stop()
        ring.pauseProgress()
        ring.value = 0
        heartRateModel.delegate = nil
        heartRateModel.clear()
        heartRateModel.finishDetection()
        heartRateModel.turnTorch(on: false)
        bpmArray.removeAll()
    }
    

    @IBAction func clickClose(_ sender: Any) {
        Logger.log(name: "measuring_closed")
        self.dismiss(animated: true)
    }
    
    @IBAction func clickInfo(_ sender: Any) {
        let vc = Info2()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    
    
    func getImageFromCamera(_ image: UIImage!) {
//        self.cameraView.isHidden = true
        self.img.image = image.makeFixOrientation()//UIImage(data: image!)
    }
    func updateDetction(_ bpmCount: Int32, time seconds: Int32) {
        
        UIScreen.main.brightness = 1.0
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        isStarted = true
        
        heart.isHidden = false
        cameraView.isHidden = false
        ring.isHidden = false
        stackViewInfo.isHidden = false
        pulsatorView.isHidden = false
        
        finger.isHidden = true
        cameraEmpty.isHidden = true
        cameraEmptyText.isHidden = true
        print("updateDetction")
        
        if self.bpmArray.isEmpty {
            self.startDateDetect = Date().timeIntervalSince1970
            self.bpmArray.removeAll()
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tickTimer), userInfo: nil, repeats: true)
            if time == 0 {
                tickTimer()
            }
            pulsator.start()
            
            self.ring.startProgress(to: 100, duration: self.count)
        } else {
            self.startDateDetect = Date().timeIntervalSince1970
        }
        
        self.bpmArray.append(Double(bpmCount))
        self.bpmLabel.text = "\(Int(self.bpmArray.last ?? 0))"
        
    }
    
    
    var isStarted = false
    @objc func tickTimer() {
        time += 1
        if time > Int(self.count) {
            time = Int(self.count)
        }
//        self.timerLabel.text = "\(30 - time) sec"
        print("tickTimer")
        
    }
    
    func pauseDetection() {
        self.timer?.invalidate()
        self.timer = nil
        self.ring.pauseProgress()
        
        if isStarted {
            
            print("ERROR!!!!")
            heartRateModel.delegate = nil
            isStarted = false
            let vc = HeartRateError()
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
    }
    
    func endDetection() {
        
        self.timer?.invalidate()
        self.timer = nil
        self.isEnd = true
        
        if isStarted {
            print("heartRateEnd")
            heartRateModel.delegate = nil
            isStarted = false
            let vc = Result()
            vc.delegate = self.delegate
            
            let p = Pulse()
            p.id = UUID().uuidString
            p.date_created = Date()
            for b in self.bpmArray {
                p.BPMLit.append(b)
            }
            vc.pulse = p
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension UIImage {
    func makeFixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage;
    }
}
