//
//  AlertViewController.swift
//  Evey
//
//  Created by PROJECTS on 17/04/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import AudioToolbox
class AlertViewController: UIViewController,CLLocationManagerDelegate {

    var delegate:actionProtocol?
    var Delegate:SampleProtocol?
    var alertDelegate:protocolFromOutComeEntryScreen?
    var counter:Int = 6907
    
    var timer: Timer?
    var label = ""
    var message = "in "
    var pause = Bool()
    var perform = Bool()
    var done = Bool()
    var outcomeDone = Bool()
    
    var beaconsArray = NSArray()
    var responseBeacon = NSDictionary()
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    @IBOutlet weak var border3: UILabel!
    @IBOutlet weak var border2: UILabel!
    @IBOutlet weak var border1: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var completeBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var msgLabel: UILabel!
    
    var startTime = Date()
    var residentName = String()
    var screenFrame = CGRect()
    let transitioner = CAVTransitioner()
    
    var audioPlayer = AVAudioPlayer()
    
    let roomUrl = Bundle.main.url(forResource: "Room", withExtension: "mp3")
    let hallwayUrl = Bundle.main.url(forResource: "Hallway", withExtension:"mp3")

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transitioner
        let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
        if previousBeaconArray.count > 0 {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.decrease), userInfo: nil, repeats: true)
        }
    }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    @IBAction func deleteBtnAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        if pause == true {
            self.delegate?.pauseButton(actionButton: "Cancel")
        }else if perform == true {
            self.delegate?.performButton(actionButton: "Cancel")
        }else if done == true {
            self.delegate?.doneButton(actionButton: "Cancel")
        }else if outcomeDone == true {
            self.alertDelegate?.doneButtonAction(actionButton: "Cancel")
        }
        timer?.invalidate()

    }
    @IBAction func completeBtnAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: {
            self.locationManager.stopMonitoring(for: self.region)
            self.locationManager.stopRangingBeacons(in: self.region)

            if self.pause == true {
                self.delegate?.pauseButton(actionButton: "Yes")
            }else if self.perform == true {
                self.delegate?.performButton(actionButton: "Yes")
            }else if self.done == true {
                self.delegate?.doneButton(actionButton: "Yes")
            }else if self.outcomeDone == true {
                self.alertDelegate?.doneButtonAction(actionButton: "Yes")
            }
            self.timer?.invalidate()
        })

    }
    @IBAction func pauseBtnAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        if pause == true {
            self.delegate?.pauseButton(actionButton: "No")
        }else if perform == true {
            self.delegate?.performButton(actionButton: "No")
        }else if done == true {
            self.delegate?.doneButton(actionButton: "No")
        }else if outcomeDone == true {
            self.alertDelegate?.doneButtonAction(actionButton: "No")
        }
        timer?.invalidate()
        
    }
    func decrease()
    {
        var minutes: Int
        var seconds: Int
        var hours:Int
        if(counter >= 0) {
            let date2 = Date()
            self.counter = Int(date2.timeIntervalSince(startTime))
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
        
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.95)
        
        var hour = Calendar.current.component(.hour, from: startTime)
        
        let minute = Calendar.current.component(.minute, from: startTime)
        var AMPM = "AM"
        if hour > 12 {
            hour = hour-12
            AMPM = "PM"
        }
        if hour == 12 {
            hour = hour-12
            AMPM = "PM"
        }
        var time = "\(hour):\(minute) \(AMPM)"

        if minute < 10 {
            time = "\(hour):0\(minute) \(AMPM)"
        }else{
            time = "\(hour):\(minute) \(AMPM)"
        }
        startTimeLabel.text = "Visit started at \(time)"
        if pause == true {
            let msg = "Your visit to \(residentName) has been Paused"
            
            let attString = NSMutableAttributedString(string: msg)
            
            let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
            
            attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 14, length: residentName.characters.count))
            
            attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msg.characters.count-6, length: 6))

            titleLbl.attributedText = attString
            
            let msgForAnotherCare = "Do you want to track another Resident/Care during this time?"
            
            let attributeString = NSMutableAttributedString(string: msgForAnotherCare)
            
            attributeString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msgForAnotherCare.characters.count-31, length: 14))

            msgLabel.attributedText = attributeString
        }else if perform == true || done == true{
            let msg = "I have marked your visit with \(residentName) as Completed"
            
            let attString = NSMutableAttributedString(string: msg)
            
            let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
            
            attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 30, length: residentName.characters.count))
            
            attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msg.characters.count-9, length: 9))

            titleLbl.attributedText = attString
            
            let msgForAnotherCare = "Do you want to track another Resident/Care during this time?"
            
            let attributeString = NSMutableAttributedString(string: msgForAnotherCare)
            
            attributeString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msgForAnotherCare.characters.count-31, length: 14))
            
            msgLabel.attributedText = attributeString

        }else if outcomeDone == true {
            let msg = "I have marked your visit with \(residentName) as Completed"
            
            let attString = NSMutableAttributedString(string: msg)
            
            let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
            
            attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 30, length: residentName.characters.count))
            
            attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msg.characters.count-9, length: 9))
            
            titleLbl.attributedText = attString
            
            let msgForAnotherCare = "Do you want to track another Resident/Care during this time?"
            
            let attributeString = NSMutableAttributedString(string: msgForAnotherCare)
            
            attributeString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msgForAnotherCare.characters.count-31, length: 14))
            
            msgLabel.attributedText = attributeString
            
        }
        //locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
       // locationManager.startRangingBeacons(in: region)
        //locationManager.startMonitoring(for: region)
        
        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion:nil)

        
