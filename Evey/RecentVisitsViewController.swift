//
//  RecentVisitsViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 23/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import AudioToolbox
class RecentVisitsViewController: UIViewController , UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var openBtn: UIButton!
    @IBOutlet weak var closedBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var recentVisitsLbl: UILabel!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var buttonsViewUpBorder: UILabel!
    
    @IBOutlet weak var visitsButtonsView: UIView!
    
    var screenNameStr = String()
    var tab1VC:OpenVisitsTableViewController! = nil
    var tab2VC:ClosedVisitsTableViewController! = nil
    var tab3VC:AllVisitsTableViewController! = nil
    
    private var pageController: UIPageViewController!
    private var arrVC:[UIViewController] = []
    private var currentPage: Int!
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
        let reversedClosedVisits = NSMutableArray()
        
        for arrayIndex in stride(from: Constants.recentClosedVisits.count - 1, through: 0, by: -1) {
            reversedClosedVisits.add(Constants.recentClosedVisits[arrayIndex])
        }
        Constants.recentClosedVisits = reversedClosedVisits

        for care in Constants.recentOpenVisits {
            Constants.recentAllVists.add(care as! NSDictionary)
        }
        
        for care in Constants.recentClosedVisits {
            Constants.recentAllVists.add(care as! NSDictionary)
        }

        currentPage = 0
        createPageViewController()
        segmentedController.addTarget(self, action: #selector(self.selectPageIndexBySegmentControl), for: UIControlEvents.valueChanged)
        segmentedController.layer.cornerRadius = segmentedController.frame.height/4.8333
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
        if screenNameStr.characters.count != 0{
        if screenNameStr == "Menu" {
            UserDefaults.standard.set("MenuViewController", forKey: "from")

        }else{
            UserDefaults.standard.set("ResidentSelect", forKey: "from")
        }
        
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.locationManager.stopMonitoring(for: region)
        self.locationManager.stopRangingBeacons(in: region)
        Constants.recentAllVists.removeAllObjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageController.reloadInputViews()
    }
    
    //MARK: - CreatePagination
    
    private func createPageViewController() {
        
        pageController = UIPageViewController.init(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
        
        pageController.view.backgroundColor = UIColor.clear
        pageController.delegate = self
        pageController.dataSource = self
        
        for svScroll in pageController.view.subviews as! [UIScrollView] {
            svScroll.delegate = self
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pageController.view.frame = CGRect(x: 0, y: self.segmentedController.frame.origin.y+self.segmentedController.frame.height+self.view.frame.height/66.7, width: self.view.frame.size.width, height: self.view.frame.height/1.437)
            
            
            self.buttonsView.frame = CGRect(x: 0, y: (self.pageController.view.frame.origin.y+self.pageController.view.frame.height), width: self.view.frame.width, height: self.view.frame.height/12.584)
            
            
            self.doneBtn.frame = CGRect(x: self.view.frame.width/1.306, y: self.buttonsView.frame.size.height/4.818, width: self.view.frame.width/5.281, height: self.buttonsView.frame.size.height/1.766)
            
            self.buttonsViewUpBorder.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)

        }
        
        let homeStoryboard = UIStoryboard(name: "Main", bundle: nil)
        tab1VC = homeStoryboard.instantiateViewController(withIdentifier: "OpenVisitsTableViewController") as! OpenVisitsTableViewController
        tab2VC = homeStoryboard.instantiateViewController(withIdentifier: "ClosedVisitsTableViewController") as! ClosedVisitsTableViewController
        tab3VC = homeStoryboard.instantiateViewController(withIdentifier: "AllVisitsTableViewController") as! AllVisitsTableViewController
        
        arrVC = [tab1VC, tab2VC, tab3VC]
        tab1VC.height = self.view.frame.height
        pageController.setViewControllers([tab1VC], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        self.addChildViewController(pageController)
        self.view.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
    }
    
    
    private func indexofviewController(viewCOntroller: UIViewController) -> Int {
        if(arrVC .contains(viewCOntroller)) {
            return arrVC.index(of: viewCOntroller)!
        }
        
        return -1
    }
    
    //MARK: - Pagination Delegate Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = indexofviewController(viewCOntroller: viewController)
        
        if(index != -1) {
            index = index - 1
        }
        
        if(index < 0) {
            return nil
        }
        else {
            return arrVC[index]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = indexofviewController(viewCOntroller: viewController)
        
        if(index != -1) {
            index = index + 1
        }
        
        if(index >= arrVC.count) {
            return nil
        }
        else {
            return arrVC[index]
        }
        
    }
    
    func pageViewController(_ pageViewController1: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if(completed) {
            currentPage = arrVC.index(of: (pageViewController1.viewControllers?.last)!)
            segmentedController.selectedSegmentIndex = currentPage
        }
        
    }
    
    //MARK: - Set Top bar after selecting Option from Top Tabbar

    @IBAction func cancelButton(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "from") as! String == "ResidentSelect" {
        //if screenNameStr == "ResidentSelect" {
          let residentSelect = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            view.window!.layer.add(transition, forKey: kCATransition)
            self.locationManager.stopMonitoring(for: region)
            self.locationManager.stopRangingBeacons(in: region)
            self.present(residentSelect, animated: false, completion: nil)
        }else{
            let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            view.window!.layer.add(transition, forKey: kCATransition)
            self.locationManager.stopMonitoring(for: region)
            self.locationManager.stopRangingBeacons(in: region)

            self.present(menuViewController, animated: false, completion: nil)
 
        }
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        self.locationManager.stopMonitoring(for: region)
        self.locationManager.stopRangingBeacons(in: region)
        
        self.present(menuViewController, animated: false, completion: nil)
    }
    
    @IBAction func menuBtnAction(_ sender: Any) {
        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.locationManager.stopMonitoring(for: region)
        self.locationManager.stopRangingBeacons(in: region)

        self.present(menuViewController, animated: false, completion: nil)
    }
    func layOuts(){
        
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        backBtn.frame = CGRect(x: screenWidth/23.437, y: screenHeight/23, width: screenWidth/18.75, height: screenHeight/33.35)
        
        eveyTitle.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.size.width+screenWidth/3.712, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.213, y: screenHeight/23.437, width: screenWidth/11.363, height: screenHeight/31.761)
        
        
        recentVisitsLbl.frame = CGRect(x: screenWidth/23.437, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/66.7, width: screenWidth/1.518, height: screenHeight/21.516)
        
        segmentedController.frame = CGRect(x: screenWidth/23.437, y: recentVisitsLbl.frame.origin.y+recentVisitsLbl.frame.height+screenHeight/55.583, width: screenWidth/1.093, height: screenHeight/19.057)
    }
    func selectPageIndexBySegmentControl(){
        
        switch segmentedController.selectedSegmentIndex {
        case 0:
            
            pageController.setViewControllers([arrVC[0]], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
            currentPage = 0
            
        case 1:
            if currentPage > 1{
                pageController.setViewControllers([arrVC[1]], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
                currentPage = 1
            }else{
                pageController.setViewControllers([arrVC[1]], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
                currentPage = 1
                
            }
        case 2:
            if currentPage < 2 {
                pageController.setViewControllers([arrVC[2]], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
                currentPage = 2
                
                
            }else{
                pageController.setViewControllers([arrVC[2]], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
                currentPage = 2
                
            }
        default:
            break
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
                                
                                self.locationManager.stopRangingBeacons(in: region)
                                self.locationManager.stopMonitoring(for: region)

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
                                locationManager.stopRangingBeacons(in: region)
                                locationManager.stopMonitoring(for: region)
                                Times.Previous_End_Time.removeAll()
                                
                                UserDefaults.standard.set([responseBeacon.value(forKey: "_id")], forKey: "PreviousBeaconArray")
                                
                                popup.dismiss(animated: true, completion: {
                                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    self.timer?.invalidate()
                                })// comletion of popup
                                
                                
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
                            
                            print("Dash After")
                                let pauseButton = CancelButton(title: "Pause") {
                                    UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                    self.timer?.invalidate()

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
                            print("hallway Beacon Count\(hallwayBeaconArray.count)")
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
