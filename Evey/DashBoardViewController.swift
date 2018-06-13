//
//  DashBoardViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 26/09/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AudioToolbox
import AVFoundation
import CoreBluetooth
class DashBoardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource ,UIScrollViewDelegate,CLLocationManagerDelegate,CBCentralManagerDelegate{
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet weak var announceLbl: UILabel!
    
    @IBOutlet weak var announceTV: UITextView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eveyTitle: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var desView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var timer: Timer?

    var sectionsArray = [String]()
    var openVisitsArray = NSArray()
    var closedVisitsArray = NSArray()
    var scheduledVisitsArray = NSArray()
    
    let headerView = UIView()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    let cell = VisitsTableViewCell()
    var cellHeight = CGFloat()
    
    var beaconsArray = NSArray()
    var responseBeacon = NSDictionary()

    // for beacon detection
    
    var acceptableDistance = Double()

    var popup = PopupDialog(title: "", message:NSAttributedString(), buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
        
    }
    var announcementString = String()
    
    var announcement = Bool()
    
    var rssiLabel = UILabel()
    
    var audioPlayer = AVAudioPlayer()
    
    let roomUrl = Bundle.main.url(forResource: "Room", withExtension: "mp3")
    let hallwayUrl = Bundle.main.url(forResource: "Hallway", withExtension:"mp3")
    
    let image = UIImageView()

    var centralManager: CBCentralManager!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        startScanning()

        beaconsDataFromServer()
        
