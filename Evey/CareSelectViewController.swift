//
//  CareSelectViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 24/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
protocol actionProtocol {
    
    func callBack(message:String,name:String)
    
}

class CareSelectViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,actionProtocol,CLLocationManagerDelegate{
    func callBack (message:String,name:String){
       // self.deselectMethod()
        if name == "Pause" {
            
                let msg = "To Pause your visit please select Care"
                let attStr = NSMutableAttributedString(string: msg)
            
                let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
            
                attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 5))
                attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 34, length: 4))

                self.popup = PopupDialog(title: "", message: attStr,  buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
                let okButton = DefaultButton(title: "Ok", action: {
                    
                })
                let cancelButton = CancelButton(title: "Cancel", action: {
                    
                    let date2 = Date()
                    
                    let formater = DateComponentsFormatter()
                    formater.unitsStyle = .full
                    formater.allowedUnits = [.month, .day, .hour, .minute, .second]
                    formater.maximumUnitCount = 2
                    
                    
                    let str = formater.string(from: Constants.dateArray[0], to: date2)
                    
                    print(str!)
                    
                    let time = date2.timeIntervalSince(Constants.dateArray[0])
                    
                    print(time)
                    
                    print("Second \(floor(time))")
                    print(Int(time))

                    
                    let vc  = CustomAlertViewController()
                    vc.delegate = self
                    vc.counter = Int(time)
                    vc.screenFrame = self.view.frame
                    
                    self.present(vc, animated: true, completion: {
                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                    })

                })
                
                self.popup.addButtons([cancelButton,okButton])
                self.present(self.popup, animated: true, completion: {
                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                    
                })
                
            

        }else if name == "Complete"{
            let msg = "To Complete your visit please select Care"
            let attStr = NSMutableAttributedString(string: msg)
            let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
            
            attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 8))
            attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 37, length: 4))

            self.popup = PopupDialog(title: "", message: attStr,  buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
            let okButton = DefaultButton(title: "Ok", action: {
                
            })
            let cancelButton = CancelButton(title: "Cancel", action: {
                
                let date2 = Date()
                let formater = DateComponentsFormatter()
                formater.unitsStyle = .full
                formater.allowedUnits = [.month, .day, .hour, .minute, .second]
                formater.maximumUnitCount = 2
                
                let time = date2.timeIntervalSince(Constants.dateArray[0])
                let vc  = CustomAlertViewController()
                vc.delegate = self
                vc.counter = Int(time)
                vc.screenFrame = self.view.frame
                self.present(vc, animated: true, completion: {
                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                })
            })
            
            self.popup.addButtons([cancelButton,okButton])
            self.present(self.popup, animated: true, completion: {
                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                
            })

        }else{
            
        }
    }
    
    var caresArray = NSMutableArray()
    @IBOutlet weak var residentDetails: UILabel!
    @IBOutlet weak var careSelectTableView: UITableView!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var buttonsViewBorder: UILabel!
    let msg  = NSAttributedString()
    

    var alertForPause  = Bool()
    var alertForComplete = Bool()
    var alertForContinue = Bool()
    
    
    
    
    var alertController: UIAlertController!
    var counter:Int = 18156
    
    var timer: Timer?
    var label = ""
    var message = "in "

    
    var leftSwipe = Bool()
    var RightSwipe = Bool()
    var getpath = IndexPath()
    var rightgetpath = IndexPath()
    var performedVisitsArray = NSMutableArray()
    var openVisitsArray = NSMutableArray ()
    var residentNameRoom =  String()
    var outcomeDictionary = ["Treatments": ["Performed", "Refused", "Out-of-Facility", "Notes"],
                             "Escort": ["Performed", "Refused", "Notes"],
                             "Bathing": ["Performed", "Refused", "Notes"],
                             "TEDS": ["On", "Off", "Notes"],
                             "Room Trays": ["Performed", "Notes"],
                             "ACCU": ["Performed", "Refused", "Out-of-Facility", "Call Nurse", "Notes"],
                             "Cares": ["Performed", "Refused", "Out-of-Facility", "Notes"],
                             "Eye Drops": ["Performed", "Refused", "Out-of-Facility", "Notes"]]
    var careQuickSelect =   ["Treatments": "Performed","Escort": "Performed",
                             "Bathing": "Performed","TEDS": "On",
                             "Room Trays": "Performed","ACCU": "Performed",
                             "Cares": "Performed","Eye Drops": "Performed"]
    
    var residentDetailsStr = String()
    
    //for beacon Detection
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")

    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
    
    
    
    // to find current time
    
    var date = Date()
    // to find current time
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(careSelectTableView.frame.size.width), height: CGFloat(px))
        let line = UIView(frame: frame)
        self.careSelectTableView.tableHeaderView = line
        line.backgroundColor = self.careSelectTableView.separatorColor
        self.careSelectTableView.tableFooterView = UIView()
        caresArray = ["Treatments","Escort","Bathing","TEDS","Room Trays","ACCU","Cares","Eye Drops"]
        
        let gestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeLeft))
        gestureLeft.direction = .left
        gestureLeft.delegate = self as? UIGestureRecognizerDelegate
        careSelectTableView.addGestureRecognizer(gestureLeft)
        
        let gestureRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight))
        gestureRight.delegate = self as? UIGestureRecognizerDelegate
        gestureRight.direction = .right
        careSelectTableView.addGestureRecognizer(gestureRight)
       // openVisitsArray = ["Treatments"]
        //performedVisitsArray = ["Escort"]
        
        if UserDefaults.standard.value(forKey: "Came From") as! String == "DashBoardViewController" || UserDefaults.standard.value(forKey: "Came From") as! String == "RecentVisitsViewController" {
            residentDetails.text = UserDefaults.standard.value(forKey: "ResidentDetails") as? String
            residentDetailsStr = (UserDefaults.standard.value(forKey: "ResidentDetails") as? String)!


        }else{
        residentDetails.text = UserDefaults.standard.value(forKey: "nameRoom") as? String
            residentDetailsStr = (UserDefaults.standard.value(forKey: "nameRoom") as? String)!
        }
        residentDetails.text = residentDetailsStr

        // to detect beacons
        
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)
        acceptableDistance = 2.0
        rssiArray.removeAll()
        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
        if residentDetailsStr == "Edward J.310" {
            openVisitsArray = ["Eye Drops"]
            performedVisitsArray = ["Bathing"]
            
        }else{
            openVisitsArray = ["Treatments"]
            performedVisitsArray = ["Escort"]
            
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if alertForPause == true || alertForComplete == true {
            
            var msg = ""
            var attString = NSMutableAttributedString(string: msg)
            
            var font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)

            if alertForPause == true {
                
                msg = "To Pause your visit please select Care"
                
                attString = NSMutableAttributedString(string: msg)
                
                font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
                
                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 5))
                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 34, length: 4))

                
            }else{
                
                msg = "To Complete your visit please select Care"
                attString = NSMutableAttributedString(string: msg)
                
                font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
                
                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 8))
                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 37, length: 4))

            }
            
            popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                
            })
            
            let okButton = DefaultButton(title: "Ok", action: {
                
            })
            popup.addButtons([okButton])
            self.present(popup, animated: true, completion: {
                self.alertForPause = false
            })
        }else if alertForContinue == true {
            let date2 = Date()
            let vc  = CustomAlertViewController()
            vc.delegate = self
            vc.counter = Int(date2.timeIntervalSince(Constants.dateArray[0]))
            vc.screenFrame = self.view.frame
            
            self.present(vc, animated: true, completion: {
                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                self.alertForContinue = false
            })
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caresArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return careSelectTableView.frame.height/11.181
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ResidentSelectTestTableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath) as! ResidentSelectTestTableViewCell
        cell.separatorInset = UIEdgeInsets.zero
        cell.careImage.image = UIImage(named: "\(caresArray[indexPath.row])")
        cell.careNameLabel.text = caresArray.object(at: indexPath.row) as? String
