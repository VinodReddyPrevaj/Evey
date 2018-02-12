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
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.locationManager.stopMonitoring(for: self.region)
            self.locationManager.stopRangingBeacons(in: self.region)
            
            self.view.window!.layer.add(transition, forKey: kCATransition)
            
            self.present(openVisitsVC, animated: false, completion: nil)

            
            
            
            
        }else if  message == "View Scheduled Visits" {
            
            let scheduledVisitsVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduledVisitsViewController") as! ScheduledVisitsViewController

            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)
            view.window!.layer.add(transition, forKey: kCATransition)
            self.present(scheduledVisitsVC, animated: false, completion: nil)

        }
        else if message == "Pause" {
            let msg = "To Pause your visit please select Care"
            let attStr = NSMutableAttributedString(string: msg)
            
            
            let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
            
            attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 5))
            attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 34, length: 4))

            self.popup = PopupDialog(title: "", message: attStr,  buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
            
            let okButton = DefaultButton(title: "Ok", action: {
               
                
            })
            
            let cancelButton = CancelButton(title: "Cancel", action: {
                let date2 = Date()
                let vc  = CustomAlertViewController()
                vc.Delegate = self
                vc.counter = Int(date2.timeIntervalSince(Constants.dateArray[0]))
                vc.screenFrame = self.view.frame
                self.present(vc, animated: true, completion: {
                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                })
            })
            
            self.popup.addButtons([cancelButton,okButton])
            self.present(self.popup, animated: true, completion: {
                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                
            })
            
        }else if message == "Complete" {
            let msg = "To Complete your visit please select Care"
            
            let attStr = NSMutableAttributedString(string: msg)
            
            let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
            
            attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 3, length: 8))
            attStr.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 37, length: 4))

            self.popup = PopupDialog(title: "", message: attStr,  buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
            
            let okButton = DefaultButton(title: "Ok", action: {
                
            })
            
            let cancelButton = CancelButton(title: "Cancel", action: {
                
                let date2 = Date()
                let vc  = CustomAlertViewController()
                vc.Delegate = self
                vc.counter = Int(date2.timeIntervalSince(Constants.dateArray[0]))
                vc.screenFrame = self.view.frame
                self.present(vc, animated: true, completion: {
                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                })
            })
            
            self.popup.addButtons([cancelButton,okButton])
            self.present(self.popup, animated: true, completion: {
                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
            })
            
        }else if message == "Delete" {
            
        }else {
            let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
            CSVC.residentNameRoom = name
            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)
            UserDefaults.standard.set(name, forKey: "nameRoom")
            UserDefaults.standard.set(name, forKey: "SelectedArray")

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
    var count  = Int()
    var hint1 = Bool()
    var names = NSMutableArray()
    var rooms = NSMutableArray()
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
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")

    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
    
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        names = ["Chris P.","Edward J."]
        rooms = ["310","310","310","310"]
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
        acceptableDistance = 2.0
        rssiArray.removeAll()

        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion:nil)

        print(UserDefaults.standard.value(forKey: "Reddy")!)
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
            vc.Delegate = self
            vc.counter = Int(date2.timeIntervalSince(Constants.dateArray[0]))
            vc.screenFrame = self.view.frame
            self.present(vc, animated: true, completion: {
                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                self.alertForContinue = false
            })
        }
        //if Constants.dateArray.count == 0 {
            date = Date()
            Constants.dateArray.append(date)
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
                transition.duration = 0
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
        if lefSwipeiS == true {
            if names.count == 1 {
                cell.detailsView.frame = CGRect(x: -cell.contentView.frame.size.width/3, y: cell.contentView.frame.height/53.75, width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.height/1.043)
                
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.detailsView.frame.size.height/2.926, width: cell.contentView.frame.size.width/2.929, height: cell.detailsView.frame.size.height/11.944)
                
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height, width: cell.contentView.frame.size.width/2.929, height: cell.detailsView.frame.size.height/11.944)

            }else{
                cell.detailsView.frame = CGRect(x: -cell.contentView.frame.size.width/3, y: cell.contentView.frame.size.height/26.875, width: cell.contentView.frame.size.width/0.75, height: cell.contentView.frame.size.height/1.085)

            }
        }else {
            if names.count == 1 {
                cell.detailsView.frame = CGRect(x: CGFloat(0), y: CGFloat(cell.contentView.frame.height/53.75), width: cell.contentView.frame.width/0.75, height: cell.contentView.frame.height/1.043)
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.detailsView.frame.size.height/2.926, width: cell.contentView.frame.size.width/2.929, height: cell.detailsView.frame.size.height/11.944)
                
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height, width: cell.contentView.frame.size.width/2.929, height: cell.detailsView.frame.size.height/11.944)

            }else{
                cell.scheduledCareImage.setImage(#imageLiteral(resourceName: "scheduleVisit2").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.vistStatus.setImage(#imageLiteral(resourceName: "openVisitIcon").withRenderingMode(.alwaysOriginal), for: .normal)
                if names[indexPath.row] as? String == "Edward J." {
                    
                    cell.vistStatus.frame = CGRect(x: cell.contentView.frame.size.width/2.678, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/14.333)
                    cell.scheduledCareImage.frame = CGRect(x: cell.vistStatus.frame.origin.x+cell.vistStatus.frame.width+cell.contentView.frame.width/7.5, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/14.333)
                    cell.scheduledCareImage.tag = indexPath.row
                    cell.detailsView.addSubview(cell.vistStatus)
                    cell.detailsView.addSubview(cell.scheduledCareImage)

                }else{
                    
                    cell.vistStatus.frame = CGRect(x: cell.contentView.frame.width/2.0833, y:cell.detailsView.frame.size.height/5.685, width: cell.contentView.frame.width/25, height: cell.contentView.frame.height/14.333)
                    cell.scheduledCareImage.isHidden = true
                    cell.detailsView.addSubview(cell.vistStatus)

                }
                cell.detailsView.frame = CGRect(x: CGFloat(0), y: CGFloat(cell.contentView.frame.height/26.875), width: CGFloat(cell.contentView.frame.width/0.75), height: CGFloat(cell.contentView.frame.height/1.080))
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.vistStatus.frame.origin.y+cell.vistStatus.frame.height+cell.detailsView.frame.height/19.9, width: cell.contentView.frame.size.width/2.929, height: cell.detailsView.frame.size.height/5.527)
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height, width: cell.contentView.frame.size.width/2.929, height: cell.detailsView.frame.size.height/5.527)
 
            }

        }
        

        cell.upBordelLabel.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(cell.detailsView.frame.width), height: CGFloat(1))
        cell.bottomBorderLabel.frame = CGRect(x: CGFloat(0), y: CGFloat(cell.detailsView.frame.size.height-1), width: CGFloat(cell.detailsView.frame.width), height: CGFloat(1))
        // to remove the highlight on click on cell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
         self.residentTableView.separatorColor = UIColor.clear
        cell.residentNameLbl.text = names[indexPath.row] as? String
        cell.residentRoomLbl.text = rooms[indexPath.row] as? String

        if #available(iOS 9.0, *) {
            if( traitCollection.forceTouchCapability == .available){
                
                registerForPreviewing(with: self, sourceView: cell.vistStatus)
                forceTouchAvailable = true

            }else{
                
                forceTouchAvailable = false
            }
        } else {
            forceTouchAvailable = false
        }
        if forceTouchAvailable == false {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressCell(_:)))
            gesture.minimumPressDuration = 0.5
            cell.vistStatus.addGestureRecognizer(gesture)
        }

        cell.vistStatus.tag = indexPath.row
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as! ResidentSelectTestTableViewCell
        cell.detailsView.backgroundColor = UIColor(red: 219.0 / 255.0, green: 242.0 / 255.0, blue: 251.0 / 255.0, alpha: 1)
        self.deselectMethod()
        didSelectIsEnable = true
        didSelectIndexPath = indexPath
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
            let cell = tableView.cellForRow(at: indexPath) as! ResidentSelectTestTableViewCell
            cell.detailsView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 1, blue: 0.9960784314, alpha: 1)
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

        cell.detailsView.backgroundColor = UIColor(red: 219.0 / 255.0, green: 242.0 / 255.0, blue: 251.0 / 255.0, alpha: 1)
        
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
            cell.detailsView.addSubview(visitButton)
   
            checkInButton.frame = CGRect(x: cell.contentView.frame.size.width/1, y: cell.detailsView.frame.size.height/2, width: cell.contentView.frame.size.width/3, height: cell.detailsView.frame.size.height/2)
            cell.detailsView.addSubview(checkInButton)


        }else{
        visitButton.frame = CGRect(x: cell.contentView.frame.size.width/1, y: 0, width: cell.contentView.frame.size.width/3, height: cell.detailsView.frame.size.height/2)
        cell.detailsView.addSubview(visitButton)
        
        checkInButton.frame = CGRect(x: cell.contentView.frame.size.width/1, y: cell.detailsView.frame.size.height/2, width: cell.contentView.frame.size.width/3, height: cell.detailsView.frame.size.height/2)
        cell.detailsView.addSubview(checkInButton)
        }
        
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.names.count == 1{
                cell.detailsView.frame = CGRect(x: -(cell.contentView.frame.size.width/3.33), y: cell.contentView.frame.size.height/53.75, width: cell.contentView.frame.size.width/0.75, height: cell.contentView.frame.size.height/1.043)
   
            }else{
            cell.detailsView.frame = CGRect(x: -cell.contentView.frame.size.width/3.33, y: cell.contentView.frame.height/26.875, width: cell.contentView.frame.size.width/0.75, height: cell.contentView.frame.height/1.0858)
            cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y, width: CGFloat(cell.residentNameLbl.frame.width), height: CGFloat(cell.residentNameLbl.frame.height))
            cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentRoomLbl.frame.origin.y, width: CGFloat(cell.residentRoomLbl.frame.width), height: CGFloat(cell.residentRoomLbl.frame.height))
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
            cell.detailsView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 1, blue: 0.9960784314, alpha: 1)
                //UIColor(red: 246.0 / 255.0, green: 251.0 / 255.0, blue: 254.0 / 255.0, alpha: 1)

        }

        UIView.animate(withDuration: 0.3, animations: {
            if self.names.count == 1{
                cell.detailsView.frame = CGRect(x: 0, y: cell.contentView.frame.size.height/53.75, width: cell.contentView.frame.size.width/0.75, height: cell.contentView.frame.size.height/1.043)
 
            }else{
                cell.detailsView.frame = CGRect(x: CGFloat(0), y: CGFloat(cell.contentView.frame.height/26.875), width: CGFloat(cell.contentView.frame.width/0.75), height: CGFloat(cell.contentView.frame.height/1.085))
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y, width: cell.contentView.frame.size.width/2.929, height: cell.detailsView.frame.size.height/5.527)
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentRoomLbl.frame.origin.y, width: cell.contentView.frame.size.width/2.929, height: cell.detailsView.frame.size.height/5.527)
            }

        }, completion: nil)

    }
}
    func visitButtonAction(_ sender: Any) {
        
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.residentTableView)
        let indexpath: IndexPath? = self.residentTableView.indexPathForRow(at: buttonPosition)
        let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController")as! CareSelectViewController
        CSVC.residentNameRoom = "\(self.names[(indexpath?.row)!] as! String )\(self.rooms[(indexpath?.row)!] as! String)"
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        UserDefaults.standard.set("\(self.names[(indexpath?.row)!] as! String )\(self.rooms[(indexpath?.row)!] as! String)", forKey: "nameRoom")
        UserDefaults.standard.set([self.names[(indexpath?.row)!] as! String], forKey: "SelectedArray")
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


        let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
        }
        
        // Create first button
        let okButton = DefaultButton(title: "OK") {
            self.deselectMethod()

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
        cell.detailsView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 1, blue: 0.9960784314, alpha: 1)
            //UIColor(red: 246.0 / 255.0, green: 251.0 / 255.0, blue: 254.0 / 255.0, alpha: 1)
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.names.count == 1{
                cell.detailsView.frame = CGRect(x: 0, y: cell.contentView.frame.size.height/53.75, width: cell.contentView.frame.size.width/0.75, height: cell.contentView.frame.size.height/1.043)
                
            }else{
                cell.detailsView.frame = CGRect(x: CGFloat(0), y: CGFloat(cell.contentView.frame.height/26.875), width: CGFloat(cell.contentView.frame.width/0.75), height: CGFloat(cell.contentView.frame.height/1.085))
                cell.residentNameLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentNameLbl.frame.origin.y, width: cell.contentView.frame.size.width/2.929, height: cell.detailsView.frame.size.height/5.527)
                cell.residentRoomLbl.frame = CGRect(x: cell.contentView.frame.size.width/3.048, y: cell.residentRoomLbl.frame.origin.y, width: cell.contentView.frame.size.width/2.929, height: cell.detailsView.frame.size.height/5.527)
            }
            
        }, completion: nil)

    }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        //guard let cell = residentTableView?.cellForRow(at: indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "ForceTouchPeekViewController") as? ForceTouchPeekViewController else { return nil }
        detailVC.delegate = self
        
        if previewingContext.sourceView.tag == 0 {
            detailVC.residentNameStr = "Chris P.310"
        }else{
            detailVC.residentNameStr = "Edward J.310"
        }
        detailVC.preferredContentSize = CGSize(width: self.view.frame.width, height:self.view.frame.height/1.3884 )
        
        //self.view.frame.height/1.419
        //466
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        //show(viewControllerToCommit, sender: view)
        
    }
    @IBAction func backButtonAction(_ sender: Any) {
 
        
        let dashBoard = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
        let transition = CATransition()
        transition.duration = 0
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
        transition.duration = 0
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
                            print("Resident After")
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

                            })
                            
                            let continueButton = CancelButton(title: "Continue", action: {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    let date2 = Date()
                                    let vc  = CustomAlertViewController()
                                    vc.Delegate = self
                                    vc.counter = Int(date2.timeIntervalSince(Constants.dateArray[0]))
                                    vc.screenFrame = self.view.frame
                                    
                                    self.present(vc, animated: true, completion: {
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


                            })

                            let completeButton = CancelButton(title: "Complete", action: {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
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
 
                            })

                            let deleteButton = DestructiveButton(title: "Delete", action: {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                            })

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
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(DVC, animated: false, completion: nil)
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
