//
//  ResidentDetailsViewController.swift
//  Evey
//
//  Created by PROJECTS on 06/02/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import AudioToolbox
class ResidentDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {

    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var residentLbl: UILabel!
    
    @IBOutlet weak var residentNameBtn: UIButton!
    
    @IBOutlet weak var residentNameLbl: UILabel!
    
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var homeLbl: UILabel!
    
    @IBOutlet weak var numberBtn: UIButton!
    
    @IBOutlet weak var borderLbl: UILabel!
    
    @IBOutlet weak var addressTextView: UITextView!
    
    @IBOutlet weak var residentVisitsTableView: UITableView!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var buttonViewBorder: UILabel!
    
    @IBOutlet weak var residentNameBorder: UILabel!
    
    @IBOutlet weak var homeBorder: UILabel!
    
    var residentName = "vinod Reddy"
    
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

    var residentID = String()

    let headerView = UIView()

    var residentDictionary = NSDictionary()
    
    var sectionsArray = [String]()

    var openVisitsArray = NSMutableArray()
    var closedVisitsArray = NSMutableArray()
    var scheduledVisitsArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        statusImage.isHidden = true
        residentVisitsTableView.delegate = self
        residentVisitsTableView.dataSource = self
        residentVisitsTableView.tableFooterView = UIView(frame: .zero)

        residentNameLbl.text =  residentName
        let stringInputArr = residentName.components(separatedBy:" ")
        var stringNeed = ""
        
        for string in stringInputArr {
            stringNeed = stringNeed + String(string.characters.first!)
        }
        let image = UIImageView()
        self.headerView.addSubview(image)

        residentNameBtn.setTitle(stringNeed, for: .normal)
        
        for resident in Constants.residents {
            if (resident as! NSDictionary).value(forKey: "_id") as! String == residentID {
                residentDictionary = resident as! NSDictionary
            }
        }
        
        residentNameLbl.text = "\(residentDictionary.value(forKey: "name") as! String).\(residentDictionary.value(forKey: "room") as! String)"
        
        numberBtn.setTitle("\(residentDictionary.value(forKey: "home_phone") as! String)", for: .normal)
        
