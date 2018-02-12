//
//  OpenVisitsViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 20/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class OpenVisitsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    @IBOutlet weak var residentNameLabel: UILabel!

    @IBOutlet weak var openVisitsTableView: UITableView!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var evey: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var openVisitImage: UIImageView!
    
    @IBOutlet weak var residentNameLbl: UILabel!
    
    @IBOutlet weak var buttonsView: UIView!
    
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var borderLbl: UILabel!
    
    
    let openVisits = [["Service": "Treatments",
                       "Start time": "8:15 AM",
                       "End time": "8:22 AM"],
                      ["Service": "Medication",
                       "Start time": "12:05 PM",
                       "End time": "12:18 PM"],
                      ["Service": "Bathing",
                       "Start time": "3:15 PM",
                       "End time": "3:22 PM"]]
    
    var residentNameStr = String()
    
    // for beacon detection
    
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        
        residentNameLbl.text = UserDefaults.standard.value(forKey: "openVisitsResidentName") as? String
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(openVisitsTableView.frame.size.width), height: CGFloat(px))
        let line = UIView(frame: frame)
        self.openVisitsTableView.tableHeaderView = line
        line.backgroundColor = self.openVisitsTableView.separatorColor
        openVisitsTableView.tableFooterView = UIView()
        
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)
        acceptableDistance = 2.0
        rssiArray.removeAll()
        
        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion:nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        let RSVC =  self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
        
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        self.present(RSVC, animated: false, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = OpenVisitsTableViewCell1()
        cell = openVisitsTableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! OpenVisitsTableViewCell1
        cell.serviceNameLabel.text = "\((openVisits[indexPath.row]["Service"])!)"
        cell.startTimeLbl.text = "\((openVisits[indexPath.row]["Start time"])!)"
        cell.pauseTimeLbl.text = "\((openVisits[indexPath.row]["End time"])!)"
        cell.serviceImage.image = UIImage(named: openVisits[indexPath.row]["Service"]!)
        
        
        
        let cellWidth = cell.contentView.frame.width
        let cellHeight = cell.contentView.frame.height
        
        
        cell.serviceLbl.frame = CGRect(x: cellWidth/25, y: cellHeight/8.4, width: cellWidth/6.696, height: cellHeight/4)
        
        cell.serviceImage.frame = CGRect(x: cell.serviceLbl.frame.origin.x+cell.serviceLbl.frame.width+cellWidth/46.875, y: cellHeight/10.5, width: cellWidth/15, height: cellWidth/15)
        
        cell.serviceNameLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.width+cellWidth/46.875, y: cellHeight/8.4, width: cellWidth/3.989, height: cellHeight/4)
        
        cell.startTime.frame = CGRect(x: cellWidth/25, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.height, width: cellWidth/5.208, height: cellHeight/4)
        
        cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.width, y:  cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.height, width: cellWidth/5.514, height: cellHeight/4)
        
        
        cell.pauseTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.width+cellWidth/25, y:  cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.height, width: cellWidth/4.6875, height: cellHeight/4)
        
        cell.pauseTimeLbl.frame = CGRect(x: cell.pauseTime.frame.origin.x+cell.pauseTime.frame.width, y:  cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.height, width: cellWidth/5.514, height: cellHeight/4)
        
        cell.totalTimeSpent.frame =  CGRect(x: cellWidth/25, y: cell.pauseTime.frame.origin.y+cell.pauseTime.frame.height, width: cellWidth/3.232, height: cellHeight/4)
        
        cell.totalTimeSpentLbl.frame =  CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.width, y: cell.pauseTime.frame.origin.y+cell.pauseTime.frame.height, width: cellWidth/4.213, height: cellHeight/4)
        
        cell.arrow.frame = CGRect(x: cellWidth/1.126, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.height, width: cellWidth/12.5, height: cellWidth/12.5)
        
        
        
        cell.separatorInset = UIEdgeInsets.zero
        cell.arrow.addTarget(self, action: #selector(arrowAction(_:)), for: .touchUpInside)

     return cell
     }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController")as! CareSelectViewController
        CSVC.residentNameRoom = ""
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        UserDefaults.standard.set(residentNameLbl.text, forKey: "nameRoom")
        UserDefaults.standard.set(residentNameLbl.text, forKey: "SelectedArray")
        self.present(CSVC, animated: false, completion: {
            
        })

    }
    func layOuts(){
        
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        backBtn.frame = CGRect(x: screenWidth/23.437, y: screenHeight/23, width: screenWidth/18.75, height: screenHeight/33.35)
        
        evey.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.size.width+screenWidth/3.712, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: evey.frame.origin.x+evey.frame.size.width+screenWidth/4.213, y: screenHeight/23.437, width: screenWidth/11.363, height: screenHeight/31.761)
        
        openVisitImage.frame = CGRect(x: screenWidth/25, y: evey.frame.origin.y+evey.frame.size.height+screenHeight/24.703, width: screenWidth/18.75, height: screenWidth/18.75)
        
        
        
        residentNameLbl.frame = CGRect(x: openVisitImage.frame.origin.x+openVisitImage.frame.width+screenWidth/37.5, y: evey.frame.origin.y+evey.frame.size.height+screenHeight/35.105, width: screenWidth/1.518, height: screenHeight/18.527)
        
        openVisitsTableView.frame =  CGRect(x: 0, y: residentNameLbl.frame.origin.y+residentNameLbl.frame.size.height+screenHeight/44.466, width: screenWidth, height: screenHeight/1.355)
        
        buttonsView.frame = CGRect(x: 0, y: openVisitsTableView.frame.origin.y+openVisitsTableView.frame.size.height, width: screenWidth, height: screenHeight/12.584)
        
        
        backButton.frame = CGRect(x: screenWidth/1.306, y: buttonsView.frame.size.height/4.818, width: screenWidth/5.281, height: buttonsView.frame.size.height/1.766)
        
        
        borderLbl.frame = CGRect(x: 0, y: 0, width: screenWidth, height:1)
        
    }
    
    func arrowAction(_ sender: Any) {
//        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.openVisitsTableView)
//        let indexpath: IndexPath? = self.openVisitsTableView.indexPathForRow(at: buttonPosition)
        let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController")as! CareSelectViewController
        CSVC.residentNameRoom = residentNameStr
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set(residentNameLbl.text, forKey: "nameRoom")
        UserDefaults.standard.set(residentNameLbl.text, forKey: "SelectedArray")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        self.present(CSVC, animated: false, completion: {
            
        })
 
    }

    @IBAction func menuBtnAction(_ sender: Any) {
        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("OpenVisitsViewController", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        self.present(menu, animated: false, completion: nil)

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