        self.todayCaresFromServer()
        image.frame = CGRect(x: 0, y: screenHeight/3.510, width: screenWidth/3.75, height: screenWidth/3.75)
        image.animationImages = [#imageLiteral(resourceName: "frame_00"),#imageLiteral(resourceName: "frame_01"),#imageLiteral(resourceName: "frame_02"),#imageLiteral(resourceName: "frame_03"),#imageLiteral(resourceName: "frame_04"),#imageLiteral(resourceName: "frame_05"),#imageLiteral(resourceName: "frame_06"),#imageLiteral(resourceName: "frame_07"),#imageLiteral(resourceName: "frame_08"),#imageLiteral(resourceName: "frame_09"),#imageLiteral(resourceName: "frame_10")]
        image.animationDuration = 0.7
        image.startAnimating()
        image.center = self.view.center
        self.tableView.addSubview(image)
        layOuts()
        
        //audioPlayer = AVAudioPlayer(contentsOfURL: pianoSound, error: nil)

        rssiLabel.frame = desView.frame
        acceptableDistance = 2.0
        
        if announcementString.characters.count > 0 {
        }
        if announcementString.contains("</p><p>") || announcementString.contains("<p>"){
            announcementString = announcementString.replacingOccurrences(of: "</p><p>", with: "\n")
            announcementString = announcementString.replacingOccurrences(of: "<p>", with: "")
            announcementString = announcementString.replacingOccurrences(of: "</p>", with: "")
            announcementString = announcementString.replacingOccurrences(of: "<br>", with: "")

        }
        
        let rssiLbl = UILabel()
        rssiLbl.frame = self.desView.frame
        self.desView.addSubview(rssiLbl)

        cellHeight = tableView.frame.height/5.317
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognizerAction(_gesture:)))
        self.desView.addGestureRecognizer(panGestureRecognizer)
        
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)
        
       // let attrStr = try? NSAttributedString(data: announcementString.data(using: String.Encoding.unicode)!, options:[ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        descriptionTextView.isScrollEnabled = true
        descriptionTextView.text = announcementString

        descriptionTextView.textColor = .white
        
        descriptionTextView.font = UIFont(name: "San Francisco Display", size: 20)
        descriptionTextView.sizeToFit()
        desView.addSubview(descriptionTextView)

        descriptionTextView.isScrollEnabled = false
        var frame = descriptionTextView.frame
        frame.size.height = descriptionTextView.contentSize.height
        descriptionTextView.frame = frame

        desView.frame = CGRect(x: desView.frame.origin.x, y: desView.frame.origin.y, width: desView.frame.width, height: descriptionTextView.frame.height+descriptionTextView.frame.origin.y+descriptionTextView.frame.origin.y)

        headerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: desView.frame.origin.y+desView.frame.height)

        if UserDefaults.standard.value(forKey: "Status") as! String == "false" || announcementString.characters.count == 0{
            self.desView.isHidden=true
            headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/5.841)
            tableView.tableHeaderView = headerView
            
        }
        if Constants.dashBoard == true {
            nameLabel.isHidden = true
            self.desView.isHidden=true

            welcomeLabel.text = "Dashboard"
            headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/9.528)
            tableView.tableHeaderView = headerView
            
        }

        nameLabel.text = UserDefaults.standard.value(forKey: "user_First_Name") as? String
        
        self.tableView.tableFooterView = UIView()

    }
    
    func panGestureRecognizerAction(_gesture:UIPanGestureRecognizer) {
        
        
        let translate = _gesture.translation(in: self.view)
        if _gesture.state == UIGestureRecognizerState.changed {
            _gesture.view!.center = CGPoint(x:_gesture.view!.center.x + translate.x, y:desView.frame.origin.y+(desView.frame.height/2))
            _gesture.setTranslation(CGPoint.zero, in: self.view)
            
        }
        if _gesture.state == UIGestureRecognizerState.ended {
            let velocity = _gesture.velocity(in: self.view)
            if velocity.x <= -100 {
                self.desView.isHidden=true
                UserDefaults.standard.set("false", forKey: "Status")
                self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/5.841)
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.tableView.tableHeaderView = self.headerView
                })
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.desView.frame.origin = CGPoint(x: CGFloat(0.0), y: self.desView.frame.origin.y)
                    
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.tableView.reloadData(effect: .roll)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionsArray.count
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        Constants.dashBoard = true
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            if sectionsArray.count == 1 {
//                if sectionsArray[section] == "Visits Today" {
//                    return closedVisitsArray.count
//
//                }else {
//                    return openVisitsArray.count
// 
//                }
//            }else {
//                return openVisitsArray.count
//  
//            }
//            
//        }else {
//            
//            return closedVisitsArray.count
//            
//        }
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
                
                heignt = self.tableView.frame.height/6.6
                
            }else{
                heignt = cellHeight

            }
        case "Open Visits":
                heignt = cellHeight
        default : break
        }
        return heignt
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = VisitsTableViewCell()
        
        switch sectionsArray[indexPath.section] {
        case "Visits Today":
            var resident = NSDictionary()

            resident = closedVisitsArray[indexPath.row] as! NSDictionary
            if resident.value(forKey: "care_id") as! String == "5ab5064971a5957989df4f21" {
                cell = tableView.dequeueReusableCell(withIdentifier: "Check-In", for: indexPath) as! VisitsTableViewCell
                let cellWidth =  cell.contentView.frame.size.width
                let cellHeight = cell.contentView.frame.size.height
               
                
                let residentDetails = resident.value(forKey: "resident") as! NSDictionary
                let residentRoom = resident.value(forKey: "room") as! NSDictionary
                let _name = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
                
                
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

            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! VisitsTableViewCell

            resident = closedVisitsArray[indexPath.row] as! NSDictionary
            let cellWidth =  cell.contentView.frame.size.width
            let cellHeight = cell.contentView.frame.size.height
            
            cell.endTime.text = "End time:"
            cell.totalTimeSpent.text = "Total time spent:"
            cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+cellWidth/25.875, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.671, height: cellHeight/5.478)
            
            cell.endTiemLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
            
            cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.234, height: cellHeight/5.478)
            
            cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth-(cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.width), height: cellHeight/5.478)

            let residentDetails = resident.value(forKey: "resident") as! NSDictionary
            let residentRoom = resident.value(forKey: "room") as! NSDictionary
            let _name = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
            
            let care = resident.value(forKey: "care") as! NSDictionary
            
            let _care = care.value(forKey: "name") as! String
            
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
            cell.serviceLabel.text = _care
            
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
                    
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):0\(calendar.component(.minute, from: endDate!)) PM"
                    
                    
                }else if hours == 12 {
                    
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) PM"
                    
                }else {
                    
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) AM"
                    
                }
            }else{
                let hours = calendar.component(.hour, from: endDate!)
                
                if hours > 12 {
                    
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):\(calendar.component(.minute, from: endDate!)) PM"
                    
                }else if hours == 12 {
                    
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) PM"
                    
                    
                }else{
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) AM"
                    
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

                
                //cell.totalTimeSpentLbl.text = "\(total_hours) hours \(total_minutes) minutes"
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
                // layOuts
                
                cell.typeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/7.6, width: cellWidth/25, height: cellWidth/25)
                cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.680)
                cell.service.frame = CGRect(x: cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/6.677, height: cellHeight/5.478)
                
                cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/18, width: cellWidth/15.333, height: cellWidth/15.333)
                
                cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/4.019, height: cellHeight/5.478)
                
                cell.startTime.frame = CGRect(x: cellWidth/46, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.111, height: cellHeight/5.478)
                
                cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
                
                cell.endTime.text = "End time:"
                
                cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+cellWidth/25.875, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.671, height: cellHeight/5.478)
                
                cell.endTiemLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
                
                cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.234, height: cellHeight/5.478)
                
                cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth-(cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.width), height: cellHeight/5.478)
                
                cell.arrow.frame = CGRect(x: cellWidth/1.106, y: cellHeight/3.315, width: cellWidth/12.545, height: cellHeight/4.064)
                
                cell.arrow.addTarget(self, action: #selector(arrowAction(_:)), for: .touchUpInside)
        
                cell.separatorInset = UIEdgeInsets.zero
        
            return cell
        }

        case "Open Visits":
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! VisitsTableViewCell
            var resident = NSDictionary()

            cell.endTime.text = "Pause time:"
            cell.totalTimeSpent.text = "Staff Member:"
            let cellWidth =  cell.contentView.frame.size.width
            let cellHeight = cell.contentView.frame.size.height
            
            resident = openVisitsArray[indexPath.row] as! NSDictionary
            
            let residentDetails = resident.value(forKey: "resident") as! NSDictionary
            let residentRoom = resident.value(forKey: "room") as! NSDictionary
            let _name = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
            
            let care = resident.value(forKey: "care") as! NSDictionary
            
            let _care = care.value(forKey: "name") as! String
            
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
            
            let user = resident.value(forKey: "user") as! NSDictionary
            
            cell.residentNameLbl.text = _name
            cell.typeImage.image = UIImage(named: _typeImage)
            cell.serviceImage.image = UIImage(named: _care)
            cell.serviceLabel.text = _care
            
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
                    
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):0\(calendar.component(.minute, from: endDate!)) PM"
                    
                    
                }else if hours == 12 {
                    
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) PM"
                    
                }else {
                    
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) AM"
                    
                }
            }else{
                let hours = calendar.component(.hour, from: endDate!)
                
                if hours > 12 {
                    
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):\(calendar.component(.minute, from: endDate!)) PM"
                    
                }else if hours == 12 {
                    
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) PM"
                    
                    
                }else{
                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) AM"
                    
                }
                
            }
            cell.totalTimeSpentLbl.text = "\(user.value(forKey: "first_name")!) \(user.value(forKey: "last_name")!)"

            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            // layOuts
            
            cell.typeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/7.6, width: cellWidth/25, height: cellWidth/25)
            
            // cellWidth/22.058
            cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.680)
            
            cell.service.frame = CGRect(x: cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/6.677, height: cellHeight/5.478)
            
            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/18, width: cellWidth/15.333, height: cellWidth/15.333)
            
            cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/4.019, height: cellHeight/5.478)
            
            cell.startTime.frame = CGRect(x: cellWidth/46, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.111, height: cellHeight/5.478)
            
            cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
            
            cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+screenWidth/37.5, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/4.6875, height: cellHeight/5.478)
            
            cell.endTiemLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
            
            cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.947, height: cellHeight/5.478)
            
            cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth-(cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.width), height: cellHeight/5.478)
            
            cell.arrow.frame = CGRect(x: cellWidth/1.106, y: cellHeight/3.315, width: cellWidth/12.545, height: cellHeight/4.064)
            
            cell.separatorInset = UIEdgeInsets.zero
            cell.arrow.addTarget(self, action: #selector(arrowAction(_:)), for: .touchUpInside)
            
            return cell

        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! VisitsTableViewCell
            return cell

        }
        