        let residentDic = Constants.residents.filter { ($0 as! NSDictionary).value(forKey: "_id") as! String == residentID }
        if (residentDic[0] as! NSDictionary).value(forKey: "avadar") as! String != "" {
            self.residentNameBtn.isHidden = true
            image.animationImages = [#imageLiteral(resourceName: "frame_00"),#imageLiteral(resourceName: "frame_01"),#imageLiteral(resourceName: "frame_02"),#imageLiteral(resourceName: "frame_03"),#imageLiteral(resourceName: "frame_04"),#imageLiteral(resourceName: "frame_05"),#imageLiteral(resourceName: "frame_06"),#imageLiteral(resourceName: "frame_07"),#imageLiteral(resourceName: "frame_08"),#imageLiteral(resourceName: "frame_09"),#imageLiteral(resourceName: "frame_10")]
            image.animationDuration = 0.7
            image.startAnimating()

            let url = URL(string: (residentDic[0] as! NSDictionary).value(forKey: "avadar") as! String)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    image.stopAnimating()
                    image.image = UIImage(data: data!)
                    image.clipsToBounds = true
                    image.layer.cornerRadius = image.frame.height/2
                }
            }
            
        }

        DispatchQueue.global().async {
            let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/residents/\(self.residentID)")!
            let session = URLSession.shared
            let request = NSMutableURLRequest (url: url as URL)
            request.httpMethod = "Get"
            
            request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
            
            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                if let data = data {
                    let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    let cares = re.value(forKey: "cares") as! NSArray
                
                    DispatchQueue.main.async( execute: {
                        for care in cares {
                            if (care as! NSDictionary).value(forKey: "care_status") as! String == "Closed" {
                                self.closedVisitsArray.add(care as! NSDictionary)
                            }else{
                                
                                self.openVisitsArray.add(care as! NSDictionary)
                            }
                        }

                        if self.openVisitsArray.count > 0 && self.closedVisitsArray.count > 0{
                            self.statusImage.isHidden = false
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
                            
                             self.openVisitsArray = self.openVisitsArray.sorted { (obj1, obj2) -> Bool in
                                
                                return (dateFormatter.date(from:((((obj1 as! NSDictionary).value(forKey: "total_time"))) as! NSDictionary).value(forKey: "start") as! String))! < (dateFormatter.date(from:((((obj2 as! NSDictionary).value(forKey: "total_time"))) as! NSDictionary).value(forKey: "start") as! String ))!
                            } as! NSMutableArray
                            self.closedVisitsArray = self.closedVisitsArray.sorted { (obj1, obj2) -> Bool in
                                
                                return (dateFormatter.date(from:((((obj1 as! NSDictionary).value(forKey: "total_time"))) as! NSDictionary).value(forKey: "start") as! String))! > (dateFormatter.date(from:((((obj2 as! NSDictionary).value(forKey: "total_time"))) as! NSDictionary).value(forKey: "start") as! String ))!
                                } as! NSMutableArray

                            self.sectionsArray.append("Open Visits")
                            self.sectionsArray.append("Visits Today")
                            
                        }else if self.openVisitsArray.count > 0 {
                            self.statusImage.isHidden = false

                            self.sectionsArray.append("Open Visits")
                            
                        }else if self.closedVisitsArray.count > 0 {
                            let str = "Visits Today"
                            self.sectionsArray.append(str)
                            
                        }
                        if self.sectionsArray.count > 0 {
                            self.residentVisitsTableView.reloadData()
                            print(self.openVisitsArray)
                        }
                    })
                }
            }
            task.resume()
            
        }

        
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

        let floorNum = residentDictionary.value(forKey: "floor_no") as! Int
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        let floor = formatter.string(from: NSNumber(integerLiteral: floorNum))
        
        addressTextView.text = "\(floor!) floor, \n\(residentDictionary.value(forKey: "sector_name") as! String), \n\(residentDictionary.value(forKey: "fac_name") as! String), \n\(residentDictionary.value(forKey: "org_name") as! String)."
        
        layOuts()
        image.frame =  self.residentNameBtn.frame

        //statusImage .isHidden = true

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch sectionsArray[section] {
        case "Visits Today":
            return closedVisitsArray.count
            
        case "Open Visits":
            return openVisitsArray.count
        default:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heignt = CGFloat()
        switch sectionsArray[indexPath.section] {
        case "Visits Today":
            var resident = NSDictionary()
            
            resident = closedVisitsArray[indexPath.row] as! NSDictionary
            if resident.value(forKey: "care_id") as! String == "5ab5064971a5957989df4f21" {
                
                heignt = self.residentVisitsTableView.frame.height/6.6
                
            }else{
                heignt = self.residentVisitsTableView.frame.height/5.317

                
            }
        case "Open Visits":
            heignt = self.residentVisitsTableView.frame.height/5.317
        default : break
        }
        return heignt
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ResidentVisitsTableViewCell()
        switch sectionsArray[indexPath.section] {
        case "Visits Today":
            var resident = NSDictionary()
            
            resident = closedVisitsArray[indexPath.row] as! NSDictionary
            print(resident)
            print(resident.value(forKey: "care_type") as! String)
            if resident.value(forKey: "care_id") as! String == "5ab5064971a5957989df4f21" {
                cell = tableView.dequeueReusableCell(withIdentifier: "Check-In", for: indexPath) as! ResidentVisitsTableViewCell
                let cellWidth =  cell.contentView.frame.size.width
                let cellHeight = cell.contentView.frame.size.height
                
                let _name = "\(residentDictionary.value(forKey: "name") as! String).\(residentDictionary.value(forKey: "room") as! String)"
                
                cell.checkinResidentName.text = _name
                
                let totalminutes = resident.value(forKey: "total_minutes") as! Double
                
                let seconds = totalminutes * Double(60)
                
                let total_hours = (Int(seconds) / 60) / 60
                
                
                let total_minutes = (Int(seconds) % 3600) / 60
                if total_hours > 0 {
                    
                    cell.checkinTime.text = "\(total_hours) hours \(total_minutes) minutes"
                    
                }else{
                    
                    cell.checkinTime.text = "\(total_minutes) minutes"
                    
                }
                
                cell.checkInTypeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/6.733, width: cellWidth/25, height: cellWidth/25)
                
                cell.checkinResidentName.frame = CGRect(x: cell.checkInTypeImage.frame.origin.x+cell.checkInTypeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.148)
                
                cell.checkinService.frame = CGRect(x: cellWidth/46, y: cell.checkinResidentName.frame.origin.y+cell.checkinResidentName.frame.size.height-cellHeight/25.25, width: cellWidth/6.677, height: cellHeight/4.391)
                
                cell.checkinImage.frame = CGRect(x: cell.checkinService.frame.origin.x+cell.checkinService.frame.size.width+cellWidth/82.8, y: cell.checkinService.frame.origin.y, width: cellWidth/18.818, height: cellWidth/18.818)
                
                cell.checkinServiceLabel.frame = CGRect(x: cell.checkinImage.frame.origin.x+cell.checkinImage.frame.size.width+cellWidth/46, y: cell.checkinResidentName.frame.origin.y+cell.checkinResidentName.frame.size.height-cellHeight/25.25, width: cellWidth/4.019, height: cellHeight/4.391)
                
                cell.time.frame = CGRect(x: cellWidth/46, y: cell.checkinService.frame.origin.y+cell.checkinService.frame.size.height+cellHeight/cellHeight, width: cellWidth/9.615, height: cellHeight/4.391)
                
                cell.checkinTime.frame = CGRect(x: cell.time.frame.origin.x+cell.time.frame.size.width, y: cell.checkinService.frame.origin.y+cell.checkinService.frame.size.height+cellHeight/cellHeight, width: cellWidth-(cell.time.frame.origin.x+cell.time.frame.width), height: cellHeight/4.391)
                
                cell.separatorInset = UIEdgeInsets.zero
                
                return cell
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ResidentVisitsTableViewCell
                
                resident = closedVisitsArray[indexPath.row] as! NSDictionary
                let cellWidth =  cell.contentView.frame.size.width
                let cellHeight = cell.contentView.frame.size.height
                
                cell.pauseTime.text = "End time:"
                cell.totalTimeSpent.text = "Total time spent:"
                
                let _name = "\(residentDictionary.value(forKey: "name") as! String).\(residentDictionary.value(forKey: "room") as! String)"
                
                let care = resident.value(forKey: "care_id") as! String
                
                //let _care = care.value(forKey: "name") as! String
                
                var careIds = NSDictionary()
                
                let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                
                if let careIDs = careIDs {
                    careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                }
                
                let care_Id = careIds.allKeys(for: care) as NSArray
                let _care = care_Id.firstObject as! String
                
                let careType = resident.value(forKey: "care_type") as! String
                
                var _typeImage = String()
                if careType == "Track" {
                    _typeImage = "performedVisitIcon"
                    
                }else if careType == "Schedule" {
                    _typeImage = "scheduledPerformedVisitIcon"
                    
                }
                
                let timeTrack = resident.value(forKey: "total_time") as! NSDictionary
                
                
                let startTime = timeTrack.value(forKey: "start") as! String
                
                let endTime = timeTrack.value(forKey: "end") as! String
                
                
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
                
                let startDate = dateformatter.date(from: startTime)
                
                let endDate = dateformatter.date(from: endTime)
                
                let calendar = Calendar.current
                
                cell.residentNameLbl.text = _name
                cell.typeImage.image = UIImage(named: _typeImage)
                cell.serviceImage.image = UIImage(named: _care)
                cell.serviceNameLabel.text = _care
                
                if calendar.component(.minute, from: startDate!) < 10 {
                    let hours = calendar.component(.hour, from: startDate!)
                    if hours > 12 {
                        cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!) - 12):0\(calendar.component(.minute, from: startDate!)) PM"
                    }else if hours == 12{
                        
                        cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):0\(calendar.component(.minute, from: startDate!)) PM"
                        
                    }else{
                        cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):0\(calendar.component(.minute, from: startDate!)) AM"
                    }
                }else{
                    let hours = calendar.component(.hour, from: startDate!)
                    if hours > 12 {
                        
                        cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!) - 12):\(calendar.component(.minute, from: startDate!)) PM"
                        
                    }else if hours == 12 {
                        cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):\(calendar.component(.minute, from: startDate!)) PM"
                    }else{
                        cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):\(calendar.component(.minute, from: startDate!)) AM"
                    }
                    
                }
                if calendar.component(.minute, from: endDate!) < 10 {
                    let hours = calendar.component(.hour, from: endDate!)
                    
                    if hours > 12 {
                        
                        cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):0\(calendar.component(.minute, from: endDate!)) PM"
                        
                        
                    }else if hours == 12 {
                        
                        cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) PM"
                        
                    }else {
                        
                        cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) AM"
                        
                    }
                }else{
                    let hours = calendar.component(.hour, from: endDate!)
                    
                    if hours > 12 {
                        
                        cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):\(calendar.component(.minute, from: endDate!)) PM"
                        
                    }else if hours == 12 {
                        
                        cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) PM"
                        
                        
                    }else{
                        cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) AM"
                        
                    }
                    
                }
                let totalminutes = resident.value(forKey: "total_minutes") as! Double
                
                let seconds = totalminutes * Double(60)
                
                let total_hours = (Int(seconds) / 60) / 60
                
                
                let total_minutes = (Int(seconds) % 3600) / 60
                if total_hours > 0 {
                    
                    cell.totalTimeSpentLbl.text = "\(total_hours) hours \(total_minutes) minutes"
                    
                }else{
                    
                    cell.totalTimeSpentLbl.text = "\(total_minutes) minutes"
                    
                }
                
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                // layOuts
                
                cell.typeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/7.8, width: cellWidth/25, height: cellWidth/25)
                
                cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.680)
                
                cell.serviceLbl.frame = CGRect(x: cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/6.677, height: cellHeight/5.478)
                
                cell.serviceImage.frame = CGRect(x: cell.serviceLbl.frame.origin.x+cell.serviceLbl.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/18, width: cellWidth/15.333, height: cellWidth/15.333)
                
                cell.serviceNameLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/4.019, height: cellHeight/5.478)
                
                cell.startTime.frame = CGRect(x: cellWidth/46, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.111, height: cellHeight/5.478)
                
                cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
                
                
                cell.pauseTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+screenWidth/37.5, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cell.pauseTime.frame.width, height: cellHeight/5.478)
                
                cell.pauseTime.sizeToFit()
                
                cell.pauseTime.frame = CGRect(x: cell.pauseTime.frame.origin.x, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cell.pauseTime.frame.width, height: cellHeight/5.478)
                
                cell.pauseTimeLbl.frame = CGRect(x: cell.pauseTime.frame.origin.x+cell.pauseTime.frame.size.width, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
                
                cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.234, height: cellHeight/5.478)
                
                cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/4.224, height: cellHeight/5.478)
            

                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets.zero
                residentVisitsTableView.tableFooterView = UIView()
                return cell
            }

        case "Open Visits":
        cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ResidentVisitsTableViewCell
        var resident = NSDictionary()
        
        cell.pauseTimeLbl.text = "Pause time:"
        cell.totalTimeSpent.text = "Staff Member:"
        let cellWidth =  cell.contentView.frame.size.width
        let cellHeight = cell.contentView.frame.size.height
        
        resident = openVisitsArray[indexPath.row] as! NSDictionary
        
        let _name = "\(residentDictionary.value(forKey: "name") as! String).\(residentDictionary.value(forKey: "room") as! String)"

        
        let care = resident.value(forKey: "care_id") as! String
        
        //let _care = care.value(forKey: "name") as! String
        
        var careIds = NSDictionary()
        
        let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
        
        if let careIDs = careIDs {
            careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
        }
        
        let care_Id = careIds.allKeys(for: care) as NSArray
        let _care = care_Id.firstObject as! String

        let careType = resident.value(forKey: "care_type") as! String
        
        var _typeImage = String()
        if careType == "Track" {
            
            _typeImage = "openVisitIcon"
            
        }else if careType == "Schedule" {
            
            _typeImage = "scheduledOpenVisitIcon"
            
        }
        
        let timeTrack = resident.value(forKey: "total_time") as! NSDictionary
        
        let startTime = timeTrack.value(forKey: "start") as! String
        
        let endTime = timeTrack.value(forKey: "end") as! String
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        
        let startDate = dateformatter.date(from: startTime)
        
        let endDate = dateformatter.date(from: endTime)
        
        let calendar = Calendar.current
        
        //let user = resident.value(forKey: "user") as! NSDictionary
        
        cell.residentNameLbl.text = _name
        cell.typeImage.image = UIImage(named: _typeImage)
        cell.serviceImage.image = UIImage(named: _care)
        cell.serviceNameLabel.text = _care
        
        if calendar.component(.minute, from: startDate!) < 10 {
            let hours = calendar.component(.hour, from: startDate!)
            if hours > 12 {
                cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!) - 12):0\(calendar.component(.minute, from: startDate!)) PM"
            }else if hours == 12{
                
                cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):0\(calendar.component(.minute, from: startDate!)) PM"
                
            }else{
                cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):0\(calendar.component(.minute, from: startDate!)) AM"
            }
        }else{
            let hours = calendar.component(.hour, from: startDate!)
            if hours > 12 {
                
                cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!) - 12):\(calendar.component(.minute, from: startDate!)) PM"
                
            }else if hours == 12 {
                cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):\(calendar.component(.minute, from: startDate!)) PM"
            }else{
                cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):\(calendar.component(.minute, from: startDate!)) AM"
            }
            
        }
        if calendar.component(.minute, from: endDate!) < 10 {
            let hours = calendar.component(.hour, from: endDate!)
            
            if hours > 12 {
                
                cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):0\(calendar.component(.minute, from: endDate!)) PM"
                
                
            }else if hours == 12 {
                
                cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) PM"
                
            }else {
                
                cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) AM"
                
            }
        }else{
            let hours = calendar.component(.hour, from: endDate!)
            
            if hours > 12 {
                
                cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):\(calendar.component(.minute, from: endDate!)) PM"
                
            }else if hours == 12 {
                
                cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) PM"
                
                
            }else{
                cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) AM"
                
            }
            
        }
        cell.totalTimeSpentLbl.text = resident.value(forKey: "user_name") as? String
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // layOuts
        
        cell.typeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/7.8, width: cellWidth/25, height: cellWidth/25)
        
        cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.680)
        
        cell.serviceLbl.frame = CGRect(x: cellWidth/46, y:cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/6.677, height: cellHeight/5.478)
        
        cell.serviceImage.frame = CGRect(x: cell.serviceLbl.frame.origin.x+cell.serviceLbl.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/18, width: cellWidth/15.333, height: cellWidth/15.333)
        
        cell.serviceNameLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/4.019, height: cellHeight/5.478)
        
        cell.startTime.frame = CGRect(x: cellWidth/46, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.111, height: cellHeight/5.478)
        
        cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
        
        
        cell.pauseTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+screenWidth/37.5, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cell.pauseTime.frame.width, height: cellHeight/5.478)
        
        cell.pauseTimeLbl.frame = CGRect(x: cell.pauseTime.frame.origin.x+cell.pauseTime.frame.size.width, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
        
        cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.234, height: cellHeight/5.478)
        cell.totalTimeSpent.sizeToFit()
        cell.totalTimeSpent.frame = CGRect(x:cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cell.totalTimeSpent.frame.width, height: cellHeight/5.478)
        cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width+1, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: screenWidth-(cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.width), height: cellHeight/5.478)
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets.zero
        residentVisitsTableView.tableFooterView = UIView()
        return cell
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ResidentVisitsTableViewCell
            return cell

        }
        