//        if (leftSwipe == true ){
//            if indexPath == getpath {
//
//           cell.pauseButton.frame = CGRect(x: 375, y: 0, width: 125, height: cell.caresView.frame.width)
//                cell.pauseButton.setTitle("Pause", for: UIControlState.normal)
//                cell.pauseButton.addTarget(self, action: #selector(self.pauseButtonAction(_:)), for:.touchUpInside)
//
//            
//            }
//
//         }else if (RightSwipe == true ) {
//            if indexPath == rightgetpath{
//                cell.caresView.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.width/0.6, height: cell.contentView.frame.height)
//            }
//         }else{
            cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
            if openVisitsArray.contains(caresArray.object(at: indexPath.row)) || performedVisitsArray.contains(caresArray.object(at: indexPath.row)){
                if openVisitsArray.contains(caresArray.object(at: indexPath.row)){
                    if residentDetailsStr == "Edward J.310" {
                        cell.visitStatusImage.image = UIImage(named: "scheduledOpenVisitIcon")
                    }else{
                    cell.visitStatusImage.image = UIImage(named: "openVisitIcon")
                    }
                }
                if performedVisitsArray.contains(caresArray.object(at: indexPath.row)){
                    if residentDetailsStr == "Edward J.310" {
                        cell.visitStatusImage.image = UIImage(named: "scheduledPerformedVisitIcon")
                    }else{
                        cell.visitStatusImage.image = UIImage(named: "performedVisitIcon")
                    }
                }
                cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                
                cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
                
                cell.caresView.addSubview(cell.visitStatusImage)
                cell.caresView.backgroundColor = UIColor.clear
                
                cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                
                cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                
                cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                
                cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                
                cell.pauseButton.setTitle("Pause", for: UIControlState.normal)

                cell.pauseButton.addTarget(self, action: #selector(self.pauseButtonAction(_:)), for:.touchUpInside)
                


            }else{
                cell.visitStatusImage.removeFromSuperview()
                cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                
                cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.819, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                
                cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.984, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                
                cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                
                cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                
                cell.pauseButton.setTitle("Pause", for: UIControlState.normal)
                
                cell.pauseButton.addTarget(self, action: #selector(self.pauseButtonAction(_:)), for:.touchUpInside)

            }
       // }
        cell.rightArrowBtn.addTarget(self, action: #selector(self.rightArrowBtnAction(_:)), for: .touchUpInside)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if leftSwipe == true || RightSwipe == true{
            
        self.deselectMethod()
        }
    }
    func handleSwipeLeft(_ gestureRecognizer: UISwipeGestureRecognizer) {
        self.deselectMethod()
        let point: CGPoint = gestureRecognizer.location(in: careSelectTableView)
        let indexPath: IndexPath? = careSelectTableView.indexPathForRow(at: point)
        if indexPath != nil {
            getpath = indexPath!
         getpath = indexPath!
        if((indexPath) != nil)
        {
            leftSwipe = true
            RightSwipe = false
            let cell: ResidentSelectTestTableViewCell = careSelectTableView.cellForRow(at: indexPath!) as! ResidentSelectTestTableViewCell
            //cell.rightArrowBtn.isHidden = true
            if residentDetailsStr == "Edward J.310" {
                cell.pauseButton.setTitleColor(UIColor(red: 100.0/255.0, green: 187.0/255.0, blue: 214/255.0, alpha: 1.0), for: UIControlState.normal)
                
               cell.pauseButton.backgroundColor = UIColor.init(red: 254.0/255.0, green: 232.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            }else{
                cell.pauseButton.setTitleColor(UIColor(red: 32.0 / 255.0, green: 138.0 / 255.0, blue: 200.0 / 255.0, alpha: 1), for: UIControlState.normal)
                cell.pauseButton.backgroundColor = UIColor(red: 219.0 / 255.0, green: 242.0 / 255.0, blue: 251.0 / 255.0, alpha: 1)
            }

            if openVisitsArray.contains(caresArray.object(at: (indexPath?.row)!)) || performedVisitsArray.contains(caresArray.object(at: (indexPath?.row)!)) {
                UIView.animate(withDuration: 0.3, animations: {

                    
                if self.openVisitsArray.contains(self.caresArray.object(at: (indexPath?.row)!)){
                    if self.residentDetailsStr == "Edward J.310" {
                        cell.visitStatusImage.image = UIImage(named: "scheduledOpenVisitIcon")
                    }else{
                        cell.visitStatusImage.image = UIImage(named: "openVisitIcon")
                    }
                }
                if self.performedVisitsArray.contains(self.caresArray.object(at: (indexPath?.row)!)) {
                        if self.residentDetailsStr == "Edward J.310" {
                            cell.visitStatusImage.image = UIImage(named: "scheduledPerformedVisitIcon")
                        }else{
                            cell.visitStatusImage.image = UIImage(named: "performedVisitIcon")
                        }
 
                }
                    cell.pauseButton.frame = CGRect(x: cell.caresView.frame.width/1.333333, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                }, completion: nil)
            }
            else{
            UIView.animate(withDuration: 0.3, animations: {
                cell.pauseButton.frame = CGRect(x: cell.caresView.frame.width/1.333333, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
            }, completion: nil)
            }
        }
        }
    }
    func handleSwipeRight(_ gestureRecognizer: UISwipeGestureRecognizer) {
       self.deselectMethod()
        let point: CGPoint = gestureRecognizer.location(in: careSelectTableView)
        let indexPath: IndexPath? = careSelectTableView.indexPathForRow(at: point)
        if indexPath != nil {
        rightgetpath = indexPath!
        if((indexPath) != nil)
        {
            leftSwipe = false
            RightSwipe = true
            let cell: ResidentSelectTestTableViewCell = careSelectTableView.cellForRow(at: indexPath!) as! ResidentSelectTestTableViewCell
            //cell.caresView.backgroundColor = UIColor(red: 249.0 / 255.0, green: 249.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)

            let perfomButton = UIButton()
            perfomButton.addTarget(self, action: #selector(self.performButtonAction(_:)), for:.touchUpInside)
            perfomButton.frame = CGRect(x: 0, y: cell.caresView.frame.origin.y, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
            perfomButton.setTitle(careQuickSelect["\((cell.careNameLabel.text)! as NSString)"], for: .normal)
            if residentDetailsStr == "Edward J.310" {
                perfomButton.setTitleColor(UIColor(red: 100.0/255.0, green: 187.0/255.0, blue: 214/255.0, alpha: 1.0), for: UIControlState.normal)

                perfomButton.backgroundColor = UIColor.init(red: 254.0/255.0, green: 232.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            }else{
                perfomButton.setTitleColor(UIColor.white, for: UIControlState.normal)

            perfomButton.backgroundColor = UIColor(red: 32.0 / 255.0, green: 138.0 / 255.0, blue: 200.0 / 255.0, alpha: 1)
            }
            cell.caresView.addSubview(perfomButton)
            if openVisitsArray.contains(caresArray.object(at: (indexPath?.row)!)) || performedVisitsArray.contains(caresArray.object(at: (indexPath?.row)!)){
                UIView.animate(withDuration: 0.3, animations: {
                    cell.caresView.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                   if self.openVisitsArray.contains(self.caresArray.object(at: (indexPath?.row)!)){
                        if self.residentDetailsStr == "Edward J.310" {
                            cell.visitStatusImage.image = UIImage(named: "scheduledOpenVisitIcon")
                        }else{
                            cell.visitStatusImage.image = UIImage(named: "openVisitIcon")
                        }
                    }
                    if self.performedVisitsArray.contains(self.caresArray.object(at: (indexPath?.row)!)) {
                        if self.residentDetailsStr == "Edward J.310" {
                            cell.visitStatusImage.image = UIImage(named: "scheduledPerformedVisitIcon")
                        }else{
                            cell.visitStatusImage.image = UIImage(named: "performedVisitIcon")
                        }
  
                    }
                    cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.819, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
                    
                    cell.caresView.addSubview(cell.visitStatusImage)
                    
                    cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.373, y: cell.careImage.frame.origin.y, width: cell.careImage.frame.width, height: cell.careImage.frame.height)
                    
                    cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.781, y: cell.careNameLabel.frame.origin.y, width: cell.careNameLabel.frame.width, height: cell.careNameLabel.frame.height)
                    
                }, completion: nil)
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    cell.caresView.frame = CGRect(x:0, y: cell.caresView.frame.origin.y, width: cell.contentView.frame.width/0.75, height: cell.caresView.frame.size.height)
                    //cell.caresView.backgroundColor = UIColor(red: 249.0 / 255.0, green: 249.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)
                    cell.careImage.frame = CGRect(x: cell.contentView.frame.width/3, y: cell.careImage.frame.origin.y, width: cell.careImage.frame.width, height: cell.careImage.frame.height)
                    cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/2.142, y: cell.careNameLabel.frame.origin.y, width: cell.careNameLabel.frame.width, height: cell.careNameLabel.frame.height)
                }, completion: nil)
            }
        }
        }
    }
    
    
    func pauseButtonAction(_ sender: Any) {

        
        // Create the dialog
        
        
        let msg = "Your visit to \((self.residentDetails.text)!) has been Paused"
        let attString = NSMutableAttributedString(string: msg)
        let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
        
        attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msg.characters.count-7, length: 7))

        
        let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {

        }
        
        
        // Create first button
        let buttonOne = CancelButton(title: "Cancel") {
            self.deselectMethod()

        }
        
        // Create second button
        let buttonTwo = DefaultButton(title: "OK") {
            var buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.careSelectTableView)
            var indexpath:IndexPath?
            if buttonPosition.y < 0.5 {
                buttonPosition = CGPoint(x: 0.0, y: 0.5)
                indexpath = self.careSelectTableView.indexPathForRow(at: buttonPosition)
            }else{

             indexpath = self.careSelectTableView.indexPathForRow(at: buttonPosition)
            }
            
            let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:indexpath!) as! ResidentSelectTestTableViewCell
            
            if self.performedVisitsArray.contains(cell.careNameLabel.text! as NSString) {
                self.performedVisitsArray.remove(cell.careNameLabel.text! as NSString)
                self.openVisitsArray.add(cell.careNameLabel.text! as NSString)
            }else{
                self.openVisitsArray.add(cell.careNameLabel.text! as NSString)
            }
            
            self.leftSwipe = false
            UIView.animate(withDuration: 0.3, animations: {
                if self.residentDetailsStr == "Edward J.310" {
                    cell.visitStatusImage.image = UIImage(named: "scheduledOpenVisitIcon")
                }else{
                    cell.visitStatusImage.image = UIImage(named: "openVisitIcon")
                }
                
                cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                
                cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
                
                cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                
                cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                
                cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                
            }, completion: {(finished) -> Void in
                cell.caresView.addSubview( cell.visitStatusImage)
                cell.rightArrowBtn.isHidden = false
                
            })

            let previousBeaconArray : [Int] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [Int]
            if previousBeaconArray.count == 0{
                let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                self.locationManager.stopMonitoring(for: self.region)
                self.locationManager.stopRangingBeacons(in: self.region)
                let transition = CATransition()
                transition.duration = 0
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionMoveIn
                transition.subtype = kCATransitionFromLeft
                self.view.window!.layer.add(transition, forKey: kCATransition)
                
                self.present(nvc, animated: false, completion: {
                    UserDefaults.standard.set([], forKey: "SelectedArray")
                    UserDefaults.standard.set([], forKey: "NamesArray")
                    UserDefaults.standard.set("", forKey: "Came From")

                })
            }else{
                let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                self.locationManager.stopMonitoring(for: self.region)
                self.locationManager.stopRangingBeacons(in: self.region)
                let transition = CATransition()
                transition.duration = 0
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionMoveIn
                transition.subtype = kCATransitionFromLeft
                self.view.window!.layer.add(transition, forKey: kCATransition)
                
                
                // to check any performed visits
                
                var namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                if namesArray.contains(self.residentDetails.text!){
                }else{
                    namesArray.append(self.residentDetails.text!)
                }
                
                UserDefaults.standard.set(namesArray, forKey: "NamesArray")
                
                self.present(nvc, animated: false, completion: {
                    UserDefaults.standard.set([], forKey: "SelectedArray")
                })
                
            }
            
            
            
        }

        
        popup.addButtons([buttonOne, buttonTwo])
        // Present dialog
        self.present(popup, animated: true, completion: nil)

    }
    func performButtonAction(_ sender: Any) {

        
        // Create the dialog
        
        let msg = "I have marked your visit with \((self.residentDetails.text)!) as Completed"
        let attString = NSMutableAttributedString(string: msg)
        let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
        
        attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msg.characters.count-10, length: 10))


        
        let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
        }
        
        // Create first button
        let okButton = DefaultButton(title: "OK") {
            var buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.careSelectTableView)
            var indexpath:IndexPath?
            if buttonPosition.y < 0.5 {
                buttonPosition = CGPoint(x: 0.0, y: 0.5)
                indexpath = self.careSelectTableView.indexPathForRow(at: buttonPosition)
            }else{
                
                indexpath = self.careSelectTableView.indexPathForRow(at: buttonPosition)
            }
            let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:indexpath!) as! ResidentSelectTestTableViewCell
            if self.openVisitsArray.contains(cell.careNameLabel.text! as NSString) {
                self.openVisitsArray.remove(cell.careNameLabel.text! as NSString)
                self.performedVisitsArray.add(cell.careNameLabel.text! as NSString)
            }else{
                self.performedVisitsArray.add(cell.careNameLabel.text! as NSString)
            }
            
            self.RightSwipe = false
            cell.rightArrowBtn.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.caresView.frame.size.height)
                cell.caresView.backgroundColor = UIColor.clear
                if self.residentDetailsStr == "Edward J.310" {
                    cell.visitStatusImage.image = UIImage(named: "scheduledPerformedVisitIcon")
                }else{
                    cell.visitStatusImage.image = UIImage(named: "performedVisitIcon")
                }
                cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
                cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: CGFloat(cell.careImage.frame.origin.y), width: CGFloat(cell.careImage.frame.width), height: CGFloat(cell.careImage.frame.height))
                cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: CGFloat(cell.careNameLabel.frame.origin.y), width: CGFloat(cell.careNameLabel.frame.width), height: CGFloat(cell.careNameLabel.frame.height))
                cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: CGFloat(cell.rightArrowBtn.frame.origin.y), width: CGFloat(cell.rightArrowBtn.frame.width), height: CGFloat(cell.rightArrowBtn.frame.height))
            }, completion: {(finished) -> Void in
                cell.caresView.addSubview(cell.visitStatusImage)
            })
            let previousBeaconArray : [Int] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [Int]
            if previousBeaconArray.count == 0{
                let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                self.locationManager.stopMonitoring(for: self.region)
                self.locationManager.stopRangingBeacons(in: self.region)
                let transition = CATransition()
                transition.duration = 0
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionMoveIn
                transition.subtype = kCATransitionFromLeft
                self.view.window!.layer.add(transition, forKey: kCATransition)
                
                

                self.present(nvc, animated: false, completion: {
                    
                    UserDefaults.standard.set([], forKey: "SelectedArray")
                    UserDefaults.standard.set([], forKey: "NamesArray")
                    UserDefaults.standard.set("", forKey: "Came From")

                })
            }else{
                if UserDefaults.standard.value(forKey: "Came From") as! String != "DashBoardViewController" {
                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                    self.locationManager.stopMonitoring(for: self.region)
                    self.locationManager.stopRangingBeacons(in: self.region)
                    let transition = CATransition()
                    transition.duration = 0
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionMoveIn
                    transition.subtype = kCATransitionFromLeft
                    self.view.window!.layer.add(transition, forKey: kCATransition)
                    
                    self.present(nvc, animated: false, completion: {
                        
                        UserDefaults.standard.set("", forKey: "Came From")
                        
                    })

                    
                }else{
                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                    self.locationManager.stopMonitoring(for: self.region)
                    self.locationManager.stopRangingBeacons(in: self.region)
                    let transition = CATransition()
                    transition.duration = 0
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionMoveIn
                    transition.subtype = kCATransitionFromLeft
                    self.view.window!.layer.add(transition, forKey: kCATransition)
                    // to check any performed visits
                    var namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                    if namesArray.contains(self.residentDetails.text!){
                    
                    }else{
                    namesArray.append(self.residentDetails.text!)
                    
                    }
                    UserDefaults.standard.set(namesArray, forKey: "NamesArray")

                    self.present(nvc, animated: false, completion: {
                    
                        UserDefaults.standard.set([], forKey: "SelectedArray")

                    })
                }
                
            }
            
        }
        let cancelButton = CancelButton(title: "Cancel") {
            self.deselectMethod()
        }
        
        popup.addButtons([cancelButton,okButton])
         //Present dialog
        self.present(popup, animated: true, completion: nil)

    }

    func deselectMethod() {
        if leftSwipe == true {
            leftSwipe = false
            let cell: ResidentSelectTestTableViewCell = careSelectTableView.cellForRow(at:getpath) as! ResidentSelectTestTableViewCell
            if openVisitsArray.contains(caresArray.object(at: (getpath.row))) || performedVisitsArray.contains(caresArray.object(at: (getpath.row))){
                UIView.animate(withDuration: 0.3, animations: {
                    
                    cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                if self.openVisitsArray.contains(self.caresArray.object(at: (self.getpath.row))){
                    if self.residentDetailsStr == "Edward J.310" {
                        cell.visitStatusImage.image = UIImage(named: "scheduledOpenVisitIcon")
                    }else{
                        cell.visitStatusImage.image = UIImage(named: "openVisitIcon")
                    }
                }
                if self.performedVisitsArray.contains(self.caresArray.object(at: (self.getpath.row))){
                        if self.residentDetailsStr == "Edward J.310" {
                            cell.visitStatusImage.image = UIImage(named: "scheduledPerformedVisitIcon")
                        }else{
                            cell.visitStatusImage.image = UIImage(named: "performedVisitIcon")
                        }
                }
                }, completion: { (finished) -> Void in

                    cell.rightArrowBtn.isHidden = false
                })
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: cell.caresView.frame.origin.y, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)

                }, completion: { (finished) -> Void in
                })
            }
        }
        if RightSwipe == true {
            RightSwipe = false
            let cell: ResidentSelectTestTableViewCell = careSelectTableView.cellForRow(at:rightgetpath) as! ResidentSelectTestTableViewCell
            cell.caresView.backgroundColor = UIColor.clear

            if openVisitsArray.contains(caresArray.object(at: (rightgetpath.row))) || performedVisitsArray.contains(caresArray.object(at: (rightgetpath.row))) {
                UIView.animate(withDuration: 0.3, animations: {
                    
                    cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: CGFloat(cell.caresView.frame.origin.y), width: cell.contentView.frame.width/0.75, height: CGFloat(cell.caresView.frame.size.height))
                if self.openVisitsArray.contains(self.caresArray.object(at: (self.rightgetpath.row))){
                    if self.residentDetailsStr == "Edward J.310" {
                        cell.visitStatusImage.image = UIImage(named: "scheduledOpenVisitIcon")
                    }else{
                        cell.visitStatusImage.image = UIImage(named: "openVisitIcon")
                    }
                }
                if self.performedVisitsArray.contains(self.caresArray.object(at: (self.rightgetpath.row))){
                        if self.residentDetailsStr == "Edward J.310" {
                            cell.visitStatusImage.image = UIImage(named: "scheduledPerformedVisitIcon")
                        }else{
                            cell.visitStatusImage.image = UIImage(named: "performedVisitIcon")
                        }
                }
                    cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
                    cell.caresView.addSubview(cell.visitStatusImage)
                    cell.caresView.backgroundColor = UIColor.clear
                    cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: CGFloat(cell.careImage.frame.origin.y), width: CGFloat(cell.careImage.frame.width), height: CGFloat(cell.careImage.frame.height))
                    cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: CGFloat(cell.careNameLabel.frame.origin.y), width: CGFloat(cell.careNameLabel.frame.width), height: CGFloat(cell.careNameLabel.frame.height))
                    cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: CGFloat(cell.rightArrowBtn.frame.origin.y), width: CGFloat(cell.rightArrowBtn.frame.width), height: CGFloat(cell.rightArrowBtn.frame.height))
                }, completion: { (finished) -> Void in
                    cell.rightArrowBtn.isHidden = false
                })
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: CGFloat(cell.caresView.frame.origin.y), width: cell.contentView.frame.width/0.75, height: CGFloat(cell.caresView.frame.size.height))
                    cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.819, y: CGFloat(cell.careImage.frame.origin.y), width: CGFloat(cell.careImage.frame.width), height: CGFloat(cell.careImage.frame.height))
                    cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.984, y: CGFloat(cell.careNameLabel.frame.origin.y), width: CGFloat(cell.careNameLabel.frame.width), height: CGFloat(cell.careNameLabel.frame.height))
                    cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: CGFloat(cell.rightArrowBtn.frame.origin.y), width: CGFloat(cell.rightArrowBtn.frame.width), height: CGFloat(cell.rightArrowBtn.frame.height))
                }, completion: { (finished) -> Void in
                        cell.rightArrowBtn.isHidden = false
                })
            }
     
        }
    }
    func rightArrowBtnAction(_ sender: Any) {
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: careSelectTableView)
        let indexpath: IndexPath? = careSelectTableView.indexPathForRow(at: buttonPosition)
        let cell: ResidentSelectTestTableViewCell = careSelectTableView.cellForRow(at:(indexpath)!) as! ResidentSelectTestTableViewCell
        let OEVC = self.storyboard?.instantiateViewController(withIdentifier: "OutcomeEntryViewController")as! OutcomeEntryViewController