//        if (indexPath.section==0) {
//            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! VisitsTableViewCell
//            
//            var resident = NSDictionary()
//            if sectionsArray[indexPath.section] == "Visits Today" {
//                
//                resident = closedVisitsArray[indexPath.row] as! NSDictionary
//                let cellWidth =  cell.contentView.frame.size.width
//                let cellHeight = cell.contentView.frame.size.height
//
//                cell.endTime.text = "End time:"
//                cell.totalTimeSpent.text = "Total time spent:"
//                cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+cellWidth/25.875, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.671, height: cellHeight/5.478)
//                
//                cell.endTiemLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
//                
//                cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.234, height: cellHeight/5.478)
//                
//                cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth-(cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.width), height: cellHeight/5.478)
//
//            }else{
//                cell.endTime.text = "Pause time:"
//                cell.totalTimeSpent.text = "Staff Member:"
//                let cellWidth =  cell.contentView.frame.size.width
//                let cellHeight = cell.contentView.frame.size.height
//
//                resident = openVisitsArray[indexPath.row] as! NSDictionary
//                cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+screenWidth/37.5, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/4.6875, height: cellHeight/5.478)
//                
//                cell.endTiemLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
//                
//                cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.947, height: cellHeight/5.478)
//                
//                cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth-(cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.width), height: cellHeight/5.478)
//
//            }
//            
//            let residentDetails = resident.value(forKey: "resident") as! NSDictionary
//            let residentRoom = resident.value(forKey: "room") as! NSDictionary
//            let _name = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
//            
//            let care = resident.value(forKey: "care") as! NSDictionary
//            
//            let _care = care.value(forKey: "name") as! String
//            
//            let careType = resident.value(forKey: "care_type") as! String
//            
//            var _typeImage = String()
//            if careType == "Track" {
//                if sectionsArray[indexPath.section] == "Visits Today" {
//                    _typeImage = "performedVisitIcon"
//                    
//                }else{
//                    _typeImage = "openVisitIcon"
//                    
//                }
//            }else if careType == "Schedule" {
//                if sectionsArray[indexPath.section] == "Visits Today" {
//                    _typeImage = "scheduledPerformedVisitIcon"
//                    
//                }else{
//                    
//                    _typeImage = "scheduledOpenVisitIcon"
//                }
//            }
//            
//            let timeTrack = resident.value(forKey: "total_time") as! NSDictionary
//            
//            
//            let startTime = timeTrack.value(forKey: "start") as! String
//            
//            let endTime = timeTrack.value(forKey: "end") as! String
//            
//            
//            let dateformatter = DateFormatter()
//            dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
//            
//            let startDate = dateformatter.date(from: startTime)
//            
//            let endDate = dateformatter.date(from: endTime)
//            
//            let calendar = Calendar.current
//            
//            let user = resident.value(forKey: "user") as! NSDictionary
//            
//            
//            cell.residentNameLbl.text = _name
//            cell.typeImage.image = UIImage(named: _typeImage)
//            cell.serviceImage.image = UIImage(named: _care)
//            cell.serviceLabel.text = _care
//            
//            if calendar.component(.minute, from: startDate!) < 10 {
//                let hours = calendar.component(.hour, from: startDate!)
//                if hours > 12 {
//                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!) - 12):0\(calendar.component(.minute, from: startDate!)) PM"
//                }else if hours == 12{
//                    
//                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):0\(calendar.component(.minute, from: startDate!)) PM"
//
//                }else{
//                        cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):0\(calendar.component(.minute, from: startDate!)) AM"
//                }
//            }else{
//                let hours = calendar.component(.hour, from: startDate!)
//                if hours > 12 {
//                    
//                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!) - 12):\(calendar.component(.minute, from: startDate!)) PM"
//  
//                }else if hours == 12 {
//                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):\(calendar.component(.minute, from: startDate!)) PM"
//                }else{
//                        cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):\(calendar.component(.minute, from: startDate!)) AM"
//                }
//                
//            }
//            if calendar.component(.minute, from: endDate!) < 10 {
//                let hours = calendar.component(.hour, from: endDate!)
//                
//                if hours > 12 {
//                    
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):0\(calendar.component(.minute, from: endDate!)) PM"
//
//
//                }else if hours == 12 {
//
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) PM"
//
//                }else {
//                    
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) AM"
//                    
//                }
//            }else{
//                let hours = calendar.component(.hour, from: endDate!)
//                
//                if hours > 12 {
//                    
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):\(calendar.component(.minute, from: endDate!)) PM"
//
//                }else if hours == 12 {
//                    
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) PM"
//
//
//                }else{
//                        cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) AM"
//  
//                }
//                
//            }
//            if sectionsArray[indexPath.section] == "Visits Today" {
//                let totalminutes = resident.value(forKey: "total_minutes") as! Double
//                
//                let seconds = totalminutes * Double(60)
//                
//                let total_hours = (Int(seconds) / 60) / 60
//                
//                
//                let total_minutes = (Int(seconds) % 3600) / 60
//                
//                if total_hours > 0 {
//                    
//                    cell.totalTimeSpentLbl.text = "\(total_hours) hours \(total_minutes) minutes"
//                    
//                    
//                }else{
//                    
//                    cell.totalTimeSpentLbl.text = "\(total_minutes) minutes"
//                    
//                }
//
//            }else{
//                
//                cell.totalTimeSpentLbl.text = "\(user.value(forKey: "first_name")!) \(user.value(forKey: "last_name")!)"
//            }
//
//            cell.selectionStyle = UITableViewCellSelectionStyle.none
//            
//            // layOuts
//            
//            let cellWidth =  cell.contentView.frame.size.width
//            let cellHeight = cell.contentView.frame.size.height
//            
//            cell.typeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/7.6, width: cellWidth/25, height: cellWidth/25)
//            
//            
//            // cellWidth/22.058
//            cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.680)
//            
//            cell.service.frame = CGRect(x: cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/6.677, height: cellHeight/5.478)
//            
//            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/18, width: cellWidth/15.333, height: cellWidth/15.333)
//            
//            
//            cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/4.019, height: cellHeight/5.478)
//            
//            
//            
//            cell.startTime.frame = CGRect(x: cellWidth/46, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.111, height: cellHeight/5.478)
//            
//            cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
//            
//            
//            
//            cell.arrow.frame = CGRect(x: cellWidth/1.106, y: cellHeight/3.315, width: cellWidth/12.545, height: cellHeight/4.064)
//            
//            
//            
//            cell.separatorInset = UIEdgeInsets.zero
//            cell.arrow.addTarget(self, action: #selector(arrowAction(_:)), for: .touchUpInside)
//            
//            return cell
//            
//            
//        }
            //        else if (indexPath.section==1) {
            //            cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath) as! VisitsTableViewCell
            //
            //
            //            if (indexPath.row == 0) {
            //               cell.serviceImage.image=UIImage(named:"Bathing")
            //                cell.serviceLabel.text="Bathing"
            //                cell.nextServiceTiemLbl.text = "9:00 AM - 10:00 AM"
            //
            //            }else{
            //                cell.serviceImage.image=UIImage(named:"Eye Drops")
            //                cell.serviceLabel.text="Eye Drops"
            //                cell.frequencyLbl.text = "Daily"
            //
            //            }
            //            cell.separatorInset = UIEdgeInsets.zero
            //            cell.selectionStyle = UITableViewCellSelectionStyle.none
            //
            //            // layOuts
            //
            //            let cellWidth =  cell.contentView.frame.size.width
            //            let cellHeight = cell.contentView.frame.size.height
            //
            //
            //
            //            cell.residentNameLbl1.frame = CGRect(x: cellWidth/34.5, y: cellHeight/19, width: cellWidth/2.049, height: cellHeight/3.677)
            //
            //            cell.service.frame = CGRect(x: cellWidth/34.5, y: cell.residentNameLbl1.frame.origin.y+cell.residentNameLbl1.frame.size.height+cellHeight/42, width: cellWidth/6.677, height: cellHeight/5.478)
            //
            //            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl1.frame.origin.y+cell.residentNameLbl1.frame.size.height+cellHeight/42, width: cellWidth/15.333, height: cellWidth/15.333)
            //
            //
            //            cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl1.frame.origin.y+cell.residentNameLbl1.frame.size.height+cellHeight/42, width: cellWidth/4.019, height: cellHeight/5.478)
            //
            //
            //            cell.startDate.frame = CGRect(x: cellWidth/34.5, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/10.35, height: cellHeight/5.428)
            //
            //            cell.startDateLbl.frame = CGRect(x: cell.startDate.frame.origin.x+cell.startDate.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/5.914, height: cellHeight/5.428)
            //
            //            cell.endDate.frame = CGRect(x: cell.startDateLbl.frame.origin.x+cell.startDateLbl.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/12.937, height: cellHeight/5.428)
            //
            //            cell.endDateLbl.frame = CGRect(x: cell.endDate.frame.origin.x+cell.endDate.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/5.914, height: cellHeight/5.428)
            //
            //            cell.frequency.frame = CGRect(x: cell.endDateLbl.frame.origin.x+cell.endDateLbl.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/5.240, height: cellHeight/5.428)
            //
            //            cell.frequencyLbl.frame = CGRect(x: cell.frequency.frame.origin.x+cell.frequency.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/4.6, height: cellHeight/5.428)
            //
            //
            //            cell.nextServiceTime.frame = CGRect(x: cellWidth/34.5, y: cell.startDate.frame.origin.y+cell.startDate.frame.size.height, width: cellWidth/3.066, height: cellHeight/5.428)
            //
            //            cell.nextServiceTiemLbl.frame = CGRect(x: cell.nextServiceTime.frame.origin.x+cell.nextServiceTime.frame.size.width, y: cell.startDate.frame.origin.y+cell.startDate.frame.size.height, width: cellWidth/2.156, height: cellHeight/5.428)
            //
            //            cell.arrow1.frame = CGRect(x: cellWidth/1.106, y: cellHeight/3.315, width: cellWidth/12.545, height: cellHeight/4.064)
            //
            //            cell.arrow1.addTarget(self, action: #selector(arrowAction(_:)), for: .touchUpInside)
            //
            //            cell.arrow1.tag = indexPath.section
            //
            //            return cell
            //           performedVisitIcon
            //scheduledPerformedVisitIcon
            //        }
