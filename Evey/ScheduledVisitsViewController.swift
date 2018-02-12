//
//  ScheduledVisitsViewController.swift
//  Evey
//
//  Created by PROJECTS on 01/02/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class ScheduledVisitsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    
    @IBOutlet weak var evey: UIImageView!

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var borderLbl: UILabel!
    @IBOutlet weak var scheduleVisitLbl: UILabel!
    
    @IBOutlet weak var scheduledVisitsTable: UITableView!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var backActionBtn: UIButton!
    
    // for beacon detection
    
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       layOuts()
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.scheduledVisitsTable.frame.width, height: CGFloat(px))
        let line = UIView(frame: frame)
        self.scheduledVisitsTable.tableHeaderView = line
        line.backgroundColor = self.scheduledVisitsTable.separatorColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return scheduledVisitsTable.frame.height/3.232
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ScheduledVisitsTableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ScheduledVisitsTableViewCell
        
        self.scheduledVisitsTable.tableFooterView = UIView()
        self.scheduledVisitsTable.separatorInset = .zero
        cell.selectionStyle = .none
        //layouts
        let cellWidth = cell.contentView.frame.width
        let cellHeight = cell.contentView.frame.height
        
        cell.scheduleImage.frame = CGRect(x: cellWidth/24.352, y: cellHeight/10.5, width: cellWidth/20.7, height: cellWidth/20.7)
        
        cell.residentNameLbl.frame = CGRect(x: cell.scheduleImage.frame.origin.x+cell.scheduleImage.frame.width+cellWidth/37.636, y: cellHeight/21, width: cellWidth/2.049, height: cellHeight/4.941)
        
        cell.serviceLbl.frame = CGRect(x: cellWidth/24.352, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.height, width: cellWidth/6.786, height: cellHeight/7.304)
        
        cell.serviceImageView.frame = CGRect(x: cell.serviceLbl.frame.origin.x+cell.serviceLbl.frame.width+cellWidth/69, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.height, width: cellWidth/15.333, height: cellWidth/15.333)
        
        cell.serviceNameLbl.frame = CGRect(x: cell.serviceImageView.frame.origin.x+cell.serviceImageView.frame.width+cellWidth/41.4, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.height, width: cellWidth/2.539, height: cellHeight/7.304)
        
        cell.startLbl.frame = CGRect(x: cellWidth/24.352, y: cell.serviceNameLbl.frame.origin.y+cell.serviceNameLbl.frame.height, width: cellWidth/10.35, height: cellHeight/7.304)
        
        cell.startDateLbl.frame = CGRect(x: cell.startLbl.frame.origin.x+cell.startLbl.frame.width, y: cell.serviceNameLbl.frame.origin.y+cell.serviceNameLbl.frame.height, width: cellWidth/5.914, height: cellHeight/7.304)
        
        cell.endLbl.frame = CGRect(x: cell.startDateLbl.frame.origin.x+cell.startDateLbl.frame.width, y: cell.serviceNameLbl.frame.origin.y+cell.serviceNameLbl.frame.height, width: cellWidth/12.937, height: cellHeight/7.304)
        
        cell.endDateLbl.frame = CGRect(x: cell.endLbl.frame.origin.x+cell.endLbl.frame.width, y: cell.serviceNameLbl.frame.origin.y+cell.serviceNameLbl.frame.height, width: cellWidth/5.914, height: cellHeight/7.304)
        
        cell.frequencyLbl.frame = CGRect(x: cell.endDateLbl.frame.origin.x+cell.endDateLbl.frame.width, y: cell.serviceNameLbl.frame.origin.y+cell.serviceNameLbl.frame.height, width: cellWidth/5.447, height: cellHeight/7.304)
        
        cell.frequencyTypeLbl.frame = CGRect(x: cell.frequencyLbl.frame.origin.x+cell.frequencyLbl.frame.width, y: cell.serviceNameLbl.frame.origin.y+cell.serviceNameLbl.frame.height, width: cellWidth/4.6, height: cellHeight/7.304)
        
        cell.nextLbl.frame = CGRect(x: cellWidth/24.352, y: cell.frequencyLbl.frame.origin.y+cell.frequencyLbl.frame.height, width: cellWidth/9.857, height: cellHeight/7.304)
        
        cell.nextDateLbl.frame = CGRect(x: cell.nextLbl.frame.origin.x+cell.nextLbl.frame.width+screenWidth/103.5, y: cell.frequencyLbl.frame.origin.y+cell.frequencyLbl.frame.height, width: cellWidth/1.344, height: cellHeight/7.304)
        
        cell.briefDescriptionLbl.frame = CGRect(x: cellWidth/24.352, y: cell.nextDateLbl.frame.origin.y+cell.nextDateLbl.frame.height, width: cellWidth/1.067, height: cellHeight/3.652)
        cell.forwardArrow.frame = CGRect(x: cell.residentNameLbl.frame.origin.x+cell.residentNameLbl.frame.width+cellWidth/3.234, y: cellHeight/4.307, width: cellWidth/14.785, height: cellWidth/14.785)


        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailedDescriptionVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailedDescriptionsViewController") as! DetailedDescriptionsViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)

        self.present(detailedDescriptionVC, animated: false, completion: nil)

    }


    @IBAction func cancelBtnAction(_ sender: Any) {
        let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)

        self.present(RSVC, animated: false, completion: nil)

    }
   
    @IBAction func backBtnAction(_ sender: Any) {
        let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        
        self.present(RSVC, animated: false, completion: nil)

    }
    
    @IBAction func menuBtnAction(_ sender: Any) {
    
        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("ScheduledVisits", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        
        self.present(menu, animated: false, completion: nil)

    }
    
    func layOuts(){
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        backBtn.frame = CGRect(x: screenWidth/24.352, y: screenHeight/23, width: screenWidth/18.818, height: screenWidth/18.818)
        
        evey.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.width+screenWidth/3.696, y: screenHeight/23.741, width: screenWidth/3.763 , height: screenHeight/28.306)
        
        menuBtn.frame = CGRect(x: evey.frame.origin.x+evey.frame.width+screenWidth/4.224, y: screenHeight/23.741, width: screenWidth/11.5, height: screenHeight/32)
        
        scheduleVisitLbl.frame = CGRect(x: screenWidth/24.352, y: backBtn.frame.origin.y+backBtn.frame.height+screenHeight/30.666, width: screenWidth/1.38, height: screenHeight/18.871)
        
        scheduledVisitsTable.frame = CGRect(x: 0, y: scheduleVisitLbl.frame.origin.y+scheduleVisitLbl.frame.height+screenHeight/43.294, width: screenWidth, height: screenHeight/1.355)
        
        buttonView.frame = CGRect(x: 0, y: scheduledVisitsTable.frame.origin.y+scheduledVisitsTable.frame.height, width: screenWidth, height: screenHeight/12.689)
        
        cancelBtn.frame = CGRect(x: screenWidth/15.333, y: buttonView.frame.height/4.916, width: screenWidth/5.307, height: buttonView.frame.height/1.787)
        cancelBtn.isHidden = true

        backActionBtn.frame = CGRect(x: cancelBtn.frame.origin.x+cancelBtn.frame.width+screenWidth/1.962, y: buttonView.frame.height/4.916, width: screenWidth/5.307, height: buttonView.frame.height/1.787)
        
        
        borderLbl.frame = CGRect(x: 0, y: 1, width: screenWidth, height: 1)

    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
        if (knownBeacons.count>0) {
            let closeBeacon = knownBeacons[0] as CLBeacon
            var maj =  Int()
            maj =  8
            let previousBeaconArray : [Int] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [Int]
            if previousBeaconArray.count == 0 {
                if closeBeacon.major.intValue == maj {
                }else{
                    rssiArray.append(closeBeacon.rssi)
                    if rssiArray.count == 1 {
                        let sumedrssi = rssiArray.reduce(0, +)
                        let processedrssi = sumedrssi/1
                        let base = Double(10)
                        let power = Double(-57-(processedrssi))/Double(10*2)
                        let dis = pow(Double(base), power)
                        print("\(closeBeacon.major.intValue)")
                        print("\(closeBeacon.rssi)")
                        print("accuracy \(closeBeacon.accuracy)")
                        print(dis)
                        rssiArray.removeAll()
                        //if closeBeacon.accuracy <= 4.0 {
                        if dis <= 4.0{
                            UserDefaults.standard.set([closeBeacon.major.intValue], forKey: "PreviousBeaconArray")
                            
                            popup.dismiss(animated: true, completion: {
                                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                
                            })
                            locationManager.stopRangingBeacons(in: region)
                            locationManager.stopMonitoring(for: region)
                            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                            let transition = CATransition()
                            transition.duration = 0
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromRight
                            view.window!.layer.add(transition, forKey: kCATransition)
                            
                            self .present(nvc, animated: false, completion: {
                                UserDefaults.standard.set([], forKey: "SelectedArray")
                                UserDefaults.standard.set("", forKey: "Came From")
                            })
                        }
                    }
                }
                
            }else{
                if closeBeacon.major.intValue == maj {
                    rssiArray.append(closeBeacon.rssi)
                    if rssiArray.count == 1 {
                        let sumedrssi = rssiArray.reduce(0, +)
                        let processedrssi = sumedrssi/1
                        let base = Double(10)
                        let power = Double(-59-(processedrssi))/Double(10*2)
                        let dis = pow(Double(base), power)
                        print("\(closeBeacon.major.intValue)")
                        print("\(closeBeacon.rssi)")
                        print("accuracy \(closeBeacon.accuracy)")
                        print(dis)
                        rssiArray.removeAll()
                        //if closeBeacon.accuracy <= 3.0 {
                        if dis <= 3{
                            UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                            let msg = "Are you finished with your visit or are you continuing care?"
                            let attString = NSMutableAttributedString(string: msg)
                            
                            popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                            })
                            
                            print("Dash After")
                            let pauseButton = CancelButton(title: "Pause") {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                
                                
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    RSVC.alertForPause = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromRight
                                    self.view.window!.layer.add(transition, forKey: kCATransition)
                                    
                                    self.present(RSVC, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    })
                                }else{
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForPause = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromRight
                                    self.view.window!.layer.add(transition, forKey: kCATransition)
                                    
                                    self.present(nvc, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }
                                
                                
                            }
                            let continueButton = CancelButton(title: "Continue") {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                
                                
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    RSVC.alertForContinue = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromRight
                                    self.view.window!.layer.add(transition, forKey: kCATransition)
                                    
                                    self.present(RSVC, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    })
                                }else{
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForContinue = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromRight
                                    self.view.window!.layer.add(transition, forKey: kCATransition)
                                    
                                    self.present(nvc, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }
                                
                            }
                            let completeButton = CancelButton(title: "Complete") {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                
                                
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    RSVC.alertForComplete = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromRight
                                    self.view.window!.layer.add(transition, forKey: kCATransition)
                                    
                                    self.present(RSVC, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    })
                                }else{
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForComplete = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromRight
                                    self.view.window!.layer.add(transition, forKey: kCATransition)
                                    
                                    self.present(nvc, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }
                                
                            }
                            let deleteButton = DestructiveButton(title: "Delete") {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                
                                
                            }
                            popup.addButtons([pauseButton,continueButton,completeButton,deleteButton])
                            
                            let hallwayBeaconArray : [Int] = UserDefaults.standard.value(forKey: "HallwayBeaconArray") as! [Int]
                            print("hallway Beacon Count\(hallwayBeaconArray.count)")
                            if hallwayBeaconArray.count == 0{
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count >= 1 && selectedArray.count == 0{
                                    let DVC = storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                    UserDefaults.standard.set([], forKey: "NamesArray")
                                    UserDefaults.standard.set([], forKey: "SelectedArray")
                                    locationManager.stopRangingBeacons(in: region)
                                    locationManager.stopMonitoring(for: region)
                                    
                                    self.present(DVC, animated: true, completion: nil)
                                }else{
                                    
                                    UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                                    
                                    self.present(popup, animated: true, completion: {
                                        UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                        
                                        UserDefaults.standard.set([closeBeacon.major.intValue], forKey: "HallwayBeaconArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set("", forKey: "Came From")
                                        
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}
