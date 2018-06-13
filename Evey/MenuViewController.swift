//
//  MenuViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 24/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import AudioToolbox
class MenuViewController: UIViewController,CLLocationManagerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var recentVisitsBtn: UIButton!
    @IBOutlet weak var contactsButton: UIButton!
    
    @IBOutlet weak var logOutButton: UIButton!
    var screenNameStr =  String()
    //for beacon Detection
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchBtnAction(_ sender: Any) {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        searchVC.from = "Menu"
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        
        self.present(searchVC, animated: false, completion: nil)

    }

    @IBAction func contactsBtnAction(_ sender: Any) {
        let contacts = self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(contacts, animated: false, completion: nil)
    }

    @IBAction func recentVisitsBtnAction(_ sender: Any) {
        recentVisitsBtn.isUserInteractionEnabled = false
        let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")!
        let session = URLSession.shared
        let request = NSMutableURLRequest (url: url as URL)
        request.httpMethod = "Get"
        
        request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
        
        let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
            if let data = data {
                
                let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                DispatchQueue.main.async( execute: {
                    for i in 0..<re.count {
                        
                        let dictionary = re[i] as! NSDictionary
                        
                        let typeString = dictionary.value(forKey: "_id") as! String
                        
                        switch typeString {
                        case "Open"  :
                            
                            Constants.recentOpenVisits = dictionary.value(forKey: "list") as! NSArray
                            
                        default :
                            
                            Constants.recentClosedVisits = dictionary.value(forKey: "list") as! NSArray
                            
                        }
                        
                    }
                    let recentVisits = self.storyboard?.instantiateViewController(withIdentifier: "RecentVisitsViewController") as! RecentVisitsViewController
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    self.view.window!.layer.add(transition, forKey: kCATransition)
                    recentVisits.screenNameStr = "Menu"
                    self.locationManager.stopMonitoring(for: self.region)
                    self.locationManager.stopRangingBeacons(in: self.region)
                    
                    self.present(recentVisits, animated: false, completion:{
                        self.recentVisitsBtn.isUserInteractionEnabled = true

                    })

            })
        }
        }
        task.resume()

    }
    @IBAction func cancelBtnAction(_ sender: Any) {
    let screenName  = UserDefaults.standard.value(forKey: "EntryScreen") as! String
    if screenName == "ResidentSelectTestViewController"{
        
        UserDefaults.standard.removeObject(forKey: "EntryScreen");
        
        let ResidentSelectsTestViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(ResidentSelectsTestViewController, animated: false, completion: nil)
    }else if screenName == "DashBoardViewController"{
        
        UserDefaults.standard.removeObject(forKey: "EntryScreen");

            let dashBoard = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

            self.present(dashBoard, animated: false, completion: nil)

    }else if screenName == "CareSelectViewController"{

        UserDefaults.standard.removeObject(forKey: "EntryScreen");

        let dashBoard = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(dashBoard, animated: false, completion: nil)

        
    }else if screenName == "OutcomeEntryViewController"{
        UserDefaults.standard.removeObject(forKey: "EntryScreen");

        let dashBoard = self.storyboard?.instantiateViewController(withIdentifier: "OutcomeEntryViewController") as! OutcomeEntryViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(dashBoard, animated: false, completion: nil)

        
    }else if screenName == "NotesViewController"{
        UserDefaults.standard.removeObject(forKey: "EntryScreen");

        let dashBoard = self.storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(dashBoard, animated: false, completion: nil)

        
    }else if screenName == "ScheduledVisits" {
        UserDefaults.standard.removeObject(forKey: "EntryScreen");
        
        let scheduledVisitsVc = self.storyboard?.instantiateViewController(withIdentifier: "ScheduledVisitsViewController") as! ScheduledVisitsViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        
        self.present(scheduledVisitsVc, animated: false, completion: nil)

    }else if screenName == "DetailedDescription" {
        UserDefaults.standard.removeObject(forKey: "EntryScreen");
        
        let detailedDescriptionVc = self.storyboard?.instantiateViewController(withIdentifier: "DetailedDescriptionsViewController") as! DetailedDescriptionsViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        
        self.present(detailedDescriptionVc, animated: false, completion: nil)
        
    }else if screenName == "OpenVisitsViewController" {
        
        UserDefaults.standard.removeObject(forKey: "EntryScreen");
        
        let openVisitsVc = self.storyboard?.instantiateViewController(withIdentifier: "OpenVisitsViewController") as! OpenVisitsViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        
        self.present(openVisitsVc, animated: false, completion: nil)
        
        }
        

        
    }
    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        imageView.frame = CGRect(x: screenWidth/53.571, y: screenHeight/12.127, width: screenWidth/1.041, height: screenHeight/1.938)
        
        searchButton.frame = CGRect(x: screenWidth/53.571, y: imageView.frame.origin.y+imageView.frame.size.height+screenHeight/37.055, width: screenWidth/1.041, height: screenHeight/12.826)
        
        contactsButton.frame = CGRect(x: screenWidth/53.571, y: searchButton.frame.origin.y+searchButton.frame.size.height+screenHeight/66.7, width: screenWidth/1.041, height: screenHeight/12.826)
        
        recentVisitsBtn.frame = CGRect(x: screenWidth/53.571, y: contactsButton.frame.origin.y+contactsButton.frame.size.height+screenHeight/66.7, width: screenWidth/1.041, height: screenHeight/12.826)
        
        cancelBtn.frame = CGRect(x: screenWidth/53.571, y: recentVisitsBtn.frame.origin.y+recentVisitsBtn.frame.size.height+screenHeight/66.7, width: screenWidth/1.041, height: screenHeight/12.826)
        
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
                            
                            print("Dash After")
                                let pauseButton = CancelButton(title: "Pause") {
                                    
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
                                                
                                                UIApplication.shared.isIdleTimerDisabled = true

                                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                                
                                                UserDefaults.standard.set([Int(dic?.value(forKey: "major") as! String)], forKey: "HallwayBeaconArray")
                                                
                                                UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                                UserDefaults.standard.set("", forKey: "Came From")

                                                self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: true)

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
                                                
                                                UIApplication.shared.isIdleTimerDisabled = true

                                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                                
                                                UserDefaults.standard.set([Int(dic?.value(forKey: "major") as! String)], forKey: "HallwayBeaconArray")
                                                
                                                UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                                UserDefaults.standard.set("", forKey: "Came From")

                                                self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: true)

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