//        OEVC.care = cell.careNameLabel.text!
//        OEVC.imageAndText.setValue("\((cell.careNameLabel.text)!as NSString )", forKey: "CareImage")
//        OEVC.imageAndText.setValue("\((self.residentDetails.text)! as NSString)", forKey: "residentDetails")
        
        UserDefaults.standard.set("\((cell.careNameLabel.text)!as NSString )", forKey: "CareImage")
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(OEVC, animated:false) {
        }
    }
    @IBAction func menuAction(_ sender: Any) {
        
//        let date2 = Date()
//        
//        let formater = DateComponentsFormatter()
//        formater.unitsStyle = .full
//        formater.allowedUnits = [.month, .day, .hour, .minute, .second]
//        formater.maximumUnitCount = 2
//        
//        
//        let str = formater.string(from: date, to: date2)
//    
//        print(str!)
//        
//        let time = date2.timeIntervalSince(date)
//        
//        print(time)
//        
//        print("Second \(floor(time))")
//        print(Int(time))
//        
//        print("reverse \(Int(date.timeIntervalSince(date2)))") 
        

        let MenuVC = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("CareSelectViewController", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(MenuVC, animated: false, completion: nil)
 
    }
    @IBAction func backButton(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "Came From") as? String == "DashBoardViewController"{
            UserDefaults.standard.removeObject(forKey: "Came From")
            let DBVC = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopRangingBeacons(in: region)
            locationManager.stopMonitoring(for: region)

            self.present(DBVC, animated: false, completion: {
                UserDefaults.standard.set("", forKey: "Came From")
            })
   
        }else if UserDefaults.standard.value(forKey: "Came From") as? String == "RecentVisitsViewController"{
            
            UserDefaults.standard.removeObject(forKey: "Came From")
            let RVVC = self.storyboard?.instantiateViewController(withIdentifier: "RecentVisitsViewController") as! RecentVisitsViewController
            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopRangingBeacons(in: region)
            locationManager.stopMonitoring(for: region)

            self.present(RVVC, animated: false, completion: {
                UserDefaults.standard.set("", forKey: "Came From")
            })

        }else{
        let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopRangingBeacons(in: region)
            locationManager.stopMonitoring(for: region)

        self.present(RSVC, animated: false, completion: nil)
        }
    }
    func layOuts(){
        
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height

        backBtn.frame = CGRect(x: screenWidth/23.437, y: screenHeight/23, width: screenWidth/18.75, height: screenHeight/33.35)

        eveyTitle.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.size.width+screenWidth/3.712, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)

        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.213, y: screenHeight/23.437, width: screenWidth/11.363, height: screenHeight/31.761)

        residentDetails.frame = CGRect(x: screenWidth/23.437, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/35.105, width: screenWidth/1.518, height: screenHeight/18.527)
        
        careSelectTableView.frame =  CGRect(x: 0, y: residentDetails.frame.origin.y+residentDetails.frame.size.height+screenHeight/44.466, width: screenWidth, height: screenHeight/1.355)
        
        buttonView.frame = CGRect(x: 0, y: careSelectTableView.frame.origin.y+careSelectTableView.frame.size.height, width: screenWidth, height: screenHeight/12.584)
        
        
        cancelBtn.frame = CGRect(x: screenWidth/15, y: buttonView.frame.size.height/4.818, width: screenWidth/5.281, height: buttonView.frame.size.height/1.766)
        
        doneBtn.frame = CGRect(x: cancelBtn.frame.origin.x+cancelBtn.frame.size.width+screenWidth/1.963, y: buttonView.frame.size.height/4.818, width: screenWidth/5.281, height: buttonView.frame.size.height/1.766)

        
        buttonsViewBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: buttonView.frame.height/buttonView.frame.height)

        
        
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        deselectMethod()
    }
    func decrease()
    {
        var minutes: Int
        var seconds: Int
        //var hours:Int
        if(counter >= 0) {
            self.counter += 1
            print(counter)  // Correct value in console
            //hours = (counter / 60) / 60
            minutes = (counter % 3600) / 60
            seconds = (counter % 3600) % 60
            
           // alertController.message = String(format: "%02d:%02d:%02d", hours,minutes, seconds)
            print("\(minutes):\(seconds)")  // Correct value in console
        }
        else{
            dismiss(animated: true, completion: nil)
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

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
        if (knownBeacons.count>0) {
            let closeBeacon = knownBeacons[0] as CLBeacon
            var maj =  Int()
            maj =  8
            let previousBeaconArray : [Int] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [Int]
            if previousBeaconArray.count == 0 {
                if closeBeacon.major.intValue == maj {
                }else{
                    rssiArray.append(closeBeacon.rssi)
                    if rssiArray.count == 1 {
                        let sumedrssi = rssiArray.reduce(0, +)
                        let processedrssi = sumedrssi/1
                        let base = Double(10)
                        let power = Double(-57-(processedrssi))/Double(10*2)
                        let dis = pow(Double(base), power)
                        print("\(closeBeacon.major.intValue)")
                        print("\(closeBeacon.rssi)")
                        print("accuracy \(closeBeacon.accuracy)")
                        print(dis)
                        rssiArray.removeAll()
                        //if closeBeacon.accuracy <= 4.0 {
                        if dis <= 4.0{
                            UserDefaults.standard.set([closeBeacon.major.intValue], forKey: "PreviousBeaconArray")
                            
                            popup.dismiss(animated: true, completion: {
                                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                
                            })
                            locationManager.stopRangingBeacons(in: region)
                            locationManager.stopMonitoring(for: region)
                            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                            let transition = CATransition()
                            transition.duration = 0
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromLeft
                            self.view.window!.layer.add(transition, forKey: kCATransition)

                            self .present(nvc, animated: false, completion: {
                                UserDefaults.standard.set([], forKey: "SelectedArray")
                                UserDefaults.standard.set("", forKey: "Came From")

                            })
                        }
                    }
                }
                
            }else{
                if closeBeacon.major.intValue == maj {
                    rssiArray.append(closeBeacon.rssi)
                    if rssiArray.count == 1 {
                        let sumedrssi = rssiArray.reduce(0, +)
                        let processedrssi = sumedrssi/1
                        let base = Double(10)
                        let power = Double(-59-(processedrssi))/Double(10*2)
                        let dis = pow(Double(base), power)
                        print("\(closeBeacon.major.intValue)")
                        print("\(closeBeacon.rssi)")
                        print("accuracy \(closeBeacon.accuracy)")
                        print(dis)
                        rssiArray.removeAll()
                        //if closeBeacon.accuracy <= 3.0 {
                        if dis <= 3{
                            print(" care After")
                            UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                            let msg = "Are you finished with your visit or are you continuing care?"
                            let attString = NSMutableAttributedString(string: msg)
                            
                            popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                                
                            })

                            let pauseButton = CancelButton(title: "Pause", action: {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                        let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                            RSVC.alertForPause = true
                                    
                                    self.locationManager.stopMonitoring(for: region)
                                            self.locationManager.stopRangingBeacons(in: region)
                                        RSVC.alertForPause = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                        self.present(RSVC, animated: false, completion: {
                                            UserDefaults.standard.set([], forKey: "NamesArray")
                                            UserDefaults.standard.set([], forKey: "SelectedArray")
                                            UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                            UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        })
                                }else{
                                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "nameRoom"), forKey: "ResidentDetails")
                                    self.viewDidLoad()
                                    self.careSelectTableView.reloadData()
                                    self.deselectMethod()
                                    
                                    let msg = "To Pause your visit please select Care"
                                    
                                    let attStr = NSMutableAttributedString(string: msg)
                                    
                                    let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
                                    
                                    attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 5))
                                    attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 34, length: 4))

                                    
                                    self.popup = PopupDialog(title: "", message: attStr,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
                                    let okButton = DefaultButton(title: "Ok", action: { 
                                        
                                    })
                                    
                                    self.popup.addButton(okButton)
                                    self.present(self.popup, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")

                                    })
                                    
                                }
 
                            })
                            
                            let continueButton = CancelButton(title: "Continue", action: {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    
                                    RSVC.alertForContinue = true
                                    
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(RSVC, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    })
                                }else{
                                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "nameRoom"), forKey: "ResidentDetails")
                                    self.viewDidLoad()
                                    self.careSelectTableView.reloadData()
                                    self.deselectMethod()
                                    let date2 = Date()
                                    
                                    let formater = DateComponentsFormatter()
                                    formater.unitsStyle = .full
                                    formater.allowedUnits = [.month, .day, .hour, .minute, .second]
                                    formater.maximumUnitCount = 2
                                    
                                    
                                    let str = formater.string(from: Constants.dateArray[0], to: date2)
                                    
                                    print(str!)
                                    
                                    let time = date2.timeIntervalSince(Constants.dateArray[0])
                                    
                                    print(time)
                                    
                                    print("Second \(floor(time))")
                                    print(Int(time))

                                    
                                    
                                    let vc  = CustomAlertViewController()
                                    vc.delegate = self
                                    vc.counter = Int(time)
                                    vc.screenFrame = self.view.frame
                                    
                                    self.present(vc, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    })
                                    
                                }

                            })

                            
                            let completeButton = CancelButton(title: "Complete", action: {
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    RSVC.alertForComplete = true
                                    
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                   self.view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(RSVC, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    })
                                }else{
                                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "nameRoom"), forKey: "ResidentDetails")
                                    self.viewDidLoad()
                                    self.careSelectTableView.reloadData()
                                    self.deselectMethod()

                                    let msg = "To Complete your visit please select Care"
                                    let attStr = NSMutableAttributedString(string: msg)
                                    let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
                                    
                                    attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 8))
                                    attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 37, length: 4))

                                    

                                    self.popup = PopupDialog(title: "", message: attStr,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
                                    let okButton = DefaultButton(title: "Ok", action: {
                                        
                                    })
                                    
                                    self.popup.addButton(okButton)
                                    self.present(self.popup, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }
                            })

                            
                            let deleteButton = DestructiveButton(title: "Delete", action: {
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                            })
                            
                            popup.addButtons([pauseButton,continueButton,completeButton,deleteButton])
                            
                            let hallwayBeaconArray : [Int] = UserDefaults.standard.value(forKey: "HallwayBeaconArray") as! [Int]
                            if hallwayBeaconArray.count == 0 {
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count >= 1 && selectedArray.count == 0{
                                    let DVC = storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                    UserDefaults.standard.set([], forKey: "NamesArray")
                                    UserDefaults.standard.set([], forKey: "SelectedArray")
                                    locationManager.stopRangingBeacons(in: region)
                                    locationManager.stopMonitoring(for: region)
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(DVC, animated: false, completion: nil)
                                }else{
                                    

                                    self.present(popup, animated: true, completion: {
                                        UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                        UserDefaults.standard.set([closeBeacon.major.intValue], forKey: "HallwayBeaconArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set("", forKey: "Came From")
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }


}
