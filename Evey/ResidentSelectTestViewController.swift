//
//  ResidentSelectTestViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 24/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import CoreLocation
protocol SampleProtocol {
    
    func someMethod(message:String,name:String)

}
class ResidentSelectTestViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate,SampleProtocol,CLLocationManagerDelegate{
    func someMethod(message:String,name:String){
        if message == "View Open Visits"{
            
            let openVisitsVC = self.storyboard?.instantiateViewController(withIdentifier: "OpenVisitsViewController") as! OpenVisitsViewController
            UserDefaults.standard.set(name, forKey: "openVisitsResidentName")

            openVisitsVC.residentNameStr = name
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.locationManager.stopMonitoring(for: self.region)
            self.locationManager.stopRangingBeacons(in: self.region)
            
            self.view.window!.layer.add(transition, forKey: kCATransition)
            
            self.present(openVisitsVC, animated: false, completion: nil)
            
        }else if  message == "View Scheduled Visits" {
            
            let scheduledVisitsVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduledVisitsViewController") as! ScheduledVisitsViewController

            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)
            view.window!.layer.add(transition, forKey: kCATransition)
            self.present(scheduledVisitsVC, animated: false, completion: nil)

        }
        else if message == "Pause" {
            let msg = "To Pause your visit please select Resident/Care"
            let attStr = NSMutableAttributedString(string: msg)
            
            let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
            
            attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 5))
            attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 34, length: 13))

            self.popup = PopupDialog(title: "", message: attStr,  buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
            
            let okButton = DefaultButton(title: "Ok", action: {
                Times.Leaving_Time = Date()
                Times.Left_Time = [Date()]
                self.locationManager.startMonitoring(for: self.region)
                self.locationManager.startRangingBeacons(in: self.region)
            })
                        
            self.popup.addButtons([okButton])
            self.present(self.popup, animated: true, completion: {
                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                
            })
            
        }else if message == "Complete" {
            let msg = "To Complete your visit please select Resident/Care"
            
            let attStr = NSMutableAttributedString(string: msg)
            
            let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
            
            attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 8))
            attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 37, length: 13))

            self.popup = PopupDialog(title: "", message: attStr,  buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
            
            let okButton = DefaultButton(title: "Ok", action: {
                Times.Leaving_Time = Date()
                Times.Left_Time = [Date()]
                self.locationManager.startMonitoring(for: self.region)
                self.locationManager.startRangingBeacons(in: self.region)
            })
            
            self.popup.addButtons([okButton])
            self.present(self.popup, animated: true, completion: {
                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
            })
            
        }else if message == "Delete" {
            
        }else if message == "Enter a Visit" {
            
            let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
            UserDefaults.standard.set(name, forKey: "openVisitsResidentName")

            CSVC.residentNameRoom = name
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)
            UserDefaults.standard.set(name, forKey: "nameRoom")

            self.present(CSVC, animated: false, completion: nil)
            
        }
        
        
        
    }

    @IBOutlet weak var otherView: UIView!
    @IBOutlet weak var otherViewBorder: UILabel!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var residentSelectLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var eveyTitle: UIImageView!
    @IBOutlet weak var residentTableView: UITableView!
    
    var timer: Timer?

    var count  = Int()
    var names = NSMutableArray()
    var lefSwipeiS = Bool()
    var getIndexPath = IndexPath()
    var didSelectIsEnable = Bool()
    var didSelectIndexPath = IndexPath()
    var forceTouchAvailable = Bool()
    var options = NSArray()
    
    var alertForPause = Bool()
    var alertForComplete = Bool()
    var alertForContinue = Bool()
    
    //for beacon Detection
    var acceptableDistance = Double()
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")

    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
    
    var date = Date()
    
    var beaconsArray = NSArray()
    var responseBeacon = NSDictionary()
    var roomNumber = String()

    var audioPlayer = AVAudioPlayer()
    
    let roomUrl = Bundle.main.url(forResource: "Room", withExtension: "mp3")
    let hallwayUrl = Bundle.main.url(forResource: "Hallway", withExtension:"mp3")

    override func viewDidLoad() {
        super.viewDidLoad()
        ResidentDetails.closedCaresFromServer.removeAllObjects()
        ResidentDetails.openCaresFromServer.removeAllObjects()

        let residents = ResidentDetails.response.value(forKey: "_residents") as! NSArray
        for i in 0..<residents.count {
            let resident = residents[i] as! NSDictionary
        
            let cares = resident.value(forKey: "cares") as! NSArray
            let openVisitsArray = NSMutableArray()
            let closedVisitsArray = NSMutableArray()

            for elemet in cares {
                let val = elemet as! NSDictionary
            
                if val.value(forKey: "care_status") as! String == "Closed"{
                    let dic = ["user_id" : val.value(forKey: "user_id") as! String ,
                           "care_id" : val.value(forKey: "care_id") as! String,
                           "care_notes" : val.value(forKey: "care_notes") as! String,
                           "care_status" : val.value(forKey: "care_status") as! String,
                           "care_type" : val.value(forKey: "care_type") as! String,
                           "care_value" : val.value(forKey: "care_value") as! String,
                           "resident_id" : val.value(forKey: "resident_id") as! String,
                           "room_id" : val.value(forKey: "room_id") as! String,
                           "total_time" : val.value(forKey: "total_time")
                        ] as NSMutableDictionary
                    closedVisitsArray.add(dic)
                }else if val.value(forKey: "care_status") as! String == "Open"{
                    let dic = ["user_id" : val.value(forKey: "user_id") as! String ,
                           "_id" : val.value(forKey: "_id") as! String,
                           "care_id" : val.value(forKey: "care_id") as! String,
                           "care_notes" : val.value(forKey: "care_notes") as! String,
                           "care_status" : val.value(forKey: "care_status") as! String,
                           "care_type" : val.value(forKey: "care_type") as! String,
                           "care_value" : val.value(forKey: "care_value") as! String,
                           "resident_id" : val.value(forKey: "resident_id") as! String,
                           "room_id" : val.value(forKey: "room_id") as! String,
                           "total_time" :val.value(forKey: "total_time")
                        ] as NSMutableDictionary
                            openVisitsArray.add(dic)
                }
            }
            
            print(closedVisitsArray)
            ResidentDetails.closedCaresFromServer.setValue(closedVisitsArray, forKey: resident.value(forKey: "_id") as! String)
            ResidentDetails.openCaresFromServer.setValue(openVisitsArray, forKey: resident.value(forKey: "_id") as! String)
        }

        let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
        roomNumber = residentRoom.value(forKey: "room") as! String
        for i in 0..<residents.count {
            
            let resident = residents[i] as! NSDictionary
            
            names.add("\(resident.value(forKey: "first_name")!) \(resident.value(forKey: "last_name")!)")
            
        }
        
        
        layOuts()
        //names = ["Chris P.","Edward J."]
        let gestureRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight))
        gestureRight.delegate = self as? UIGestureRecognizerDelegate
        gestureRight.direction = .right
        residentTableView.addGestureRecognizer(gestureRight)

        let gestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeLeft))
        gestureLeft.direction = .left
        gestureLeft.delegate = self as? UIGestureRecognizerDelegate
        residentTableView.addGestureRecognizer(gestureLeft)
        
        // to detect beacons 
        
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)

        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion:nil)

    }
    override func viewDidAppear(_ animated: Bool) {
        if alertForPause == true || alertForComplete == true {
            
            var msg = "To Pause your visit please select Care"
            var attString = NSMutableAttributedString(string: msg)
            
            var font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
            
            if alertForPause == true {
                msg = "To Pause your visit please select Resident and Care"
                
                attString = NSMutableAttributedString(string: msg)
                
                font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
                
                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 5))
                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 34, length: 8))
                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 47, length: 4))
 
            }else{
                msg = "To Complete your visit please select Resident and Care"
                attString = NSMutableAttributedString(string: msg)
                
                font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
                
                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 8))
                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 37, length: 8))
                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 50, length: 4))

            }

             popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
            })
            
            let okButton = DefaultButton(title: "Ok", action: {
            })
            
            popup.addButtons([okButton])
            self.present(popup, animated: true, completion: { 
                self.alertForPause = false
            })
        }else if alertForContinue == true{
            
            let date2 = Date()
            let vc  = CustomAlertViewController()
            vc.roomNumber = self.roomNumber
            vc.startTime = Times.Constant_Start_Time
            vc.counter = Int(date2.timeIntervalSince(Times.Constant_Start_Time))
            
            if Times.Previous_End_Time.count > 0 {
                vc.startTime = Times.Previous_End_Time[0]
                vc.counter = Int(date2.timeIntervalSince(Times.Previous_End_Time[0]))
                
            }
            vc.Delegate = self
            vc.screenFrame = self.view.frame
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)
            self.present(vc, animated: true, completion: {
                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                self.locationManager.stopMonitoring(for: self.region)
                self.locationManager.stopRangingBeacons(in: self.region)

            })

        }
        //if Constants.dateArray.count == 0 {