//        if residentName == "Edward J" {
//            cell = residentVisitsTableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath) as! ResidentVisitsTableViewCell
//                    let cellWidth =  cell.contentView.frame.size.width
//                    let cellHeight = cell.contentView.frame.size.height
//            
//            if indexPath.row == 0 {
//                cell.scheduleServiceImage.image=UIImage(named:"Bathing")
//                cell.scheduleServiceName.text="Bathing"
//                cell.scheduleNextServiceDate.text = "June 3,9:00 AM - 10:00 AM"
//
//            }else {
//                cell.scheduleServiceImage.image=UIImage(named:"Eye Drops")
//                cell.scheduleServiceName.text="Eye Drops"
//                cell.scheduleNextServiceDate.text = "June 3,11:00 AM - 12:00 PM"
//            }
//            
//                    cell.scheduleResidentName.frame = CGRect(x: cellWidth/34.5, y: cellHeight/19, width: cellWidth/2.049, height: cellHeight/3.677)
//            
//                    cell.scheduledService.frame = CGRect(x: cellWidth/34.5, y: cell.scheduleResidentName.frame.origin.y+cell.scheduleResidentName.frame.size.height+cellHeight/42, width: cellWidth/6.677, height: cellHeight/5.478)
//            
//                    cell.scheduleServiceImage.frame = CGRect(x: cell.scheduledService.frame.origin.x+cell.scheduledService.frame.size.width+cellWidth/82.8, y: cell.scheduleResidentName.frame.origin.y+cell.scheduleResidentName.frame.size.height+cellHeight/42, width: cellWidth/15.333, height: cellWidth/15.333)
//            
//                    cell.scheduleServiceName.frame = CGRect(x: cell.scheduleServiceImage.frame.origin.x+cell.scheduleServiceImage.frame.size.width+cellWidth/46, y: cell.scheduleResidentName.frame.origin.y+cell.scheduleResidentName.frame.size.height+cellHeight/42, width: cellWidth/4.019, height: cellHeight/5.478)
//            
//                    cell.scheduleStart.frame = CGRect(x: cellWidth/34.5, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/10.35, height: cellHeight/5.428)
//            
//                    cell.scheduleStartDate.frame = CGRect(x: cell.scheduleStart.frame.origin.x+cell.scheduleStart.frame.size.width, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/5.914, height: cellHeight/5.428)
//            
//                    cell.scheduleEnd.frame = CGRect(x: cell.scheduleStartDate.frame.origin.x+cell.scheduleStartDate.frame.size.width, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/12.937, height: cellHeight/5.428)
//            
//                    cell.scheduleEndDate.frame = CGRect(x: cell.scheduleEnd.frame.origin.x+cell.scheduleEnd.frame.size.width, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/5.914, height: cellHeight/5.428)
//            
//                    cell.scheduleFrequency.frame = CGRect(x: cell.scheduleEndDate.frame.origin.x+cell.scheduleEndDate.frame.size.width, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/5.240, height: cellHeight/5.428)
//            
//                    cell.scheduleFrequencyType.frame = CGRect(x: cell.scheduleFrequency.frame.origin.x+cell.scheduleFrequency.frame.size.width, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/4.6, height: cellHeight/5.428)
//            
//                    cell.scheduleNextService.frame = CGRect(x: cellWidth/34.5, y: cell.scheduleStart.frame.origin.y+cell.scheduleStart.frame.size.height, width: cellWidth/3.066, height: cellHeight/5.428)
//                    
//                    cell.scheduleNextServiceDate.frame = CGRect(x: cell.scheduleNextService.frame.origin.x+cell.scheduleNextService.frame.size.width, y: cell.scheduleStart.frame.origin.y+cell.scheduleStart.frame.size.height, width: cellWidth-(cell.scheduleNextService.frame.width+cell.scheduleNextService.frame.origin.x), height: cellHeight/5.428)
//
//        }else{
//        cell = residentVisitsTableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ResidentVisitsTableViewCell
//        
//        let cellWidth =  cell.contentView.frame.size.width
//        let cellHeight = cell.contentView.frame.size.height
//            if indexPath.row == 0 {
//                cell.typeImage.image = UIImage(named:"openVisitIcon")
//                
//                cell.serviceNameLabel.text="Treatments"
//                cell.serviceImage.image=UIImage(named:"Treatments")
//            }else{
//                
//                cell.typeImage.image = UIImage(named:"performedVisitIcon")
//                cell.serviceImage.image=UIImage(named:"Escort")
//                cell.serviceNameLabel.text="Escort"
//                cell.startTimeLbl.text = "3:35 PM"
//                cell.pauseTime.text = "End time:"
//                cell.pauseTime.sizeToFit()
//                cell.pauseTimeLbl.text = "4:25 PM"
//                cell.totalTimeSpentLbl.text = "50 minutes"
//
//            }
//        
//        cell.typeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/10.5, width: cellWidth/18.818, height: cellWidth/18.818)
//        
//        cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.680)
//        
//        cell.serviceLbl.frame = CGRect(x: cellWidth/46, y: cell.typeImage.frame.origin.y+cell.typeImage.frame.size.height+cellHeight/14, width: cellWidth/6.677, height: cellHeight/5.478)
//        
//        cell.serviceImage.frame = CGRect(x: cell.serviceLbl.frame.origin.x+cell.serviceLbl.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/18, width: cellWidth/15.333, height: cellWidth/15.333)
//        
//        cell.serviceNameLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/4.019, height: cellHeight/5.478)
//        
//        cell.startTime.frame = CGRect(x: cellWidth/46, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.111, height: cellHeight/5.478)
//        
//        cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
//        
//        
//        cell.pauseTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+screenWidth/37.5, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cell.pauseTime.frame.width, height: cellHeight/5.478)
//        
//        cell.pauseTimeLbl.frame = CGRect(x: cell.pauseTime.frame.origin.x+cell.pauseTime.frame.size.width, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
//        
//        cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.234, height: cellHeight/5.478)
//        
//        cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/4.224, height: cellHeight/5.478)
//        }
//        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return CGFloat(self.residentVisitsTableView.frame.height/26.285)
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: self.tableView.frame.height/29.130))
//        let title = UILabel(frame: CGRect(x: self.tableView.frame.width/45, y: 0, width: tableView.bounds.size.width, height: headerView.bounds.size.height))
//        title.font = UIFont.systemFont(ofSize:17, weight: UIFontWeightMedium)
//        if (section==0) {
//            if sectionsArray[section] == "Visits Today" {
//                title.text="Visits Today"
//                title.textColor = UIColor.init(red: 104.0/255.0, green: 111.0/255.0, blue: 118.0/255.0, alpha: 1.0)
//                headerView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
//            }else{
//                title.text="Open Visits"
//                
//                title.textColor = UIColor.white
//                headerView.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.462745098, blue: 0.7333333333, alpha: 1)
//            }
//            
//            //  headerView.backgroundColor = UIColor.init(red: 29.0/255.0, green: 118.0/255.0, blue: 187.0/255.0, alpha: 1.0)
//            
//        }
//            //        else if(section==1){
//            //            title.text="Scheduled Care"
//            //            title.textColor = UIColor.init(red: 100.0/255.0, green: 187.0/255.0, blue: 214/255.0, alpha: 1.0)
//            //            headerView.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.9098039216, blue: 0, alpha: 1)
//            //            //headerView.backgroundColor = UIColor.init(red: 254.0/255.0, green: 232.0/255.0, blue: 0.0/255.0, alpha: 1.0)
//            //
//            //        }
//        else{
//            title.text="Visits Today"
//            title.textColor = UIColor.init(red: 104.0/255.0, green: 111.0/255.0, blue: 118.0/255.0, alpha: 1.0)
//            headerView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
//            // headerView.backgroundColor = UIColor.init(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
//            
//        }
//        headerView .addSubview(title)
//        
//        return headerView
//    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: self.residentVisitsTableView.frame.height/26.285))
        let title = UILabel(frame: CGRect(x: self.residentVisitsTableView.frame.width/27.6, y: 0, width: tableView.bounds.size.width, height: headerView.bounds.size.height))
            title.font = UIFont.systemFont(ofSize:17, weight: UIFontWeightMedium)
        if (section==0) {
            if sectionsArray[section] == "Visits Today" {
                title.text="Visits Today"
                title.textColor = UIColor.init(red: 104.0/255.0, green: 111.0/255.0, blue: 118.0/255.0, alpha: 1.0)
                headerView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            }else{
                title.text="Open Visits"
                
                title.textColor = UIColor.white
                headerView.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.462745098, blue: 0.7333333333, alpha: 1)
            }
            
            
        }else{
            title.text="Visits Today"
            title.textColor = UIColor.init(red: 104.0/255.0, green: 111.0/255.0, blue: 118.0/255.0, alpha: 1.0)
            headerView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            
        }
        headerView.addSubview(title)
        
        return headerView
    }
    func layOuts(){
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        backBtn.frame = CGRect(x: screenWidth/23.437, y: screenHeight/23, width: screenWidth/18.75, height: screenHeight/33.35)
        
        eveyTitle.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.size.width+screenWidth/3.712, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.213, y: screenHeight/23.437, width: screenWidth/11.363, height: screenHeight/31.761)

        //header heaight 397    fhvbsdfhj   62
        
        residentLbl.frame = CGRect(x: screenWidth/23.437, y: screenHeight/66.7, width: screenWidth/1.518, height: screenHeight/19.057)
        
        residentNameBorder.frame = CGRect(x: 0, y: residentLbl.frame.origin.y+residentLbl.frame.height+screenHeight/74.111, width: screenWidth, height: 1)
        residentNameBtn.frame = CGRect(x: screenWidth/2.622, y: residentLbl.frame.origin.y+residentLbl.frame.height+screenHeight/29, width: screenWidth/4.166, height: screenWidth/4.166)
        
        residentNameBtn.layer.cornerRadius = residentNameBtn.frame.height/2
        
        residentNameLbl.frame = CGRect(x: screenWidth/23.437, y: residentNameBtn.frame.origin.y+residentNameBtn.frame.height+screenHeight/66.7, width: screenWidth/1.093, height: screenHeight/18.527)
        
        statusImage.frame = CGRect(x: screenWidth/2.118, y: residentNameLbl.frame.origin.y+residentNameLbl.frame.height+screenHeight/83.375, width: screenWidth/25, height: screenWidth/25)
        
        homeBorder.frame = CGRect(x: 0, y: statusImage.frame.origin.y+statusImage.frame.height+screenHeight/35.105, width: screenWidth, height: 1)
        
        homeLbl.frame = CGRect(x: screenWidth/23.437, y: homeBorder.frame.origin.y+homeBorder.frame.height+screenHeight/60.636, width: screenWidth/2.313, height: screenHeight/29)
        
        numberBtn.frame = CGRect(x: screenWidth/23.437, y: homeLbl.frame.origin.y+homeLbl.frame.height, width: screenWidth/1.363, height: screenHeight/29)
        
        borderLbl.frame = CGRect(x: 0, y: numberBtn.frame.origin.y+numberBtn.frame.height+screenHeight/74.111, width: screenWidth, height: 1)
        
        addressTextView.frame = CGRect(x: screenWidth/34.090, y: borderLbl.frame.origin.y+borderLbl.frame.height, width: screenWidth/1.062, height: 100)
       
        //addressTextView.text = "home \n2421 Windcove Manner \nRoom 1209 \nWashington DC, 87780"
        
        var frame = self.addressTextView.frame
        frame.size.height = self.addressTextView.contentSize.height
        self.addressTextView.frame = frame
                
        headerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: addressTextView.frame.origin.y+addressTextView.frame.height)
        headerView.addSubview(residentLbl)
        headerView.addSubview(residentNameBorder)
        headerView.addSubview(residentNameBtn)
        headerView.addSubview(residentNameLbl)
        headerView.addSubview(statusImage)
        headerView.addSubview(homeBorder)
        headerView.addSubview(homeLbl)
        headerView.addSubview(numberBtn)
        headerView.addSubview(borderLbl)
        let label = UILabel()
        label.frame = CGRect(x: 0, y: addressTextView.frame.origin.y+addressTextView.frame.height, width: self.view.frame.width, height: 1)
        label.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        headerView.addSubview(label)
        headerView.addSubview(addressTextView)

        residentVisitsTableView.tableHeaderView = headerView

        residentVisitsTableView.frame = CGRect(x: 0, y: screenHeight/10.758, width: screenWidth, height: screenHeight/1.208)
        
        buttonView.frame = CGRect(x: 0, y: residentVisitsTableView.frame.origin.y+residentVisitsTableView.frame.height, width: screenWidth, height: screenHeight/12.584)
        buttonViewBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        backButton.frame = CGRect(x: screenWidth/1.315, y: buttonView.frame.height/5.3, width: screenWidth/5.281, height: buttonView.frame.height/1.606)
        
    }
    @IBAction func menuBtnAction(_ sender: Any) {
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(menuVC, animated: false, completion: nil)
 
        
    }
    @IBAction func backButtonAction(_ sender: Any) {
        
        let residentContactsVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentsContactsViewController") as! ResidentsContactsViewController
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(residentContactsVC, animated: false, completion: nil)

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
