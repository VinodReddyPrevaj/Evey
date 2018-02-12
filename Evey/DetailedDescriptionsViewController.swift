//
//  DetailedDescriptionsViewController.swift
//  Evey
//
//  Created by PROJECTS on 01/02/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class DetailedDescriptionsViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var evey: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var scheduledVisitImage: UIImageView!
    
    @IBOutlet weak var residentNameLbl: UILabel!
    
    @IBOutlet weak var borderLbl: UILabel!
    
    @IBOutlet weak var serviceLbl: UILabel!
    
    @IBOutlet weak var serviceImage: UIImageView!
    
    @IBOutlet weak var serviceNameLbl: UILabel!
    
    @IBOutlet weak var startLbl: UILabel!
    
    @IBOutlet weak var startDateLbl: UILabel!
    
    @IBOutlet weak var endLbl: UILabel!
    
    @IBOutlet weak var endDateLbl: UILabel!
    
    @IBOutlet weak var frequencyLbl: UILabel!
    
    @IBOutlet weak var typeOfFrequencyLbl: UILabel!
    
    @IBOutlet weak var nextLbl: UILabel!
    
    @IBOutlet weak var nextDateLbl: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var enterVisitBtn: UIButton!
    
    @IBOutlet weak var viesScheduledVisitsBtn: UIButton!
    
    @IBOutlet weak var bottomButtonsView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var backActionBtn: UIButton!
    
    @IBOutlet weak var bottomBorderLbl: UILabel!
    
    @IBOutlet weak var forwardArrow: UIButton!
    
    // for beacon detection
    
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backActionBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func layOuts(){
       
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height

        backBtn.frame = CGRect(x: screenWidth/24.352, y: screenHeight/23, width: screenWidth/18.818, height: screenWidth/18.818)
        
        evey.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.width+screenWidth/3.696, y: screenHeight/23.741, width: screenWidth/3.763 , height: screenHeight/28.306)
        
        menuBtn.frame = CGRect(x: evey.frame.origin.x+evey.frame.width+screenWidth/4.224, y: screenHeight/23.741, width: screenWidth/11.5, height: screenHeight/32)
        
        scheduledVisitImage.frame = CGRect(x: screenWidth/23, y: backBtn.frame.origin.y+backBtn.frame.height+screenHeight/21.647, width: screenWidth/20.7, height: screenWidth/20.7)
        
        residentNameLbl.frame = CGRect(x: scheduledVisitImage.frame.origin.x+scheduledVisitImage.frame.width+screenWidth/46, y: backBtn.frame.origin.y+backBtn.frame.height+screenHeight/30.666, width: screenWidth/1.38, height: screenHeight/18.871)
        
        borderLbl.frame = CGRect(x: 0, y: residentNameLbl.frame.origin.y+residentNameLbl.frame.height+screenHeight/73.6, width: screenWidth, height: 1)

        serviceLbl.frame = CGRect(x: screenWidth/24.352, y: borderLbl.frame.origin.y+borderLbl.frame.height+screenHeight/61.333, width: screenWidth/6.786, height: screenHeight/32)
        
        serviceImage.frame = CGRect(x: serviceLbl.frame.origin.x+serviceLbl.frame.width+screenWidth/69, y: borderLbl.frame.origin.y+borderLbl.frame.height+screenHeight/61.333, width: screenWidth/15.333, height: screenWidth/15.333)
        
        serviceNameLbl.frame = CGRect(x: serviceImage.frame.origin.x+serviceImage.frame.width+screenWidth/41.4, y:borderLbl.frame.origin.y+borderLbl.frame.height+screenHeight/61.333, width: screenWidth/2.539, height: screenHeight/32)
        
        startLbl.frame = CGRect(x: screenWidth/24.352, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/10.35, height: screenHeight/32)
        
        startDateLbl.frame = CGRect(x: startLbl.frame.origin.x+startLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/5.914, height: screenHeight/32)
        
        endLbl.frame = CGRect(x: startDateLbl.frame.origin.x+startDateLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/12.937, height: screenHeight/32)
        
        endDateLbl.frame = CGRect(x: endLbl.frame.origin.x+endLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/5.914, height: screenHeight/32)
        
        frequencyLbl.frame = CGRect(x: endDateLbl.frame.origin.x+endDateLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/5.447, height: screenHeight/32)
        
        typeOfFrequencyLbl.frame = CGRect(x: frequencyLbl.frame.origin.x+frequencyLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/4.6, height: screenHeight/32)
        
        nextLbl.frame = CGRect(x: screenWidth/24.352, y: frequencyLbl.frame.origin.y+frequencyLbl.frame.height, width: screenWidth/9.857, height: screenHeight/32)
        
        nextDateLbl.frame = CGRect(x: nextLbl.frame.origin.x+nextLbl.frame.width+screenWidth/103.5, y: frequencyLbl.frame.origin.y+frequencyLbl.frame.height, width: screenWidth/1.344, height: screenHeight/32)
        
        descriptionTextView.frame = CGRect(x: screenWidth/31.846, y: nextDateLbl.frame.origin.y+nextDateLbl.frame.height, width: screenWidth/1.128, height: screenHeight/2.991)
        
        var frame = self.descriptionTextView.frame
        frame.size.height = self.descriptionTextView.contentSize.height
        self.descriptionTextView.frame = frame
        
        forwardArrow.frame = CGRect(x: descriptionTextView.frame.origin.x+descriptionTextView.frame.width, y: screenHeight/3.131, width: screenWidth/14.785, height: screenWidth/14.785)
        
        forwardArrow.isHidden = true
        
        
        buttonsView.frame = CGRect(x: 0, y: descriptionTextView.frame.origin.y+descriptionTextView.frame.height, width: screenWidth, height: screenHeight/7.913)
        
        enterVisitBtn.frame = CGRect(x: 0, y: 1, width: screenWidth, height: buttonsView.frame.height/2.066)
        
        viesScheduledVisitsBtn.frame = CGRect(x: 0, y: enterVisitBtn.frame.origin.y+enterVisitBtn.frame.height+1, width: screenWidth, height: buttonsView.frame.height/2.066)
        
        bottomButtonsView.frame = CGRect(x: 0, y: screenHeight-screenHeight/12.474, width: screenWidth, height: screenHeight/12.474)
        
        cancelBtn.frame = CGRect(x: screenWidth/15.333, y: bottomButtonsView.frame.height/4.916, width: screenWidth/5.307, height: bottomButtonsView.frame.height/1.787)
        
        cancelBtn.isHidden = true
        
        backActionBtn.frame = CGRect(x: cancelBtn.frame.origin.x+cancelBtn.frame.width+screenWidth/1.962, y: bottomButtonsView.frame.height/4.916, width: screenWidth/5.307, height: bottomButtonsView.frame.height/1.787)

        
        bottomBorderLbl.frame = CGRect(x: 0, y: 1, width: screenWidth, height: 1)
        
        
    }

    func backAction(){
        
        let scheduledVisitsVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduledVisitsViewController") as! ScheduledVisitsViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        self.present(scheduledVisitsVC, animated: false, completion: nil)
   
    }
    
    @IBAction func menuBtnAction(_ sender: Any) {
        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("DetailedDescription", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        
        self.present(menu, animated: false, completion: nil)

    }
    @IBAction func viewAllScheduledVisitsAction(_ sender: Any) {
        
        let scheduledVisitsVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduledVisitsViewController") as! ScheduledVisitsViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        self.present(scheduledVisitsVC, animated: false, completion: nil)

    }
    
    @IBAction func enterVisitAction(_ sender: Any) {
        
        let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController")as! CareSelectViewController
        CSVC.residentNameRoom = residentNameLbl.text!
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set(residentNameLbl.text!, forKey: "nameRoom")
        UserDefaults.standard.set(residentNameLbl.text!, forKey: "SelectedArray")
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        self.present(CSVC, animated: false, completion: {
            
        })
 
        
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
