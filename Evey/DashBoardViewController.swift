//
//  DashBoardViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 26/09/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class DashBoardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource ,UIScrollViewDelegate,CLLocationManagerDelegate{
    let headerView = UIView()
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet weak var menuBtn: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    var hint = Bool()
    let cell = VisitsTableViewCell()
    var cellHeight = CGFloat()
    

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eveyTitle: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var desView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    // for beacon detection
    
    var rssiArray = [0]
    var acceptableDistance = Double()

    
    var popup = PopupDialog(title: "", message:NSAttributedString(), buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
    }

    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        layOuts()
        // beacon detection 
        
        acceptableDistance = 2.0
        rssiArray.removeAll()
        

       // hint = true
        cellHeight = tableView.frame.height/5.317
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognizerAction(_gesture:)))
        self.desView.addGestureRecognizer(panGestureRecognizer)
        
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)
        if UserDefaults.standard.value(forKey: "Status") as! String == "false" {
            self.desView.isHidden=true
            // hint = true
            headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/5.841)
            tableView.tableHeaderView = headerView
            
        }

        nameLabel.text = UserDefaults.standard.value(forKey: "name") as? String
        
        // to show popup alert
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
                hint = true
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
    
  
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return cellHeight
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = VisitsTableViewCell()
        if (indexPath.section==0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! VisitsTableViewCell

            
            if (indexPath.row == 0) {
                cell.residentNameLbl.text = "Edward J.310"
                cell.typeImage.image = UIImage(named:"scheduledOpenVisitIcon")
                cell.serviceImage.image=UIImage(named:"Eye Drops")
                cell.serviceLabel.text="Eye Drops"
                cell.startTimeLbl.text = "11:00 AM"
                cell.endTiemLbl.text = "11:15 AM"
                cell.totalTimeSpentLbl.text = "15 minutes"

            }else{
                cell.typeImage.image = UIImage(named:"openVisitIcon")
                cell.serviceLabel.text="Treatments"
                cell.serviceImage.image=UIImage(named:"Treatments")

            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            // layOuts

            let cellWidth =  cell.contentView.frame.size.width
            let cellHeight = cell.contentView.frame.size.height
            
            
            cell.typeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/10.5, width: cellWidth/18.818, height: cellWidth/18.818)

            cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.680)

            cell.service.frame = CGRect(x: cellWidth/46, y: cell.typeImage.frame.origin.y+cell.typeImage.frame.size.height+cellHeight/14, width: cellWidth/6.677, height: cellHeight/5.478)

            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/18, width: cellWidth/15.333, height: cellWidth/15.333)

            cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/4.019, height: cellHeight/5.478)

            cell.startTime.frame = CGRect(x: cellWidth/46, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.111, height: cellHeight/5.478)

            cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
            
            
            cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+screenWidth/37.5, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/4.6875, height: cellHeight/5.478)

            cell.endTiemLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)

            cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.234, height: cellHeight/5.478)

            cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/4.224, height: cellHeight/5.478)

            cell.arrow.frame = CGRect(x: cellWidth/1.106, y: cellHeight/3.315, width: cellWidth/12.545, height: cellHeight/4.064)
            
            
            
            cell.separatorInset = UIEdgeInsets.zero
            cell.arrow.addTarget(self, action: #selector(arrowAction(_:)), for: .touchUpInside)
            
            return cell
            
            
        }  else if (indexPath.section==1) {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath) as! VisitsTableViewCell

            
            if (indexPath.row == 0) {
               cell.serviceImage.image=UIImage(named:"Bathing")
                cell.serviceLabel.text="Bathing"
                cell.nextServiceTiemLbl.text = "9:00 AM - 10:00 AM"
                
            }else{
                cell.serviceImage.image=UIImage(named:"Eye Drops")
                cell.serviceLabel.text="Eye Drops"
                
            }
            cell.separatorInset = UIEdgeInsets.zero
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            // layOuts
            
            let cellWidth =  cell.contentView.frame.size.width
            let cellHeight = cell.contentView.frame.size.height
            
            
            
            cell.residentNameLbl1.frame = CGRect(x: cellWidth/34.5, y: cellHeight/19, width: cellWidth/2.049, height: cellHeight/3.677)
            
            cell.service.frame = CGRect(x: cellWidth/34.5, y: cell.residentNameLbl1.frame.origin.y+cell.residentNameLbl1.frame.size.height+cellHeight/42, width: cellWidth/6.677, height: cellHeight/5.478)
            
            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl1.frame.origin.y+cell.residentNameLbl1.frame.size.height+cellHeight/42, width: cellWidth/15.333, height: cellWidth/15.333)
            
            cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl1.frame.origin.y+cell.residentNameLbl1.frame.size.height+cellHeight/42, width: cellWidth/4.019, height: cellHeight/5.478)
            
            cell.startDate.frame = CGRect(x: cellWidth/34.5, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/10.35, height: cellHeight/5.428)
            
            cell.startDateLbl.frame = CGRect(x: cell.startDate.frame.origin.x+cell.startDate.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/5.914, height: cellHeight/5.428)
            
            cell.endDate.frame = CGRect(x: cell.startDateLbl.frame.origin.x+cell.startDateLbl.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/12.937, height: cellHeight/5.428)
            
            cell.endDateLbl.frame = CGRect(x: cell.endDate.frame.origin.x+cell.endDate.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/5.914, height: cellHeight/5.428)
            
            cell.frequency.frame = CGRect(x: cell.endDateLbl.frame.origin.x+cell.endDateLbl.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/5.240, height: cellHeight/5.428)
            
            cell.frequencyLbl.frame = CGRect(x: cell.frequency.frame.origin.x+cell.frequency.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/4.6, height: cellHeight/5.428)
            
            cell.nextServiceTime.frame = CGRect(x: cellWidth/34.5, y: cell.startDate.frame.origin.y+cell.startDate.frame.size.height, width: cellWidth/3.066, height: cellHeight/5.428)
            
            cell.nextServiceTiemLbl.frame = CGRect(x: cell.nextServiceTime.frame.origin.x+cell.nextServiceTime.frame.size.width, y: cell.startDate.frame.origin.y+cell.startDate.frame.size.height, width: cellWidth/2.156, height: cellHeight/5.428)
            
            cell.arrow1.frame = CGRect(x: cellWidth/1.106, y: cellHeight/3.315, width: cellWidth/12.545, height: cellHeight/4.064)

            
            
            cell.arrow1.addTarget(self, action: #selector(arrowAction(_:)), for: .touchUpInside)

            cell.arrow1.tag = indexPath.section
            
            return cell
            
        }  else   {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! VisitsTableViewCell

            cell.typeImage.image = UIImage(named:"performedVisitIcon")
            if (indexPath.row == 0) {
                cell.typeImage.image = UIImage(named: "scheduledPerformedVisitIcon")
                cell.residentNameLbl.text = "Edward J.310"
                cell.serviceImage.image=UIImage(named:"Bathing")
                cell.serviceLabel.text="Bathing"
                cell.startTimeLbl.text = "9:15 AM"
                cell.endTiemLbl.text = "9:45 AM"
                cell.totalTimeSpentLbl.text = "30 minutes"

                
            }else{

                cell.serviceImage.image=UIImage(named:"Escort")
                cell.serviceLabel.text="Escort"
                cell.startTimeLbl.text = "3:35 PM"
                cell.endTiemLbl.text = "4:25 PM"
                cell.totalTimeSpentLbl.text = "50 minutes"
  
            }
            cell.separatorInset = UIEdgeInsets.zero
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            
            // layOuts
            
            let cellWidth =  cell.contentView.frame.size.width
            let cellHeight = cell.contentView.frame.size.height
            
            
            cell.typeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/10.5, width: cellWidth/18.818, height: cellWidth/18.818)
            
            cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.680)
            
            cell.service.frame = CGRect(x: cellWidth/46, y: cell.typeImage.frame.origin.y+cell.typeImage.frame.size.height+cellHeight/14, width: cellWidth/6.677, height: cellHeight/5.478)
            
            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/18, width: cellWidth/15.333, height: cellWidth/15.333)
            
            cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/4.019, height: cellHeight/5.478)
            
            cell.startTime.frame = CGRect(x: cellWidth/46, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.111, height: cellHeight/5.478)
            
            cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
            
            cell.endTime.text = "End time:"

            cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+cellWidth/25.875, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.671, height: cellHeight/5.478)
            
            cell.endTiemLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
            
            cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.234, height: cellHeight/5.478)
            
            cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/4.224, height: cellHeight/5.478)
            
            cell.arrow.frame = CGRect(x: cellWidth/1.106, y: cellHeight/3.315, width: cellWidth/12.545, height: cellHeight/4.064)

            
            cell.arrow.addTarget(self, action: #selector(arrowAction(_:)), for: .touchUpInside)

            
            return cell
            
        }
        
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
        transition.duration = 0
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
        let title = UILabel(frame: CGRect(x: self.tableView.frame.width/27.6, y: 0, width: tableView.bounds.size.width, height: headerView.bounds.size.height))
        title.font = UIFont.systemFont(ofSize:17, weight: UIFontWeightMedium)
        if (section==0) {
            title.text="Open Visits"
            
            title.textColor = UIColor.white
            headerView.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.462745098, blue: 0.7333333333, alpha: 1)
          //  headerView.backgroundColor = UIColor.init(red: 29.0/255.0, green: 118.0/255.0, blue: 187.0/255.0, alpha: 1.0)
            
        }else if(section==1){
            title.text="Scheduled Care"
            title.textColor = UIColor.init(red: 100.0/255.0, green: 187.0/255.0, blue: 214/255.0, alpha: 1.0)
            headerView.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.9098039216, blue: 0, alpha: 1)
            //headerView.backgroundColor = UIColor.init(red: 254.0/255.0, green: 232.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            
        }else{
            title.text="Visits Today"
            title.textColor = UIColor.init(red: 104.0/255.0, green: 111.0/255.0, blue: 118.0/255.0, alpha: 1.0)
            headerView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
           // headerView.backgroundColor = UIColor.init(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            
        }
        headerView .addSubview(title)
        
        return headerView
    }