//        else   {
//            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! VisitsTableViewCell
//            
//            let resident = closedVisitsArray[indexPath.row] as! NSDictionary
//            let residentDetails = resident.value(forKey: "resident") as! NSDictionary
//            let residentRoom = resident.value(forKey: "room") as! NSDictionary
//            let _name = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
//            
//            let care = resident.value(forKey: "care") as! NSDictionary
//            
//            let _care = care.value(forKey: "name") as! String
//            
//            let careType = resident.value(forKey: "care_type") as! String
//            
//            var _typeImage = String()
//            if careType == "Track" {
//                _typeImage = "performedVisitIcon"
//            }else if _typeImage == "Schedule" {
//                _typeImage = "scheduledPerformedVisitIcon"
//            }
//            
//            let timeTrack = resident.value(forKey: "total_time") as! NSDictionary
//            
//            
//            let startTime = timeTrack.value(forKey: "start") as! String
//            
//            let endTime = timeTrack.value(forKey: "end") as! String
//            
//            
//            let dateformatter = DateFormatter()
//            dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
//            
//            let startDate = dateformatter.date(from: startTime)
//            
//            let endDate = dateformatter.date(from: endTime)
//            
//            let calendar = Calendar.current
//            
//            cell.totalTimeSpent.text = "Total time spent:"
//            cell.residentNameLbl.text = _name
//            cell.typeImage.image = UIImage(named: _typeImage)
//            cell.serviceImage.image = UIImage(named: _care)
//            cell.serviceLabel.text = _care
//            
//            if calendar.component(.minute, from: startDate!) < 10 {
//                let hours = calendar.component(.hour, from: startDate!)
//                if hours > 12 {
//                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!) - 12):0\(calendar.component(.minute, from: startDate!)) PM"
//                }else if hours == 12{
//                    
//                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):0\(calendar.component(.minute, from: startDate!)) PM"
//                    
//                }else{
//                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):0\(calendar.component(.minute, from: startDate!)) AM"
//                    
//                    
//                }
//            }else{
//                let hours = calendar.component(.hour, from: startDate!)
//                if hours > 12 {
//                    
//                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!) - 12):\(calendar.component(.minute, from: startDate!)) PM"
//                    
//                }else if hours == 12 {
//                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):\(calendar.component(.minute, from: startDate!)) PM"
//                    
//                }else{
//                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):\(calendar.component(.minute, from: startDate!)) AM"
//                    
//                }
//                
//            }
//            if calendar.component(.minute, from: endDate!) < 10 {
//                let hours = calendar.component(.hour, from: endDate!)
//                
//                if hours >= 12 {
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):0\(calendar.component(.minute, from: endDate!)) PM"
//                }else if hours == 12 {
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) PM"
//                    
//                }else {
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) AM"
//                    
//                    
//                }
//            }else{
//                let hours = calendar.component(.hour, from: endDate!)
//                
//                if hours > 12 {
//                    
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):\(calendar.component(.minute, from: endDate!)) PM"
//                    
//                }else if hours == 12 {
//                    
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) PM"
//                    
//                }else{
//                    cell.endTiemLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) AM"
//                    
//                }
//                
//            }
// 
//            
//            let totalminutes = resident.value(forKey: "total_minutes") as! Double
//            
//            let seconds = totalminutes * Double(60)
//            
//            let total_hours = (Int(seconds) / 60) / 60
//            
//            
//            let total_minutes = (Int(seconds) % 3600) / 60
//
//            if total_hours > 0 {
//                
//                cell.totalTimeSpentLbl.text = "\(total_hours) hours \(total_minutes) minutes"
//                
//                
//            }else{
//                
//                cell.totalTimeSpentLbl.text = "\(total_minutes) minutes"
//                
//            }
//            cell.separatorInset = UIEdgeInsets.zero
//            cell.selectionStyle = UITableViewCellSelectionStyle.none
//            
//            
//            // layOuts
//            
//            let cellWidth =  cell.contentView.frame.size.width
//            let cellHeight = cell.contentView.frame.size.height
//            
//            
//            cell.typeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/7.6, width: cellWidth/25, height: cellWidth/25)
//            
//            
//            cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.680)
//            
//            cell.service.frame = CGRect(x: cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/6.677, height: cellHeight/5.478)
//            
//            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/18, width: cellWidth/15.333, height: cellWidth/15.333)
//            
//            
//            cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/4.019, height: cellHeight/5.478)
//            
//            cell.startTime.frame = CGRect(x: cellWidth/46, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.111, height: cellHeight/5.478)
//            
//            cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
//            
//            cell.endTime.text = "End time:"
//            
//            cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+cellWidth/25.875, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.671, height: cellHeight/5.478)
//            
//            cell.endTiemLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
//            
//            cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.234, height: cellHeight/5.478)
//            
//            cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth-(cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.width), height: cellHeight/5.478)
//            
//            cell.arrow.frame = CGRect(x: cellWidth/1.106, y: cellHeight/3.315, width: cellWidth/12.545, height: cellHeight/4.064)
//            
//            
//            cell.arrow.addTarget(self, action: #selector(arrowAction(_:)), for: .touchUpInside)
//            
//            
//            return cell
//            
//        }
        
    }
    func arrowAction(_ sender: Any){
        
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: tableView)
        let indexpath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)
        let cell: VisitsTableViewCell = tableView.cellForRow(at:indexpath!) as! VisitsTableViewCell
        let button = sender as! UIButton
        var str = String()
        if button.tag == 1{
            str = cell.residentNameLbl1.text!
        }else{
            str = cell.residentNameLbl.text!
        }
        UserDefaults.standard.set(str, forKey: "ResidentDetails")
        
        UserDefaults.standard.set("DashBoardViewController", forKey: "Came From")
        let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)


        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        
        
        self.present(CSVC, animated: false, completion: nil)


    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section==2) {
            return "Visits Today"
            
        }
        return "Open Visits"
    }
    
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return CGFloat(self.tableView.frame.height/29.130)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: self.tableView.frame.height/29.130))
        let title = UILabel(frame: CGRect(x: self.tableView.frame.width/45, y: 0, width: tableView.bounds.size.width, height: headerView.bounds.size.height))
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
            
          //  headerView.backgroundColor = UIColor.init(red: 29.0/255.0, green: 118.0/255.0, blue: 187.0/255.0, alpha: 1.0)
            
        }
