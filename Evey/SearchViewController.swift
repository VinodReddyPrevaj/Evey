//
//  SearchViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 24/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AudioToolbox
import AVFoundation
class SearchViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var startDate: UIButton!
    
    @IBOutlet weak var endDate: UIButton!
    
    @IBOutlet weak var visitType: UIButton!
    
    @IBOutlet weak var visit: UIButton!
    
    @IBOutlet weak var staffName: UIButton!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var residentName: UIButton!
    
    @IBOutlet weak var serviceSelect: UIButton!
    
    @IBOutlet weak var serviceArrow: UIButton!
    
    var upArrow = UIBarButtonItem()
    var downArrow = UIBarButtonItem()
    let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    var start = Bool()

    let datePicker: UIDatePicker = UIDatePicker()

    // Create date formatter
    let dateFormatter: DateFormatter = DateFormatter()

    var from = String()
    
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

        dataFeeding()
        
    }
    
    func dataFeeding(){
        
        
        dateFormatter.dateFormat = "MMM/dd/yyyy hh:mm a"
        let date = Date()
        let dateMinus24Hours = Calendar.current.date(byAdding: .hour, value: -24, to: date)
        
        if from == "Menu" {
            
            endDate.setTitle(self.dateFormatter.string(from: date), for: .normal)
            startDate.setTitle(self.dateFormatter.string(from: dateMinus24Hours!), for: .normal)
            
            Constants.selections["End Date"] = date
            Constants.selections["Start Date"] = dateMinus24Hours!
            
        }
        
        endDate.setTitle(dateFormatter.string(from: Constants.selections["End Date"] as! Date), for: .normal)
        
        startDate.setTitle(dateFormatter.string(from: Constants.selections["Start Date"] as! Date), for: .normal)
        
        
        if (Constants.selections["Cares"] as! NSArray).count > 1 {
            
            visit.setTitle("Multiple", for: .normal)
            
        }else if (Constants.selections["Cares"] as! NSArray).count == 1{
            
            visit.setTitle(((Constants.selections["Cares"] as! NSMutableArray)[0] as! NSDictionary).value(forKey: "name") as? String, for: .normal)
        }
        
        
        if (Constants.selections["VisitType"] as! NSArray).count > 1 {
            
            visitType.setTitle("Multiple", for: .normal)
            
        }else if (Constants.selections["VisitType"] as! NSArray).count == 1{
            
            visitType.setTitle(((Constants.selections["VisitType"] as! NSMutableArray)[0] as! NSDictionary).value(forKey: "name") as? String, for: .normal)
            
            if ((Constants.selections["VisitType"] as! NSMutableArray)[0] as! NSDictionary).value(forKey: "name") as? String == "Check-In" {
                let color  = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 1, alpha: 0.4337007705)
                serviceSelect.setTitle("Select", for: .normal)
                Constants.selections["Cares"] = NSMutableArray()
                serviceSelect.setTitleColor(color, for: .normal)
                serviceSelect.isUserInteractionEnabled = false
                serviceArrow.isUserInteractionEnabled = false
                
            }else{
                
                serviceSelect.isUserInteractionEnabled = true
                serviceArrow.isUserInteractionEnabled = true
                
            }
            
        }
        if (Constants.selections["Residents"] as! NSArray).count > 1 {
            
            residentName.setTitle("Multiple", for: .normal)
            
        }else if (Constants.selections["Residents"] as! NSArray).count == 1{
            
            residentName.setTitle(((Constants.selections["Residents"] as! NSMutableArray)[0] as! NSDictionary).value(forKey: "name") as? String, for: .normal)
        }
        if (Constants.selections["Staff"] as! NSArray).count > 1 {
            
            staffName.setTitle("Multiple", for: .normal)
            
        }else if (Constants.selections["Staff"] as! NSArray).count == 1{
            
            staffName.setTitle(((Constants.selections["Staff"] as! NSMutableArray)[0] as! NSDictionary).value(forKey: "name") as? String, for: .normal)
        }
        
        if Constants.validation == true {
            
            if (Constants.selections["VisitType"] as! NSArray).count == 0 {
                
                self.visitType.setTitleColor(.red, for: .normal)
            }
            if (Constants.selections["Cares"] as! NSMutableArray).count == 0 {
                if (Constants.selections["VisitType"] as! NSArray).count == 1 {
                    let array = Constants.selections["VisitType"] as! NSArray
                    
                    if (array[0] as! NSDictionary).value(forKey: "name") as! String != "Check-In" {
                        self.serviceSelect.setTitleColor(.red, for: .normal)
                    }else{
                        let color  = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 1, alpha: 0.4337007705)
                        serviceSelect.setTitle("Select", for: .normal)
                        Constants.selections["Cares"] = NSMutableArray()
                        serviceSelect.setTitleColor(color, for: .normal)
                    }
                }else{
                    self.serviceSelect.setTitleColor(.red, for: .normal)
                }
            }
            
            if (Constants.selections["Residents"] as! NSArray).count == 0 {
                self.residentName.setTitleColor(.red, for: .normal)
            }
            if (Constants.selections["Staff"] as! NSArray).count == 0 {
                self.staffName.setTitleColor(.red, for: .normal)
            }

        }
  
    }
    
    func selectionButtonSelction(_ sender: Any) {
        
    }
    


    func datePickerValueChanged(_ sender: UIDatePicker){
    
        // Set date format
        dateFormatter.dateFormat = "MMM/dd/yyyy hh:mm a"
    
        // Apply date format

        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        if start == true {
            startDate.setTitle(selectedDate, for: .normal)
            Constants.selections["Start Date"] = sender.date
            if sender.date >= dateFormatter.date(from: (endDate.titleLabel?.text)!)! && sender.date <= Calendar.current.date(byAdding: .hour, value: -24, to: Date())! {
                endDate.setTitle(dateFormatter.string(from: Calendar.current.date(byAdding: .hour, value: 24, to: sender.date)!), for: .normal)
                Constants.selections["End Date"] = Calendar.current.date(byAdding: .hour, value: 24, to: sender.date)!
            }
            
        }else{
            endDate.setTitle(selectedDate, for: .normal)
            Constants.selections["End Date"] = sender.date
            if sender.date <= dateFormatter.date(from: (startDate.titleLabel?.text)!)!{
                let dateMinus24Hours = Calendar.current.date(byAdding: .hour, value: -24, to: sender.date)
                startDate.setTitle(dateFormatter.string(from: dateMinus24Hours!), for: .normal)
                Constants.selections["Start Date"] = dateMinus24Hours

            }
        }
    
    }

    @IBAction func menuButtonAction(_ sender: Any) {
        
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
        Constants.validation = false
        self.present(menuViewController, animated: false, completion: nil)

    }
    @IBAction func backButtonAction(_ sender: Any) {
        
        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        Constants.selections["Residents"] = NSMutableArray()
        Constants.selections["VisitType"] = NSMutableArray()
        Constants.selections["Cares"] = NSMutableArray()
        Constants.selections["Staff"] = NSMutableArray()
        Constants.validation = false
        self.present(menu, animated: false, completion: nil)
        
    }
    @IBAction func searchButtonAction(_ sender: Any) {
        
        if searchButton.titleLabel?.text == "Done" {
            
            let dateColor = #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 1, alpha: 1)
            startDate.setTitleColor(dateColor, for: .normal)
            endDate.setTitleColor(dateColor, for: .normal)
            datePicker.removeFromSuperview()
            start = false
            searchButton.setTitle("Search", for: .normal)
            
        }else{
            print(Constants.selections)
            if (Constants.selections["VisitType"] as! NSArray).count > 0 && (Constants.selections["Residents"] as! NSArray).count > 0 && (Constants.selections["Staff"] as! NSArray).count > 0 {
                
                if (Constants.selections["VisitType"] as! NSArray).count > 0 {
                   
                    let array = Constants.selections["VisitType"] as! NSArray
                    if array.count == 1 {
                        if (array[0] as! NSDictionary).value(forKey: "name") as! String == "Check-In" {
                            //(array[0] as! NSDictionary).value(forKey: "name") as! String == "All"
                            Constants.validation = false
                            resultFunc()
                        }else{
                            if (Constants.selections["Cares"] as! NSArray).count > 0 {
                                Constants.validation = false
                                resultFunc()
                            }else{
                                let msg = "Plaese select all the required fields"
                                
                                let attString = NSMutableAttributedString(string: msg)
                                
                                popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                                })
                                let ok = CancelButton(title: "Ok", action: {
                                    self.serviceSelect.setTitleColor(.red, for: .normal)
                                })
                                popup.addButton(ok)
                                self.present(popup, animated: true, completion: nil)
                            }
                        }
                    }
                }
                
            }else{
                Constants.validation = true
                let msg = "Plaese select all the required fields"
                let attString = NSMutableAttributedString(string: msg)
                popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                })
                let ok = CancelButton(title: "Ok", action: {
                    if (Constants.selections["VisitType"] as! NSArray).count == 0 {
                        self.visitType.setTitleColor(.red, for: .normal)
                    }
                    if (Constants.selections["Cares"] as! NSMutableArray).count == 0 {
                        if (Constants.selections["VisitType"] as! NSArray).count == 1 {
                            let array = Constants.selections["VisitType"] as! NSArray
                            if (array[0] as! NSDictionary).value(forKey: "name") as! String != "Check-In" {
                                self.serviceSelect.setTitleColor(.red, for: .normal)
                            }
                        }else{
                            self.serviceSelect.setTitleColor(.red, for: .normal)
                        }
                    }
                    if (Constants.selections["Residents"] as! NSArray).count == 0 {
                        self.residentName.setTitleColor(.red, for: .normal)
                    }
                    if (Constants.selections["Staff"] as! NSArray).count == 0 {
                        self.staffName.setTitleColor(.red, for: .normal)
                    }
                })
                popup.addButton(ok)
                self.present(popup, animated: true, completion: nil)
            }
        }
        
    }
    func resultFunc(){
        
        let visitTypes = Constants.selections["VisitType"] as! NSArray
        var visitTypeNames = [String]()
        for typeOfVisit in visitTypes {
            visitTypeNames.append((typeOfVisit as! NSDictionary).value(forKey: "name") as! String)
        }
        if visitTypeNames.count == 1{
            if visitTypeNames[0] == "All" {
                visitTypeNames = ["Open", "Closed", "Check-In"]
            }else if visitTypeNames[0] == "Performed" {
                visitTypeNames = ["Closed"]
            }
        }
        let cares = Constants.selections["Cares"] as! NSMutableArray
        var careNames = [[String:String]]()
        for care in cares {
            
            careNames.append(["_id":(care as! NSDictionary).value(forKey: "id") as! String])
            
        }
        
        let residents = Constants.selections["Residents"] as! NSMutableArray
        var residentName = String()
        var residentNames = [[String:String]]()
        for resident in residents {
            
            residentNames.append(["_id" : (resident as! NSDictionary).value(forKey: "id") as! String])
            residentName = (resident as! NSDictionary).value(forKey: "name") as! String
        }
        
        
        let staff = Constants.selections["Staff"] as! NSMutableArray
        var staffName = String()
        var staffNames = [[String:String]]()
        for staf in staff {
            
            staffNames.append(["_id" : (staf as! NSDictionary).value(forKey: "id") as! String])
            staffName = (staf as! NSDictionary).value(forKey: "name") as! String
            
        }
        
        let searchList = ["start_date" : "\(Constants.selections["Start Date"] as! Date)","end_date": "\(Constants.selections["End Date"] as! Date)","care_type":visitTypeNames,"care_id":careNames,"resident_id":residentNames,"staff_id":staffNames] as [String : Any]
        
        print(searchList)
        
        let result = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        result.paramArray = searchList
        result.residentName = residentName
        result.staffNameStr = staffName
        result.startDateStr = Constants.selections["Start Date"] as! Date as NSDate
        result.endDateStr = Constants.selections["End Date"] as! Date as NSDate
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        self.present(result, animated: false, completion: nil)

    }

    @IBAction func startDateAction(_ sender: Any) {
        
        start = true
        startDate.setTitleColor(.red, for: .normal)
        // Posiiton date picket within a view
        datePicker.frame = CGRect(x: 0, y: startDate.frame.origin.y+startDate.frame.height+self.view.frame.height/66.7, width: self.view.frame.width, height: self.view.frame.height/2.223)
        
        // Set some of UIDatePicker properties
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        
        searchButton.setTitle("Done", for: .normal)
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMM/dd/yyyy hh:mm a"

        datePicker.maximumDate = Calendar.current.date(byAdding: .hour, value: -24, to: Date())

        // Add an event to call onDidChangeDate function when value is changed.
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        
        datePicker.setDate(dateformatter.date(from: (startDate.titleLabel?.text!)!)!, animated: true)
        // Add DataPicker to the view
        self.view.addSubview(datePicker)
        
    }
    
    @IBAction func endDateAction(_ sender: Any) {
        
        start = false
        endDate.setTitleColor(.red, for: .normal)
        
        // Posiiton date picket within a view
        datePicker.frame = CGRect(x: 0, y: endDate.frame.origin.y+startDate.frame.height+self.view.frame.height/66.7, width: self.view.frame.width, height: self.view.frame.height/2.223)
        
        // Set some of UIDatePicker properties
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        
        // Add an event to call onDidChangeDate function when value is changed.
        searchButton.setTitle("Done", for: .normal)

        datePicker.maximumDate = Calendar.current.date(byAdding: .minute, value: 0, to: Date())

        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMM/dd/yyyy hh:mm a"

        datePicker.setDate(dateFormatter.date(from: (endDate.titleLabel?.text)!)!, animated: true)
        
        // Add DataPicker to the view
        self.view.addSubview(datePicker)

    }
    
    
    @IBAction func arrowAction(_ sender: Any) {
        
        if (sender as! UIButton).tag == 0 {
            
            let selection = self.storyboard?.instantiateViewController(withIdentifier: "selectCareViewController") as! selectCareViewController
            selection.hint = "Visit Type"
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopRangingBeacons(in: region)
            locationManager.stopMonitoring(for: region)
            self.present(selection, animated: false, completion: nil)
            
        }else if (sender as! UIButton).tag == 1 {
            
            let selectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "selectCareViewController") as! selectCareViewController
            selectionViewController.hint = "Visits"
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopRangingBeacons(in: region)
            locationManager.stopMonitoring(for: region)
            self.present(selectionViewController, animated: false, completion: nil)
            
        }else if (sender as! UIButton).tag == 2{
            
            let selectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "selectCareViewController") as! selectCareViewController
            selectionViewController.hint = "Residents"
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopRangingBeacons(in: region)
            locationManager.stopMonitoring(for: region)
            self.present(selectionViewController, animated: false, completion: nil)
            
        }else{
            
            let selectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "selectCareViewController") as! selectCareViewController
            selectionViewController.hint = "Staff"
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopRangingBeacons(in: region)
            locationManager.stopMonitoring(for: region)
            self.present(selectionViewController, animated: false, completion: nil)
 
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
