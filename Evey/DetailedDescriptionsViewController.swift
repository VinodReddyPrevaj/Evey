//
//  DetailedDescriptionsViewController.swift
//  Evey
//
//  Created by PROJECTS on 01/02/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import AudioToolbox
class DetailedDescriptionsViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var evey: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var scheduledVisitImage: UIImageView!
    
    @IBOutlet weak var residentNameLbl: UILabel!
    
    @IBOutlet weak var borderLbl: UILabel!
    
    @IBOutlet weak var serviceLbl: UILabel!
    
    @IBOutlet weak var serviceImage: UIImageView!
    
    @IBOutlet weak var serviceNameLbl: UILabel!
    
    @IBOutlet weak var startLbl: UILabel!
    
    @IBOutlet weak var startDateLbl: UILabel!
    
    @IBOutlet weak var endLbl: UILabel!
    
    @IBOutlet weak var endDateLbl: UILabel!
    
    @IBOutlet weak var frequencyLbl: UILabel!
    
    @IBOutlet weak var typeOfFrequencyLbl: UILabel!
    
    @IBOutlet weak var nextLbl: UILabel!
    
    @IBOutlet weak var nextDateLbl: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var enterVisitBtn: UIButton!
    
    @IBOutlet weak var viesScheduledVisitsBtn: UIButton!
    
    @IBOutlet weak var bottomButtonsView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var backActionBtn: UIButton!
    
    @IBOutlet weak var bottomBorderLbl: UILabel!
    
    @IBOutlet weak var forwardArrow: UIButton!
    
    // for beacon detection
    
    var acceptableDistance = Double()
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    var beaconsArray = NSArray()
    var responseBeacon = NSDictionary()

    var timer: Timer?

    var audioPlayer = AVAudioPlayer()
    
    let roomUrl = Bundle.main.url(forResource: "Room", withExtension: "mp3")
    let hallwayUrl = Bundle.main.url(forResource: "Hallway", withExtension:"mp3")

    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backActionBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)
        acceptableDistance = 2.0
        
        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion:nil)

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func layOuts(){
       
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height

        backBtn.frame = CGRect(x: screenWidth/24.352, y: screenHeight/23, width: screenWidth/18.818, height: screenWidth/18.818)
        
        evey.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.width+screenWidth/3.696, y: screenHeight/23.741, width: screenWidth/3.763 , height: screenHeight/28.306)
        
        menuBtn.frame = CGRect(x: evey.frame.origin.x+evey.frame.width+screenWidth/4.224, y: screenHeight/23.741, width: screenWidth/11.5, height: screenHeight/32)
        
        scheduledVisitImage.frame = CGRect(x: screenWidth/23, y: backBtn.frame.origin.y+backBtn.frame.height+screenHeight/21.647, width: screenWidth/20.7, height: screenWidth/20.7)
        
        residentNameLbl.frame = CGRect(x: scheduledVisitImage.frame.origin.x+scheduledVisitImage.frame.width+screenWidth/46, y: backBtn.frame.origin.y+backBtn.frame.height+screenHeight/30.666, width: screenWidth/1.38, height: screenHeight/18.871)
        
        borderLbl.frame = CGRect(x: 0, y: residentNameLbl.frame.origin.y+residentNameLbl.frame.height+screenHeight/73.6, width: screenWidth, height: 1)

        serviceLbl.frame = CGRect(x: screenWidth/24.352, y: borderLbl.frame.origin.y+borderLbl.frame.height+screenHeight/61.333, width: screenWidth/6.786, height: screenHeight/32)
        
        serviceImage.frame = CGRect(x: serviceLbl.frame.origin.x+serviceLbl.frame.width+screenWidth/69, y: borderLbl.frame.origin.y+borderLbl.frame.height+screenHeight/61.333, width: screenWidth/15.333, height: screenWidth/15.333)
        
        serviceNameLbl.frame = CGRect(x: serviceImage.frame.origin.x+serviceImage.frame.width+screenWidth/41.4, y:borderLbl.frame.origin.y+borderLbl.frame.height+screenHeight/61.333, width: screenWidth/2.539, height: screenHeight/32)
        
        startLbl.frame = CGRect(x: screenWidth/24.352, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/10.35, height: screenHeight/32)
        
        startDateLbl.frame = CGRect(x: startLbl.frame.origin.x+startLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/5.914, height: screenHeight/32)
        
        endLbl.frame = CGRect(x: startDateLbl.frame.origin.x+startDateLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/12.937, height: screenHeight/32)
        
        endDateLbl.frame = CGRect(x: endLbl.frame.origin.x+endLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/5.914, height: screenHeight/32)
        
        frequencyLbl.frame = CGRect(x: endDateLbl.frame.origin.x+endDateLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/5.447, height: screenHeight/32)
        
        typeOfFrequencyLbl.frame = CGRect(x: frequencyLbl.frame.origin.x+frequencyLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/4.6, height: screenHeight/32)
        
        nextLbl.frame = CGRect(x: screenWidth/24.352, y: frequencyLbl.frame.origin.y+frequencyLbl.frame.height, width: screenWidth/9.857, height: screenHeight/32)
        
        nextDateLbl.frame = CGRect(x: nextLbl.frame.origin.x+nextLbl.frame.width+screenWidth/103.5, y: frequencyLbl.frame.origin.y+frequencyLbl.frame.height, width: screenWidth/1.344, height: screenHeight/32)
        
        descriptionTextView.frame = CGRect(x: screenWidth/31.846, y: nextDateLbl.frame.origin.y+nextDateLbl.frame.height, width: screenWidth/1.128, height: screenHeight/2.991)
        
        var frame = self.descriptionTextView.frame
        frame.size.height = self.descriptionTextView.contentSize.height
        self.descriptionTextView.frame = frame
        
        forwardArrow.frame = CGRect(x: descriptionTextView.frame.origin.x+descriptionTextView.frame.width, y: screenHeight/3.131, width: screenWidth/14.785, height: screenWidth/14.785)
        
        forwardArrow.isHidden = true
        
        
        buttonsView.frame = CGRect(x: 0, y: descriptionTextView.frame.origin.y+descriptionTextView.frame.height, width: screenWidth, height: screenHeight/7.913)
        
        enterVisitBtn.frame = CGRect(x: 0, y: 1, width: screenWidth, height: buttonsView.frame.height/2.066)
        
        viesScheduledVisitsBtn.frame = CGRect(x: 0, y: enterVisitBtn.frame.origin.y+enterVisitBtn.frame.height+1, width: screenWidth, height: buttonsView.frame.height/2.066)
        
        bottomButtonsView.frame = CGRect(x: 0, y: screenHeight-screenHeight/12.474, width: screenWidth, height: screenHeight/12.474)
        
        cancelBtn.frame = CGRect(x: screenWidth/15.333, y: bottomButtonsView.frame.height/4.916, width: screenWidth/5.307, height: bottomButtonsView.frame.height/1.787)
        
        cancelBtn.isHidden = true
        
        backActionBtn.frame = CGRect(x: cancelBtn.frame.origin.x+cancelBtn.frame.width+screenWidth/1.962, y: bottomButtonsView.frame.height/4.916, width: screenWidth/5.307, height: bottomButtonsView.frame.height/1.787)

        
        bottomBorderLbl.frame = CGRect(x: 0, y: 1, width: screenWidth, height: 1)
        
        
    }

    func backAction(){
        
        let scheduledVisitsVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduledVisitsViewController") as! ScheduledVisitsViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        self.present(scheduledVisitsVC, animated: false, completion: nil)
   
    }
    
    @IBAction func menuBtnAction(_ sender: Any) {
        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("DetailedDescription", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        
        self.present(menu, animated: false, completion: nil)

    }
    @IBAction func viewAllScheduledVisitsAction(_ sender: Any) {
        
        let scheduledVisitsVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduledVisitsViewController") as! ScheduledVisitsViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        self.present(scheduledVisitsVC, animated: false, completion: nil)

    }
    
    @IBAction func enterVisitAction(_ sender: Any) {
        
        let careSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController")as! CareSelectViewController
        careSelectVC.residentNameRoom = residentNameLbl.text!
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set(residentNameLbl.text!, forKey: "nameRoom")
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        self.present(careSelectVC, animated: false, completion: {
            
        })
 
        
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
                                    print("minor")
                                    otherBeacon = aaaaaaa.value(forKey: "type") as! String
                                }
                            }
                            
                            if otherBeacon == "hallway" {

                            UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                            let msg = "Are you finished with your visit or are you continuing care?"
                            let attString = NSMutableAttributedString(string: msg)
                            
                            popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                            })
                            
                            print("Dash After")
                                let pauseButton = CancelButton(title: "Pause") {
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
                                    
                                    
                                }
                                let continueButton = CancelButton(title: "Continue") {
                                    
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
                                    
                                }
                                let completeButton = CancelButton(title: "Complete") {
                                    
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
                                    
                                }
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
                            print("hallway Beacon Count\(hallwayBeaconArray.count)")
                            if hallwayBeaconArray.count == 0{
                                
                                if Times.Previous_End_Time.count > 0{
                                    let timeGap = Date().timeIntervalSince(Times.Previous_End_Time[0])
                                    print(Times.Previous_End_Time[0])
                                    print(Date())
                                    print(timeGap)
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