//    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        
//        let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
//        if (knownBeacons.count>0) {
//            let closeBeacon = knownBeacons[0] as CLBeacon
//            
//            print(closeBeacon.minor.intValue)
//            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
//            if hint == true{
//                
//                nvc.hint1 = true
//                print("True")
//            }else{
//                nvc.hint1 = false
//                print("False")
//            }
//            let transition = CATransition()
//            transition.duration = 0
//            transition.type = kCATransitionPush
//            transition.subtype = kCATransitionFromRight
//            view.window!.layer.add(transition, forKey: kCATransition)
//            appDelegate.previousBeacon = String(closeBeacon.minor.intValue)
//
//            self .present(nvc, animated: false, completion: {
//                self.locationManager.stopRangingBeacons(in: region )
//                self.locationManager.stopMonitoring(for: region)
//            })
//
//        }else{
//            
//            
//        }
//    }
    
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
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("DashBoardViewController", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)
        self.present(menuViewController, animated: false, completion: nil)
    }
    
    func layOuts(){
        
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        eveyTitle.frame = CGRect(x: screenWidth/2.76, y: screenHeight/23.741, width: screenWidth/3.763, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.14, y: screenHeight/23.741, width: screenWidth/11.5, height: screenHeight/32)
        self.view.addSubview(headerView)
        
        headerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight/3.345)
        
        welcomeLabel.frame = CGRect(x: screenWidth/24.352, y: headerView.frame.height/12.941, width: screenWidth/1.636, height: headerView.frame.height/4)
        
        nameLabel.frame = CGRect(x: screenWidth/24.352, y: headerView.frame.height/3.437, width: 372, height: headerView.frame.height/4)
        
        desView.frame = CGRect(x: 0, y: headerView.frame.height/1.76, width: screenWidth, height: headerView.frame.height/2.291)
        
        headerView.addSubview(welcomeLabel)
        headerView.addSubview(nameLabel)
        headerView.addSubview(desView)
        tableView.tableHeaderView = headerView
        tableView.frame = CGRect(x: 0, y: eveyTitle.frame.origin.y+eveyTitle.frame.height+screenHeight/92, width: screenWidth, height: screenHeight-(eveyTitle.frame.origin.y+eveyTitle.frame.height+screenHeight/92))
        self.view.addSubview(tableView)
        descriptionTextView.frame = CGRect(x: 0, y: desView.frame.height/8.727, width: screenWidth, height: desView.frame.height/1.523)
        
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
























