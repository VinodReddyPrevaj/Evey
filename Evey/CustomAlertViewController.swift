
import UIKit

class CustomAlertViewController : UIViewController {
    var delegate:actionProtocol?
    var Delegate:SampleProtocol?
    var counter:Int = 4507
    
    var timer: Timer?
    var label = ""
    var message = "in "
    
    @IBOutlet weak var border3: UILabel!
    @IBOutlet weak var border2: UILabel!
    @IBOutlet weak var border1: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var completeBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var screenFrame = CGRect()
    let transitioner = CAVTransitioner()
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transitioner
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.decrease), userInfo: nil, repeats: true)
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    @IBAction func deleteBtnAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
        self.delegate?.callBack(message: "\(counter)", name: "Delete")
        self.Delegate?.someMethod(message: "Delete", name: "")
        timer?.invalidate()
    }
    @IBAction func completeBtnAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
        self.delegate?.callBack(message: "\(counter)", name: "Complete")
        self.Delegate?.someMethod(message: "Complete", name: "")
        timer?.invalidate()

    }
    @IBAction func pauseBtnAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
        self.delegate?.callBack(message: "\(counter)", name: "Pause")
        self.Delegate?.someMethod(message: "Pause", name: "")
        timer?.invalidate()

    }
    func decrease()
    {
        var minutes: Int
        var seconds: Int
        var hours:Int
        if(counter >= 0) {
            self.counter += 1
            print(counter)  // Correct value in console
            hours = (counter / 60) / 60
            minutes = (counter % 3600) / 60
            seconds = (counter % 3600) % 60
            timeLabel.text = String(format: "%02d:%02d:%02d", hours,minutes, seconds)
            print("\(minutes):\(seconds)")  
        }
        else{
            timer!.invalidate()
        }
    }
    
    func alertMessage() -> String {
        print(message+"\(self.label)")
        return(message+"\(self.label)")
    }
    
    func countDownString() -> String {
        print("\(counter) seconds")
        return "\(counter) seconds"
    }
    override func viewDidLoad() {
        var minutes: Int
        var seconds: Int
        var hours:Int
        hours = (counter / 60) / 60
        minutes = (counter % 3600) / 60
        seconds = (counter % 3600) % 60
        timeLabel.text = String(format: "%02d:%02d:%02d", hours,minutes, seconds)
        self.view.frame = CGRect(x: 0, y: 40, width: screenFrame.width/1.044 , height: screenFrame.height/1.533)

        titleLbl.frame = CGRect(x: self.view.frame.origin.x, y: 0, width: self.view.frame.width, height: self.view.frame.height/8.7)
        
        timeLabel.frame = CGRect(x: self.view.frame.origin.x, y: self.titleLbl.frame.origin.y+self.titleLbl.frame.height+self.view.frame.height/8.7, width: self.view.frame.width, height: self.view.frame.height/4.35)
        
        border1.frame = CGRect(x: self.view.frame.origin.x, y: self.timeLabel.frame.origin.y+self.timeLabel.frame.height+self.view.frame.height/5.304, width: self.view.frame.width, height: 1)
        
        pauseBtn.frame = CGRect(x: self.view.frame.origin.x, y: border1.frame.origin.y+border1.frame.height, width: self.view.frame.width, height: self.view.frame.height/8.7)
        
        border2.frame = CGRect(x: self.view.frame.origin.x, y: pauseBtn.frame.origin.y+pauseBtn.frame.height, width: self.view.frame.width, height: 1)
        
        completeBtn.frame = CGRect(x: self.view.frame.origin.x, y: border2.frame.origin.y+border2.frame.height, width: self.view.frame.width, height: self.view.frame.height/8.7)
        
        border3.frame = CGRect(x: self.view.frame.origin.x, y: completeBtn.frame.origin.y+completeBtn.frame.height, width: self.view.frame.width, height: 1)
        
        deleteBtn.frame = CGRect(x: self.view.frame.origin.x, y: border3.frame.origin.y+border3.frame.height, width: self.view.frame.width, height: self.view.frame.height/8.7)
        
        let path = UIBezierPath(roundedRect:titleLbl.bounds,
                                byRoundingCorners:[.topLeft, .topRight],
                                cornerRadii: CGSize(width: self.view.frame.width/27.615, height:  self.view.frame.height/32.142))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        titleLbl.layer.mask = maskLayer
    }

}