//        else if(section==1){
//            title.text="Scheduled Care"
//            title.textColor = UIColor.init(red: 100.0/255.0, green: 187.0/255.0, blue: 214/255.0, alpha: 1.0)
//            headerView.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.9098039216, blue: 0, alpha: 1)
//            //headerView.backgroundColor = UIColor.init(red: 254.0/255.0, green: 232.0/255.0, blue: 0.0/255.0, alpha: 1.0)
//            
//        }
        else{
            title.text="Visits Today"
            title.textColor = UIColor.init(red: 104.0/255.0, green: 111.0/255.0, blue: 118.0/255.0, alpha: 1.0)
            headerView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
           // headerView.backgroundColor = UIColor.init(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            
        }
        headerView .addSubview(title)
        
        return headerView
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationManager.startRangingBeacons(in: region as! CLBeaconRegion)
        
        locationManager.startMonitoring(for: region)

    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
        locationManager.stopMonitoring(for: region)
        
    }

    @IBAction func menuBtnAction(_ sender: Any) {

        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("DashBoardViewController", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(menuViewController, animated: false, completion: nil)
      
    }
    
    func decrease(){
        timer?.invalidate()
        popup.dismiss()
    }

    func layOuts(){
        
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        eveyTitle.frame = CGRect(x: screenWidth/2.76, y: screenHeight/23.741, width: screenWidth/3.763, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.14, y: screenHeight/23.741, width: screenWidth/11.5, height: screenHeight/32)
        self.view.addSubview(headerView)
        
        
        //welcomeLabel.frame = CGRect(x: screenWidth/46, y: headerView.frame.height/12.941, width: screenWidth - screenWidth/24.352, height:headerView.frame.height/4)
        
        welcomeLabel.frame = CGRect(x: screenWidth/46, y: screenHeight/43.294, width: screenWidth - screenWidth/24.352, height: screenHeight/13.381)

        
        //nameLabel.frame = CGRect(x: screenWidth/46, y: headerView.frame.height/3.437, width: screenWidth - screenWidth/24.352, height: headerView.frame.height/4)
        
        nameLabel.frame = CGRect(x: screenWidth/46, y: screenHeight/11.5, width: screenWidth - screenWidth/24.352, height: screenHeight/13.381)

        
        //desView.frame = CGRect(x: 0, y: headerView.frame.height/1.76, width: screenWidth, height: headerView.frame.height/2.291)
        
        desView.frame = CGRect(x: 0, y: screenHeight/5.888, width: screenWidth, height: screenHeight/7.666)
        
        headerView.addSubview(welcomeLabel)
        headerView.addSubview(nameLabel)
        headerView.addSubview(desView)
        tableView.tableHeaderView = headerView
        tableView.frame = CGRect(x: 0, y: eveyTitle.frame.origin.y+eveyTitle.frame.height+screenHeight/92, width: screenWidth, height: screenHeight-(eveyTitle.frame.origin.y+eveyTitle.frame.height+screenHeight/92))
        self.view.addSubview(tableView)
        descriptionTextView.frame = CGRect(x: screenWidth/207, y: screenHeight/66.909, width: screenWidth-(screenWidth/207), height: screenHeight/11.682)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
        if (knownBeacons.count>0) {
            print(knownBeacons)
            
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

                    let beaconMajor = Int(dic?.value(forKey: "major") as! String)
                    let beaconMinor = Int(dic?.value(forKey: "minor") as! String)
                    
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

                        if major == beaconMajor && minor == beaconMinor{
                            myBeacon = aaaaaaa.value(forKey: "type") as! String
                            responseBeacon = aaaaaaa
                        }
                    }
                            
                    if myBeacon == "room"{
                        

                        Service.sharedInstance.batteryLevel(beaconsWithBattery: Constants.beaconsWithPercentages)
                        
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
                            
                                let roomid = (re.value(forKey: "_room") as! NSDictionary).value(forKey: "_id") as! String
                                if roomid == Constants.room_Id{
                                }
                                Constants.room_Id = roomid

                                let startDate = Date()
                                Times.Previous_End_Time.removeAll()
                                Times.Constant_Start_Time = startDate

                                Times.Left_Time.removeAll()
                                
                                DispatchQueue.main.async( execute: {
                                
                                    //let beaconsData = NSKeyedArchiver.archivedData(withRootObject: re)
                                
                                    //UserDefaults.standard.set(beaconsData, forKey: "Residents_List")
                                
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                
                                    let transition = CATransition()
                                    transition.duration = 0.3
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromRight
                                    self.view.window!.layer.add(transition, forKey: kCATransition)
                                
                                    do {
                                        self.audioPlayer = try! AVAudioPlayer.init(contentsOf: self.roomUrl!)
                                        self.audioPlayer.prepareToPlay()
                                        
                                    }

                                    self.audioPlayer.play()
                                    
                                    //AudioServicesPlaySystemSound(SystemSoundID(1000))
                                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                                
                                    self .present(nvc, animated: false, completion: {
                                        UserDefaults.standard.set("", forKey: "Came From")
                                    })// completion of self.present
                                })
                            }
                        }
                        task.resume()
                    }//completion of room beacon
                }
            }else{
                // if previous beacon array count not euqal to Zero
                print("final \(finalRSSI)")
                let base = Double(10)
                let power = Double(Constants.hallwayRSSI-(finalRSSI))/Double(10*2)
                let dis = pow(Double(base), power)
                print(dis)
                
                if dis <= Constants.hallwayRange {
                    let beaconMajor = Int(dic?.value(forKey: "major") as! String)
                    let beaconMinor = Int(dic?.value(forKey: "minor") as! String)
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
                        let pauseButton = CancelButton(title: "Pause") {
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
                        let deleteButton = CancelButton(title: "Done") {
                            UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                            UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                            self.locationManager.stopRangingBeacons(in: region)
                            self.locationManager.stopMonitoring(for: region)

                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromLeft
                            self.view.window!.layer.add(transition, forKey: kCATransition)
                                
                            self.present(nvc, animated: false, completion: {
                                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    
                            })

                        }
                        popup.addButtons([pauseButton,continueButton,completeButton,deleteButton])
                        let hallwayBeaconArray : [Int] = UserDefaults.standard.value(forKey: "HallwayBeaconArray") as! [Int]
                        if hallwayBeaconArray.count == 0{
                            let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                            let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                            if namesArray.count >= 1 && selectedArray.count == 0{
                                let DVC = storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                locationManager.stopRangingBeacons(in: region)
                                locationManager.stopMonitoring(for: region)

                                self.present(DVC, animated: true, completion: nil)
                            }else{
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
                            }
                        }
                    }
                }
                }
                Constants.rssiArray.removeObject(at: 0)
            }
        }
    }
    
    func beaconsDataFromServer() {
        let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons")!
        let session = URLSession.shared
        let request = NSMutableURLRequest (url: url as URL)
        request.httpMethod = "Get"
        
        request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
        let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
            if let data = data {
                
                let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                
                
                DispatchQueue.main.async( execute: {
                    
                    let beaconsData = NSKeyedArchiver.archivedData(withRootObject: re)
                    UserDefaults.standard.set(beaconsData, forKey: "Beacons_List")

                })
            }
        }
        task.resume()

    }
    
    
    
    
