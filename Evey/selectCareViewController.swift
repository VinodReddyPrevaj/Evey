//
//  selectCareViewController.swift
//  Evey
//
//  Created by PROJECTS on 25/05/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AudioToolbox
import AVFoundation
class selectCareViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {

    @IBOutlet weak var selectionsTableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    let visitType = ["All","Open", "Performed", "Check-In"]
        //["All", "Check-In", "Performed", "Refused", "Notes", "On", "Off", "Out-of-Facility", "Call Nurse"]
    
    let visits = ["Bathing", "Whrilpool", "Escort", "TEDS", "Room Trays", "ACCU", "AM/PM Care", "Treatments", "Eye Drops", "Medication", "Toileting", "Blood Pressure", "Medication Reminder", "Room Cleaning", "Laundry", "Medication Set-Up", "Fall", "Check-In"]
    
    var residents = NSArray()
    
    var staff = NSArray()
    
    var visitTypeSelection = NSMutableArray()
    
    var careSelection = NSMutableArray()
    
    var residentSelection = NSMutableArray()
    
    var staffSelection = NSMutableArray()
    
    var hint = String()
    
    var selectedVisitType = NSMutableArray()
    var selectedVisitTypeNames = NSMutableArray()
   
    var selectedCares = NSMutableArray()
    var selectedCareNames = NSMutableArray()

    var selectedResidents = NSMutableArray()
    var selectedResidentsID = NSMutableArray()

    var selectedStaff = NSMutableArray()
    var selectedStaffID = NSMutableArray()

    var task = URLSessionDataTask()
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