//            date = Date()
//            Constants.dateArray.append(date)
        //}

    }

    func longPressCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        count += 1

        var point: CGPoint = gestureRecognizer.location(in: residentTableView)
        if point.y <= 0 || point.y >= 430{
            point.y  = 55
        }
        let indexPath: IndexPath? = residentTableView.indexPathForRow(at: point)
          let cell: ResidentSelectTestTableViewCell = residentTableView.cellForRow(at: indexPath!) as! ResidentSelectTestTableViewCell
        let controller = storyboard?.instantiateViewController(withIdentifier: "ForceTouchPeekViewController") as! ForceTouchPeekViewController
        controller.typeOfPeek = "longPress"
        if cell.vistStatus.tag == 1 {
            options = [
                PeekViewAction(title: "View Scheduled Visits", style: .default),
                PeekViewAction(title: "Enter a Visit", style: .default),
                PeekViewAction(title: "Cancel", style: .destructive) ]

            controller.residentNameStr = "Edward J.310"
        }else{
            controller.residentNameStr = "Chris P.310"
            options = [
                PeekViewAction(title: "View Open Visits", style: .default),
                PeekViewAction(title: "Enter a Visit", style: .default),
                PeekViewAction(title: "Cancel", style: .destructive) ]

        }
        UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelStatusBar

        // you can set different frame for each peek view here
        
        let frame = CGRect(x: 15, y: 100, width: screenWidth - 30, height: screenHeight/1.5511)

        
        PeekView().viewForController(parentViewController: self, contentViewController: controller, expectedContentViewFrame: frame, fromGesture: gestureRecognizer, shouldHideStatusBar: true, menuOptions: options as? [PeekViewAction], completionHandler: { optionIndex in
            switch optionIndex {
            
            case 0:
                let openVisitsVC = self.storyboard?.instantiateViewController(withIdentifier: "OpenVisitsViewController") as! OpenVisitsViewController
                
                UserDefaults.standard.set("Chris P.310", forKey: "openVisitsResidentName")

                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                self.locationManager.stopMonitoring(for: self.region)
                self.locationManager.stopRangingBeacons(in: self.region)
                
                self.view.window!.layer.add(transition, forKey: kCATransition)
                
                self.present(openVisitsVC, animated: false, completion: nil)
 
            case 1:
                print("Option 2 selected")
            case 2:
                print("Option 3 selected")
            default:
                break
            }
        }, dismissHandler: {
            UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal

        })

    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if names.count == 1 {
            return residentTableView.frame.size.height/1.020
        }
        else{

        return residentTableView.frame.size.height/2.041
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        forceTouchAvailable = false
        var cell = ResidentSelectTestTableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath) as! ResidentSelectTestTableViewCell
        cell.residentNameLbl.text = names[indexPath.row] as? String
        cell.residentNameLbl.sizeToFit()
        cell.residentRoomLbl.text = roomNumber
        cell.residentRoomLbl.sizeToFit()
        let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray
        
        var resident_ID = String()
        for i in 0..<residents.count {
            let residentDetails = residents[i] as! NSDictionary
            let name : String = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String)"
            print(name)
            print(self.names[(indexPath.row)])
            if name == self.names[(indexPath.row)] as! String {
                resident_ID = residentDetails.value(forKey: "_id") as! String
                print(resident_ID)
            }
        }
        
        if lefSwipeiS == true {
            if names.count == 1 {
                cell.detailsView.frame = CGRect(x: -cell.contentView.frame.size.width/3, y: cell.contentView.frame.height/53.75, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.height/1.043)
                
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.detailsView.frame.size.height/2.047, width: cell.residentNameLbl.frame.width, height: cell.detailsView.frame.size.height/11.944)
                
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height, width: cell.residentRoomLbl.frame.width, height: cell.detailsView.frame.size.height/11.944)
                
            }else{
                cell.detailsView.frame = CGRect(x: -cell.contentView.frame.size.width/3, y: cell.contentView.frame.size.height/26.875, width: cell.contentView.frame.size.width/0.75, height: cell.contentView.frame.size.height/1.085)
            }
        }
        else {
            
            //cell.scheduledCareImage.setImage(#imageLiteral(resourceName: "scheduleVisit2").withRenderingMode(.alwaysOriginal), for: .normal)
            
            cell.vistStatus.setImage(#imageLiteral(resourceName: "openVisitIcon").withRenderingMode(.alwaysOriginal), for: .normal)
            
            cell.scheduledCareImage.isHidden = true
            cell.vistStatus.isHidden = true
            
            let openCaresOfResident : [NSMutableDictionary] = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! [NSMutableDictionary]
            
            var openStoredCaresOfResident = [NSDictionary]()
            
            var openCareIDS = [String]()
            
            for visit in openCaresOfResident {
                
                openCareIDS.append(visit.value(forKey: "care_id") as! String)
                
            }
            
            for care in ResidentDetails.storedCares {
                if care.value(forKey: "resident_id") as! String == resident_ID && care.value(forKey: "care_status") as! String == "Closed" && openCareIDS.contains(care.value(forKey: "care_id") as! String){
                    openStoredCaresOfResident.append(care)
                }
            }
            print(openStoredCaresOfResident)
            if openCaresOfResident.count > 0 {
                cell.scheduledCareImage.isHidden = false
                cell.vistStatus.isHidden = false
                if openStoredCaresOfResident.count == openCaresOfResident.count {
                    cell.scheduledCareImage.isHidden = true
                    cell.vistStatus.isHidden = true
                }
                
            }
            
            if names.count == 1 {
                
                
                cell.detailsView.frame = CGRect(x: CGFloat(0), y: CGFloat(cell.contentView.frame.height/53.75), width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.height/1.043)
                
                
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.detailsView.frame.size.height/2.407, width: cell.residentNameLbl.frame.width, height: cell.detailsView.frame.size.height/11.944)
                
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height, width: cell.residentRoomLbl.frame.width, height: cell.detailsView.frame.size.height/11.944)
                
                cell.vistStatus.frame = CGRect(x: cell.contentView.frame.size.width/2.0833, y:cell.residentNameLbl.frame.origin.y-(cell.contentView.frame.width/25 + 5), width: cell.contentView.frame.width/25, height: cell.contentView.frame.width/25)
                
                cell.scheduledCareImage.frame = CGRect(x: cell.contentView.frame.size.width/2.0833, y:cell.residentNameLbl.frame.origin.y-(cell.contentView.frame.width/25 + 5), width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.width/12.5)
                cell.scheduledCareImage.center.x = cell.contentView.center.x
                cell.residentNameLbl.center.x = self.view.center.x
                cell.residentRoomLbl.center.x = self.view.center.x
                cell.scheduledCareImage.center.y = cell.vistStatus.center.y
            }else{
                if names[indexPath.row] as? String == "Edward J" {
                    
                    cell.vistStatus.frame = CGRect(x: cell.contentView.frame.size.width/2.678, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/14.333)
                    cell.scheduledCareImage.frame = CGRect(x: cell.vistStatus.frame.origin.x+cell.vistStatus.frame.width+cell.contentView.frame.width/7.5, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height:  cell.contentView.frame.width/25)
                    cell.scheduledCareImage.tag = indexPath.row
                    cell.detailsView.addSubview(cell.vistStatus)
                    cell.detailsView.addSubview(cell.scheduledCareImage)
                    
                }else{
                    
                    cell.vistStatus.frame = CGRect(x: cell.contentView.frame.width/2.0833, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height:  cell.contentView.frame.width/25)
                    cell.scheduledCareImage.isHidden = false
                    cell.vistStatus.frame = CGRect(x: cell.contentView.frame.size.width/2.0833, y:cell.residentNameLbl.frame.origin.y-(cell.contentView.frame.width/25 + 5), width: cell.contentView.frame.width/25, height: cell.contentView.frame.width/25)
                    
                    cell.scheduledCareImage.frame = CGRect(x: cell.contentView.frame.size.width/2.0833, y:cell.residentNameLbl.frame.origin.y-(cell.contentView.frame.width/25 + 5), width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.width/12.5)
                    cell.scheduledCareImage.center.x = cell.contentView.center.x
                    cell.residentNameLbl.center.x = self.view.center.x
                    cell.residentRoomLbl.center.x = self.view.center.x
                    cell.scheduledCareImage.center.y = cell.vistStatus.center.y
                    cell.detailsView.addSubview(cell.vistStatus)
                    cell.detailsView.addSubview(cell.scheduledCareImage)
                    
                }
                
                
                cell.detailsView.frame = CGRect(x: CGFloat(0), y: CGFloat(cell.contentView.frame.height/26.875), width: CGFloat(cell.contentView.frame.width/0.75), height: CGFloat(cell.contentView.frame.height/1.080))
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.vistStatus.frame.origin.y+cell.vistStatus.frame.height+cell.detailsView.frame.height/19.9, width: cell.residentNameLbl.frame.width, height: cell.detailsView.frame.size.height/5.527)
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height, width: cell.residentRoomLbl.frame.width, height: cell.detailsView.frame.size.height/5.527)
                cell.scheduledCareImage.frame = CGRect(x: cell.contentView.frame.size.width/2.0833, y:cell.residentNameLbl.frame.origin.y-(cell.contentView.frame.width/25 + 5), width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.width/12.5)
                cell.scheduledCareImage.center.x = cell.contentView.center.x
                cell.residentNameLbl.center.x = self.view.center.x
                cell.residentRoomLbl.center.x = self.view.center.x
                cell.scheduledCareImage.center.y = cell.vistStatus.center.y
                
            }
            
        }
        
        
        cell.upBordelLabel.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(cell.detailsView.frame.width), height: CGFloat(1))
        
        cell.bottomBorderLabel.frame = CGRect(x: CGFloat(0), y: CGFloat(cell.detailsView.frame.size.height-1), width: CGFloat(cell.detailsView.frame.width), height: CGFloat(1))
        // to remove the highlight on click on cell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        self.residentTableView.separatorColor = UIColor.clear
        
        if #available(iOS 9.0, *) {
            if( traitCollection.forceTouchCapability == .available){
                
                registerForPreviewing(with: self, sourceView: cell.scheduledCareImage)
                forceTouchAvailable = true
                
            }else{
                
                forceTouchAvailable = false
            }
        } else {
            forceTouchAvailable = false
        }
        //        if forceTouchAvailable == false {
        //            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressCell(_:)))
        //            gesture.minimumPressDuration = 0.5
        //            cell.vistStatus.addGestureRecognizer(gesture)
        //        }
        
        cell.vistStatus.tag = indexPath.row
        cell.scheduledCareImage.tag = indexPath.row
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController")as! CareSelectViewController
        //CSVC.residentNameRoom = "\(self.names[(indexPath.row)] as! String ).\(roomNumber)"
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        
        UserDefaults.standard.set("\(self.names[(indexPath.row)] as! String ).\(roomNumber)", forKey: "nameRoom")
        var resident_ID = String()
        let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray

        let residentDetails = residents[indexPath.row] as! NSDictionary
        resident_ID = residentDetails.value(forKey: "_id") as! String

        UserDefaults.standard.set(resident_ID, forKey: "resident_id")
        self.present(CSVC, animated: false, completion: {
            
        })

    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cell = tableView.cellForRow(at: indexPath) as! ResidentSelectTestTableViewCell
        cell.detailsView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9882352941, blue: 0.9960784314, alpha: 1)
        //UIColor(red: 246.0 / 255.0, green: 251.0 / 255.0, blue: 254.0 / 255.0, alpha: 1)

        
    }


