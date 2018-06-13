
//
//  CareSelectViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 24/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AudioToolbox
import AVFoundation
protocol actionProtocol {
    
    func callBack(message:String,name:String)
    func pauseButton(actionButton:String)
    func performButton(actionButton:String)
    func doneButton(actionButton:String)
    
}

class CareSelectViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,actionProtocol,CLLocationManagerDelegate{
    var timer: Timer?

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
    
    var performedArray = NSMutableArray()
    var pauseArray = NSMutableArray()
    var pauseCareArray = [String]()
    var performCareArray = [String]()


    var alertController: UIAlertController!
    var counter:Int = 18156
    
    var label = ""
    var message = "in "
    
    
    var openVisitsArray = NSMutableArray ()

    
    var leftSwipe = Bool()
    var RightSwipe = Bool()
    var getpath = IndexPath()
    var rightgetpath = IndexPath()
    var performedVisitsArray = NSMutableArray()
    var residentNameRoom =  String()
    var careQuickSelect =   ["Bathing": "Performed",
                             "Whirlpool": "Performed",
                             "Escort": "Performed",
                             "TEDS": "On",
                             "Room Trays": "Performed",
                             "ACCU": "Performed",
                             "AM/PM Cares":"Performed",
                             "Treatments":"Performed",
                             "Eye Drops":"Performed",
                             "Medication":"Performed",
                             "Toileting":"Performed",
                             "Blood Pressure":"Performed",
                             "Medication Reminder":"Performed",
                             "Room Cleaning":"Performed",
                             "Laundry":"Performed",
                             "Medication Set-Up":"Performed",
                             "Fall":"Performed"
                             ]
    
    var residentDetailsStr = String()
    
    //for beacon Detection
    var acceptableDistance = Double()
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")

    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
    
    var date = Date()
    // to find current time
    
    var beaconsArray = NSArray()
    var responseBeacon = NSDictionary()

    let deafaultTimesForCares = ["Treatments":15,"Escort":30,"Bathing":45,"TEDS":5,"Room Trays":10,"ACCU":5,"Eye Drops":5] as NSDictionary

    var audioPlayer = AVAudioPlayer()
    
    let roomUrl = Bundle.main.url(forResource: "Room", withExtension: "mp3")
    let hallwayUrl = Bundle.main.url(forResource: "Hallway", withExtension:"mp3")

    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        ResidentDetails.openCareIDsArray.removeAllObjects()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"

        
        let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray
        
        let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
        
        let resident_ID = UserDefaults.standard.value(forKey: "resident_id") as! String

        let openCares = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
        
        let openCaresSortedArray = openCares.sorted { (obj1, obj2) -> Bool in
            
            return (dateFormatter.date(from:((((obj1 as! NSDictionary).value(forKey: "total_time"))) as! NSDictionary).value(forKey: "start") as! String))! < (dateFormatter.date(from:((((obj2 as! NSDictionary).value(forKey: "total_time"))) as! NSDictionary).value(forKey: "start") as! String ))!
        }
        print("open\(openCaresSortedArray)")
        print(ResidentDetails.closedCaresFromServer)
        let closeCares = ResidentDetails.closedCaresFromServer.value(forKey: resident_ID) as! NSArray

        let closedCaresSortedArray = closeCares.sorted { (obj1, obj2) -> Bool in

                return (dateFormatter.date(from:((((obj1 as! NSDictionary).value(forKey: "total_time"))) as! NSDictionary).value(forKey: "start") as! String))! > (dateFormatter.date(from:((((obj2 as! NSDictionary).value(forKey: "total_time"))) as! NSDictionary).value(forKey: "start") as! String ))!
        }
        
        print("closed \(closedCaresSortedArray)")

        
        for i in 0..<openCaresSortedArray.count {
            
            ResidentDetails.openCareIDsArray.add(((openCaresSortedArray[i]) as! NSDictionary).value(forKey: "care_id") as! String)
            var careIds = NSDictionary()
            
            let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
            
            if let careIDs = careIDs {
                careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
            }
            
            let care_Id = careIds.allKeys(for: ResidentDetails.openCareIDsArray[i]) as NSArray
            openVisitsArray.add(care_Id.firstObject as! String)
        }

        print("open care ids \(ResidentDetails.openCareIDsArray)")
        print("open cares \(openVisitsArray)")
        
        let closedCaresArray = NSMutableArray()
        
        for i in 0..<closedCaresSortedArray.count {
            closedCaresArray.add(((closedCaresSortedArray[i]) as! NSDictionary).value(forKey: "care_id") as! String)
            var careIds = NSDictionary()
            
            let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
            
            if let careIDs = careIDs {
                careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
            }
            
            let care_Id = careIds.allKeys(for: closedCaresArray[i]) as NSArray
            if performedVisitsArray.contains(care_Id.firstObject as! String) || openVisitsArray.contains(care_Id.firstObject as! String){

            }else{
                performedVisitsArray.add(care_Id.firstObject as! String)
            }

        }
        print("storedCare \(ResidentDetails.storedCares.count)")
        if ResidentDetails.storedCares.count > 0 {
            for i in 0..<ResidentDetails.storedCares.count {
                if (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "resident_id") as! String == resident_ID {
                    
                    var careIds = NSDictionary()
                
                    let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                
                    if let careIDs = careIDs {
                        careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                    }
                    let storedCareId = (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String
                
                    let care_Id = careIds.allKeys(for: storedCareId) as NSArray
                
                    if openVisitsArray.contains(care_Id.firstObject as! String) || performedVisitsArray.contains(care_Id.firstObject as! String) {
                    
                        let careStatus = (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_status") as! String
                    
                        if openVisitsArray.contains(care_Id.firstObject as! String){
                            if careStatus == "Closed" {
                                openVisitsArray.remove(care_Id.firstObject as! String)
                                performedVisitsArray.add(care_Id.firstObject as! String)
                            }
                        }else if performedVisitsArray.contains(care_Id.firstObject as! String) {
                            if careStatus == "Open" {
                                performedVisitsArray.remove(care_Id.firstObject as! String)
                                openVisitsArray.add(care_Id.firstObject as! String)
                            }
                        }
                    
                    }else{
                        let careStatus = (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_status") as! String
                        if careStatus == "Open" {
                            openVisitsArray.add(care_Id.firstObject as! String)
                        }else if careStatus == "Closed" {
                            performedVisitsArray.insert(care_Id.firstObject as! String, at: 0)
                        }
                    }
                }
            }
        }
        
        print("closed care ids \(closedCaresArray)")
        print("closed cares \(performedVisitsArray)")
        for element in closedCaresArray {
            if element as! String == "5ab5064971a5957989df4f21" {
                closedCaresArray.remove(element)
            }
        }
        for elements in performedVisitsArray {
            if elements as! String == "Check-In" {
                performedVisitsArray.remove(elements)
            }
        }
        let caresList = ["Bathing","Whirlpool","Escort","TEDS","Room Trays","ACCU","AM/PM Cares", "Treatments", "Eye Drops", "Medication", "Toileting", "Blood Pressure", "Medication Reminder", "Room Cleaning", "Laundry", "Medication Set-Up", "Fall"]
        
        
        for i in 0..<openVisitsArray.count {
            caresArray.add(openVisitsArray[i])
        }
        for i in 0..<performedVisitsArray.count {
        
            caresArray.add(performedVisitsArray[i])
        }
        
        for i in 0..<caresList.count {
            if openVisitsArray.contains(caresList[i]) || performedVisitsArray.contains(caresList[i]){
                
            }else{
                caresArray.add(caresList[i])
            }
        }

        print(caresArray)
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(careSelectTableView.frame.size.width), height: CGFloat(px))
        let line = UIView(frame: frame)
        self.careSelectTableView.tableHeaderView = line
        line.backgroundColor = self.careSelectTableView.separatorColor
        self.careSelectTableView.tableFooterView = UIView()
        
        let gestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeLeft))
        gestureLeft.direction = .left
        gestureLeft.delegate = self as? UIGestureRecognizerDelegate
        careSelectTableView.addGestureRecognizer(gestureLeft)
        
        let gestureRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight))
        gestureRight.delegate = self as? UIGestureRecognizerDelegate
        gestureRight.direction = .right
        careSelectTableView.addGestureRecognizer(gestureRight)
        
        if UserDefaults.standard.value(forKey: "Came From") as! String == "DashBoardViewController" || UserDefaults.standard.value(forKey: "Came From") as! String == "RecentVisitsViewController" {
            residentDetails.text = UserDefaults.standard.value(forKey: "ResidentDetails") as? String
            residentDetailsStr = (UserDefaults.standard.value(forKey: "ResidentDetails") as? String)!


        }else{
            residentDetails.text = UserDefaults.standard.value(forKey: "nameRoom") as? String
            residentDetailsStr = (UserDefaults.standard.value(forKey: "nameRoom") as? String)!
        }
        //residentDetails.text = residentDetailsStr
        

        var residentName = String()
        
        for resident in residents {
            
            if (resident as! NSDictionary).value(forKey: "_id") as! String == UserDefaults.standard.value(forKey: "resident_id") as! String {

                residentName = "\((resident as! NSDictionary).value(forKey: "first_name") as! String) \((resident as! NSDictionary).value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
            }
        }
        residentDetails.text = residentName

        // to detect beacons
        
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)
        acceptableDistance = 2.0
        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
        if residentDetailsStr == "Edward J.310" {
            //openVisitsArray = ["Eye Drops"]
            //performedVisitsArray = ["Bathing"]
            
        }else{
            //openVisitsArray = ["Treatments"]
            //performedVisitsArray = ["Escort"]
            
        }
        
        // for default outcomes in outcome entry Screen
        let defaultOutComesDic =   ["Bathing": "Refused",
                                    "Whirlpool": "Refused",
                                    "Escort": "Refused",
                                    "TEDS": "Off",
                                    "Room Trays": "Performed",
                                    "ACCU": "Refused",
                                    "AM/PM Cares":"Refused",
                                    "Treatments":"Refused",
                                    "Eye Drops":"Refused",
                                    "Medication":"Refused",
                                    "Toileting":"Refused",
                                    "Blood Pressure":"Refused",
                                    "Medication Reminder":"Out-of-Facility",
                                    "Room Cleaning":"Performed",
                                    "Laundry":"Performed",
                                    "Medication Set-Up":"Performed",
                                    "Fall":"Performed"
        ]
        
        UserDefaults.standard.setValue(defaultOutComesDic, forKey: "defaultOutComes")
        UserDefaults.standard.setValue("", forKey: "Note")
        
        var careIds = NSDictionary()
        
        let beaconsData = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
        
        if let beaconsData = beaconsData {
            careIds = (NSKeyedUnarchiver.unarchiveObject(with: beaconsData as Data) as? NSDictionary)!
        }
        print(careIds)
        
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
    
    func callBack (message:String,name:String){
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
        if caresArray[indexPath.row] as! String == "AM/PM Cares" {
            cell.careImage.image = UIImage(named: "AMPM Cares")
        }

        cell.careNameLabel.text = caresArray.object(at: indexPath.row) as? String
        if performedArray.count > 0 {
            if performedArray.contains(indexPath) {
                if indexPath == performedArray[indexPath.row] as! IndexPath {
                    
                    cell.caresView.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.width/0.6, height: cell.contentView.frame.height)
                }
            }else{
                cell.caresView.frame = CGRect(x: cell.caresView.frame.origin.x, y: cell.caresView.frame.origin.y, width: cell.caresView.frame.width, height: cell.caresView.frame.height)
            }
        }
        else{
            cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
            caresArray.object(at: indexPath.row)
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
                
                
                
            }
            else{
                cell.visitStatusImage.removeFromSuperview()
                cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                
                cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.819, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                
                cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.984, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                
                cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                
                cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                
                cell.pauseButton.setTitle("Pause", for: UIControlState.normal)
                
                cell.pauseButton.addTarget(self, action: #selector(self.pauseButtonAction(_:)), for:.touchUpInside)
                
            }
        }
        cell.rightArrowBtn.addTarget(self, action: #selector(self.rightArrowBtnAction(_:)), for: .touchUpInside)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        deselect(index: indexPath)
    }
    func deselect(index:IndexPath) {
        if pauseArray.contains(index) {
            pauseArray.remove(index)
            let cell: ResidentSelectTestTableViewCell = careSelectTableView.cellForRow(at: index) as! ResidentSelectTestTableViewCell
            UIView.animate(withDuration: 0.3, animations: {
                
                cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
            }, completion: nil)
            
        }else if performedArray.contains(index) {
            performedArray.remove(index)
            let cell: ResidentSelectTestTableViewCell = careSelectTableView.cellForRow(at: index) as! ResidentSelectTestTableViewCell
            if openVisitsArray.contains(caresArray.object(at: index.row)) || performedVisitsArray.contains(caresArray.object(at: index.row)){
                UIView.animate(withDuration: 0.3, animations: {
                    
                    cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                    
                    cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
                    
                    cell.caresView.addSubview(cell.visitStatusImage)
                    cell.caresView.backgroundColor = UIColor.clear
                    
                    cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                    
                    cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                    
                    cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                    
                    cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                    
                }, completion: nil)
                
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    
                    //cell.visitStatusImage.removeFromSuperview()
                    cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                    
                    cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.819, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                    
                    cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.984, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                    
                    cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                    
                    cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                    
                }, completion: nil)
                
            }
            
        }

    }
    func handleSwipeLeft(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if pauseArray.count > 0 {
            for i in 0..<pauseArray.count {
                let cell: ResidentSelectTestTableViewCell = careSelectTableView.cellForRow(at: pauseArray[i] as! IndexPath) as! ResidentSelectTestTableViewCell
                UIView.animate(withDuration: 0.3, animations: {
                    
                    cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                }, completion: nil)
                
                
            }
        }
        pauseArray.removeAllObjects()
        
        let point: CGPoint = gestureRecognizer.location(in: careSelectTableView)
        print(point)
        let indexPath: IndexPath? = careSelectTableView.indexPathForRow(at: point)
        print(indexPath!)
        //pauseArray.add(careSelectTableView.indexPathForRow(at: point)!)
        
        
        
        
        if performedArray.contains(careSelectTableView.indexPathForRow(at: point)!){
            
            
            performedArray.remove(careSelectTableView.indexPathForRow(at: point)!)
            pauseArray.add(careSelectTableView.indexPathForRow(at: point)!)
            
            
        }else if pauseArray.contains(careSelectTableView.indexPathForRow(at: point)!){
            
            pauseArray.remove(careSelectTableView.indexPathForRow(at: point)!)
            pauseArray.add(careSelectTableView.indexPathForRow(at: point)!)
            
            
        }else{
            
            pauseArray.add(careSelectTableView.indexPathForRow(at: point)!)
            
        }
        
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
                        cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                        
                        cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
                        
                        cell.caresView.addSubview(cell.visitStatusImage)
                        cell.caresView.backgroundColor = UIColor.clear
                        
                        cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                        
                        cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                        
                        cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                        
                        cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                    }, completion: nil)
                }
                else{
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                        
                        cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.819, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                        
                        cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.984, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                        
                        cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                        
                        cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                    }, completion: nil)
                }
                for i in 0..<performedArray.count {
                    let cell: ResidentSelectTestTableViewCell = careSelectTableView.cellForRow(at: performedArray[i] as! IndexPath) as! ResidentSelectTestTableViewCell
                    if openVisitsArray.contains(caresArray.object(at: (performedArray[i] as! IndexPath).row)) || performedVisitsArray.contains(caresArray.object(at: (performedArray[i] as! IndexPath).row)){
                        UIView.animate(withDuration: 0.3, animations: {
                            
                            cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                            
                            cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
                            
                            cell.caresView.addSubview(cell.visitStatusImage)
                            cell.caresView.backgroundColor = UIColor.clear
                            
                            cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                            
                            cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                            
                            cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                            
                            cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                            
                        }, completion: nil)
                        
                    }else{
                        UIView.animate(withDuration: 0.3, animations: {
                            
                            //cell.visitStatusImage.removeFromSuperview()
                            cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                            
                            cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.819, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                            
                            cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.984, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                            
                            cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                            
                            cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                            
                        }, completion: nil)
                        
                    }
                    
                }
                performedArray.removeAllObjects()
                
            }
        }
    }
    func handleSwipeRight(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if pauseArray.count > 0 {
            for i in 0..<pauseArray.count {
                let cell: ResidentSelectTestTableViewCell = careSelectTableView.cellForRow(at: pauseArray[i] as! IndexPath) as! ResidentSelectTestTableViewCell
                if openVisitsArray.contains(caresArray.object(at: (pauseArray[i] as! IndexPath).row)) || performedVisitsArray.contains(caresArray.object(at: (pauseArray[i] as! IndexPath).row)){
                    UIView.animate(withDuration: 0.3, animations: {
                        
                        cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                        
                        cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
                        
                        cell.caresView.addSubview(cell.visitStatusImage)
                        cell.caresView.backgroundColor = UIColor.clear
                        
                        cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                        
                        cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                        
                        cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                        
                        cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                        
                    }, completion: nil)
                    
                }else{
                    UIView.animate(withDuration: 0.3, animations: {
                        
                        cell.visitStatusImage.removeFromSuperview()
                        cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.size.height)
                        
                        cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.819, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
                        
                        cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.984, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
                        
                        cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
                        
                        cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
                        
                    }, completion: nil)
                    
                }
                
            }
        }
        pauseArray.removeAllObjects()
        
        
        let point: CGPoint = gestureRecognizer.location(in: careSelectTableView)
        let indexPath: IndexPath? = careSelectTableView.indexPathForRow(at: point)
        
        if pauseArray.contains(careSelectTableView.indexPathForRow(at: point)!) {
            pauseArray.remove(careSelectTableView.indexPathForRow(at: point)!)
            performedArray.add(careSelectTableView.indexPathForRow(at: point)!)
            
        }else if performedArray.contains(careSelectTableView.indexPathForRow(at: point)!){
            
            performedArray.remove(careSelectTableView.indexPathForRow(at: point)!)
            performedArray.add(careSelectTableView.indexPathForRow(at: point)!)
            
            
        }else{
            
            performedArray.add(careSelectTableView.indexPathForRow(at: point)!)
            
        }
        
        
        
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
        
        var endTime = Date()
        
        let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
        
        if previousBeaconArray.count == 0 {
            endTime = Times.Leaving_Time
        }
        let vc  = AlertViewController()
        vc.delegate = self
        if Times.Previous_End_Time.count > 0 {
            vc.counter = Int(endTime.timeIntervalSince(Times.Previous_End_Time[0]))
            vc.startTime = Times.Previous_End_Time[0]
        }else{
            vc.counter = Int(endTime.timeIntervalSince(Times.Constant_Start_Time))
            vc.startTime = Times.Constant_Start_Time

        }
        vc.screenFrame = self.view.frame
        vc.pause = true
        vc.residentName = self.residentDetails.text!
        
        self.present(vc, animated: true, completion: {
        })

