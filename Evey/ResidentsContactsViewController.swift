//
//  ResidentsContactsViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 28/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import AudioToolbox
class ResidentsContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate,UISearchBarDelegate ,UIScrollViewDelegate,CLLocationManagerDelegate{
    @IBOutlet weak var residentsContactsTableView: UITableView!
    
    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var residentSelect: UILabel!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var buttonsViewBorder: UILabel!
    
    @IBOutlet weak var searchTop: UILabel!
    
    @IBOutlet weak var searchBottom: UILabel!
    
    let backGroundView = UIView()
    var timer: Timer?

    var audioPlayer = AVAudioPlayer()
    
    let roomUrl = Bundle.main.url(forResource: "Room", withExtension: "mp3")
    let hallwayUrl = Bundle.main.url(forResource: "Hallway", withExtension:"mp3")

    var swifeGesture = UISwipeGestureRecognizer()
     var tap = UITapGestureRecognizer()
    var residentContacts = [NSDictionary]()
    //["Edward J","Chris P"]
    let sectionIndexTitles = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
    @IBOutlet weak var searchBar: UISearchBar!
    var residentsSection = [String]()
    var residentsDict = [String:[NSDictionary]]()
    var filtered:[NSDictionary] = []
    var isSearch = false
    let cancelButton =  UIButton()
    let noResults = UILabel()
    
    var cameFrom = String()
    
    func generateResidentsDict(){
        for resident in Constants.residents {
            let dic = ["name":(resident as! NSDictionary).value(forKey: "name") as! String,"_id":(resident as! NSDictionary).value(forKey: "_id") as! String]
            residentContacts.append(dic as NSDictionary)
        }
        
        for resident in residentContacts {
            let residentNameArray = (resident.value(forKey: "name") as! String).components(separatedBy: " ")
            let key = "\(residentNameArray[1][residentNameArray[1].startIndex])"
            let lower = key.lowercased()
            if var residentValues = residentsDict[lower] {
                residentValues.append(resident)
                residentsDict[lower] = residentValues
            }else{
                residentsDict[lower] = [resident]
            }
        }
        residentsSection = [String](residentsDict.keys)
        residentsSection = residentsSection.sorted()
    }
    //for beacon Detection
    var acceptableDistance = Double()
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")

    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
    
    var beaconsArray = NSArray()
    var responseBeacon = NSDictionary()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        generateResidentsDict()
        noResults.text = "No Results"
        noResults.textColor = UIColor.black
        noResults.textAlignment = .center
        noResults.font = UIFont.boldSystemFont(ofSize: 21)
        noResults.frame = CGRect(x: 0, y: self.view.frame.height/2.785, width: self.view.frame.width, height: self.view.frame.height/16.675)
        noResults.isHidden = true

        self.cancelButton.frame = CGRect(x: self.view.frame.width, y: backGroundView.frame.origin.y, width: self.view.frame.width/5, height: backGroundView.frame.height)
        self.view.addSubview(self.cancelButton)
        searchBar.returnKeyType = UIReturnKeyType.search
        
        tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewWillBeginDragging(_:)))
        self.view.addGestureRecognizer(tap)
        residentsContactsTableView.addGestureRecognizer(tap)
        residentsContactsTableView.tableFooterView = UIView()
        
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
        if cameFrom == "Contacts Screen" {
        DispatchQueue.global().async {
            let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/residents")!
            let session = URLSession.shared
            let request = NSMutableURLRequest (url: url as URL)
            request.httpMethod = "Get"
            
            request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
            
            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                if let data = data {
                    
                    let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                    Constants.residents = re
                    self.residentContacts.removeAll()
                    self.residentsDict.removeAll()
                    DispatchQueue.main.async( execute: {
                        self.generateResidentsDict()
                        self.residentsContactsTableView.reloadData()
                    })
                }
            }
            task.resume()

        }
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true
        UIView.animate(withDuration: 2, animations: {
            searchBar.frame = CGRect(x: searchBar.frame.origin.x, y: searchBar.frame.origin.y, width: self.view.frame.width/1.25, height: searchBar.frame.height)

        }) { (true) in
            
        }
        self.cancelButton.setTitle("Cancel", for: .normal)
        self.cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        self.cancelButton.backgroundColor = UIColor.init(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        self.cancelButton.setTitleColor(UIColor(red: 94/255, green: 185/255, blue: 255/255, alpha: 1.0), for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.frame = CGRect(x: self.view.frame.width/1.25, y: self.backGroundView.frame.origin.y, width: self.view.frame.width/5, height: self.backGroundView.frame.height)
        }
        self.cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(self.cancelButton)
        
        
    }
    func cancel(){
        noResults.isHidden = true
        residentsContactsTableView.isHidden = false
        isSearch = false
        searchBar.text = nil
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBar.resignFirstResponder()

            self.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/15.159)
        }) { (true) in
        }
        UIView.animate(withDuration: 0.3, animations: { 
            self.cancelButton.frame = CGRect(x: self.view.frame.width, y: self.backGroundView.frame.origin.y, width: self.view.frame.width/5, height: self.backGroundView.frame.height)

        }) { (true) in
            self.residentsContactsTableView.reloadData()
        }
    }
    
    func dismissKeyboard(){
        
        searchBar.resignFirstResponder()
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (searchBar.text?.characters.count)! > 0 {
            searchBar.resignFirstResponder()
        }else{
            searchBar.resignFirstResponder()
            searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/15.159)
            self.cancelButton.frame = CGRect(x: self.view.frame.width, y: backGroundView.frame.origin.y, width: self.view.frame.width/5, height: backGroundView.frame.height)
        }

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
        searchBar.text = nil
        UIView.animate(withDuration: 0.3, animations: { 
            searchBar.resignFirstResponder()

        }) { (true) in
            
        }
        residentsContactsTableView.reloadData()

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            residentsContactsTableView.isHidden = false
            noResults.isHidden = true
            residentsContactsTableView.reloadData()
        }else{
            isSearch = true
            
            filtered = residentContacts.filter { ($0.value(forKey: "name") as! String).contains(searchText) }

            if filtered.count == 0 {
                residentsContactsTableView.isHidden = true
                noResults.isHidden = false

                self.view.addSubview(noResults)

            }else{
                noResults.isHidden = true
                residentsContactsTableView.isHidden = false
                residentsContactsTableView.reloadData()
            }
        }

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearch == true && (searchBar.text?.characters.count)! > 0{
            return 1
        }else{
        
        return residentsSection.count
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch == true && (searchBar.text?.characters.count)! > 0{
            
            return filtered.count
        }else{

        let residentKey = residentsSection[section]
        if let residentValues = residentsDict[residentKey] {
            return residentValues.count
        }
        return 0
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height/15.159
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ResidentVisitsTableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ResidentVisitsTableViewCell
        
        cell.residentName.frame = CGRect(x: 0, y: cell.contentView.frame.height/22, width: cell.contentView.frame.width, height: cell.contentView.frame.height/1.1)
        
        if  isSearch == true && (searchBar.text?.characters.count)! > 0
        {
            let fullName = filtered[indexPath.row].value(forKey: "name") as! String
            let fullNameArray = fullName.components(separatedBy: " ")
            let customString = NSMutableAttributedString(string: "\(fullName)");
            customString.addAttribute(NSFontAttributeName, value:(UIFont.init(name: ".SFUIText-Bold", size: 17))!, range: NSRange(location: fullNameArray[0].characters.count+1,length: fullNameArray[1].characters.count))
            cell.residentName.setAttributedTitle(customString, for: .normal)
            return cell
        }else{
            let residentKey = residentsSection[indexPath.section]
            if var residentValues = residentsDict[residentKey.lowercased()] {

                residentValues = residentValues.sorted {($0.value(forKey: "name") as! String) < ($1.value(forKey: "name") as! String)}
                let fullName = residentValues[indexPath.row].value(forKey: "name") as! String
                let fullNameArr = fullName.components(separatedBy: " ")
                let customString = NSMutableAttributedString(string: "\(residentValues[indexPath.row].value(forKey: "name") as! String)");
                customString.addAttribute(NSFontAttributeName, value:(UIFont.init(name: ".SFUIText-Bold", size: 17))!, range: NSRange(location: fullNameArr[0].characters.count+1,length: fullNameArr[1].characters.count))
                
                cell.residentName.setAttributedTitle(customString, for: .normal)
                
            }
            
            cell.residentName.addTarget(self, action: #selector(didSelectName(_:)), for: .touchUpInside)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            residentsContactsTableView.tableFooterView = UIView()
            //residentsContactsTableView.separatorInset = .zero

            return cell
        }

     }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearch == true && (searchBar.text?.characters.count)! > 0{
            return nil
        }else{
            return residentsSection[section].uppercased()
        }
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isSearch == true && (searchBar.text?.characters.count)! > 0{
            return nil
        }else{
        return sectionIndexTitles
        }
        
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let index = residentsSection.index(of: title.lowercased()) else{
            return -1
        }
        return index
    }
    func didSelectName(_ sender:Any) {
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.residentsContactsTableView)
        let indexpath: IndexPath? = self.residentsContactsTableView.indexPathForRow(at: buttonPosition)
        let cell: ResidentVisitsTableViewCell = residentsContactsTableView.cellForRow(at:(indexpath)!) as! ResidentVisitsTableViewCell
        
        let residentDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentDetailsViewController") as! ResidentDetailsViewController
        self.searchBar.resignFirstResponder()
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        
        residentDetailsVC.residentName = "\((cell.residentName.titleLabel?.text)!)"
        
        if  isSearch == true && (searchBar.text?.characters.count)! > 0
        {
            residentDetailsVC.residentID = filtered[(indexpath?.row)!].value(forKey: "_id") as! String
        }else{
            let residentKey = residentsSection[(indexpath?.section)!]
            var residentValues = residentsDict[residentKey.lowercased()]

            residentValues = residentValues?.sorted {($0.value(forKey: "name") as! String) < ($1.value(forKey: "name") as! String)}
            
            residentDetailsVC.residentID = residentValues?[(indexpath?.row)!].value(forKey: "_id") as! String

        }
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        self.present(residentDetailsVC, animated: false, completion: nil)

    }
    
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        let contactsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(contactsViewController, animated: false, completion: nil)
        
        
    }
    @IBAction func menuBtnAction(_ sender: Any) {
        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(menuViewController, animated: false, completion: nil)
    }

    func layOuts(){
        
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        eveyTitle.frame = CGRect(x: screenWidth/2.757, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.166, y: screenHeight/23.821, width: screenWidth/11.363, height: screenHeight/31.761)
        
        residentSelect.frame = CGRect(x: screenWidth/46.875, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/31.761, width: screenWidth/1.518, height: screenHeight/19.051)

        
        backGroundView.backgroundColor = UIColor.init(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        backGroundView.frame = CGRect(x: 0, y: residentSelect.frame.origin.y+residentSelect.frame.height+screenHeight/83.375, width: screenWidth, height: screenHeight/15.159)
        searchBar.frame = CGRect(x: 0, y: 0, width: screenWidth, height: backGroundView.frame.height)
        
        backGroundView.addSubview(searchBar)
        self.view.addSubview(backGroundView)
        
        searchTop.frame = CGRect(x: 0, y: backGroundView.frame.origin.y-1, width:backGroundView.frame.width, height: 1)

        searchBottom.frame = CGRect(x: 0, y: backGroundView.frame.origin.y+backGroundView.frame.height, width:searchBar.frame.width, height: 1)

        
        residentsContactsTableView.frame =  CGRect(x: 0, y: backGroundView.frame.origin.y+backGroundView.frame.size.height+screenHeight/133.4, width: screenWidth, height: screenHeight/1.485)
        
        buttonsView.frame = CGRect(x: 0, y: residentsContactsTableView.frame.origin.y+residentsContactsTableView.frame.size.height, width: screenWidth, height: screenHeight/12.584)
        
        
        cancelBtn.frame = CGRect(x: screenWidth/1.315, y: buttonsView.frame.size.height/4.818, width: screenWidth/5.281, height: buttonsView.frame.size.height/1.766)
        
        buttonsViewBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: buttonsView.frame.height/buttonsView.frame.height)
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
                
                print("final \(finalRSSI)")
                let base = Double(10)
                let power = Double(-57-(finalRSSI))/Double(10*2)
                let dis = pow(Double(base), power)
                print(dis)

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