//        titleLbl.frame = CGRect(x: self.view.frame.origin.x, y: 0, width: self.view.frame.width, height: self.view.frame.height/8.7)
//        
//        timeLabel.frame = CGRect(x: self.view.frame.origin.x, y: self.titleLbl.frame.origin.y+self.titleLbl.frame.height+self.view.frame.height/8.7, width: self.view.frame.width, height: self.view.frame.height/4.35)
//        
//        border1.frame = CGRect(x: self.view.frame.origin.x, y: self.timeLabel.frame.origin.y+self.timeLabel.frame.height+self.view.frame.height/5.304, width: self.view.frame.width, height: 1)
//        
//        pauseBtn.frame = CGRect(x: self.view.frame.origin.x, y: border1.frame.origin.y+border1.frame.height, width: self.view.frame.width, height: self.view.frame.height/8.7)
//        
//        border2.frame = CGRect(x: self.view.frame.origin.x, y: pauseBtn.frame.origin.y+pauseBtn.frame.height, width: self.view.frame.width, height: 1)
//        
//        completeBtn.frame = CGRect(x: self.view.frame.origin.x, y: border2.frame.origin.y+border2.frame.height, width: self.view.frame.width, height: self.view.frame.height/8.7)
//        
//        border3.frame = CGRect(x: self.view.frame.origin.x, y: completeBtn.frame.origin.y+completeBtn.frame.height, width: self.view.frame.width, height: 1)
//        
//        deleteBtn.frame = CGRect(x: self.view.frame.origin.x, y: border3.frame.origin.y+border3.frame.height, width: self.view.frame.width, height: self.view.frame.height/8.7)
//        
//        let path = UIBezierPath(roundedRect:titleLbl.bounds,
//                                byRoundingCorners:[.topLeft, .topRight],
//                                cornerRadii: CGSize(width: self.view.frame.width/27.615, height:  self.view.frame.height/32.142))
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = path.cgPath
        //titleLbl.layer.mask = maskLayer
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    
        let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
        if (knownBeacons.count>0) {
            let array = ["major": (knownBeacons[0]).major.stringValue ,"minor": (knownBeacons[0]).minor.stringValue,"rssi":(knownBeacons[0]).rssi] as [String : Any]
    
            Constants.nearBeacon = ["major":(knownBeacons[0]).major.intValue,"minor":(knownBeacons[0]).minor.intValue]

            Constants.rssiArray.add(array)
            print(Constants.rssiArray.count)
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
    
                    if dis <= Constants.roomRange {
    
                        let beaconsData = UserDefaults.standard.object(forKey: "Beacons_List") as? NSData
    
                        if let beaconsData = beaconsData {
                            beaconsArray = (NSKeyedUnarchiver.unarchiveObject(with: beaconsData as Data) as? NSArray)!
                        }
                        var myBeacon = String()
    
                        for i in 0..<beaconsArray.count {
    
                            let aaaaaaa = beaconsArray[i] as! NSDictionary
    
                            let beaconMajor = Int(dic?.value(forKey: "major") as! String)
    
                            let beaconMinor = Int(dic?.value(forKey: "minor") as! String)
    
    
                            let majorStr = aaaaaaa.value(forKey: "major") as! String
    
                            let major = Int(majorStr)
    
                            let minorStr = aaaaaaa.value(forKey: "minor") as! String
    
                            let minor = Int(minorStr)
    
    
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
    
                    if dis <= Constants.hallwayRange {
                        let beaconsData = UserDefaults.standard.object(forKey: "Beacons_List") as? NSData
    
                        if let beaconsData = beaconsData {
                            beaconsArray = (NSKeyedUnarchiver.unarchiveObject(with: beaconsData as Data) as? NSArray)!
                        }
                        var otherBeacon = String()
                        for i in 0..<beaconsArray.count {
    
                            let aaaaaaa = beaconsArray[i] as! NSDictionary
    
                            let beaconMajor = Int(dic?.value(forKey: "major") as! String)
    
                            let beaconMinor = Int(dic?.value(forKey: "minor") as! String)
    
                            let majorStr = aaaaaaa.value(forKey: "major") as! String
    
                            let major = Int(majorStr)
    
                            let minorStr = aaaaaaa.value(forKey: "minor") as! String
    
                            let minor = Int(minorStr)
    
                            if major == beaconMajor && minor == beaconMinor{
                                otherBeacon = aaaaaaa.value(forKey: "type") as! String
                            }
                        }
    
                        if otherBeacon == "hallway" {
    
                            UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                            let msg = "Are you finished with your visit or are you continuing care?"
                            let attString = NSMutableAttributedString(string: msg)
    
                            popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
    
                            })
    
                            let pauseButton = CancelButton(title: "Pause", action: {
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
    
                            let completeButton = CancelButton(title: "Complete", action: {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                
                                
                                
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
                                
                            })
    
                            let deleteButton = CancelButton(title: "Done", action: {
                                let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
    
    
    
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
    
}