func handleSwipeLeft(_ gestureRecognizer: UISwipeGestureRecognizer) {
    self.deselectMethod()
    if didSelectIsEnable == true{
        self.tableView(residentTableView, didDeselectRowAt: didSelectIndexPath)
    }
    let point: CGPoint = gestureRecognizer.location(in: residentTableView)
    let indexPath: IndexPath? = residentTableView.indexPathForRow(at: point)
    getIndexPath = indexPath!
    if((indexPath) != nil)
     
    {
        
        let cell: ResidentSelectTestTableViewCell = residentTableView.cellForRow(at: indexPath!) as! ResidentSelectTestTableViewCell
        lefSwipeiS = true

        cell.detailsView.backgroundColor = #colorLiteral(red: 0.8588235294, green: 0.9450980392, blue: 0.9803921569, alpha: 1)
            //UIColor(red: 219.0 / 255.0, green: 242.0 / 255.0, blue: 251.0 / 255.0, alpha: 1)
        
        let visitButton = UIButton()
        visitButton.setTitle("Visit", for: UIControlState.normal)
        visitButton.addTarget(self, action: #selector(self.visitButtonAction(_:)), for:.touchUpInside)
        visitButton.backgroundColor = UIColor(red: 32.0 / 255.0, green: 138.0 / 255.0, blue: 200.0 / 255.0, alpha: 1)
        visitButton.titleLabel?.textColor = UIColor.white

        let checkInButton = UIButton()
        checkInButton.setTitle("CheckIn", for: UIControlState.normal)
        checkInButton.addTarget(self, action: #selector(self.checkInButtonAction(_:)), for:.touchUpInside)
        checkInButton.backgroundColor = UIColor(red: 251.0 / 255.0, green: 186.0 / 255.0, blue: 21.0 / 255.0, alpha: 1)
        checkInButton.titleLabel?.textColor = UIColor.white

        if names.count == 1 {
            visitButton.frame = CGRect(x: cell.contentView.frame.size.width/1, y: CGFloat(0), width: cell.contentView.frame.size.width/3, height: cell.detailsView.frame.size.height/2)
            //cell.detailsView.addSubview(visitButton)
   
            checkInButton.frame = CGRect(x: cell.contentView.frame.size.width/1, y: 0, width: cell.contentView.frame.size.width/3, height: cell.detailsView.frame.size.height)
            cell.detailsView.addSubview(checkInButton)


        }else{
            visitButton.frame = CGRect(x: cell.contentView.frame.size.width/1, y: 0, width: cell.contentView.frame.size.width/3, height: cell.detailsView.frame.size.height/2)
            //cell.detailsView.addSubview(visitButton)
        
            checkInButton.frame = CGRect(x: cell.contentView.frame.size.width/1, y:0, width: cell.contentView.frame.size.width/3, height: cell.detailsView.frame.size.height)
            cell.detailsView.addSubview(checkInButton)
        }
        
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.names.count == 1{
                cell.detailsView.frame = CGRect(x: -(cell.contentView.frame.size.width/3.33), y: cell.contentView.frame.size.height/53.75, width: cell.contentView.frame.size.width/0.75, height: cell.contentView.frame.size.height/1.043)
                
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y, width: CGFloat(cell.residentNameLbl.frame.width), height: CGFloat(cell.residentNameLbl.frame.height))
                
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentRoomLbl.frame.origin.y, width: CGFloat(cell.residentRoomLbl.frame.width), height: CGFloat(cell.residentRoomLbl.frame.height))
                
                cell.vistStatus.frame = CGRect(x: cell.contentView.frame.size.width/3, y: cell.vistStatus.frame.origin.y, width: cell.vistStatus.frame.width, height: cell.vistStatus.frame.height)

            }else{
                cell.detailsView.frame = CGRect(x: -cell.contentView.frame.size.width/3.33, y: cell.contentView.frame.height/26.875, width: cell.contentView.frame.size.width/0.75, height: cell.contentView.frame.height/1.0858)
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y, width: CGFloat(cell.residentNameLbl.frame.width), height: CGFloat(cell.residentNameLbl.frame.height))
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentRoomLbl.frame.origin.y, width: CGFloat(cell.residentRoomLbl.frame.width), height: CGFloat(cell.residentRoomLbl.frame.height))
                
                cell.vistStatus.frame = CGRect(x: cell.contentView.frame.size.width/3, y: cell.vistStatus.frame.origin.y, width: cell.vistStatus.frame.width, height: cell.vistStatus.frame.height)
                
                cell.scheduledCareImage.frame = CGRect(x: cell.vistStatus.frame.origin.x+cell.vistStatus.frame.width+cell.contentView.frame.width/7.5, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/14.333)
                


            }
        }, completion: nil)

    }
    }
