//
//  ResultViewController.swift
//  Evey
//
//  Created by PROJECTS on 31/05/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AudioToolbox
import AVFoundation
class ResultViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var resulttab: UITableView!
    
    @IBOutlet weak var startDate: UILabel!
    
    @IBOutlet weak var endDate: UILabel!
    
    @IBOutlet weak var residentNameLbl: UILabel!
    @IBOutlet weak var staffName: UILabel!
    
    @IBOutlet weak var scrollCol1: UILabel!
    
    @IBOutlet weak var scrollCol2: UILabel!
    
    @IBOutlet weak var scrollCol3: UILabel!
    
    @IBOutlet weak var scrollCol4: UILabel!
    
    @IBOutlet weak var scrollCol5: UILabel!
    
    var paramArray = [String:Any]()
    
    var residentName = String()
    
    var staffNameStr = String()
    
    var startDateStr = NSDate()
    
    var endDateStr = NSDate()
    
    var resultsArray = NSArray()
    
    var cellHeight = CGFloat()
    
    var noteWidth = CGFloat()
    
    var animation = UIImageView()
    
    //Beacon detection
    var timer: Timer?
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: true, completion: nil)
    
    var beaconsArray = NSArray()
    var responseBeacon = NSDictionary()
    
    var audioPlayer = AVAudioPlayer()
    
    let roomUrl = Bundle.main.url(forResource: "Room", withExtension: "mp3")
    let hallwayUrl = Bundle.main.url(forResource: "Hallway", withExtension:"mp3")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scroll.delegate = self
    
        scrollCol1.text = "DATE PERFORMED"
        scrollCol2.text = "SERVICE"
        scrollCol3.text = "OUTCOME"
        scrollCol4.text = "NOTES"
        scrollCol5.text = "TOTAL TIME"
        
        noteWidth = screenWidth/1.5
        layOuts()

        
        resulttab.tableFooterView = UIView()
        dataFeeding()
        
        DispatchQueue.global().async {
            self.loadingAnimation()
            let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/report/search")! //change the url
            
            //create the session object
            let session = URLSession.shared
            
            //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
            request.httpMethod = "POST" //set http method as POST
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: self.paramArray, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
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
                    var response = try! JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                    if response.count > 0 {
                        print(self.resultsArray)
                        DispatchQueue.main.async( execute: {
                            self.scrollCol1.isHidden = false
                            self.scrollCol2.isHidden = false
                            self.scrollCol3.isHidden = false
                            self.scrollCol4.isHidden = false
                            self.scrollCol5.isHidden = false
                            let px = 1 / UIScreen.main.scale
                            let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.size.width), height: CGFloat(px))
                            let line = UIView(frame: frame)
                            self.resulttab.tableHeaderView = line
                            line.backgroundColor = self.resulttab.separatorColor
                            self.animation.stopAnimating()
                            self.animation.isHidden = true
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"

                             response = response.sorted { (obj1, obj2) -> Bool in
                                
                                return (dateFormatter.date(from:(obj1 as! NSDictionary).value(forKey: "performed_date") as! String))! < (dateFormatter.date(from:(obj2 as! NSDictionary).value(forKey: "performed_date") as! String ))!
                                
                            } as NSArray

                            self.resultsArray = response
                            self.resulttab.reloadData()
                        })
                    }else{
                        DispatchQueue.main.async( execute: {
                            self.resulttab.isHidden = true
                            self.animation.stopAnimating()
                            self.animation.isHidden = true
                            self.scroll.contentSize = CGSize(width: screenWidth, height: self.scroll.frame.height)
                            let label = UILabel()
                            label.text = "No Results Found"
                            label.frame = CGRect(x: 0, y: (screenHeight/6), width: screenWidth, height: screenHeight/22.233)
                            label.textColor = .gray
                            label.textAlignment = .center
                            self.scroll.addSubview(label)
                            
                        })
                    }
                }
            })
            task.resume()
            
        }

        //BEACON Detection
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)
        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    }
    func loadingAnimation(){
        animation.frame = CGRect(x: 0, y: screenHeight/6, width: screenWidth/3.75, height: screenWidth/3.75)
        animation.animationImages = [#imageLiteral(resourceName: "frame_00"),#imageLiteral(resourceName: "frame_01"),#imageLiteral(resourceName: "frame_02"),#imageLiteral(resourceName: "frame_03"),#imageLiteral(resourceName: "frame_04"),#imageLiteral(resourceName: "frame_05"),#imageLiteral(resourceName: "frame_06"),#imageLiteral(resourceName: "frame_07"),#imageLiteral(resourceName: "frame_08"),#imageLiteral(resourceName: "frame_09"),#imageLiteral(resourceName: "frame_10")]
        animation.animationDuration = 0.7
        animation.startAnimating()
        animation.center.x = self.view.center.x
        self.scroll.addSubview(animation)
        
    }

    func dataFeeding(){
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMM dd, yyyy hh:mm a"
        startDate.text = dateformatter.string(from: startDateStr as Date)
        endDate.text = dateformatter.string(from: endDateStr as Date)
        residentNameLbl.text = residentName
        staffName.text = staffNameStr

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.resultsArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let care = resultsArray[indexPath.row] as! NSDictionary
        if (care.value(forKey: "care_notes") as! String).characters.count > 0 {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: scrollCol4.frame.width, height: 44)
            
            label.numberOfLines = 0
            
            label.text = care.value(forKey: "care_notes") as? String
            
            label.sizeToFit()
            
            label.frame = CGRect(x: 0, y: 0, width: scrollCol4.frame.width, height: label.frame.height)
            
            cellHeight = label.frame.height
            
            return label.frame.height
  
        }else{
            
            //cellHeight = resulttab.frame.height/7.272
            return resulttab.frame.height/7.272
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ResultTableViewCell()
        cell = self.resulttab.dequeueReusableCell(withIdentifier: "recell") as! ResultTableViewCell

        let care = resultsArray[indexPath.row] as! NSDictionary
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        let date = dateformatter.date(from: (care.value(forKey: "performed_date"))! as! String)
        dateformatter.dateFormat = "MMM dd, yy hh:mm a"
        
        // Apply date format
        
        let performedDate: String = dateformatter.string(from: date!)


        cell.col1.text = performedDate
        cell.col2.text = care.value(forKey: "care_name") as? String
        cell.col3.text = care.value(forKey: "care_value") as? String
        cell.col4.text = care.value(forKey: "care_notes") as? String
        //cell.col5.text = care.value(forKey: "total_minutes") as? String
        
        let totalminutes = care.value(forKey: "total_minutes") as! Double
        
        let seconds = totalminutes * Double(60)
        
        let total_hours = (Int(seconds) / 60) / 60
        
        
        let total_minutes = (Int(seconds) % 3600) / 60
        if total_hours > 0 {
            
            cell.col5.text = "\(total_hours) h \(total_minutes) min"
            
        }else{
            
            cell.col5.text = "\(total_minutes) minutes"
            
        }

        if (care.value(forKey: "care_notes") as! String).characters.count > 0 {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: scrollCol4.frame.width, height: 44)
            
            label.numberOfLines = 0
            
            label.text = care.value(forKey: "care_notes") as? String
            
            label.sizeToFit()
            
            label.frame = CGRect(x: 0, y: 0, width: scrollCol4.frame.width, height: label.frame.height)
            
            cellHeight = label.frame.height

        }else{
            cellHeight = resulttab.frame.height/7.272

        }
        //layOuts
        
        cell.col1.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/1.875, height: cellHeight)
        
        cell.col2.frame = CGRect(x: cell.col1.frame.origin.x+cell.col1.frame.width, y: 0, width: self.view.frame.width/2.5, height: cellHeight)
        
        cell.col3.frame = CGRect(x: cell.col2.frame.origin.x+cell.col2.frame.width, y: 0, width: self.view.frame.width/2.5, height: cellHeight)
        
        cell.col4.frame = CGRect(x: cell.col3.frame.origin.x+cell.col3.frame.width, y: 0, width: noteWidth, height: cellHeight)
        
        cell.col5.frame = CGRect(x: cell.col4.frame.origin.x+cell.col4.frame.width, y: 0, width: self.view.frame.width/2.5, height: cellHeight)

        cell.separatorInset = .zero
        
        cell.selectionStyle = .none
        return cell

    }
    func layOuts(){
        
        scrollCol1.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/1.875, height: screenHeight/15.159)
        scrollCol2.frame = CGRect(x: scrollCol1.frame.origin.x+scrollCol1.frame.width, y: 0, width: self.view.frame.width/2.5, height: screenHeight/15.159)
        scrollCol3.frame = CGRect(x: scrollCol2.frame.origin.x+scrollCol2.frame.width, y: 0, width: self.view.frame.width/2.5, height: screenHeight/15.159)
        scrollCol4.frame = CGRect(x: scrollCol3.frame.origin.x+scrollCol3.frame.width, y: 0, width: noteWidth, height: screenHeight/15.159)
        scrollCol5.frame = CGRect(x: scrollCol4.frame.origin.x+scrollCol4.frame.width, y: 0, width: self.view.frame.width/2.5, height: screenHeight/15.159)
        
        resulttab.frame = CGRect(x: 0, y: self.resulttab.frame.origin.y, width: scrollCol1.frame.width+scrollCol2.frame.width+scrollCol3.frame.width+scrollCol4.frame.width+scrollCol5.frame.width, height: self.resulttab.frame.height)
        
        scroll.frame = CGRect(x: 0, y: self.scroll.frame.origin.y, width: screenWidth, height: self.scroll.frame.height)
        
        self.scroll.contentSize = CGSize(width: self.scrollCol1.frame.width+self.scrollCol2.frame.width+self.scrollCol3.frame.width+self.scrollCol4.frame.width+self.scrollCol5.frame.width, height: self.scroll.frame.height)

    }

    @IBAction func doneAction(_ sender: Any) {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        searchVC.from = "Menu"
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        Constants.selections["Residents"] = NSMutableArray()
        Constants.selections["VisitType"] = NSMutableArray()
        Constants.selections["Cares"] = NSMutableArray()
        Constants.selections["Staff"] = NSMutableArray()
        
        self.present(searchVC, animated: false, completion: nil)

    }
    @IBAction func cancelAction(_ sender: Any) {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        searchVC.from = "Menu"
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        Constants.selections["Residents"] = NSMutableArray()
        Constants.selections["VisitType"] = NSMutableArray()
        Constants.selections["Cares"] = NSMutableArray()
        Constants.selections["Staff"] = NSMutableArray()

        self.present(searchVC, animated: false, completion: nil)

    }

    @IBAction func menu(_ sender: Any) {
        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        Constants.selections["Residents"] = NSMutableArray()
        Constants.selections["VisitType"] = NSMutableArray()
        Constants.selections["Cares"] = NSMutableArray()
        Constants.selections["Staff"] = NSMutableArray()
        self.present(menuViewController, animated: false, completion: nil)
 
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