    var animation = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //Inserting Line top of TableView
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.size.width), height: CGFloat(px))
        let line = UIView(frame: frame)
        self.selectionsTableView.tableHeaderView = line
        line.backgroundColor = self.selectionsTableView.separatorColor

        switch hint {
            
        case "Visit Type":
            
            titleLabel.text = "Select Visit Type"
            let selections = Constants.selections["VisitType"] as! NSMutableArray
            
            for item in selections {
                selectedVisitType.add(item)
                selectedVisitTypeNames.add((item as! NSDictionary).value(forKey: "name") as! String)
            }
            
        case "Visits":
            
            titleLabel.text = "Select Visit"
            let selections = Constants.selections["Cares"] as! NSMutableArray
            for item in selections {
                selectedCares.add(item)
                selectedCareNames.add((item as! NSDictionary).value(forKey: "name") as! String)

            }

        case "Residents":
            
            titleLabel.text = "Select Resident"
            let selections = Constants.selections["Residents"] as! NSMutableArray
            if selections.count == 0 {
                loadingAnimation()
            }
            for item in selections {
                selectedResidents.add(item)
                selectedResidentsID.add((item as! NSDictionary).value(forKey: "id") as! String)
            }

        case "Staff":
            titleLabel.text = "Select Staff"
            let selections = Constants.selections["Staff"] as! NSMutableArray
            if selections.count == 0 {
                loadingAnimation()
            }
            for item in selections {
                selectedStaff.add(item)
                selectedStaffID.add((item as! NSDictionary).value(forKey: "id") as! String)
            }

        default:
            break
            
        }
        selectionsTableView.tableFooterView = UIView()
        if hint == "Residents" {
            DispatchQueue.global().async {
                let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/residents")!
                let session = URLSession.shared
                let request = NSMutableURLRequest (url: url as URL)
                request.httpMethod = "Get"
                
                request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                
                self.task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                    if let data = data {
                        
                        let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                        
                        self.residents = re
                        DispatchQueue.main.async( execute: {
                            self.animation.stopAnimating()
                            self.animation.isHidden = true
                            self.selectionsTableView.reloadData()
                        })
                    }
                }
                self.task.resume()
                
            }
        }else if hint == "Staff" {
            DispatchQueue.global().async {
                let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/users")!
                let session = URLSession.shared
                let request = NSMutableURLRequest (url: url as URL)
                request.httpMethod = "Get"
                
                request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                
                self.task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                    if let data = data {
                        
                        let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                        self.staff = re

                        DispatchQueue.main.async( execute: {
                            self.animation.stopAnimating()
                            self.animation.isHidden = true
                            self.selectionsTableView.reloadData()
                        })
                    }
                }
                self.task.resume()
                
            }

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        //task.cancel()
        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.locationManager.stopMonitoring(for: region)
        self.locationManager.stopRangingBeacons(in: region)
        Constants.selections["Residents"] = NSMutableArray()
        Constants.selections["VisitType"] = NSMutableArray()
        Constants.selections["Cares"] = NSMutableArray()
        Constants.selections["Staff"] = NSMutableArray()
        self.present(menuViewController, animated: false, completion: nil)

    }
    func loadingAnimation(){
        animation.frame = CGRect(x: 0, y: screenHeight/5, width: screenWidth/3.75, height: screenWidth/3.75)
        animation.animationImages = [#imageLiteral(resourceName: "frame_00"),#imageLiteral(resourceName: "frame_01"),#imageLiteral(resourceName: "frame_02"),#imageLiteral(resourceName: "frame_03"),#imageLiteral(resourceName: "frame_04"),#imageLiteral(resourceName: "frame_05"),#imageLiteral(resourceName: "frame_06"),#imageLiteral(resourceName: "frame_07"),#imageLiteral(resourceName: "frame_08"),#imageLiteral(resourceName: "frame_09"),#imageLiteral(resourceName: "frame_10")]
        animation.animationDuration = 0.7
        animation.startAnimating()
        animation.center.x = self.view.center.x
        self.selectionsTableView.addSubview(animation)

    }

    @IBAction func cancelButtonAction(_ sender: Any) {
       // task.cancel()
        let selectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController

        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.locationManager.stopMonitoring(for: region)
        self.locationManager.stopRangingBeacons(in: region)
        self.present(selectionViewController, animated: false, completion: nil)

    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        switch hint {
        case "Visit Type":
            Constants.selections["VisitType"] = selectedVisitType
        case "Visits":
            Constants.selections["Cares"] = selectedCares
        case "Residents":
            Constants.selections["Residents"] = selectedResidents
        case "Staff":
            Constants.selections["Staff"] = selectedStaff

        default:
            break
        }

        let selectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(selectionViewController, animated: false, completion: nil)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch hint {
        case "Visit Type":
            return visitType.count
        case "Visits":
            return Constants.careIDs.count
        case "Residents":
            return residents.count
        case "Staff":
            return staff.count
        default:
            return 0
        }

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = selectionTableViewCell()
        cell = self.selectionsTableView.dequeueReusableCell(withIdentifier: "selectionCell") as! selectionTableViewCell
        
        cell.selectionButton.setImage(#imageLiteral(resourceName: "selected").withRenderingMode(.alwaysOriginal), for: .selected)
        cell.selectionButton.addTarget(self, action: #selector(selectionButtonSelction(_:)), for: .touchUpInside)
        cell.rowButton.addTarget(self, action: #selector(selectionButtonSelction(_:)), for: .touchUpInside)
        switch hint {
            
        case "Visit Type":
            
            cell.nameLabel.text = visitType[indexPath.row]
            if selectedVisitTypeNames.contains(visitType[indexPath.row]) {
                if cell.selectionButton.isSelected == false {
                    cell.selectionButton.isSelected = true
                }
            }
            
        case "Visits":
            
            cell.nameLabel.text = (Constants.careIDs[indexPath.row] as! NSDictionary).value(forKey: "name") as? String 
            if selectedCareNames.contains((Constants.careIDs[indexPath.row] as! NSDictionary).value(forKey: "name") as! String) {
                if cell.selectionButton.isSelected == false {
                    cell.selectionButton.isSelected = true
                }
            }else{
                cell.selectionButton.isSelected = false
            }

        case "Residents":
            
            cell.nameLabel.text = "\((residents[indexPath.row] as! NSDictionary).value(forKey: "first_name") as! String) \((residents[indexPath.row] as! NSDictionary).value(forKey: "last_name") as! String).\((residents[indexPath.row] as! NSDictionary).value(forKey: "room") as! String)"
            
            if selectedResidentsID.contains((residents[indexPath.row] as! NSDictionary).value(forKey: "_id") as! String) {
                if cell.selectionButton.isSelected == false {
                    cell.selectionButton.isSelected = true
                }

            }else{
                cell.selectionButton.isSelected = false
            }

        case "Staff":
            
            cell.nameLabel.text = "\((staff[indexPath.row] as! NSDictionary).value(forKey: "first_name") as! String) \((staff[indexPath.row] as! NSDictionary).value(forKey: "last_name") as! String)"
            
            if selectedStaffID.contains((staff[indexPath.row] as! NSDictionary).value(forKey: "_id") as! String) {
                if cell.selectionButton.isSelected == false {
                    cell.selectionButton.isSelected = true
                }
                
            }else{
                cell.selectionButton.isSelected = false
            }
            
        default:
            break
        }
        cell.selectionButton.frame = CGRect(x: screenWidth/34.090, y: cell.contentView.frame.height/6.285, width: screenWidth/13.392, height: screenWidth/13.392)
        
        cell.selectionButton.layer.cornerRadius = cell.selectionButton.frame.height/2
        cell.selectionButton.layer.borderWidth = 2
        let borderColor = #colorLiteral(red: 0.8666666667, green: 0.8745098039, blue: 0.8823529412, alpha: 1)
        cell.selectionButton.layer.borderColor = borderColor.cgColor

        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets.zero
        return cell
    }
    
    func selectionButtonSelction(_ sender: Any) {
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.selectionsTableView)
        let indexpath: IndexPath? = self.selectionsTableView.indexPathForRow(at: buttonPosition)
        let cell: selectionTableViewCell = selectionsTableView.cellForRow(at:(indexpath)!) as! selectionTableViewCell

        if cell.selectionButton.isSelected == false {

            switch hint {
                
            case "Visit Type":
                
                if selectedVisitTypeNames.contains("All") {
                    let indexPath = IndexPath(row: 0, section: 0)
                    
                    let cell: selectionTableViewCell = selectionsTableView.cellForRow(at: indexPath) as! selectionTableViewCell
                    cell.selectionButton.isSelected = false
                    selectedVisitTypeNames.remove("All")
                    var obj = NSDictionary()
                    for element in selectedVisitType {
                        if (element as! NSDictionary).value(forKey: "name") as! String == "All" {
                            obj = element as! NSDictionary
                        }
                    }
                    selectedVisitType.remove(obj)
                }else if selectedVisitTypeNames.contains("Check-In") {
                    let indexPath = IndexPath(row: 3, section: 0)
                    
                    let cell: selectionTableViewCell = selectionsTableView.cellForRow(at: indexPath) as! selectionTableViewCell
                    cell.selectionButton.isSelected = false
                    selectedVisitTypeNames.remove("Check-In")
                    var obj = NSDictionary()
                    for element in selectedVisitType {
                        if (element as! NSDictionary).value(forKey: "name") as! String == "Check-In" {
                            obj = element as! NSDictionary
                        }
                    }
                    selectedVisitType.remove(obj)
                }

                if cell.nameLabel.text == "All" {
                    
                    for element in selectedVisitType {
                    
                        let cell: selectionTableViewCell = selectionsTableView.cellForRow(at: (element as! NSDictionary).value(forKey: "index") as! IndexPath) as! selectionTableViewCell
                        cell.selectionButton.isSelected = false
                    }
                    selectedVisitTypeNames.removeAllObjects()
                    selectedVisitType.removeAllObjects()

                }else if cell.nameLabel.text == "Check-In" {
                    for element in selectedVisitType {
                        
                        let cell: selectionTableViewCell = selectionsTableView.cellForRow(at: (element as! NSDictionary).value(forKey: "index") as! IndexPath) as! selectionTableViewCell
                        cell.selectionButton.isSelected = false
                    }
                    selectedVisitTypeNames.removeAllObjects()
                    selectedVisitType.removeAllObjects()
                    
                }

                selectedVisitType.add(["name":cell.nameLabel.text!,"index":indexpath!])
                selectedVisitTypeNames.add(cell.nameLabel.text!)
                
            case "Visits":
                selectedCares.add(["name":cell.nameLabel.text!,"index":indexpath!,"id":(Constants.careIDs[(indexpath?.row)!] as! NSDictionary).value(forKey: "id")])
                
                    selectedCareNames.add((Constants.careIDs[(indexpath?.row)!] as! NSDictionary).value(forKey: "name") as!String)
                
            case "Residents":
                
                if selectedResidents.count > 0 {
                    
                    let indexPath = (selectedResidents[0] as! NSDictionary).value(forKey: "index") as! IndexPath
                    
                    let cell: selectionTableViewCell = selectionsTableView.cellForRow(at: indexPath) as! selectionTableViewCell
                    cell.selectionButton.isSelected = false
                    selectedResidents.removeAllObjects()
                    selectedResidentsID.removeAllObjects()
                    
                }

                selectedResidents.add(["name":"\((residents[(indexpath?.row)!] as! NSDictionary).value(forKey: "first_name") as! String) \((residents[(indexpath?.row)!] as! NSDictionary).value(forKey: "last_name") as! String).\((residents[(indexpath?.row)!] as! NSDictionary).value(forKey: "room") as! String)","id":"\((residents[(indexpath?.row)!] as! NSDictionary).value(forKey: "_id") as! String)","index":indexpath!])
                
                selectedResidentsID.add((residents[(indexpath?.row)!] as! NSDictionary).value(forKey: "_id") as! String)
                
            case "Staff":
                
                if selectedStaff.count > 0 {
                    
                let indexPath = (selectedStaff[0] as! NSDictionary).value(forKey: "index") as! IndexPath
                
                let cell: selectionTableViewCell = selectionsTableView.cellForRow(at: indexPath) as! selectionTableViewCell
                cell.selectionButton.isSelected = false
                selectedStaff.removeAllObjects()
                selectedStaffID.removeAllObjects()
                    
                }
                selectedStaff.add(["name":"\((staff[(indexpath?.row)!] as! NSDictionary).value(forKey: "first_name") as! String) \((staff[(indexpath?.row)!] as! NSDictionary).value(forKey: "last_name") as! String)","id":"\((staff[(indexpath?.row)!] as! NSDictionary).value(forKey: "_id") as! String)","index":indexpath!])
                
                selectedStaffID.add((staff[(indexpath?.row)!] as! NSDictionary).value(forKey: "_id") as! String)
                
                

            default:
                break
            }
            cell.selectionButton.isSelected = true
        }else{
            
            switch hint {
            case "Visit Type":
                
                cell.selectionButton.isSelected = false
                
                if cell.nameLabel.text == "All" {

                    selectedVisitTypeNames.removeAllObjects()
                    selectedVisitType.removeAllObjects()
                    
                }else{
                    var obj = NSDictionary()
                    for element in selectedVisitType {
                        if (element as! NSDictionary).value(forKey: "name") as? String == cell.nameLabel.text
                        {
                            obj = element as! NSDictionary
                        }
                    }
                    selectedVisitType.remove(obj)

                    selectedVisitTypeNames.remove(cell.nameLabel.text!)
                }
                
            case "Visits":
                var obj = NSDictionary()

                for element in selectedCares {
                    if (element as! NSDictionary).value(forKey: "name") as? String == cell.nameLabel.text
                    {
                        obj = element as! NSDictionary

                    }
                    
                }
                selectedCares.remove(obj)

                selectedCareNames.remove((Constants.careIDs[(indexpath?.row)!] as! NSDictionary).value(forKey: "id") as! String)

                
            case "Residents":
                var obj = NSDictionary()
                for element in selectedResidents {
                    if (element as! NSDictionary).value(forKey: "id") as! String == (residents[(indexpath?.row)!] as! NSDictionary).value(forKey: "_id") as! String {
                        obj = element as! NSDictionary
                    }
                }
                selectedResidents.remove(obj)

                selectedResidentsID.remove((residents[(indexpath?.row)!] as! NSDictionary).value(forKey: "_id") as! String)
                                
            case "Staff":
                var obj = NSDictionary()
                for element in selectedStaff {
                    if (element as! NSDictionary).value(forKey: "id") as! String == (staff[(indexpath?.row)!] as! NSDictionary).value(forKey: "_id") as! String {
                        obj = element as! NSDictionary
                    }
                }
                selectedStaff.remove(obj)
                
                selectedStaffID.remove((staff[(indexpath?.row)!] as! NSDictionary).value(forKey: "_id") as! String)
                
            default:
                break
            }
            
            cell.selectionButton.isSelected = false
        }
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