func handleSwipeRight(_ gestureRecognizer: UISwipeGestureRecognizer) {
    let point: CGPoint = gestureRecognizer.location(in: residentTableView)
    let indexPath: IndexPath? = residentTableView.indexPathForRow(at: point)

    if((indexPath) != nil)
    {
        let cell: ResidentSelectTestTableViewCell = residentTableView.cellForRow(at: indexPath!) as! ResidentSelectTestTableViewCell
        if lefSwipeiS == true {
            cell.detailsView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9882352941, blue: 0.9960784314, alpha: 1)
                //UIColor(red: 246.0 / 255.0, green: 251.0 / 255.0, blue: 254.0 / 255.0, alpha: 1)

        }

        UIView.animate(withDuration: 0.3, animations: {
            if self.names.count == 1{
                cell.detailsView.frame = CGRect(x: 0, y: cell.contentView.frame.size.height/53.75, width: cell.contentView.frame.size.width/0.75, height: cell.contentView.frame.size.height/1.043)
                
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y, width: cell.residentNameLbl.frame.width, height: cell.residentNameLbl.frame.height)
                
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentRoomLbl.frame.origin.y, width: cell.residentRoomLbl.frame.width, height: cell.residentRoomLbl.frame.height)
                
                cell.residentNameLbl.center.x = self.view.center.x
                cell.residentRoomLbl.center.x = self.view.center.x
                
                cell.vistStatus.frame = CGRect(x: cell.contentView.frame.size.width/2.0833, y:cell.residentNameLbl.frame.origin.y-(cell.contentView.frame.width/25 + 5), width: cell.contentView.frame.width/25, height: cell.contentView.frame.width/25)

            }else{
                
                cell.detailsView.frame = CGRect(x: CGFloat(0), y: CGFloat(cell.contentView.frame.height/26.875), width: CGFloat(cell.contentView.frame.width/0.75), height: CGFloat(cell.contentView.frame.height/1.085))
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y, width: cell.residentNameLbl.frame.width, height: cell.detailsView.frame.size.height/5.527)
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentRoomLbl.frame.origin.y, width: cell.residentRoomLbl.frame.width, height: cell.detailsView.frame.size.height/5.527)

                cell.residentNameLbl.center.x = self.view.center.x
                cell.residentRoomLbl.center.x = self.view.center.x
                
                if cell.residentNameLbl.text == "Edward J"{
                    
                    cell.vistStatus.frame = CGRect(x: cell.contentView.frame.size.width/2.678, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/14.333)
                    cell.scheduledCareImage.frame = CGRect(x: cell.vistStatus.frame.origin.x+cell.vistStatus.frame.width+cell.contentView.frame.width/7.5, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/14.333)

                }else{
                    cell.vistStatus.center.x = self.view.center.x

                }

            }

        }, completion: nil)

    }
}
    func visitButtonAction(_ sender: Any) {
        
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.residentTableView)
        let indexpath: IndexPath? = self.residentTableView.indexPathForRow(at: buttonPosition)
        let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController")as! CareSelectViewController
        CSVC.residentNameRoom = "\(self.names[(indexpath?.row)!] as! String )\(roomNumber)"
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        UserDefaults.standard.set("\(self.names[(indexpath?.row)!] as! String ).\(roomNumber)", forKey: "nameRoom")
        self.present(CSVC, animated: false, completion: {

        })

    }
    func checkInButtonAction(_ sender: Any) {
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.residentTableView)
        let indexpath: IndexPath? = self.residentTableView.indexPathForRow(at: buttonPosition)
        let msg = "Check-In has been recorded for \(names[(indexpath?.row)!]) "
        
        let attString = NSMutableAttributedString(string: msg)
        
       let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
        
        attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 0, length: 8))

        attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 31, length: (names[(indexpath?.row)!] as! String).characters.count))

        let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
        }
        
        // Create first button
        let okButton = DefaultButton(title: "OK") {
            
            self.deselectMethod()
            let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
            
            
            let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray
            
            let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
            
            var resident_ID = String()
            for i in 0..<residents.count {
                let residentDetails = residents[i] as! NSDictionary
                let name : String = "\(residentDetails.value(forKey: "first_name") as! String) \(residentDetails.value(forKey: "last_name") as! String)"
                print(name)
                print(self.names[(indexpath?.row)!])
                if name == self.names[(indexpath?.row)!] as! String {
                    resident_ID = residentDetails.value(forKey: "_id") as! String
                    print(resident_ID)
                }
            }

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
                         "resident_id": resident_ID,
                         "care_id": "5ab5064971a5957989df4f21",
                         "care_value": "Check-In",
                         "care_notes": "",
                         "care_type": "Track",
                         "care_status": "Check-In",
                         "time_track": ["start_time":"\(startedTime)",
                            "end_time":"\(Date())"]
                    
                ]
            
            let parameters = [param]
            Times.Previous_End_Time = [Date()]
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
                        
                    })
                    
                    
                }
            })
            task.resume()


        }
        let cancelButton = CancelButton(title: "Delete"){
            
            self.deselectMethod()
            
        }
        
        
        
        
        popup.addButtons([cancelButton,okButton])
        self.present(popup, animated: true, completion: nil)
        
        
    }

    func deselectMethod() {
        if lefSwipeiS == true {
            lefSwipeiS = false
        let cell: ResidentSelectTestTableViewCell = residentTableView.cellForRow(at:getIndexPath) as! ResidentSelectTestTableViewCell
        cell.detailsView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9882352941, blue: 0.9960784314, alpha: 1)
            //UIColor(red: 246.0 / 255.0, green: 251.0 / 255.0, blue: 254.0 / 255.0, alpha: 1)
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.names.count == 1{
                cell.detailsView.frame = CGRect(x: 0, y: cell.contentView.frame.size.height/53.75, width: cell.contentView.frame.size.width/0.75, height: cell.contentView.frame.size.height/1.043)
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y, width: cell.residentNameLbl.frame.width, height: cell.residentNameLbl.frame.size.height)
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentRoomLbl.frame.origin.y, width: cell.residentRoomLbl.frame.width, height: cell.residentRoomLbl.frame.size.height)
                cell.residentNameLbl.center.x = self.view.center.x
                cell.residentRoomLbl.center.x = self.view.center.x

                
            }else{
                cell.detailsView.frame = CGRect(x: CGFloat(0), y: CGFloat(cell.contentView.frame.height/26.875), width: CGFloat(cell.contentView.frame.width/0.75), height: CGFloat(cell.contentView.frame.height/1.085))
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y, width: cell.residentNameLbl.frame.width, height: cell.detailsView.frame.size.height/5.527)
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentRoomLbl.frame.origin.y, width: cell.residentRoomLbl.frame.width, height: cell.detailsView.frame.size.height/5.527)
                cell.residentNameLbl.center.x = self.view.center.x
                cell.residentRoomLbl.center.x = self.view.center.x
                if cell.residentNameLbl.text == "Edward J"{
                    
                    cell.vistStatus.frame = CGRect(x: cell.contentView.frame.size.width/2.678, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/14.333)
                    cell.scheduledCareImage.frame = CGRect(x: cell.vistStatus.frame.origin.x+cell.vistStatus.frame.width+cell.contentView.frame.width/7.5, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/14.333)
                    
                }else{
                    cell.vistStatus.center.x = self.view.center.x
                    
                }
            }
            
        }, completion: nil)

    }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        //guard let cell = residentTableView?.cellForRow(at: indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "ForceTouchPeekViewController") as? ForceTouchPeekViewController else { return nil }
        detailVC.delegate = self
        
        // have to check
        deselectMethod()
        
        var resident_ID = String()
        let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray
        
        print([previewingContext.sourceView.tag])
        resident_ID = (residents[previewingContext.sourceView.tag] as! NSDictionary).value(forKey: "_id") as! String
        detailVC.residentNameStr = "\(names[previewingContext.sourceView.tag]).\(roomNumber)"
        detailVC.residentID = resident_ID
        detailVC.preferredContentSize = CGSize(width: self.view.frame.width, height:self.view.frame.height/1.3884 )
        
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        // have to check
        deselectMethod()
        let openVisitsVC = self.storyboard?.instantiateViewController(withIdentifier: "OpenVisitsViewController") as! OpenVisitsViewController
        
        let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray
        
        let name = (residents[previewingContext.sourceView.tag] as! NSDictionary).value(forKey: "_id") as! String
        
        UserDefaults.standard.set(name, forKey: "openVisitsResidentName")
        
        openVisitsVC.residentNameStr = name
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        show(openVisitsVC, sender: view)
        
    }
    @IBAction func backButtonAction(_ sender: Any) {
 
        
        let dashBoard = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)

        self.present(dashBoard, animated: false, completion: nil)
    }
    @IBAction func menuButton(_ sender: Any) {

        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("ResidentSelectTestViewController", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(menu, animated: false, completion: nil)
    }
    func layOuts(){
        
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        backButton.frame = CGRect(x: screenWidth/23.437, y: screenHeight/23, width: screenWidth/18.75, height: screenHeight/33.35)
        
        eveyTitle.frame = CGRect(x: backButton.frame.origin.x+backButton.frame.size.width+screenWidth/3.712, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.213, y: screenHeight/23.437, width: screenWidth/11.363, height: screenHeight/31.761)

        
        residentSelectLbl.frame = CGRect(x: screenWidth/23.437, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/66.7, width: screenWidth/1.518, height: screenHeight/21.516)
        
        residentTableView.frame =  CGRect(x: 0, y: residentSelectLbl.frame.origin.y+residentSelectLbl.frame.size.height+screenHeight/83.875, width: screenWidth, height: screenHeight/1.519)
        
        otherView.frame = CGRect(x: 0, y: residentTableView.frame.origin.y+residentTableView.frame.size.height, width: screenWidth, height: screenHeight/5.251)

        otherBtn.frame = CGRect(x: screenWidth/3.048, y: otherView.frame.size.height/3.023, width: screenWidth/2.929, height: otherView.frame.size.height/3.527)
        
        otherViewBorder.frame = CGRect(x: 0, y: 0, width: otherView.frame.size.width, height: 1)
        
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
                                                let startDate = Date()
                                                Times.Constant_Start_Time = startDate
                                                
                                                let roomid = (re.value(forKey: "_room") as! NSDictionary).value(forKey: "_id") as! String
                                                
                                                if roomid == Constants.room_Id{
                                                    print("residentselect  times.lefttime>0 \(Constants.room_Id)")
//                                                    if Times.Previous_End_Time.count > 0 {
//                                                        Times.Constant_Start_Time = Times.Previous_End_Time[0]
//  
//                                                    }else {
//                                                        Times.Constant_Start_Time = Times.Constant_Start_Time
//                                                    }
                                                }
                                                Constants.room_Id = roomid
                                                Times.Previous_End_Time.removeAll()

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
                                                        
                
                                                    Times.Previous_End_Time.removeAll()
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
                            
                            UserDefaults.standard.set([responseBeacon.value(forKey: "_id")], forKey: "PreviousBeaconArray")
                                
                                //self.presentingViewController?.dismiss(animated: true)

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
                                    
                                    let startDate = Date()
                                    Times.Constant_Start_Time = startDate

                                    let roomid = (re.value(forKey: "_room") as! NSDictionary).value(forKey: "_id") as! String
                                    
                                    if roomid == Constants.room_Id{
                                        print("residentselect  times.lefttime else \(Constants.room_Id)")
                                        if Times.Previous_End_Time.count > 0 {
                                            Times.Constant_Start_Time = Times.Previous_End_Time[0]
 
                                        }else {
                                            Times.Constant_Start_Time = Times.Constant_Start_Time
                                        }
                                    }
                                    Constants.room_Id = roomid
                                    print("residentselect  times.lefttime>0 \(Constants.room_Id)")
                                    Times.Previous_End_Time.removeAll()

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
                                //self.timer?.invalidate()


                            })

                            let pauseButton = CancelButton(title: "Pause", action: {
                                self.timer?.invalidate()

                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                    let msg = "To Pause your visit please select Resident and Care"
                                    let attString = NSMutableAttributedString(string: msg)
                                    
                                    let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
                                    
                                    attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 5))
                                    attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 34, length: 8))
                                    attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 47, length: 4))
                                    
                                    self.popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                                        
                                    })

                                    let okButton = DefaultButton(title: "Ok", action: {
                                        
                                    })
                                    self.popup.addButton(okButton)
                                    
                                    self.present(self.popup, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    })
                                
                            })
                            
                            let continueButton = CancelButton(title: "Continue", action: {
                                self.timer?.invalidate()
                                Times.Left_Time.removeAll()
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                let date2 = Date()
                                
                                let vc  = CustomAlertViewController()
                                vc.roomNumber = self.roomNumber
                                vc.startTime = Times.Constant_Start_Time
                                vc.counter = Int(date2.timeIntervalSince(Times.Constant_Start_Time))

                                if Times.Previous_End_Time.count > 0 {
                                    vc.startTime = Times.Previous_End_Time[0]
                                    vc.counter = Int(date2.timeIntervalSince(Times.Previous_End_Time[0]))

                                }
                                vc.Delegate = self
                                vc.screenFrame = self.view.frame
                                self.locationManager.stopMonitoring(for: self.region)
                                self.locationManager.stopRangingBeacons(in: self.region)
                                self.present(vc, animated: true, completion: {
                                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    self.locationManager.stopMonitoring(for: self.region)
                                    self.locationManager.stopRangingBeacons(in: self.region)

                                })
                            })

                            let completeButton = CancelButton(title: "Complete", action: {
                                self.timer?.invalidate()

                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                let msg = "To Complete your visit please select Resident and Care"
                                let attString = NSMutableAttributedString(string: msg)
                                    
                                let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
                                    
                                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 8))
                                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 37, length: 8))
                                attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 50, length: 4))
                                    
                                self.popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                                        
                                })
                                    
                                let okButton = DefaultButton(title: "Ok", action: {
                                        
                                })
                                self.popup.addButton(okButton)
                                    
                                self.present(self.popup, animated: true, completion: {
                                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                })
                            })

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

                                            self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: true)

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
                                            
                                            UIApplication.shared.isIdleTimerDisabled = true
                                                
                                            self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: true)
                                            
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
                        self.locationManager.stopMonitoring(for: self.region)
                        self.locationManager.stopRangingBeacons(in: self.region)
  
                        
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