//        // Create the dialog
//        
//        //let msg = "Your visit to \((self.residentDetails.text)!) has been Paused"
//        let msg = "Do you want to track another Resident/Care?"
//        let attString = NSMutableAttributedString(string: msg)
//        let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
//        
//        attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msg.characters.count-14, length: 14))
//
//        let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
//
//        }
//        var buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.careSelectTableView)
//        var indexpath:IndexPath?
//        if buttonPosition.y < 0.5 {
//            buttonPosition = CGPoint(x: 0.0, y: 0.5)
//            indexpath = self.careSelectTableView.indexPathForRow(at: buttonPosition)
//        }else{
//            
//            indexpath = self.careSelectTableView.indexPathForRow(at: buttonPosition)
//        }
//        // Create second button
//        let buttonTwo = DefaultButton(title: "No") {
//            
//            let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:indexpath!) as! ResidentSelectTestTableViewCell
//            
//            if self.performedVisitsArray.contains(cell.careNameLabel.text! as NSString) {
//                self.performedVisitsArray.remove(cell.careNameLabel.text! as NSString)
//                self.openVisitsArray.add(cell.careNameLabel.text! as NSString)
//            }else{
//                self.openVisitsArray.add(cell.careNameLabel.text! as NSString)
//            }
//            self.leftSwipe = false
//            UIView.animate(withDuration: 0.3, animations: {
//                if self.residentDetailsStr == "Edward J.310" {
//                    cell.visitStatusImage.image = UIImage(named: "scheduledOpenVisitIcon")
//                }else{
//                    cell.visitStatusImage.image = UIImage(named: "openVisitIcon")
//                }
//                
//                cell.pauseButton.frame = CGRect(x: cell.contentView.frame.width/0.75, y: 0, width: cell.contentView.frame.width/3, height: cell.caresView.frame.height)
//                
//                cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
//                
//                cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: cell.contentView.frame.height/11, width: cell.contentView.frame.width/10.416, height: cell.contentView.frame.height/1.222)
//                
//                cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/1.865, height: cell.contentView.frame.height/1.517)
//                
//                cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: cell.contentView.frame.height/4.888, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
//                
//            }, completion: {(finished) -> Void in
//                cell.caresView.addSubview( cell.visitStatusImage)
//                cell.rightArrowBtn.isHidden = false
//                
//            })
//            
//            if UserDefaults.standard.value(forKey: "Came From") as! String == "DashBoardViewController" {
//                
//                let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
//                
//                if previousBeaconArray.count == 0{
//                    
//                }else{
//                    
//                    
//                }
//            }else{
//                let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
//                
//                let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
//                
//                let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray
//                    
//                let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
//                    
//                var resident_ID = String()
//                for i in 0..<residents.count {
//                    let residentDetails = residents[i] as! NSDictionary
//                    let name : String = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
//                    if name == UserDefaults.standard.value(forKey: "nameRoom") as! String {
//                            resident_ID = residentDetails.value(forKey: "_id") as! String
//                    }
//                }
//                let roomId = residentRoom.value(forKey: "_id") as! String
//                    
//                var careNames = [String]()
//                for i in 0..<self.pauseArray.count {
//                    let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:(self.pauseArray[i] as! IndexPath)) as! ResidentSelectTestTableViewCell
//                        careNames.append(cell.careNameLabel.text!)
//                }
//                var careIds = NSDictionary()
//                    
//                let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
//                    
//                if let careIDs = careIDs {
//                    careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
//                }
//                    
//                let care_Id = careIds.value(forKey: careNames[0]) as! String
//                    
//                let care_Value = self.careQuickSelect["\(careNames[0])"]!
//                    
//                
//                var param = NSMutableDictionary()
//                if ResidentDetails.openCareIDsArray.contains(care_Id){
//                    var id = String()
//                    let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
//                    for i in 0..<openVisits.count{
//                        if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
//                            id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
//                        }
//                    }
//                    param = ["_id":id,
//                                 "user_id": user_Id,
//                                 "room_id": roomId,
//                                 "resident_id": resident_ID,
//                                 "care_id": care_Id,
//                                 "care_value": care_Value,
//                                 "care_notes": "",
//                                 "care_type": "Track",
//                                 "care_status": "Open",
//                                 "time_track": ""
//                    ]
//                }else{
//                    param = ["user_id": user_Id,
//                                 "room_id": roomId,
//                                 "resident_id": resident_ID,
//                                 "care_id": care_Id,
//                                 "care_value": care_Value,
//                                 "care_notes": "",
//                                 "care_type": "Track",
//                                 "care_status": "Open",
//                                 "time_track": ""
//                    ]
//                }
//                if ResidentDetails.storedCares.count > 0 {
//                    var elementIndex = [Int]()
//                    for i in 0..<ResidentDetails.storedCares.count{
//                        let element = ResidentDetails.storedCares[i]
//                        if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
//                            elementIndex = [i]
//                        }else{
//                            
//                        }
//                    }
//                    if elementIndex.count > 0 {
//                        ResidentDetails.storedCares.remove(at: elementIndex[0])
//                        
//                        ResidentDetails.storedCares.append(param)
//                        
//                    }else{
//                        ResidentDetails.storedCares.append(param)
//                    }
//                }else{
//                    ResidentDetails.storedCares.append(param)
//                }
//                
//                print(ResidentDetails.storedCares)
//                var defaultTimesArray = [Int]()
//                
//                for i in 0..<ResidentDetails.storedCares.count {
//                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
//                    
//                    defaultTimesArray.append(self.deafaultTimesForCares.value(forKey: careName.first as! String) as! Int)
//                    
//                    
//                }
//                let min = defaultTimesArray.min()
//                
//                var timeRatios: [Int] = []
//                for value in defaultTimesArray { timeRatios.append(value/min!) }
//                
//                let sumOfTimeRatios = timeRatios.reduce(0, +)
//                
//                var startTime = Date()
//                if Times.Previous_End_Time.count > 0 {
//                    startTime = Times.Previous_End_Time[0]
//                }else{
//                    startTime = Times.Constant_Start_Time
//                }
//                let endTime = Date()
//                Times.Previous_End_Time = [endTime]
//                let totalTime = Int(endTime.timeIntervalSince(startTime))
//                
//                let onePartOfTime = totalTime/sumOfTimeRatios
//                
//                var timesWithRespectToRatios : [Int] = []
//                
//                for value in timeRatios {
//                    timesWithRespectToRatios.append(value*onePartOfTime)
//                }
//                
//                let careTimesDictionary = NSMutableDictionary()
//                
//                for i in 0..<ResidentDetails.storedCares.count {
//                    if i == 0 {
//                        
//                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
//                        
//                        let end_time = startTime.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
//                        careTimesDictionary.setValue(["start_time":startTime,"end_time":end_time], forKey: careName.first as! String)
//                        
//                    }else {
//                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
//                        
//                        let beforeCareName = careIds.allKeys(for: (ResidentDetails.storedCares[i-1] as NSDictionary).value(forKey: "care_id") as! String)
//                        
//                        let times_array = careTimesDictionary.value(forKey: beforeCareName.first as! String) as! NSDictionary
//                        
//                        let start_time = times_array.value(forKey: "end_time") as! Date
//                        
//                        let end_time = start_time.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
//                        
//                        careTimesDictionary.setValue(["start_time":start_time,"end_time":end_time], forKey: careName.first as! String)
//                        
//                    }
//                }
//                for i in 0..<ResidentDetails.storedCares.count {
//                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
//                    
//                    let careTimes = careTimesDictionary.value(forKey: careName.first as! String) as! NSDictionary
//                    
//                    (ResidentDetails.storedCares[i] as NSMutableDictionary).setValue(["start_time":"\(careTimes.value(forKey: "start_time") as! Date)","end_time":"\(careTimes.value(forKey: "end_time") as! Date)"], forKeyPath: "time_track")
//                }
//                print(ResidentDetails.storedCares)
//                
//                Times.Previous_End_Time = [Date()]
//                
//                //create the url with URL
//                let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")! //change the url
//                    
//                //create the session object
//                let session = URLSession.shared
//                    
//                //now create the URLRequest object using the url object
//                var request = URLRequest(url: url)
//                request.httpMethod = "POST" //set http method as POST
//                    
//                do {
//                    request.httpBody = try JSONSerialization.data(withJSONObject: ResidentDetails.storedCares, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
//                } catch let error {
//                    print(error.localizedDescription)
//                }
//                    
//                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
//                    
//                //create dataTask using the session object to send data to the server
//                let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
//                    
//                    guard error == nil else {
//                        return
//                    }
//                    
//                    guard let data = data else {
//                        return
//                    }
//                    
//                    do {
//                        //create json object from data
//                        _ = try! JSONSerialization.jsonObject(with: data, options: [])
//                        if previousBeaconArray.count == 0{
//                            DispatchQueue.main.async( execute: {
//                                
//                                let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
//                                self.locationManager.stopMonitoring(for: self.region)
//                                self.locationManager.stopRangingBeacons(in: self.region)
//                                let transition = CATransition()
//                                transition.duration = 0.3
//                                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                                transition.type = kCATransitionMoveIn
//                                transition.subtype = kCATransitionFromLeft
//                                self.view.window!.layer.add(transition, forKey: kCATransition)
//                                
//                                self.present(nvc, animated: false, completion: {
//                                    UserDefaults.standard.set("", forKey: "Came From")
//                                    
//                                })
//                                
//                                
//                            })
//                            
//                        }else {
//                            let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/\(((UserDefaults.standard.value(forKey: "PreviousBeaconArray")) as! NSArray)[0] as! String)")!
//                            
//                            let session = URLSession.shared
//                            let request = NSMutableURLRequest (url: url as URL)
//                            request.httpMethod = "Get"
//                            
//                            request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
//                            
//                            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
//                                if let data = data {
//                                    
//                                    let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                                    //print(re)
//                                    ResidentDetails.response = re
//                                    DispatchQueue.main.async( execute: {
//                                        let reDirectingVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
//                                        
//                                        self.locationManager.stopMonitoring(for: self.region)
//                                        self.locationManager.stopRangingBeacons(in: self.region)
//                                        let transition = CATransition()
//                                        transition.duration = 0.3
//                                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                                        transition.type = kCATransitionMoveIn
//                                        transition.subtype = kCATransitionFromLeft
//                                        self.view.window!.layer.add(transition, forKey: kCATransition)
//                                        
//                                        self.present(reDirectingVC, animated: false, completion: {
//
//                                        })
//                                        
//                                        
//                                    })
//                                }
//                            }
//                            task.resume()
//                        }
//                    }
//                })
//                task.resume()
//            }
//           ResidentDetails.storedCares.removeAll()
//        }
//        // Create first button
//        let cancelButton = CancelButton(title: "Yes") {
//            self.deselect(index: indexpath!)
//            
//            let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:indexpath!) as! ResidentSelectTestTableViewCell
//            if self.openVisitsArray.contains(cell.careNameLabel.text! as NSString) {
//                self.openVisitsArray.remove(cell.careNameLabel.text! as NSString)
//                self.performedVisitsArray.add(cell.careNameLabel.text! as NSString)
//            }else{
//                self.performedVisitsArray.add(cell.careNameLabel.text! as NSString)
//            }
//                
//            self.RightSwipe = false
//            cell.rightArrowBtn.isHidden = false
//                
//            UIView.animate(withDuration: 0.3, animations: {
//                cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.caresView.frame.size.height)
//                    cell.caresView.backgroundColor = UIColor.clear
//                if self.residentDetailsStr == "Edward J.310" {
//                    cell.visitStatusImage.image = UIImage(named: "scheduledPerformedVisitIcon")
//                }else{
//                    cell.visitStatusImage.image = UIImage(named: "performedVisitIcon")
//                }
//                cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
//                cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: CGFloat(cell.careImage.frame.origin.y), width: CGFloat(cell.careImage.frame.width), height: CGFloat(cell.careImage.frame.height))
//                cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: CGFloat(cell.careNameLabel.frame.origin.y), width: CGFloat(cell.careNameLabel.frame.width), height: CGFloat(cell.careNameLabel.frame.height))
//                cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: CGFloat(cell.rightArrowBtn.frame.origin.y), width: CGFloat(cell.rightArrowBtn.frame.width), height: CGFloat(cell.rightArrowBtn.frame.height))
//            }, completion: {(finished) -> Void in
//                cell.caresView.addSubview(cell.visitStatusImage)
//            })
//                
//            let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
//            
//            let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray
//                
//            let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
//                
//            var resident_ID = String()
//            for i in 0..<residents.count {
//                let residentDetails = residents[i] as! NSDictionary
//                let name : String = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
//                if name == UserDefaults.standard.value(forKey: "nameRoom") as! String {
//                    resident_ID = residentDetails.value(forKey: "_id") as! String
//                }
//            }
//            let roomId = residentRoom.value(forKey: "_id") as! String
//                
//            var careNames = [String]()
//            careNames.append(cell.careNameLabel.text!)
//                
//            var careIds = NSDictionary()
//                
//            let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
//                
//            if let careIDs = careIDs {
//                careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
//            }
//                
//            let care_Id = careIds.value(forKey: careNames[0]) as! String
//                
//            let care_Value = self.careQuickSelect["\(careNames[0])"]!
//                
//            var param = NSMutableDictionary()
//            if ResidentDetails.openCareIDsArray.contains(care_Id){
//                var id = String()
//                let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
//                for i in 0..<openVisits.count{
//                    if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
//                        id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
//                    }
//                }
//                param = ["_id":id,
//                             "user_id": user_Id,
//                             "room_id": roomId,
//                             "resident_id": resident_ID,
//                             "care_id": care_Id,
//                             "care_value": care_Value,
//                             "care_notes": "",
//                             "care_type": "Track",
//                             "care_status": "Open",
//                             "time_track": ""
//                        
//                    ]
//            }else{
//                param = ["user_id": user_Id,
//                             "room_id": roomId,
//                             "resident_id": resident_ID,
//                             "care_id": care_Id,
//                             "care_value": care_Value,
//                             "care_notes": "",
//                             "care_type": "Track",
//                             "care_status": "Open",
//                             "time_track": ""
//                        
//                    ]
//            }
//            if ResidentDetails.storedCares.count > 0 {
//                var elementIndex = [Int]()
//                for i in 0..<ResidentDetails.storedCares.count{
//                    let element = ResidentDetails.storedCares[i]
//                    if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
//                            elementIndex = [i]
//                    }
//                }
//                if elementIndex.count > 0 {
//                    ResidentDetails.storedCares.remove(at: elementIndex[0])
//                        
//                    ResidentDetails.storedCares.append(param)
//                        
//                }else{
//                    ResidentDetails.storedCares.append(param)
//                }
//            }else{
//                ResidentDetails.storedCares.append(param)
//            }
//                
//            print(ResidentDetails.storedCares)
//            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
//                
//            self.locationManager.stopMonitoring(for: self.region)
//                
//            self.locationManager.stopRangingBeacons(in: self.region)
//                
//            let transition = CATransition()
//                
//            transition.duration = 0.3
//                
//            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                
//            transition.type = kCATransitionMoveIn
//                
//            transition.subtype = kCATransitionFromLeft
//                
//            self.view.window!.layer.add(transition, forKey: kCATransition)
//            // to check any performed visits
//            
//            self.present(nvc, animated: false, completion: {
//                    
//            })
//                
//        }
//        
//        popup.addButtons([cancelButton, buttonTwo])
//        // Present dialog
//        self.present(popup, animated: true, completion: nil)
//
    }
    func performButtonAction(_ sender: Any) {
        
        // Create the dialog
        if self.performedArray.count < 2 {
            
            var endTime = Date()
            
            let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
            if previousBeaconArray.count == 0 {
               endTime = Times.Leaving_Time
            }
            let vc  = AlertViewController()
            vc.delegate = self
            if Times.Previous_End_Time.count > 0 {
                vc.counter = Int(endTime.timeIntervalSince(Times.Previous_End_Time[0]))
                vc.startTime = Times.Previous_End_Time[0]
                
            }else{
                vc.counter = Int(endTime.timeIntervalSince(Times.Constant_Start_Time))
                vc.startTime = Times.Constant_Start_Time

            }
            vc.screenFrame = self.view.frame
            vc.perform = true
            vc.residentName = self.residentDetails.text!
            
            self.present(vc, animated: true, completion: {
            })

//            let msg = "Do you want to track another Resident/Care?"
//
//            //let msg = "I have marked your visit with \((self.residentDetails.text)!) as Completed"
//            
//            let attString = NSMutableAttributedString(string: msg)
//            
//            let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
//            
//            attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msg.characters.count-14, length: 14))
//
//
//
//            let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
//            }
//            var buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.careSelectTableView)
//            
//            var indexpath:IndexPath?
//            
//            if buttonPosition.y < 0.5 {
//                buttonPosition = CGPoint(x: 0.0, y: 0.5)
//                indexpath = self.careSelectTableView.indexPathForRow(at: buttonPosition)
//            }else{
//            
//                indexpath = self.careSelectTableView.indexPathForRow(at: buttonPosition)
//            }
//
//            // Create first button
//            let okButton = DefaultButton(title: "No") {
//
//                let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:indexpath!) as! ResidentSelectTestTableViewCell
//                if self.openVisitsArray.contains(cell.careNameLabel.text! as NSString) {
//                    self.openVisitsArray.remove(cell.careNameLabel.text! as NSString)
//                    self.performedVisitsArray.add(cell.careNameLabel.text! as NSString)
//                }else{
//                    self.performedVisitsArray.add(cell.careNameLabel.text! as NSString)
//                }
//            
//                self.RightSwipe = false
//                cell.rightArrowBtn.isHidden = false
//            
//                UIView.animate(withDuration: 0.3, animations: {
//                    cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.caresView.frame.size.height)
//                    cell.caresView.backgroundColor = UIColor.clear
//                    if self.residentDetailsStr == "Edward J.310" {
//                        cell.visitStatusImage.image = UIImage(named: "scheduledPerformedVisitIcon")
//                    }else{
//                        cell.visitStatusImage.image = UIImage(named: "performedVisitIcon")
//                    }
//                    cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
//                    cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: CGFloat(cell.careImage.frame.origin.y), width: CGFloat(cell.careImage.frame.width), height: CGFloat(cell.careImage.frame.height))
//                    cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: CGFloat(cell.careNameLabel.frame.origin.y), width: CGFloat(cell.careNameLabel.frame.width), height: CGFloat(cell.careNameLabel.frame.height))
//                    cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: CGFloat(cell.rightArrowBtn.frame.origin.y), width: CGFloat(cell.rightArrowBtn.frame.width), height: CGFloat(cell.rightArrowBtn.frame.height))
//                }, completion: {(finished) -> Void in
//                    cell.caresView.addSubview(cell.visitStatusImage)
//                })
//                if UserDefaults.standard.value(forKey: "Came From") as! String == "DashBoardViewController" {
//                
//                    let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
//                    if previousBeaconArray.count == 0{
//                    
//                    }else{
//                    
//                    }
//                }else{
//                    let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
//                    
//                    let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
//                    
//                    
//                    let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray
//                    
//                    let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
//                    
//                    var resident_ID = String()
//                    for i in 0..<residents.count {
//                        let residentDetails = residents[i] as! NSDictionary
//                        let name : String = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
//                        if name == UserDefaults.standard.value(forKey: "nameRoom") as! String {
//                                resident_ID = residentDetails.value(forKey: "_id") as! String
//                        }
//                    }
//                    let roomId = residentRoom.value(forKey: "_id") as! String
//                    
//                    var careNames = [String]()
//                    let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:indexpath!) as! ResidentSelectTestTableViewCell
//                    careNames.append(cell.careNameLabel.text!)
//                
//                    var careIds = NSDictionary()
//                
//                    let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
//                    
//                    if let careIDs = careIDs {
//                        careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
//                    }
//                    
//                    let care_Id = careIds.value(forKey: careNames[0]) as! String
//
//                    let care_Value = self.careQuickSelect["\(careNames[0])"]!
//                    
//                    var param = NSMutableDictionary()
//                    if ResidentDetails.openCareIDsArray.contains(care_Id){
//                        var id = String()
//                        let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
//
//                        for i in 0..<openVisits.count{
//                            if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
//                                    id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
//                            }
//                        }
//                        param = ["_id":id,
//                                "user_id": user_Id,
//                                "room_id": roomId,
//                                "resident_id": resident_ID,
//                                "care_id": care_Id,
//                                "care_value": care_Value,
//                                "care_notes": "",
//                                "care_type": "Track",
//                                "care_status": "Closed",
//                                "time_track": ""
//                            
//                            ]
//                    }else{
//                        param = ["user_id": user_Id,
//                                 "room_id": roomId,
//                                 "resident_id": resident_ID,
//                                 "care_id": care_Id,
//                                 "care_value": care_Value,
//                                 "care_notes": "",
//                                 "care_type": "Track",
//                                 "care_status": "Closed",
//                                 "time_track": ""
//                            
//                            ]
//                    }
//                    
//                    if ResidentDetails.storedCares.count > 0 {
//                        var elementIndex = [Int]()
//                        for i in 0..<ResidentDetails.storedCares.count{
//                            let element = ResidentDetails.storedCares[i]
//                            if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
//                                elementIndex = [i]
//                            }else{
//                                
//                            }
//                        }
//                        if elementIndex.count > 0 {
//                            ResidentDetails.storedCares.remove(at: elementIndex[0])
//                            
//                            ResidentDetails.storedCares.append(param)
//                            
//                        }else{
//                            ResidentDetails.storedCares.append(param)
//                        }
//                    }else{
//                        ResidentDetails.storedCares.append(param)
//                    }
//                
//                print(ResidentDetails.storedCares)
//                var defaultTimesArray = [Int]()
//                
//                for i in 0..<ResidentDetails.storedCares.count {
//                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
//                    
//                    defaultTimesArray.append(self.deafaultTimesForCares.value(forKey: careName.first as! String) as! Int)
//                    
//                    
//                }
//                let min = defaultTimesArray.min()
//                
//                var timeRatios: [Int] = []
//                for value in defaultTimesArray { timeRatios.append(value/min!) }
//                
//                let sumOfTimeRatios = timeRatios.reduce(0, +)
//                
//                var startTime = Date()
//                if Times.Previous_End_Time.count > 0 {
//                    startTime = Times.Previous_End_Time[0]
//                }else{
//                    startTime = Times.Constant_Start_Time
//                }
//                let endTime = Date()
//                Times.Previous_End_Time = [endTime]
//                let totalTime = Int(endTime.timeIntervalSince(startTime))
//                
//                let onePartOfTime = totalTime/sumOfTimeRatios
//                
//                var timesWithRespectToRatios : [Int] = []
//                
//                for value in timeRatios {
//                    timesWithRespectToRatios.append(value*onePartOfTime)
//                }
//                
//                let careTimesDictionary = NSMutableDictionary()
//                
//                for i in 0..<ResidentDetails.storedCares.count {
//                    if i == 0 {
//                        
//                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
//                        
//                        let end_time = startTime.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
//                        careTimesDictionary.setValue(["start_time":startTime,"end_time":end_time], forKey: careName.first as! String)
//                        
//                    }else {
//                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
//                        
//                        let beforeCareName = careIds.allKeys(for: (ResidentDetails.storedCares[i-1] as NSDictionary).value(forKey: "care_id") as! String)
//                        
//                        let times_array = careTimesDictionary.value(forKey: beforeCareName.first as! String) as! NSDictionary
//                        
//                        let start_time = times_array.value(forKey: "end_time") as! Date
//                        
//                        let end_time = start_time.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
//                        
//                        careTimesDictionary.setValue(["start_time":start_time,"end_time":end_time], forKey: careName.first as! String)
//                        
//                    }
//                }
//                for i in 0..<ResidentDetails.storedCares.count {
//                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
//                    
//                    let careTimes = careTimesDictionary.value(forKey: careName.first as! String) as! NSDictionary
//                    
//                    (ResidentDetails.storedCares[i] as NSMutableDictionary).setValue(["start_time":"\(careTimes.value(forKey: "start_time") as! Date)","end_time":"\(careTimes.value(forKey: "end_time") as! Date)"], forKeyPath: "time_track")
//                }
//                print(ResidentDetails.storedCares)
//                
//                    
//                    Times.Previous_End_Time = [Date()]
//                    
//                    //create the url with URL
//                    let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")! //change the url
//                    
//                    //create the session object
//                    let session = URLSession.shared
//                    
//                    //now create the URLRequest object using the url object
//                    var request = URLRequest(url: url)
//                    request.httpMethod = "POST" //set http method as POST
//                    
//                    do {
//                        request.httpBody = try JSONSerialization.data(withJSONObject: ResidentDetails.storedCares, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
//                    } catch let error {
//                        print(error.localizedDescription)
//                    }
//                    
//                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//                    request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
//                    
//                    //create dataTask using the session object to send data to the server
//                    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
//                        
//                        guard error == nil else {
//                            return
//                        }
//                    
//                        guard let data = data else {
//                            return
//                        }
//                        
//                        do {
//                            //create json object from data
//                            _ = try! JSONSerialization.jsonObject(with: data, options: [])
//                            if previousBeaconArray.count == 0{
//                                DispatchQueue.main.async( execute: {
//                                    
//                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
//                                    self.locationManager.stopMonitoring(for: self.region)
//                                    self.locationManager.stopRangingBeacons(in: self.region)
//                                    let transition = CATransition()
//                                    transition.duration = 0.3
//                                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                                    transition.type = kCATransitionMoveIn
//                                    transition.subtype = kCATransitionFromLeft
//                                    self.view.window!.layer.add(transition, forKey: kCATransition)
//                                    
//                                    self.present(nvc, animated: false, completion: {
//                                        UserDefaults.standard.set("", forKey: "Came From")
//                                        
//                                    })
//                                    
//                                    
//                                })
//                            }else {
//                            let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/\(((UserDefaults.standard.value(forKey: "PreviousBeaconArray")) as! NSArray)[0] as! String)")!
//                            
//                            let session = URLSession.shared
//                            let request = NSMutableURLRequest (url: url as URL)
//                            request.httpMethod = "Get"
//                            
//                            request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
//                            
//                            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
//                                if let data = data {
//                                    
//                                    let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
//                                        //print(re)
//                                    ResidentDetails.response = re
//                                    DispatchQueue.main.async( execute: {
//                                        let reDirectingVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
// 
//                                        self.locationManager.stopMonitoring(for: self.region)
//                                        self.locationManager.stopRangingBeacons(in: self.region)
//                                        let transition = CATransition()
//                                        transition.duration = 0.3
//                                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                                        transition.type = kCATransitionMoveIn
//                                        transition.subtype = kCATransitionFromLeft
//                                        self.view.window!.layer.add(transition, forKey: kCATransition)
//                                        
//                                        self.present(reDirectingVC, animated: false, completion: {
//
//                                        })
//                                        
//                                        
//                                    })
//                                }
//                            }
//                            task.resume()
//                            }
//                        }
//                    })
//                    task.resume()
//
//                }
//                ResidentDetails.storedCares.removeAll()
//            }
//
//            let cancelButton = CancelButton(title: "Yes") {
//                
//                let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:indexpath!) as! ResidentSelectTestTableViewCell
//                if self.openVisitsArray.contains(cell.careNameLabel.text! as NSString) {
//                    self.openVisitsArray.remove(cell.careNameLabel.text! as NSString)
//                    self.performedVisitsArray.add(cell.careNameLabel.text! as NSString)
//                }else{
//                    self.performedVisitsArray.add(cell.careNameLabel.text! as NSString)
//                }
//                    
//                self.RightSwipe = false
//                cell.rightArrowBtn.isHidden = false
//                    
//                UIView.animate(withDuration: 0.3, animations: {
//                    cell.caresView.frame = CGRect(x: -cell.contentView.frame.width/3, y: 0, width: cell.contentView.frame.width/0.75, height: cell.caresView.frame.size.height)
//                        cell.caresView.backgroundColor = UIColor.clear
//                    if self.residentDetailsStr == "Edward J.310" {
//                        cell.visitStatusImage.image = UIImage(named: "scheduledPerformedVisitIcon")
//                    }else{
//                        cell.visitStatusImage.image = UIImage(named: "performedVisitIcon")
//                    }
//                    cell.visitStatusImage.frame =  CGRect(x: cell.contentView.frame.width/2.586, y: cell.contentView.frame.height/3.142, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/2.933)
//                    cell.careImage.frame = CGRect(x: cell.contentView.frame.width/2.130, y: CGFloat(cell.careImage.frame.origin.y), width: CGFloat(cell.careImage.frame.width), height: CGFloat(cell.careImage.frame.height))
//                    cell.careNameLabel.frame = CGRect(x: cell.contentView.frame.width/1.644, y: CGFloat(cell.careNameLabel.frame.origin.y), width: CGFloat(cell.careNameLabel.frame.width), height: CGFloat(cell.careNameLabel.frame.height))
//                    cell.rightArrowBtn.frame = CGRect(x: cell.contentView.frame.width/0.815, y: CGFloat(cell.rightArrowBtn.frame.origin.y), width: CGFloat(cell.rightArrowBtn.frame.width), height: CGFloat(cell.rightArrowBtn.frame.height))
//                }, completion: {(finished) -> Void in
//                    cell.caresView.addSubview(cell.visitStatusImage)
//                })
//                
//                let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
//                        
//                        
//                let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray
//                        
//                let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
//                        
//                var resident_ID = String()
//                for i in 0..<residents.count {
//                    let residentDetails = residents[i] as! NSDictionary
//                    let name : String = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
//                    if name == UserDefaults.standard.value(forKey: "nameRoom") as! String {
//                        resident_ID = residentDetails.value(forKey: "_id") as! String
//                    }
//                }
//                let roomId = residentRoom.value(forKey: "_id") as! String
//                        
//                var careNames = [String]()
//                careNames.append(cell.careNameLabel.text!)
//                        
//                var careIds = NSDictionary()
//                        
//                let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
//                        
//                if let careIDs = careIDs {
//                    careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
//                }
//                        
//                let care_Id = careIds.value(forKey: careNames[0]) as! String
//                        
//                let care_Value = self.careQuickSelect["\(careNames[0])"]!
//                        
//                var param = NSMutableDictionary()
//                if ResidentDetails.openCareIDsArray.contains(care_Id){
//                    var id = String()
//                    let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
//                    for i in 0..<openVisits.count{
//                        if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
//                            id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
//                        }
//                    }
//                    param = ["_id":id,
//                                     "user_id": user_Id,
//                                     "room_id": roomId,
//                                     "resident_id": resident_ID,
//                                     "care_id": care_Id,
//                                     "care_value": care_Value,
//                                     "care_notes": "",
//                                     "care_type": "Track",
//                                     "care_status": "Closed",
//                                     "time_track": ""
//                                
//                            ]
//                }else{
//                    param = ["user_id": user_Id,
//                                     "room_id": roomId,
//                                     "resident_id": resident_ID,
//                                     "care_id": care_Id,
//                                     "care_value": care_Value,
//                                     "care_notes": "",
//                                     "care_type": "Track",
//                                     "care_status": "Closed",
//                                     "time_track": ""
//                                
//                            ]
//                }
//                if ResidentDetails.storedCares.count > 0 {
//                    var elementIndex = [Int]()
//                    for i in 0..<ResidentDetails.storedCares.count{
//                        let element = ResidentDetails.storedCares[i]
//                        if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
//                                elementIndex = [i]
//                        }
//                    }
//                    if elementIndex.count > 0 {
//                        ResidentDetails.storedCares.remove(at: elementIndex[0])
//                            
//                        ResidentDetails.storedCares.append(param)
//                            
//                    }else{
//                        ResidentDetails.storedCares.append(param)
//                    }
//                }else{
//                    ResidentDetails.storedCares.append(param)
//                }
//                    
//                
//                print(ResidentDetails.storedCares)
//                let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
//                
//                self.locationManager.stopMonitoring(for: self.region)
//                
//                self.locationManager.stopRangingBeacons(in: self.region)
//                
//                let transition = CATransition()
//                
//                transition.duration = 0.3
//                
//                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                
//                transition.type = kCATransitionMoveIn
//                
//                transition.subtype = kCATransitionFromLeft
//                
//                self.view.window!.layer.add(transition, forKey: kCATransition)
//                // to check any performed visits
//                
//                self.present(nvc, animated: false, completion: {
//                    
//                })
//                
//            }
//        
//            popup.addButtons([cancelButton,okButton])
//            //Present dialog
//            self.present(popup, animated: true, completion: nil)
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
        transition.duration = 0.3
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
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("CareSelectViewController", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(MenuVC, animated: false, completion: nil)
 
    }
    @IBAction func backButton(_ sender: Any) {
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        cancelBtn.isUserInteractionEnabled = false
        backBtn.isUserInteractionEnabled = false
        if UserDefaults.standard.value(forKey: "Came From") as? String == "DashBoardViewController"{
            UserDefaults.standard.removeObject(forKey: "Came From")
            let DBVC = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            view.window!.layer.add(transition, forKey: kCATransition)

            self.present(DBVC, animated: false, completion: {
                UserDefaults.standard.set("", forKey: "Came From")
            })
   
        }else if UserDefaults.standard.value(forKey: "Came From") as? String == "RecentVisitsViewController"{
            
            UserDefaults.standard.removeObject(forKey: "Came From")
            let RVVC = self.storyboard?.instantiateViewController(withIdentifier: "RecentVisitsViewController") as! RecentVisitsViewController
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            view.window!.layer.add(transition, forKey: kCATransition)

            self.present(RVVC, animated: false, completion: {
                UserDefaults.standard.set("", forKey: "Came From")
            })

        }else{
            let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
            if previousBeaconArray.count == 0 {
                
                let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                self.view.window!.layer.add(transition, forKey: kCATransition)
                
                self.present(RSVC, animated: false, completion: {
                    self.cancelBtn.isUserInteractionEnabled = true
                    self.backBtn.isUserInteractionEnabled = true

                    UserDefaults.standard.set("", forKey: "Came From")
                    
                })
                
            }else{
                let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/\(((UserDefaults.standard.value(forKey: "PreviousBeaconArray")) as! NSArray)[0] as! String)")!
                
                let session = URLSession.shared
                let request = NSMutableURLRequest (url: url as URL)
                request.httpMethod = "Get"
                
                request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                
                let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                    if let data = data {
                        
                        let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                        //print(re)
                        ResidentDetails.response = re
                        DispatchQueue.main.async( execute: {
                            let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromLeft
                            self.view.window!.layer.add(transition, forKey: kCATransition)
                            
                            self.present(RSVC, animated: false, completion: {
                                
                                self.cancelBtn.isUserInteractionEnabled = true
                                self.backBtn.isUserInteractionEnabled = true

                                UserDefaults.standard.set("", forKey: "Came From")
                                
                            })
                            
                        })
                    }
                }
                task.resume()
  
            }

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
            let array = ["major": (knownBeacons[0]).major.stringValue ,"minor": (knownBeacons[0]).minor.stringValue,"rssi":(knownBeacons[0]).rssi] as [String : Any]
            
            Constants.nearBeacon = ["major":(knownBeacons[0]).major.intValue,"minor":(knownBeacons[0]).minor.intValue]

            Constants.rssiArray.add(array)
            if Constants.rssiArray.count == 1 {
                print(Constants.rssiArray)
                
                var Counting : [NSDictionary : Int] = [:]
                for items in Constants.rssiArray {
                    
                    let val = items as! [String:Any]
                    let storeValues = ["major":val["major"]!,"minor":val["minor"]!] as NSDictionary
                    Counting[storeValues] = (Counting[storeValues] ?? 0) + 1
                    
                }
                
                let heighRepeat = Counting.max { a, b in a.value < b.value }
                print("heigh \((heighRepeat)!))")
                var totalRSSIArray = [Int]()
                let dic = heighRepeat?.key
                for element in Constants.rssiArray {
                    let val = element as! [String:Any]
                    let compareString = "\(val["major"]!) \(val["minor"]!)"
                    let otherString = "\(dic?.value(forKey: "major") as! String) \(dic?.value(forKey: "minor") as! String)"
                    if compareString == otherString {
                        totalRSSIArray.append(val["rssi"]! as! Int)
                    }
                }
                print(totalRSSIArray)
                let sum = totalRSSIArray.reduce(0, +)
                let finalRSSI : Double = Double(Double(sum)/Double((heighRepeat?.value)!))
                
            
            let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
            if previousBeaconArray.count == 0 {
                
                print("final \(finalRSSI)")
                let base = Double(10)
                let power = Double(Constants.roomRSSI-(finalRSSI))/Double(10*2)
                let dis = pow(Double(base), power)
                print(dis)

               if dis <= Constants.roomRange  {
                            
                    let beaconsData = UserDefaults.standard.object(forKey: "Beacons_List") as? NSData
                            
                    if let beaconsData = beaconsData {
                        beaconsArray = (NSKeyedUnarchiver.unarchiveObject(with: beaconsData as Data) as? NSArray)!
                    }
                    var myBeacon = String()
                            
                    for i in 0..<beaconsArray.count {
                                
                        let aaaaaaa = beaconsArray[i] as! NSDictionary
                                
                        let majorStr = aaaaaaa.value(forKey: "major") as! String
                                
                        let major = Int(majorStr)
                                
                        let minorStr = aaaaaaa.value(forKey: "minor") as! String
                                
                        let minor = Int(minorStr)
                        
                        let beaconMajor = Int(dic?.value(forKey: "major") as! String)
                        
                        let beaconMinor = Int(dic?.value(forKey: "minor") as! String)

                        if major == beaconMajor && minor == beaconMinor{
                            myBeacon = aaaaaaa.value(forKey: "type") as! String
                            responseBeacon = aaaaaaa
                                    
                                    
                        }
                    }
                            
                if myBeacon == "room"{
                    Service.sharedInstance.batteryLevel(beaconsWithBattery: Constants.beaconsWithPercentages)

                    if Times.Left_Time.count > 0{
                        
                        
                        let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
                        
                        let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
                        
                        let roomId = residentRoom.value(forKey: "_id") as! String
                        
                        var startedTime = Date()
                        
                        if Times.Previous_End_Time.count > 0 {
                            startedTime = Times.Previous_End_Time[0]
                        }else{
                            startedTime = Times.Constant_Start_Time
                        }
                        let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
                        var endTime = Date()
                        
                        if previousBeaconArray.count == 0 {
                            endTime = Times.Leaving_Time
                        }
                        var param = [String:Any]()
                        param = ["user_id": user_Id,
                                 "room_id": roomId,
                                 "resident_id": "",
                                 "care_id": "",
                                 "care_value": "",
                                 "care_notes": "",
                                 "care_type": "UnTrack",
                                 "care_status": "Closed",
                                 "time_track": ["start_time":"\(startedTime)",
                                    "end_time":"\(endTime)"]
                            
                        ]
                        
                        let parameters = [param]
                        
                        //create the url with URL
                        let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")! //change the url
                        
                        //create the session object
                        let session = URLSession.shared
                        
                        //now create the URLRequest object using the url object
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST" //set http method as POST
                        
                        do {
                            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                        } catch let error {
                            print(error.localizedDescription)
                        }
                        
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                        
                        //create dataTask using the session object to send data to the server
                        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                            
                            guard error == nil else {
                                return
                            }
                            guard let data = data else {
                                return
                            }
                            
                            do {
                                //create json object from data
                                _ = try! JSONSerialization.jsonObject(with: data, options: [])
                                
                                Times.Previous_End_Time.removeAll()
                                
                                UserDefaults.standard.set([self.responseBeacon.value(forKey: "_id")], forKey: "PreviousBeaconArray")
                                
                                self.popup.dismiss(animated: true, completion: {
                                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    self.timer?.invalidate()
                                })// comletion of popup
                                
                                self.locationManager.stopRangingBeacons(in: region)
                                self.locationManager.stopMonitoring(for: region)
                                
                                let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/\(self.responseBeacon.value(forKey: "_id")!)")!
                                
                                let session = URLSession.shared
                                let request = NSMutableURLRequest (url: url as URL)
                                request.httpMethod = "Get"
                                
                                request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                                
                                let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                                    if let data = data {
                                        
                                        let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                                        ResidentDetails.response = re
                                        
                                        print(re)
                                        
                                        DispatchQueue.main.async( execute: {
                                            
                                            //let beaconsData = NSKeyedArchiver.archivedData(withRootObject: re)
                                            
                                            //UserDefaults.standard.set(beaconsData, forKey: "Residents_List")
                                            
                                            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                            Times.Left_Time.removeAll()
                                            let transition = CATransition()
                                            transition.duration = 0.3
                                            transition.type = kCATransitionPush
                                            transition.subtype = kCATransitionFromRight
                                            self.view.window!.layer.add(transition, forKey: kCATransition)
                                            
                                            let startDate = Date()
        
                                            
                                            Times.Constant_Start_Time = startDate
                                            do {
                                                self.audioPlayer = try! AVAudioPlayer.init(contentsOf: self.roomUrl!)
                                                self.audioPlayer.prepareToPlay()
                                                
                                            }
                                            
                                            self.audioPlayer.play()
                                            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                            
                                            self .present(nvc, animated: false, completion: {
                                                UserDefaults.standard.set("", forKey: "Came From")
                                            })// completion of self.present
                                            
                                        })
                                    }
                                }
                                task.resume()
                                
                            }
                        })
                        task.resume()
                        timer?.invalidate()
                        
                        
                    }else{
                        
                        
                        Times.Previous_End_Time.removeAll()
                        
                        UserDefaults.standard.set([responseBeacon.value(forKey: "_id")], forKey: "PreviousBeaconArray")
                        
                        popup.dismiss(animated: true, completion: {
                            UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                            self.timer?.invalidate()
                        })// comletion of popup
                        
                        locationManager.stopRangingBeacons(in: region)
                        locationManager.stopMonitoring(for: region)
                        
                        let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/\(responseBeacon.value(forKey: "_id")!)")!
                        
                        let session = URLSession.shared
                        let request = NSMutableURLRequest (url: url as URL)
                        request.httpMethod = "Get"
                        
                        request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                        
                        let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                            if let data = data {
                                
                                let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                                ResidentDetails.response = re
                                
                                print(re)
                                
                                DispatchQueue.main.async( execute: {
                                    
                                    //let beaconsData = NSKeyedArchiver.archivedData(withRootObject: re)
                                    
                                    //UserDefaults.standard.set(beaconsData, forKey: "Residents_List")
                                    
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    
                                    let transition = CATransition()
                                    transition.duration = 0.3
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromRight
                                    self.view.window!.layer.add(transition, forKey: kCATransition)
                                    
                                    let startDate = Date()

                                    
                                    Times.Constant_Start_Time = startDate
                                    do {
                                        self.audioPlayer = try! AVAudioPlayer.init(contentsOf: self.roomUrl!)
                                        self.audioPlayer.prepareToPlay()
                                        
                                    }
                                    
                                    self.audioPlayer.play()
                                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                    
                                    self .present(nvc, animated: false, completion: {
                                        UserDefaults.standard.set("", forKey: "Came From")
                                    })// completion of self.present
                                    
                                })
                            }
                        }
                        task.resume()
                    }
                }
                }
                
                
            }else{
                print("final \(finalRSSI)")
                let base = Double(10)
                let power = Double(Constants.hallwayRSSI-(finalRSSI))/Double(10*2)
                let dis = pow(Double(base), power)
                print(dis)

               if dis <= Constants.hallwayRange  {
                
                    let beaconsData = UserDefaults.standard.object(forKey: "Beacons_List") as? NSData
                
                    if let beaconsData = beaconsData {
                        beaconsArray = (NSKeyedUnarchiver.unarchiveObject(with: beaconsData as Data) as? NSArray)!
                    }
                    var otherBeacon = String()
                    for i in 0..<beaconsArray.count {
                        
                        let aaaaaaa = beaconsArray[i] as! NSDictionary
                        
                        
                        let majorStr = aaaaaaa.value(forKey: "major") as! String
                        
                        let major = Int(majorStr)
                        
                        let minorStr = aaaaaaa.value(forKey: "minor") as! String
                        
                        let minor = Int(minorStr)
                        
                        let beaconMajor = Int(dic?.value(forKey: "major") as! String)
                        
                        let beaconMinor = Int(dic?.value(forKey: "minor") as! String)

                        if major == beaconMajor && minor == beaconMinor{

                            otherBeacon = aaaaaaa.value(forKey: "type") as! String
                        }
                    }
                    
                    if otherBeacon == "hallway" {

                        print(" care After")
                        UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                        let msg = "Are you finished with your visit or are you continuing care?"
                        let attString = NSMutableAttributedString(string: msg)
                            
                        popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                                
                        })

                        let pauseButton = CancelButton(title: "Pause", action: {
                           
                            self.timer?.invalidate()

                            UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                            let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                            RSVC.alertForPause = true
                            
                            self.locationManager.stopMonitoring(for: region)
                            self.locationManager.stopRangingBeacons(in: region)
                            RSVC.alertForPause = true
                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromLeft
                            self.view.window!.layer.add(transition, forKey: kCATransition)
                            
                            self.present(RSVC, animated: false, completion: {
                                UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                            })
                            
                            
                        })
                        
                        let continueButton = CancelButton(title: "Continue", action: {
                            
                            self.timer?.invalidate()
                            UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                            let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                            self.locationManager.stopMonitoring(for: region)
                            self.locationManager.stopRangingBeacons(in: region)
                            RSVC.alertForContinue = true
                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromLeft
                            self.view.window!.layer.add(transition, forKey: kCATransition)
                            self.present(RSVC, animated: false, completion: {
                                UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                            })
                            
                        })
                        let completeButton = CancelButton(title: "Complete") {

                            UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                            
                            self.timer?.invalidate()
                            
                            let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                            self.locationManager.stopMonitoring(for: region)
                            self.locationManager.stopRangingBeacons(in: region)
                            
                            RSVC.alertForComplete = true
                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromRight
                            self.view.window!.layer.add(transition, forKey: kCATransition)
                            
                            self.present(RSVC, animated: false, completion: {
                                UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                            })
                            
                        }


                        
                        let deleteButton = CancelButton(title: "Done", action: {
                            let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
                            
                            self.timer?.invalidate()
                            
                            let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
                            
                            let roomId = residentRoom.value(forKey: "_id") as! String
                            
                            
                            var startedTime = Date()
                            
                            if Times.Previous_End_Time.count > 0 {
                                startedTime = Times.Previous_End_Time[0]
                            }else{
                                startedTime = Times.Constant_Start_Time
                            }
                            
                            var param = [String:Any]()
                            param = ["user_id": user_Id,
                                     "room_id": roomId,
                                     "resident_id": "",
                                     "care_id": "",
                                     "care_value": "",
                                     "care_notes": "",
                                     "care_type": "UnTrack",
                                     "care_status": "Closed",
                                     "time_track": ["start_time":"\(startedTime)",
                                        "end_time":"\(Date())"]
                                
                            ]
                            
                            let parameters = [param]
                            
                            //create the url with URL
                            let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")! //change the url
                            
                            //create the session object
                            let session = URLSession.shared
                            
                            //now create the URLRequest object using the url object
                            var request = URLRequest(url: url)
                            request.httpMethod = "POST" //set http method as POST
                            
                            do {
                                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                            } catch let error {
                                print(error.localizedDescription)
                            }
                            
                            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                            request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                            
                            //create dataTask using the session object to send data to the server
                            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                                
                                guard error == nil else {
                                    return
                                }
                                
                                guard let data = data else {
                                    return
                                }
                                
                                do {
                                    //create json object from data
                                    _ = try! JSONSerialization.jsonObject(with: data, options: [])
                                    
                                    DispatchQueue.main.async( execute: {
                                        
                                        let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                        self.locationManager.stopMonitoring(for: self.region)
                                        self.locationManager.stopRangingBeacons(in: self.region)
                                        let transition = CATransition()
                                        transition.duration = 0.3
                                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                        transition.type = kCATransitionMoveIn
                                        transition.subtype = kCATransitionFromLeft
                                        self.view.window!.layer.add(transition, forKey: kCATransition)
                                        
                                        self.present(nvc, animated: false, completion: {
                                            UserDefaults.standard.set("", forKey: "Came From")
                                            UserDefaults.standard.set([], forKey: "HallwayBeaconArray")

                                        })
                                    })
                                }
                            })
                            task.resume()
                        })
                        
                        popup.addButtons([pauseButton,continueButton,completeButton,deleteButton])
                        
                        let hallwayBeaconArray : [Int] = UserDefaults.standard.value(forKey: "HallwayBeaconArray") as! [Int]
                        if hallwayBeaconArray.count == 0{
                            if Times.Previous_End_Time.count > 0{
                                let timeGap = Date().timeIntervalSince(Times.Previous_End_Time[0])
                                if timeGap > 15 {
                                    Times.Leaving_Time = Date()
                                    Times.Left_Time = [Date()]
                                    UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                                    do {
                                        self.audioPlayer = try! AVAudioPlayer.init(contentsOf: self.hallwayUrl!)
                                        self.audioPlayer.prepareToPlay()
                                        
                                    }
                                    
                                    self.audioPlayer.play()
                                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                    
                                    self.present(popup, animated: true, completion: {
                                        
                                        UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                        
                                        UserDefaults.standard.set([Int(dic?.value(forKey: "major") as! String)], forKey: "HallwayBeaconArray")
                                        
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set("", forKey: "Came From")
                                        //self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: true)

                                    })
                                    
                                }else{
                                    let DVC = storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                    locationManager.stopRangingBeacons(in: region)
                                    locationManager.stopMonitoring(for: region)
                                    let transition = CATransition()
                                    transition.duration = 0.3
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    view.window!.layer.add(transition, forKey: kCATransition)
                                    do {
                                        self.audioPlayer = try! AVAudioPlayer.init(contentsOf: self.hallwayUrl!)
                                        self.audioPlayer.prepareToPlay()
                                        
                                    }
                                    
                                    self.audioPlayer.play()
                                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                    
                                    self.present(DVC, animated: false, completion: nil)
                                    
                                }
                                
                            }else{
                                let timeGap = Date().timeIntervalSince(Times.Constant_Start_Time)
                                if timeGap > 15 {
                                    Times.Leaving_Time = Date()
                                    Times.Left_Time = [Date()]

                                    UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                                    do {
                                        self.audioPlayer = try! AVAudioPlayer.init(contentsOf: self.hallwayUrl!)
                                        self.audioPlayer.prepareToPlay()
                                        
                                    }
                                    
                                    self.audioPlayer.play()
                                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                    
                                    self.present(popup, animated: true, completion: {
                                        
                                        UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                        
                                        UserDefaults.standard.set([Int(dic?.value(forKey: "major") as! String)], forKey: "HallwayBeaconArray")
                                        
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set("", forKey: "Came From")
                                        //self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: true)

                                    })
                                    
                                }else {
                                    let DVC = storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                    locationManager.stopRangingBeacons(in: region)
                                    locationManager.stopMonitoring(for: region)
                                    let transition = CATransition()
                                    transition.duration = 0.3
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    view.window!.layer.add(transition, forKey: kCATransition)
                                    do {
                                        self.audioPlayer = try! AVAudioPlayer.init(contentsOf: self.hallwayUrl!)
                                        self.audioPlayer.prepareToPlay()
                                        
                                    }
                                    
                                    self.audioPlayer.play()
                                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                    
                                    self.present(DVC, animated: false, completion: nil)
                                    
                                }
                            }
                        }
            }
                    }
                }
                Constants.rssiArray.removeObject(at: 0)

            }
    }
    }


    @IBAction func doneButtonAction(_ sender: Any) {
        self.forMultipleResidents()
    }
    
    
    func forMultipleResidents(){
        
        if performedArray.count > 0 || pauseArray.count > 0 {
            var endTime = Date()
            
            let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
            if previousBeaconArray.count == 0 {
                endTime = Times.Leaving_Time
            }
            let vc  = AlertViewController()
            vc.delegate = self
            if Times.Previous_End_Time.count > 0 {
                
                vc.counter = Int(endTime.timeIntervalSince(Times.Previous_End_Time[0]))
                vc.startTime = Times.Previous_End_Time[0]
                
            }else{
                vc.counter = Int(endTime.timeIntervalSince(Times.Constant_Start_Time))
                vc.startTime = Times.Constant_Start_Time
                
            }
            vc.screenFrame = self.view.frame
            vc.done = true
            vc.residentName = self.residentDetails.text!
            
            self.present(vc, animated: true, completion: {
            })

        }else{
            let msg = "Please select a care to perform"

            let attString = NSMutableAttributedString(string: msg)
    
            let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
            }

            let okButton = DefaultButton(title: "OK") {

            }
            popup.addButtons([okButton])
            
            self.present(popup, animated: true, completion: nil)

        }
    }
    func pauseButton(actionButton: String) {
        if actionButton == "No" {
            let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:pauseArray[0] as! IndexPath) as! ResidentSelectTestTableViewCell
        
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

            if UserDefaults.standard.value(forKey: "Came From") as! String == "DashBoardViewController" {
                
                let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
                
                if previousBeaconArray.count == 0{
                    
                }else{
                    
                    
                }
            }else{
                let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
                
                let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
                
                let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
                
                let resident_ID = UserDefaults.standard.value(forKey: "resident_id") as! String

                let roomId = residentRoom.value(forKey: "_id") as! String
                
                var careNames = [String]()
                for i in 0..<self.pauseArray.count {
                    let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:(self.pauseArray[i] as! IndexPath)) as! ResidentSelectTestTableViewCell
                    careNames.append(cell.careNameLabel.text!)
                }
                var careIds = NSDictionary()
                
                let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                
                if let careIDs = careIDs {
                    careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                }
                
                let care_Id = careIds.value(forKey: careNames[0]) as! String
                
                let care_Value = self.careQuickSelect["\(careNames[0])"]!
                
                
                var param = NSMutableDictionary()
                if ResidentDetails.openCareIDsArray.contains(care_Id){
                    var id = String()
                    let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
                    for i in 0..<openVisits.count{
                        if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
                            id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
                        }
                    }
                    param = ["_id":id,
                             "user_id": user_Id,
                             "room_id": roomId,
                             "resident_id": resident_ID,
                             "care_id": care_Id,
                             "care_value": care_Value,
                             "care_notes": "",
                             "care_type": "Track",
                             "care_status": "Open",
                             "time_track": ""
                    ]
                }else{
                    param = ["user_id": user_Id,
                             "room_id": roomId,
                             "resident_id": resident_ID,
                             "care_id": care_Id,
                             "care_value": care_Value,
                             "care_notes": "",
                             "care_type": "Track",
                             "care_status": "Open",
                             "time_track": ""
                    ]
                }
                if ResidentDetails.storedCares.count > 0 {
                    var elementIndex = [Int]()
                    for i in 0..<ResidentDetails.storedCares.count{
                        let element = ResidentDetails.storedCares[i]
                        if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
                            elementIndex = [i]
                        }else{
                            
                        }
                    }
                    if elementIndex.count > 0 {
                        ResidentDetails.storedCares.remove(at: elementIndex[0])
                        
                        ResidentDetails.storedCares.append(param)
                        
                    }else{
                        ResidentDetails.storedCares.append(param)
                    }
                }else{
                    ResidentDetails.storedCares.append(param)
                }
                
                print(ResidentDetails.storedCares)
                var defaultTimesArray = [Int]()
                
                for i in 0..<ResidentDetails.storedCares.count {
                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                    
                    defaultTimesArray.append(self.deafaultTimesForCares.value(forKey: careName.first as! String) as! Int)
                    
                    
                }
                let min = defaultTimesArray.min()
                
                var timeRatios: [Int] = []
                for value in defaultTimesArray { timeRatios.append(value/min!) }
                
                let sumOfTimeRatios = timeRatios.reduce(0, +)
                
                var startTime = Date()
                if Times.Previous_End_Time.count > 0 {
                    startTime = Times.Previous_End_Time[0]
                }else{
                    startTime = Times.Constant_Start_Time
                }
                
                var endTime = Date()
                
                if previousBeaconArray.count == 0 {
                    endTime = Times.Leaving_Time
                }
                
                Times.Previous_End_Time = [endTime]
                let totalTime = Int(endTime.timeIntervalSince(startTime))
                
                let onePartOfTime = totalTime/sumOfTimeRatios
                
                var timesWithRespectToRatios : [Int] = []
                
                for value in timeRatios {
                    timesWithRespectToRatios.append(value*onePartOfTime)
                }
                
                let careTimesDictionary = NSMutableDictionary()
                
                for i in 0..<ResidentDetails.storedCares.count {
                    if i == 0 {
                        
                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let end_time = startTime.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
                        careTimesDictionary.setValue(["start_time":startTime,"end_time":end_time], forKey: careName.first as! String)
                        
                    }else {
                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let beforeCareName = careIds.allKeys(for: (ResidentDetails.storedCares[i-1] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let times_array = careTimesDictionary.value(forKey: beforeCareName.first as! String) as! NSDictionary
                        
                        let start_time = times_array.value(forKey: "end_time") as! Date
                        
                        let end_time = start_time.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
                        
                        careTimesDictionary.setValue(["start_time":start_time,"end_time":end_time], forKey: careName.first as! String)
                        
                    }
                }
                for i in 0..<ResidentDetails.storedCares.count {
                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                    
                    let careTimes = careTimesDictionary.value(forKey: careName.first as! String) as! NSDictionary
                    
                    (ResidentDetails.storedCares[i] as NSMutableDictionary).setValue(["start_time":"\(careTimes.value(forKey: "start_time") as! Date)","end_time":"\(careTimes.value(forKey: "end_time") as! Date)"], forKeyPath: "time_track")
                }
                print(ResidentDetails.storedCares)
                
                Times.Previous_End_Time = [Date()]
                
                //create the url with URL
                let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")! //change the url
                
                //create the session object
                let session = URLSession.shared
                
                //now create the URLRequest object using the url object
                var request = URLRequest(url: url)
                request.httpMethod = "POST" //set http method as POST
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: ResidentDetails.storedCares, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                } catch let error {
                    print(error.localizedDescription)
                }
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                
                //create dataTask using the session object to send data to the server
                let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    
                    guard error == nil else {
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    do {
                        //create json object from data
                        _ = try! JSONSerialization.jsonObject(with: data, options: [])
                        if previousBeaconArray.count == 0{
                            DispatchQueue.main.async( execute: {
                                
                                let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                self.locationManager.stopMonitoring(for: self.region)
                                self.locationManager.stopRangingBeacons(in: self.region)
                                let transition = CATransition()
                                transition.duration = 0.3
                                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                transition.type = kCATransitionMoveIn
                                transition.subtype = kCATransitionFromLeft
                                self.view.window!.layer.add(transition, forKey: kCATransition)
                                
                                self.present(nvc, animated: false, completion: {
                                    UserDefaults.standard.set("", forKey: "Came From")
                                    
                                })
                                
                                
                            })
                            
                        }else {
                            let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/\(((UserDefaults.standard.value(forKey: "PreviousBeaconArray")) as! NSArray)[0] as! String)")!
                            
                            let session = URLSession.shared
                            let request = NSMutableURLRequest (url: url as URL)
                            request.httpMethod = "Get"
                            
                            request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                            
                            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                                if let data = data {
                                    
                                    let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                                    //print(re)
                                    ResidentDetails.response = re
                                    DispatchQueue.main.async( execute: {
                                        let reDirectingVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                        
                                        self.locationManager.stopMonitoring(for: self.region)
                                        self.locationManager.stopRangingBeacons(in: self.region)
                                        let transition = CATransition()
                                        transition.duration = 0.3
                                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                        transition.type = kCATransitionMoveIn
                                        transition.subtype = kCATransitionFromLeft
                                        self.view.window!.layer.add(transition, forKey: kCATransition)
                                        
                                        self.present(reDirectingVC, animated: false, completion: {
                                            
                                        })
                                        
                                        
                                    })
                                }
                            }
                            task.resume()
                        }
                    }
                })
                task.resume()
            }
            ResidentDetails.storedCares.removeAll()
        }else if actionButton == "Yes" {
            
            let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:pauseArray[0] as! IndexPath) as! ResidentSelectTestTableViewCell
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

            let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
            
            let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
            
            let resident_ID = UserDefaults.standard.value(forKey: "resident_id") as! String

            let roomId = residentRoom.value(forKey: "_id") as! String
            
            var careNames = [String]()
            for i in 0..<self.pauseArray.count {
                let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:(self.pauseArray[i] as! IndexPath)) as! ResidentSelectTestTableViewCell
                careNames.append(cell.careNameLabel.text!)
            }
            
            var careIds = NSDictionary()
            
            let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
            
            if let careIDs = careIDs {
                careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
            }
            
            let care_Id = careIds.value(forKey: careNames[0]) as! String
            
            let care_Value = self.careQuickSelect["\(careNames[0])"]!
            
            var param = NSMutableDictionary()
            if ResidentDetails.openCareIDsArray.contains(care_Id){
                var id = String()
                let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
                for i in 0..<openVisits.count{
                    if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
                        id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
                    }
                }
                param = ["_id":id,
                         "user_id": user_Id,
                         "room_id": roomId,
                         "resident_id": resident_ID,
                         "care_id": care_Id,
                         "care_value": care_Value,
                         "care_notes": "",
                         "care_type": "Track",
                         "care_status": "Open",
                         "time_track": ""
                    
                ]
            }else{
                param = ["user_id": user_Id,
                         "room_id": roomId,
                         "resident_id": resident_ID,
                         "care_id": care_Id,
                         "care_value": care_Value,
                         "care_notes": "",
                         "care_type": "Track",
                         "care_status": "Open",
                         "time_track": ""
                    
                ]
            }
            if ResidentDetails.storedCares.count > 0 {
                var elementIndex = [Int]()
                for i in 0..<ResidentDetails.storedCares.count{
                    let element = ResidentDetails.storedCares[i]
                    if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
                        elementIndex = [i]
                    }
                }
                if elementIndex.count > 0 {
                    ResidentDetails.storedCares.remove(at: elementIndex[0])
                    
                    ResidentDetails.storedCares.append(param)
                    
                }else{
                    ResidentDetails.storedCares.append(param)
                }
            }else{
                ResidentDetails.storedCares.append(param)
            }
            
            print(ResidentDetails.storedCares)
            self.deselect(index: pauseArray[0] as! IndexPath)

            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
            
            self.locationManager.stopMonitoring(for: self.region)
            
            self.locationManager.stopRangingBeacons(in: self.region)
            
            let transition = CATransition()
            
            transition.duration = 0.3
            
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            transition.type = kCATransitionMoveIn
            
            transition.subtype = kCATransitionFromLeft
            
            self.view.window!.layer.add(transition, forKey: kCATransition)
            // to check any performed visits
            
            self.present(nvc, animated: false, completion: {
                
            })
   
        }else if actionButton == "Cancel" {
            self.deselect(index: pauseArray[0] as! IndexPath)
        }
 
    }
    func performButton(actionButton: String) {
        if actionButton == "No"{
            
            let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:performedArray[0] as! IndexPath) as! ResidentSelectTestTableViewCell
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
            if UserDefaults.standard.value(forKey: "Came From") as! String == "DashBoardViewController" {
                
                let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
                if previousBeaconArray.count == 0{
                    
                }else{
                    
                }
            }else{
                let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
                
                let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
                
                let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
                
                let resident_ID = UserDefaults.standard.value(forKey: "resident_id") as! String

                let roomId = residentRoom.value(forKey: "_id") as! String
                
                var careNames = [String]()
                careNames.append(cell.careNameLabel.text!)
                
                var careIds = NSDictionary()
                
                let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                
                if let careIDs = careIDs {
                    careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                }
                
                let care_Id = careIds.value(forKey: careNames[0]) as! String
                
                let care_Value = self.careQuickSelect["\(careNames[0])"]!
                
                var param = NSMutableDictionary()
                if ResidentDetails.openCareIDsArray.contains(care_Id){
                    var id = String()
                    let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
                    
                    for i in 0..<openVisits.count{
                        if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
                            id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
                        }
                    }
                    param = ["_id":id,
                             "user_id": user_Id,
                             "room_id": roomId,
                             "resident_id": resident_ID,
                             "care_id": care_Id,
                             "care_value": care_Value,
                             "care_notes": "",
                             "care_type": "Track",
                             "care_status": "Closed",
                             "time_track": ""
                        
                    ]
                }else{
                    param = ["user_id": user_Id,
                             "room_id": roomId,
                             "resident_id": resident_ID,
                             "care_id": care_Id,
                             "care_value": care_Value,
                             "care_notes": "",
                             "care_type": "Track",
                             "care_status": "Closed",
                             "time_track": ""
                        
                    ]
                }
                
                if ResidentDetails.storedCares.count > 0 {
                    var elementIndex = [Int]()
                    for i in 0..<ResidentDetails.storedCares.count{
                        let element = ResidentDetails.storedCares[i]
                        if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
                            elementIndex = [i]
                        }else{
                            
                        }
                    }
                    if elementIndex.count > 0 {
                        ResidentDetails.storedCares.remove(at: elementIndex[0])
                        
                        ResidentDetails.storedCares.append(param)
                        
                    }else{
                        ResidentDetails.storedCares.append(param)
                    }
                }else{
                    ResidentDetails.storedCares.append(param)
                }
                
                print(ResidentDetails.storedCares)
                var defaultTimesArray = [Int]()
                
                for i in 0..<ResidentDetails.storedCares.count {
                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                    
                    defaultTimesArray.append(self.deafaultTimesForCares.value(forKey: careName.first as! String) as! Int)
                    
                    
                }
                let min = defaultTimesArray.min()
                
                var timeRatios: [Int] = []
                for value in defaultTimesArray { timeRatios.append(value/min!) }
                
                let sumOfTimeRatios = timeRatios.reduce(0, +)
                
                var startTime = Date()
                if Times.Previous_End_Time.count > 0 {
                    startTime = Times.Previous_End_Time[0]
                }else{
                    startTime = Times.Constant_Start_Time
                }
                var endTime = Date()

                if previousBeaconArray.count == 0 {
                    endTime = Times.Leaving_Time
                }
                Times.Previous_End_Time = [endTime]
                let totalTime = Int(endTime.timeIntervalSince(startTime))
                
                let onePartOfTime = totalTime/sumOfTimeRatios
                
                var timesWithRespectToRatios : [Int] = []
                
                for value in timeRatios {
                    timesWithRespectToRatios.append(value*onePartOfTime)
                }
                
                let careTimesDictionary = NSMutableDictionary()
                
                for i in 0..<ResidentDetails.storedCares.count {
                    if i == 0 {
                        
                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let end_time = startTime.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
                        careTimesDictionary.setValue(["start_time":startTime,"end_time":end_time], forKey: careName.first as! String)
                        
                    }else {
                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let beforeCareName = careIds.allKeys(for: (ResidentDetails.storedCares[i-1] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let times_array = careTimesDictionary.value(forKey: beforeCareName.first as! String) as! NSDictionary
                        
                        let start_time = times_array.value(forKey: "end_time") as! Date
                        
                        let end_time = start_time.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
                        
                        careTimesDictionary.setValue(["start_time":start_time,"end_time":end_time], forKey: careName.first as! String)
                        
                    }
                }
                for i in 0..<ResidentDetails.storedCares.count {
                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                    
                    let careTimes = careTimesDictionary.value(forKey: careName.first as! String) as! NSDictionary
                    
                    (ResidentDetails.storedCares[i] as NSMutableDictionary).setValue(["start_time":"\(careTimes.value(forKey: "start_time") as! Date)","end_time":"\(careTimes.value(forKey: "end_time") as! Date)"], forKeyPath: "time_track")
                }
                print(ResidentDetails.storedCares)
                
                
                Times.Previous_End_Time = [Date()]
                
                //create the url with URL
                let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")! //change the url
                
                //create the session object
                let session = URLSession.shared
                
                //now create the URLRequest object using the url object
                var request = URLRequest(url: url)
                request.httpMethod = "POST" //set http method as POST
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: ResidentDetails.storedCares, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                } catch let error {
                    print(error.localizedDescription)
                }
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                
                //create dataTask using the session object to send data to the server
                let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    
                    guard error == nil else {
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    do {
                        //create json object from data
                        _ = try! JSONSerialization.jsonObject(with: data, options: [])
                        if previousBeaconArray.count == 0{
                            DispatchQueue.main.async( execute: {
                                
                                let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                self.locationManager.stopMonitoring(for: self.region)
                                self.locationManager.stopRangingBeacons(in: self.region)
                                let transition = CATransition()
                                transition.duration = 0.3
                                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                transition.type = kCATransitionMoveIn
                                transition.subtype = kCATransitionFromLeft
                                self.view.window!.layer.add(transition, forKey: kCATransition)
                                
                                self.present(nvc, animated: false, completion: {
                                    UserDefaults.standard.set("", forKey: "Came From")
                                    
                                })
                                
                                
                            })
                        }else {
                            let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/\(((UserDefaults.standard.value(forKey: "PreviousBeaconArray")) as! NSArray)[0] as! String)")!
                            
                            let session = URLSession.shared
                            let request = NSMutableURLRequest (url: url as URL)
                            request.httpMethod = "Get"
                            
                            request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                            
                            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                                if let data = data {
                                    
                                    let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                                    //print(re)
                                    ResidentDetails.response = re
                                    DispatchQueue.main.async( execute: {
                                        let reDirectingVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                        
                                        self.locationManager.stopMonitoring(for: self.region)
                                        self.locationManager.stopRangingBeacons(in: self.region)
                                        let transition = CATransition()
                                        transition.duration = 0.3
                                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                        transition.type = kCATransitionMoveIn
                                        transition.subtype = kCATransitionFromLeft
                                        self.view.window!.layer.add(transition, forKey: kCATransition)
                                        
                                        self.present(reDirectingVC, animated: false, completion: {
                                            
                                        })
                                        
                                        
                                    })
                                }
                            }
                            task.resume()
                        }
                    }
                })
                task.resume()
                
            }
            ResidentDetails.storedCares.removeAll()
        }else if actionButton == "Yes"{
            
            let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:performedArray[0] as! IndexPath) as! ResidentSelectTestTableViewCell
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
            
            let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
            
            let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
            
            let resident_ID = UserDefaults.standard.value(forKey: "resident_id") as! String

            let roomId = residentRoom.value(forKey: "_id") as! String
            
            var careNames = [String]()
            careNames.append(cell.careNameLabel.text!)
            
            var careIds = NSDictionary()
            
            let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
            
            if let careIDs = careIDs {
                careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
            }
            
            let care_Id = careIds.value(forKey: careNames[0]) as! String
            
            let care_Value = self.careQuickSelect["\(careNames[0])"]!
            
            var param = NSMutableDictionary()
            if ResidentDetails.openCareIDsArray.contains(care_Id){
                var id = String()
                let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
                for i in 0..<openVisits.count{
                    if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
                        id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
                    }
                }
                param = ["_id":id,
                         "user_id": user_Id,
                         "room_id": roomId,
                         "resident_id": resident_ID,
                         "care_id": care_Id,
                         "care_value": care_Value,
                         "care_notes": "",
                         "care_type": "Track",
                         "care_status": "Closed",
                         "time_track": ""
                    
                ]
            }else{
                param = ["user_id": user_Id,
                         "room_id": roomId,
                         "resident_id": resident_ID,
                         "care_id": care_Id,
                         "care_value": care_Value,
                         "care_notes": "",
                         "care_type": "Track",
                         "care_status": "Closed",
                         "time_track": ""
                    
                ]
            }
            if ResidentDetails.storedCares.count > 0 {
                var elementIndex = [Int]()
                for i in 0..<ResidentDetails.storedCares.count{
                    let element = ResidentDetails.storedCares[i]
                    if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
                        elementIndex = [i]
                    }
                }
                if elementIndex.count > 0 {
                    ResidentDetails.storedCares.remove(at: elementIndex[0])
                    
                    ResidentDetails.storedCares.append(param)
                    
                }else{
                    ResidentDetails.storedCares.append(param)
                }
            }else{
                ResidentDetails.storedCares.append(param)
            }
            
            
            print(ResidentDetails.storedCares)
            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
            
            self.locationManager.stopMonitoring(for: self.region)
            
            self.locationManager.stopRangingBeacons(in: self.region)
            
            let transition = CATransition()
            
            transition.duration = 0.3
            
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            transition.type = kCATransitionMoveIn
            
            transition.subtype = kCATransitionFromLeft
            
            self.view.window!.layer.add(transition, forKey: kCATransition)
            // to check any performed visits
            
            self.present(nvc, animated: false, completion: {
                
            })
            
        }else if actionButton == "Cancel" {
            self.deselect(index: performedArray[0] as! IndexPath)
        }
    }
    
    func doneButton(actionButton: String) {
        
        let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
        let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
        
        let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
            
        let resident_ID = UserDefaults.standard.value(forKey: "resident_id") as! String
        
        let roomId = residentRoom.value(forKey: "_id") as! String
        
        if actionButton == "No"{
            if self.performedArray.count > 0 {
                
                var careNames = [String]()
                for i in 0..<self.performedArray.count {
                    let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:(self.performedArray[i] as! IndexPath)) as! ResidentSelectTestTableViewCell
                    careNames.append(cell.careNameLabel.text!)
                }
                for i in 0..<careNames.count {
                    
                    var careIds = NSDictionary()
                    
                    let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                    
                    if let careIDs = careIDs {
                        careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                    }
                    
                    let care_Id = careIds.value(forKey: careNames[i]) as! String
                    
                    let care_Value = self.careQuickSelect["\(careNames[i])"]!
                    
                    var param = NSMutableDictionary()
                    
                    if ResidentDetails.openCareIDsArray.contains(care_Id){
                        var id = String()
                        let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
                        for i in 0..<openVisits.count{
                            if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
                                
                                id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
                            }
                        }
                        param = ["_id":id,
                                 "user_id": user_Id,
                                 "room_id": roomId,
                                 "resident_id": resident_ID,
                                 "care_id": care_Id,
                                 "care_value": care_Value,
                                 "care_notes": "",
                                 "care_type": "Track",
                                 "care_status": "Closed",
                                 "time_track": ""
                        ]
                    }else{
                        param = ["user_id": user_Id,
                                 "room_id": roomId,
                                 "resident_id": resident_ID,
                                 "care_id": care_Id,
                                 "care_value": care_Value,
                                 "care_notes": "",
                                 "care_type": "Track",
                                 "care_status": "Closed",
                                 "time_track": ""
                        ]
                    }
                    
                    if ResidentDetails.storedCares.count > 0 {
                        var elementIndex = [Int]()
                        for i in 0..<ResidentDetails.storedCares.count{
                            let element = ResidentDetails.storedCares[i]
                            if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
                                elementIndex = [i]
                            }else{
                                
                            }
                        }
                        if elementIndex.count > 0 {
                            ResidentDetails.storedCares.remove(at: elementIndex[0])
                            
                            ResidentDetails.storedCares.append(param)
                            
                        }else{
                            ResidentDetails.storedCares.append(param)
                        }
                    }else{
                        ResidentDetails.storedCares.append(param)
                    }
                }
                print(ResidentDetails.storedCares)
                var defaultTimesArray = [Int]()
                var careIds = NSDictionary()
                
                let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                
                if let careIDs = careIDs {
                    careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                }
                
                for i in 0..<ResidentDetails.storedCares.count {
                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                    defaultTimesArray.append(self.deafaultTimesForCares.value(forKey: careName.first as! String) as! Int)
                    
                }
                let min = defaultTimesArray.min()
                
                var timeRatios: [Int] = []
                for value in defaultTimesArray { timeRatios.append(value/min!) }
                
                let sumOfTimeRatios = timeRatios.reduce(0, +)
                
                var startTime = Date()
                if Times.Previous_End_Time.count > 0 {
                    startTime = Times.Previous_End_Time[0]
                }else{
                    startTime = Times.Constant_Start_Time
                }
                var endTime = Date()
                
                if previousBeaconArray.count == 0 {
                    endTime = Times.Leaving_Time
                }
                Times.Previous_End_Time = [endTime]
                let totalTime = Int(endTime.timeIntervalSince(startTime))
                
                let onePartOfTime = totalTime/sumOfTimeRatios
                
                var timesWithRespectToRatios : [Int] = []
                
                for value in timeRatios {
                    timesWithRespectToRatios.append(value*onePartOfTime)
                }
                
                let careTimesDictionary = NSMutableDictionary()
                
                for i in 0..<ResidentDetails.storedCares.count {
                    if i == 0 {
                        
                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let end_time = startTime.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
                        careTimesDictionary.setValue(["start_time":startTime,"end_time":end_time], forKey: careName.first as! String)
                        
                    }else {
                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let beforeCareName = careIds.allKeys(for: (ResidentDetails.storedCares[i-1] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let times_array = careTimesDictionary.value(forKey: beforeCareName.first as! String) as! NSDictionary
                        
                        let start_time = times_array.value(forKey: "end_time") as! Date
                        
                        let end_time = start_time.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
                        
                        careTimesDictionary.setValue(["start_time":start_time,"end_time":end_time], forKey: careName.first as! String)
                        
                    }
                }
                for i in 0..<ResidentDetails.storedCares.count {
                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                    
                    let careTimes = careTimesDictionary.value(forKey: careName.first as! String) as! NSDictionary
                    
                    (ResidentDetails.storedCares[i] as NSMutableDictionary).setValue(["start_time":"\(careTimes.value(forKey: "start_time") as! Date)","end_time":"\(careTimes.value(forKey: "end_time") as! Date)"], forKeyPath: "time_track")
                }
                print(ResidentDetails.storedCares)
                //create the url with URL
                let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")! //change the url
                
                //create the session object
                let session = URLSession.shared
                
                //now create the URLRequest object using the url object
                var request = URLRequest(url: url)
                request.httpMethod = "POST" //set http method as POST
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: ResidentDetails.storedCares, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                } catch let error {
                    print(error.localizedDescription)
                }
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                
                //create dataTask using the session object to send data to the server
                let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    
                    guard error == nil else {
                        return
                    }
                    guard let data = data else {
                        return
                    }
                    do {
                        
                        //create json object from data
                        _ = try! JSONSerialization.jsonObject(with: data, options: [])
                        /***************************************************************************/
                        let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
                        
                        if previousBeaconArray.count == 0{
                            DispatchQueue.main.async( execute: {

                            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                            self.locationManager.stopMonitoring(for: self.region)
                            self.locationManager.stopRangingBeacons(in: self.region)
                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                            transition.type = kCATransitionMoveIn
                            transition.subtype = kCATransitionFromLeft
                            self.view.window!.layer.add(transition, forKey: kCATransition)
                            self.present(nvc, animated: false, completion: {
                                UserDefaults.standard.set("", forKey: "Came From")
                            })
                        })
                            
                        }else{
                            
                            let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/\(((UserDefaults.standard.value(forKey: "PreviousBeaconArray")) as! NSArray)[0] as! String)")!
                            
                            let session = URLSession.shared
                            let request = NSMutableURLRequest (url: url as URL)
                            request.httpMethod = "Get"
                            
                            request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                            
                            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                                if let data = data {
                                    let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                                    ResidentDetails.response = re
                                    DispatchQueue.main.async( execute: {
                                        let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                        self.locationManager.stopMonitoring(for: self.region)
                                        self.locationManager.stopRangingBeacons(in: self.region)
                                        let transition = CATransition()
                                        transition.duration = 0.3
                                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                        transition.type = kCATransitionMoveIn
                                        transition.subtype = kCATransitionFromLeft
                                        self.view.window!.layer.add(transition, forKey: kCATransition)
                                        
                                        // to check any performed visits
                                        
                                        self.present(nvc, animated: false, completion: {
                                        })
                                    })
                                }
                            }
                            task.resume()
                        
                        }
                    }
                })
                task.resume()
            }else if self.pauseArray.count > 0 {
                var careNames = [String]()
                for i in 0..<self.pauseArray.count {
                    let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:(self.pauseArray[i] as! IndexPath)) as! ResidentSelectTestTableViewCell
                    careNames.append(cell.careNameLabel.text!)
                }
                for i in 0..<careNames.count {
                    
                    var careIds = NSDictionary()
                    
                    let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                    
                    if let careIDs = careIDs {
                        careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                    }
                    
                    let care_Id = careIds.value(forKey: careNames[i]) as! String
                    
                    let care_Value = self.careQuickSelect["\(careNames[i])"]!
                    
                    var param = NSMutableDictionary()
                    
                    if ResidentDetails.openCareIDsArray.contains(care_Id){
                        var id = String()
                        let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
                        for i in 0..<openVisits.count{
                            if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
                                id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
                            }
                        }
                        param = ["_id":id,
                                 "user_id": user_Id,
                                 "room_id": roomId,
                                 "resident_id": resident_ID,
                                 "care_id": care_Id,
                                 "care_value": care_Value,
                                 "care_notes": "",
                                 "care_type": "Track",
                                 "care_status": "Open",
                                 "time_track": ""
                        ]
                    }else{
                        
                        param = ["user_id": user_Id,
                                 "room_id": roomId,
                                 "resident_id": resident_ID,
                                 "care_id": care_Id,
                                 "care_value": care_Value,
                                 "care_notes": "",
                                 "care_type": "Track",
                                 "care_status": "Open",
                                 "time_track": ""
                        ]
                    }
                    
                    if ResidentDetails.storedCares.count > 0 {
                        var elementIndex = [Int]()
                        for i in 0..<ResidentDetails.storedCares.count{
                            let element = ResidentDetails.storedCares[i]
                            if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
                                elementIndex = [i]
                            }else{
                                
                            }
                        }
                        if elementIndex.count > 0 {
                            ResidentDetails.storedCares.remove(at: elementIndex[0])
                            
                            ResidentDetails.storedCares.append(param)
                            
                        }else{
                            ResidentDetails.storedCares.append(param)
                        }
                    }else{
                        ResidentDetails.storedCares.append(param)
                    }
                }
                var defaultTimesArray = [Int]()
                
                var careIds = NSDictionary()
                
                let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                
                if let careIDs = careIDs {
                    careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                }
                
                for i in 0..<ResidentDetails.storedCares.count {
                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                    defaultTimesArray.append(self.deafaultTimesForCares.value(forKey: careName.first as! String) as! Int)
                    
                }
                let min = defaultTimesArray.min()
                
                var timeRatios: [Int] = []
                
                for value in defaultTimesArray { timeRatios.append(value/min!) }
                let sumOfTimeRatios = timeRatios.reduce(0, +)
                
                var startTime = Date()
                if Times.Previous_End_Time.count > 0 {
                    startTime = Times.Previous_End_Time[0]
                    
                }else{
                    startTime = Times.Constant_Start_Time
                    
                }
                var endTime = Date()
                
                if previousBeaconArray.count == 0 {
                    endTime = Times.Leaving_Time
                }
                
                Times.Previous_End_Time = [endTime]
                let totalTime = Int(endTime.timeIntervalSince(startTime))
                
                let onePartOfTime = totalTime/sumOfTimeRatios
                
                var timesWithRespectToRatios : [Int] = []
                
                for value in timeRatios { timesWithRespectToRatios.append(value*onePartOfTime) }
                
                let careTimesDictionary = NSMutableDictionary()
                
                for i in 0..<ResidentDetails.storedCares.count {
                    if i == 0 {
                        
                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let end_time = startTime.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
                        careTimesDictionary.setValue(["start_time":startTime,"end_time":end_time], forKey: careName.first as! String)
                        
                    }else {
                        
                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let beforeCareName = careIds.allKeys(for: (ResidentDetails.storedCares[i-1] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let times_array = careTimesDictionary.value(forKey: beforeCareName.first as! String) as! NSDictionary
                        
                        let start_time = times_array.value(forKey: "end_time") as! Date
                        
                        let end_time = start_time.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
                        
                        careTimesDictionary.setValue(["start_time":start_time,"end_time":end_time], forKey: careName.first as! String)
                        
                    }
                }
                for i in 0..<ResidentDetails.storedCares.count {
                    
                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                    
                    let careTimes = careTimesDictionary.value(forKey: careName.first as! String) as! NSDictionary
                    
                    (ResidentDetails.storedCares[i] as NSMutableDictionary).setValue(["start_time":"\(careTimes.value(forKey: "start_time") as! Date)","end_time":"\(careTimes.value(forKey: "end_time") as! Date)"], forKeyPath: "time_track")
                    
                }
                print(ResidentDetails.storedCares)
                //create the url with URL
                let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")! //change the url
                
                //create the session object
                let session = URLSession.shared
                
                //now create the URLRequest object using the url object
                var request = URLRequest(url: url)
                request.httpMethod = "POST" //set http method as POST
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: ResidentDetails.storedCares, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                } catch let error {
                    print(error.localizedDescription)
                }
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                
                //create dataTask using the session object to send data to the server
                let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    
                    guard error == nil else {
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    do {
                        
                        //create json object from data
                        
                        _ = try! JSONSerialization.jsonObject(with: data, options: [])
                        let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
                        
                        if previousBeaconArray.count == 0{
                            DispatchQueue.main.async( execute: {

                            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                            self.locationManager.stopMonitoring(for: self.region)
                            self.locationManager.stopRangingBeacons(in: self.region)
                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                            transition.type = kCATransitionMoveIn
                            transition.subtype = kCATransitionFromLeft
                            self.view.window!.layer.add(transition, forKey: kCATransition)
                            self.present(nvc, animated: false, completion: {
                                UserDefaults.standard.set("", forKey: "Came From")
                            })
                            })
                            
                        }else{
                            let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/\(((UserDefaults.standard.value(forKey: "PreviousBeaconArray")) as! NSArray)[0] as! String)")!
                            
                            let session = URLSession.shared
                            let request = NSMutableURLRequest (url: url as URL)
                            request.httpMethod = "Get"
                            
                            request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                            
                            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                                
                                if let data = data {
                                    
                                    let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                                    ResidentDetails.response = re
                                    DispatchQueue.main.async( execute: {
                                        
                                        let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                        self.locationManager.stopMonitoring(for: self.region)
                                        self.locationManager.stopRangingBeacons(in: self.region)
                                        let transition = CATransition()
                                        transition.duration = 0.3
                                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                        transition.type = kCATransitionMoveIn
                                        transition.subtype = kCATransitionFromLeft
                                        self.view.window!.layer.add(transition, forKey: kCATransition)
                                        
                                        self.present(nvc, animated: false, completion: {

                                        })
                                    })
                                }
                            }
                            task.resume()
                        }
                    }
                })
                task.resume()
            }
            ResidentDetails.storedCares.removeAll()
        }else if actionButton == "Yes"{
            if self.performedArray.count > 0 {
                var careNames = [String]()
                for i in 0..<self.performedArray.count {
                    let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:(self.performedArray[i] as! IndexPath)) as! ResidentSelectTestTableViewCell
                    careNames.append(cell.careNameLabel.text!)
                }
                for i in 0..<careNames.count {
                    
                    var careIds = NSDictionary()
                    
                    let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                    
                    if let careIDs = careIDs {
                        careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                    }
                    
                    let care_Id = careIds.value(forKey: careNames[i]) as! String
                    
                    
                    let care_Value = self.careQuickSelect["\(careNames[i])"]!
                    
                    var param = NSMutableDictionary()
                    if ResidentDetails.openCareIDsArray.contains(care_Id){
                        var id = String()
                        let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
                        for i in 0..<openVisits.count{
                            if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
                                id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
                            }
                        }
                        param = ["_id":id,
                                 "user_id": user_Id,
                                 "room_id": roomId,
                                 "resident_id": resident_ID,
                                 "care_id": care_Id,
                                 "care_value": care_Value,
                                 "care_notes": "",
                                 "care_type": "Track",
                                 "care_status": "Closed",
                                 "time_track": ""
                        ]
                    }else{
                        param = ["user_id": user_Id,
                                 "room_id": roomId,
                                 "resident_id": resident_ID,
                                 "care_id": care_Id,
                                 "care_value": care_Value,
                                 "care_notes": "",
                                 "care_type": "Track",
                                 "care_status": "Closed",
                                 "time_track": ""
                        ]
                    }
                    
                    if ResidentDetails.storedCares.count > 0 {
                        var elementIndex = [Int]()
                        for i in 0..<ResidentDetails.storedCares.count{
                            let element = ResidentDetails.storedCares[i]
                            if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
                                elementIndex = [i]
                            }else{
                                
                            }
                        }
                        if elementIndex.count > 0 {
                            ResidentDetails.storedCares.remove(at: elementIndex[0])
                            
                            ResidentDetails.storedCares.append(param)
                            
                        }else{
                            ResidentDetails.storedCares.append(param)
                        }
                    }else{
                        ResidentDetails.storedCares.append(param)
                    }
                    
                }
                print(ResidentDetails.storedCares)
                let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                
                self.locationManager.stopMonitoring(for: self.region)
                
                self.locationManager.stopRangingBeacons(in: self.region)
                
                let transition = CATransition()
                
                transition.duration = 0.3
                
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                
                transition.type = kCATransitionMoveIn
                
                transition.subtype = kCATransitionFromLeft
                
                self.view.window!.layer.add(transition, forKey: kCATransition)
                // to check any performed visits
                
                
                self.present(nvc, animated: false, completion: {
                    
                })
                
            }else if self.pauseArray.count > 0 {
                var careNames = [String]()
                for i in 0..<self.pauseArray.count {
                    let cell: ResidentSelectTestTableViewCell = self.careSelectTableView.cellForRow(at:(self.pauseArray[i] as! IndexPath)) as! ResidentSelectTestTableViewCell
                    careNames.append(cell.careNameLabel.text!)
                }
                for i in 0..<careNames.count {
                    
                    var careIds = NSDictionary()
                    
                    let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                    
                    if let careIDs = careIDs {
                        careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                    }
                    
                    let care_Id = careIds.value(forKey: careNames[i]) as! String
                    
                    
                    let care_Value = self.careQuickSelect["\(careNames[i])"]!
                    
                    var param = NSMutableDictionary()
                    if ResidentDetails.openCareIDsArray.contains(care_Id){
                        var id = String()
                        let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
                        for i in 0..<openVisits.count{
                            if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
                                id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
                            }
                        }
                        param = ["_id":id,
                                 "user_id": user_Id,
                                 "room_id": roomId,
                                 "resident_id": resident_ID,
                                 "care_id": care_Id,
                                 "care_value": care_Value,
                                 "care_notes": "",
                                 "care_type": "Track",
                                 "care_status": "Open",
                                 "time_track": ""
                        ]
                    }else{
                        param = ["user_id": user_Id,
                                 "room_id": roomId,
                                 "resident_id": resident_ID,
                                 "care_id": care_Id,
                                 "care_value": care_Value,
                                 "care_notes": "",
                                 "care_type": "Track",
                                 "care_status": "Open",
                                 "time_track": ""
                        ]
                    }
                    if ResidentDetails.storedCares.count > 0 {
                        var elementIndex = [Int]()
                        for i in 0..<ResidentDetails.storedCares.count{
                            let element = ResidentDetails.storedCares[i]
                            if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
                                elementIndex = [i]
                            }else{
                                
                            }
                        }
                        if elementIndex.count > 0 {
                            ResidentDetails.storedCares.remove(at: elementIndex[0])
                            
                            ResidentDetails.storedCares.append(param)
                            
                        }else{
                            ResidentDetails.storedCares.append(param)
                        }
                    }else{
                        ResidentDetails.storedCares.append(param)
                    }
                }
                print(ResidentDetails.storedCares)
                let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                
                self.locationManager.stopMonitoring(for: self.region)
                
                self.locationManager.stopRangingBeacons(in: self.region)
                
                let transition = CATransition()
                
                transition.duration = 0.3
                
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                
                transition.type = kCATransitionMoveIn
                
                transition.subtype = kCATransitionFromLeft
                
                self.view.window!.layer.add(transition, forKey: kCATransition)
                // to check any performed visits
                
                
                self.present(nvc, animated: false, completion: {
                    
                })
                
            }
        }else if actionButton == "Cancel" {

        }
    }
    func dismissAlert(){
        
        let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
        
        let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
        
        let roomId = residentRoom.value(forKey: "_id") as! String
        
        
        var startedTime = Date()
        
        if Times.Previous_End_Time.count > 0 {
            startedTime = Times.Previous_End_Time[0]
        }else{
            startedTime = Times.Constant_Start_Time
        }
        let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
        var endTime = Date()
        
        if previousBeaconArray.count == 0 {
            endTime = Times.Leaving_Time
        }
        var param = [String:Any]()
        param = ["user_id": user_Id,
                 "room_id": roomId,
                 "resident_id": "",
                 "care_id": "",
                 "care_value": "",
                 "care_notes": "",
                 "care_type": "UnTrack",
                 "care_status": "Closed",
                 "time_track": ["start_time":"\(startedTime)",
                    "end_time":"\(endTime)"]
            
        ]
        
        let parameters = [param]
        
        //create the url with URL
        let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                _ = try! JSONSerialization.jsonObject(with: data, options: [])
                
                DispatchQueue.main.async( execute: {
                    
                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                    self.locationManager.stopMonitoring(for: self.region)
                    self.locationManager.stopRangingBeacons(in: self.region)
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionMoveIn
                    transition.subtype = kCATransitionFromLeft
                    self.view.window!.layer.add(transition, forKey: kCATransition)
                    UIApplication.shared.isIdleTimerDisabled = false

                    self.present(nvc, animated: false, completion: {
                        UserDefaults.standard.set("", forKey: "Came From")
                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                    })
                })
            }
        })
        task.resume()
        timer?.invalidate()
        self.popup.dismiss(animated: true, completion: {
            UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
            
        })
        
    }

}

