//
//  ContactsViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 24/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class ContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource ,CLLocationManagerDelegate{
    @IBOutlet weak var contactsTableView: UITableView!
    var contactsArray = ["Tech Support","Administrators","Residents"]
    //for beacon Detection
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: true, completion: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactsTableView.tableFooterView = UIView()
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
    

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contactsArray.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ContactsTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.typeOfContactsLbl.text = contactsArray[indexPath.row]
        
        cell.typeOfContactsLbl.frame = CGRect(x: self.view.frame.width/22.058, y: cell.contentView.frame.height/4, width: self.view.frame.width/1.25, height: cell.contentView.frame.height/2.095)
        
        cell.forwardArrowBtn.frame = CGRect(x: cell.typeOfContactsLbl.frame.origin.x+cell.typeOfContactsLbl.frame.width+self.view.frame.width/12.5, y: cell.contentView.frame.height/5.5, width: self.view.frame.width/1.25, height: cell.contentView.frame.height/5.5)

        cell.separatorInset = UIEdgeInsets.zero

     return cell
     }
    
    func forwardArrowBtnAction(_ sender: Any){
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: contactsTableView)
        let indexpath: IndexPath? = contactsTableView.indexPathForRow(at: buttonPosition)
        froward(indexpath:indexpath!)
 
    }
    func froward(indexpath : IndexPath){
        let cell: ContactsTableViewCell = contactsTableView.cellForRow(at:(indexpath)) as! ContactsTableViewCell
        
        if cell.typeOfContactsLbl.text == "Tech Support" {
            let techsupport = self.storyboard?.instantiateViewController(withIdentifier: "TechSupportContactViewController") as! TechSupportContactViewController
            let transition = CATransition()
            transition.duration = 0.1
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.present(techsupport, animated: false, completion: nil)
            
        }else if cell.typeOfContactsLbl.text == "Administrators"{
            let administators = self.storyboard?.instantiateViewController(withIdentifier: "AdminstratorsViewController") as! AdminstratorsViewController
            let transition = CATransition()
            transition.duration = 0.1
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: kCATransition)
            
            self.present(administators, animated: false, completion: nil)
            
        }else if cell.typeOfContactsLbl.text == "Residents"{
            let residentContacts = self.storyboard?.instantiateViewController(withIdentifier: "ResidentsContactsViewController") as! ResidentsContactsViewController
            let transition = CATransition()
            transition.duration = 0.1
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: kCATransition)
            
            self.present(residentContacts, animated: false, completion: nil)
        }

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        froward(indexpath:indexPath)

    }

    @IBAction func cancelBtnAction(_ sender: Any) {
        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(menu, animated: false, completion: nil)
    }
    @IBAction func menuBtnAction(_ sender: Any) {
        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(menuViewController, animated: false, completion: nil)
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
