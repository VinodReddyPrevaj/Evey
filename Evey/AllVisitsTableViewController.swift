//
//  AllVisitsTableViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 23/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class AllVisitsTableViewController: UITableViewController,CLLocationManagerDelegate {
    //for beacon Detection
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
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
    override func viewWillDisappear(_ animated: Bool) {
        self.locationManager.stopMonitoring(for: region)
        self.locationManager.stopRangingBeacons(in: region)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height/4.377358490566038
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = AllVisitsTableViewCell()
         cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! AllVisitsTableViewCell
        if indexPath.row == 0 {
            cell.visitImage.image = UIImage(named: "scheduledOpenVisitIcon")
            cell.residentNameLbl.text = "Edward J.310"
            cell.serviceImage.image = UIImage(named: "Eye Drops")
            cell.serviceName.text = "Eye Drops"
            cell.startTimeLbl.text = "11:00 AM"
            cell.endTimeLbl.text = "11:15 AM"
            
            
        }else if indexPath.row == 1 {
            cell.visitImage.image = UIImage(named: "openVisitIcon")
            cell.residentNameLbl.text = "Chris P.310"
            cell.serviceImage.image = UIImage(named: "Treatments")
            cell.serviceName.text = "Treatments"
            cell.startTimeLbl.text = "1:25 PM"
            cell.endTimeLbl.text = "2:01 PM"
            
        }else if indexPath.row == 2 {
            cell.visitImage.image = UIImage(named: "scheduledPerformedVisitIcon")
            cell.residentNameLbl.text = "Edward J.310"
            cell.serviceImage.image = UIImage(named: "Bathing")
            cell.serviceName.text = "Bathing"
            cell.startTimeLbl.text = "9:15 AM"
            cell.endTimeLbl.text = "9:45 AM"
            
            
        }else{
            cell.visitImage.image = UIImage(named: "performedVisitIcon")
            cell.residentNameLbl.text = "Chris P.310"
            cell.serviceImage.image = UIImage(named: "Escort")
            cell.serviceName.text = "Escort"
            cell.startTimeLbl.text = "3:35 PM"
            cell.endTimeLbl.text = "4:25 PM"
            
        }


        self.tableView.tableFooterView = UIView()
        cell.separatorInset = UIEdgeInsets.zero
        //layOuts
        let cellWidth =  cell.contentView.frame.width
        let cellHeight = cell.contentView.frame.height
        
        cell.visitImage.frame = CGRect(x: cellWidth/31.25, y: cellHeight/4.818, width: cellWidth/18.75, height: cellHeight/5.3)
        
        cell.residentNameLbl.frame = CGRect(x: cell.visitImage.frame.origin.x+cell.visitImage.frame.width+cellWidth/46.875, y: cellHeight/9.636, width: cellWidth/2.049, height: cellHeight/2.465)
        
        cell.service.frame = CGRect(x: cellWidth/31.25, y: cell.visitImage.frame.origin.y+cell.visitImage.frame.height+cellHeight/13.25, width: cellWidth/6.696, height: cellHeight/5.047)
        
        cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.width+cellWidth/46.875, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.height-cellHeight/17.666, width: cellWidth/15, height: cellHeight/4.24)
        
        cell.serviceName.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.width+cellWidth/46.875, y: cell.visitImage.frame.origin.y+cell.visitImage.frame.height+cellHeight/13.25, width: cellWidth/3.989, height: cellHeight/5.047)
        
        cell.startTime.frame = CGRect(x: cellWidth/31.25, y: cell.service.frame.origin.y+cell.service.frame.height, width: cellWidth/5.208, height: cellHeight/5.047)
        
        cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.width, y:  cell.service.frame.origin.y+cell.service.frame.height, width: cellWidth/5.514, height: cellHeight/5.047)
        
        
        cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.width+cellWidth/25, y:  cell.service.frame.origin.y+cell.service.frame.height, width: cellWidth/5.859, height: cellHeight/5.047)
        
        cell.endTimeLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.width, y:  cell.service.frame.origin.y+cell.service.frame.height, width: cellWidth/5.514, height: cellHeight/5.047)
        
        cell.arrow.frame = CGRect(x: cellWidth/1.126, y: cellHeight/2.304, width: cellWidth/12.5, height: cellHeight/3.785)
        
        cell.arrow.addTarget(self, action: #selector(arrowAction(_:)), for: .touchUpInside)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.arrow.isHidden = true

        return cell
    }
    func arrowAction( _ sender:Any){
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: tableView)
        let indexpath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)
        let cell: AllVisitsTableViewCell = tableView.cellForRow(at:indexpath!) as! AllVisitsTableViewCell
        
        UserDefaults.standard.set(cell.residentNameLbl.text, forKey: "ResidentDetails")
        
        UserDefaults.standard.set("RecentVisitsViewController", forKey: "Came From")
        let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
        
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        
        self.locationManager.stopRangingBeacons(in: region)
        self.locationManager.stopMonitoring(for: region)

        self.present(CSVC, animated: false, completion: nil)

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section==2) {
            return "Visits Today"
            
        }
        return "Today"
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return CGFloat(23.0)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 23))
        let title = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.size.width, height: headerView.bounds.size.height))
        title.font = UIFont.systemFont(ofSize:17, weight: UIFontWeightMedium)
        if (section==0) {
            title.text="Today"
            
            title.textColor = UIColor.init(red: 104.0/255.0, green: 111.0/255.0, blue: 118.0/255.0, alpha: 1.0)
            headerView.backgroundColor = UIColor.init(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            
        }else if(section==1){
            title.text="Scheduled Care"
            title.textColor = UIColor.init(red: 100.0/255.0, green: 187.0/255.0, blue: 214/255.0, alpha: 1.0)
            headerView.backgroundColor = UIColor.init(red: 254.0/255.0, green: 232.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            
        }else{
            title.text="Visits Today"
            title.textColor = UIColor.init(red: 104.0/255.0, green: 111.0/255.0, blue: 118.0/255.0, alpha: 1.0)
            headerView.backgroundColor = UIColor.init(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            
        }
        headerView .addSubview(title)
        
        return headerView
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