//    let predicate1 = NSPredicate(format: "idnum = %@",value);
//    
//    
//    let predicate = NSPredicate(format: "id = %@",infoDictionary.value(forKey: "industry") as! CVarArg);
//    
//    
//    let predicate2 = NSPredicate(format: "idpass = %@",value);
//    
//    let predicate = NSPredicate(format:  predicate1 ,predicate2)
//    
//    
//    
//    let filteredArray = industryMaster.filter { predicate.evaluate(with: $0) };
//    
//    if filteredArray.count > 0
//    
//    {
//    
//    let data = (filteredArray as NSArray).object(at: 0) as! NSDictionary
//    
//    cell.infoLabel.text = data.value(forKey: "name") as? String
//    
//    }
    func todayCaresFromServer(){
        
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
                        
                        self.openVisitsArray = dictionary.value(forKey: "list") as! NSArray
                    
                    default :
                        
                        self.closedVisitsArray = dictionary.value(forKey: "list") as! NSArray
                        
                    }

                }
                    
                if self.openVisitsArray.count > 0 && self.closedVisitsArray.count > 0{
                        self.sectionsArray.append("Open Visits")
                        self.sectionsArray.append("Visits Today")
                        
                }else if self.openVisitsArray.count > 0 {

                        self.sectionsArray.append("Open Visits")

                }else if self.closedVisitsArray.count > 0 {
                        let str = "Visits Today"
                        self.sectionsArray.append(str)

                }
                if self.sectionsArray.count > 0 {
                        
                    let reversedClosedVisits = NSMutableArray()
                        
                    for arrayIndex in stride(from: self.closedVisitsArray.count - 1, through: 0, by: -1) {
                        reversedClosedVisits.add(self.closedVisitsArray[arrayIndex])
                    }
                    self.closedVisitsArray = reversedClosedVisits
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.image.stopAnimating()
                    self.image.isHidden = true

                    self.tableView.reloadData()

                }else{
                    
                    self.image.stopAnimating()
                    self.image.isHidden = true
                    
                    let visitslabel = UILabel()
                    visitslabel.text = "No visits today"
                    visitslabel.textColor = .gray
                    visitslabel.textAlignment = .center
                    visitslabel.frame = CGRect(x: 0, y: self.tableView.frame.height/2, width: screenWidth, height: screenHeight/22.3333)
                    visitslabel.center = self.view.center
                    self.tableView.addSubview(visitslabel)
                }
            })
                
            }
        }
        task.resume()
 
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
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var message = "CoreBluetooth state did update:"
        
        switch central.state {
        case .poweredOff:
            message += " poweredOff"
        case .poweredOn:
            message += " poweredOn"
            
            // start ble scan
            startScanning()
        case .resetting:
            message += " resetting"
        case .unauthorized:
            message += " unauthorized"
        case .unknown:
            message += " unknown"
        case .unsupported:
            let string = "b45"
            if let value = UInt8(string, radix: 16) {
                print(value)
            }
            
            message += " unsupported"
        }
        
        print(message)
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        guard let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? Dictionary<CBUUID, AnyObject> else {
            return
        }
        
        if let BeaconData = serviceData[CBUUID(string:"FEAA")] {
            
            let advertisementString : String = "\(BeaconData)"
            
            
            let voltageHexString = advertisementString.substring(with: 5..<9)
            let batteryVoltage = Int(voltageHexString, radix: 16)!
            let batteryStandardVoltage = 3000
            var batteryPercentage = (batteryVoltage/batteryStandardVoltage) * 100
            if batteryPercentage > 100 {
                batteryPercentage = 100
            }
            if Constants.beaconsWithPercentages.count > 0{
                for beacon in Constants.beaconsWithPercentages {
                    if (beacon as! NSDictionary).value(forKey: "name") as! String == advertisementData[CBAdvertisementDataLocalNameKey] as! String{
                        Constants.beaconsWithPercentages.remove(beacon)
                    }
                }
                Constants.beaconsWithPercentages.add(["name":advertisementData[CBAdvertisementDataLocalNameKey] as! String,"percentage":batteryPercentage])
                
            }else{
                Constants.beaconsWithPercentages.add(["name":advertisementData[CBAdvertisementDataLocalNameKey] as! String,"percentage":batteryPercentage])
                
            }
            
        }
        
    }
    func startScanning() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }

    

}
























