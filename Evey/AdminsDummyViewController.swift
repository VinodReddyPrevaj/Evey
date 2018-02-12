//
//  AdminsDummyViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 01/12/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class AdminsDummyViewController: UIViewController ,CLLocationManagerDelegate{

    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var administratorLbl: UILabel!
    
    @IBOutlet weak var administratorsView: UIView!
    
    @IBOutlet weak var michaelJackson: UIButton!
    
    @IBOutlet weak var edwardLeven: UIButton!
    
    @IBOutlet weak var elloitNess: UIButton!
    
    @IBOutlet weak var michaelJacksonBtn: UIButton!
    
    @IBOutlet weak var edwardLevenBtn: UIButton!
    
    @IBOutlet weak var elloitNessBtn: UIButton!
    
    @IBOutlet weak var firstBorder: UILabel!
    
    @IBOutlet weak var secondBorder: UILabel!
    @IBOutlet weak var thirdBorder: UILabel!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var buttonsViewBorder: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //for beacon Detection
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        // to detect beacons
        
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
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        let admins = self.storyboard?.instantiateViewController(withIdentifier: "ContactsDummyViewController") as! ContactsDummyViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(admins, animated: false, completion: nil)
 
    }
    @IBAction func michaelJackson(_ sender: Any) {
        let admins = self.storyboard?.instantiateViewController(withIdentifier: "AdministratorContactViewController") as! AdministratorContactViewController
        admins.titleNameString = "MJ"
        admins.administratorName = "Michael Jackson"
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(admins, animated: false, completion: nil)

    }

    @IBAction func elloitNess(_ sender: Any) {
        print("elloiness")
        let admins = self.storyboard?.instantiateViewController(withIdentifier: "AdministratorContactViewController") as! AdministratorContactViewController
        admins.titleNameString = "EN"
        admins.administratorName = "Elloit Ness"
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(admins, animated: false, completion: nil)

    }
    @IBAction func edwardLeven(_ sender: Any) {
        let admins = self.storyboard?.instantiateViewController(withIdentifier: "AdministratorContactViewController") as! AdministratorContactViewController
        admins.titleNameString = "EL"
        admins.administratorName = "Edward Leven"
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(admins, animated: false, completion: nil)

    }
    @IBAction func menuBtnAction(_ sender: Any) {
        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0
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
        
        administratorLbl.frame = CGRect(x: screenWidth/46.875, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/133.4, width: screenWidth/1.518, height: screenHeight/19.051)
        
        searchBar.frame = CGRect(x: 0, y: administratorLbl.frame.origin.y+administratorLbl.frame.height, width: screenWidth, height: screenHeight/15.159)
        
        administratorsView.frame = CGRect(x: 0, y: searchBar.frame.origin.y+searchBar.frame.size.height, width: screenWidth, height: screenHeight/3.994)
        
        michaelJackson.frame = CGRect(x: screenWidth/22.058, y: administratorsView.frame.height/20.875, width: screenWidth/2.737, height: administratorsView.frame.height/5.566)
        
        michaelJacksonBtn.frame = CGRect(x: 0, y: michaelJackson.frame.origin.y, width: screenWidth, height: michaelJackson.frame.height)
        
        firstBorder.frame = CGRect(x: 0, y: michaelJackson.frame.origin.y+michaelJackson.frame.height+administratorsView.frame.height/27.833, width: screenWidth, height: 1)
        
        edwardLeven.frame = CGRect(x: screenWidth/22.058, y: firstBorder.frame.origin.y+firstBorder.frame.height+administratorsView.frame.height/33.4, width: screenWidth/3.232, height: administratorsView.frame.height/5.566)
        
        edwardLevenBtn.frame = CGRect(x: 0, y: edwardLeven.frame.origin.y, width: screenWidth, height: edwardLeven.frame.height)
        
        secondBorder.frame = CGRect(x: 0, y: edwardLeven.frame.origin.y+edwardLeven.frame.height+administratorsView.frame.height/27.833, width: screenWidth, height: 1)
        
        elloitNess.frame = CGRect(x: screenWidth/22.058, y: secondBorder.frame.origin.y+secondBorder.frame.height+administratorsView.frame.height/33.4, width: screenWidth/4.261, height: administratorsView.frame.height/5.566)
        
        elloitNessBtn.frame = CGRect(x: 0, y: elloitNess.frame.origin.y, width: screenWidth, height: elloitNess.frame.height)
        
        thirdBorder.frame = CGRect(x: 0, y: elloitNess.frame.origin.y+elloitNess.frame.height+administratorsView.frame.height/27.833, width: screenWidth, height: 1)
        
        buttonsView.frame = CGRect(x: 0, y: screenHeight-screenHeight/12.584, width: screenWidth, height: screenHeight/12.584)
        
        buttonsViewBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        
        cancelBtn.frame = CGRect(x: screenWidth/1.315, y: buttonsView.frame.size.height/4.818, width: screenWidth/5.281, height: buttonsView.frame.size.height/1.766)
        
        
        
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
                            self .present(nvc, animated: true, completion: {
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
                            print("After")
                            UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                            let msg = "Are you finished with your visit or are you continuing care?"
                            let attString = NSMutableAttributedString(string: msg)
                            
                            popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                                
                            })

                            let pauseButton = CancelButton(title: "Pause", action: {
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {

                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                        self.locationManager.stopMonitoring(for: region)
                                        self.locationManager.stopRangingBeacons(in: region)
                                        RSVC.alertForPause = true
                                        self.present(RSVC, animated: true, completion: {
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
                                    self.present(nvc, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }
                                
                            })
                            
                            let continueButton = CancelButton(title: "Continue", action: {
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    RSVC.alertForContinue = true
                                    self.present(RSVC, animated: true, completion: {
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
                                    self.present(nvc, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }

                            })
                            
                            let completeButton = CancelButton(title: "Complete", action: {
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    RSVC.alertForComplete = true
                                    self.present(RSVC, animated: true, completion: {
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
                                    self.present(nvc, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }
 
                            })
                            
                            let deleteButton = DestructiveButton(title: "Delete", action: {
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                            })
                            popup.addButtons([pauseButton,continueButton,completeButton,deleteButton])

                            let hallwayBeaconArray : [Int] = UserDefaults.standard.value(forKey: "HallwayBeaconArray") as! [Int]
                            if hallwayBeaconArray.count == 0 {
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
                                    
                                    self.present(popup, animated: true, completion: {
                                        UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                        UserDefaults.standard.set([closeBeacon.major.intValue], forKey: "HallwayBeaconArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
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
