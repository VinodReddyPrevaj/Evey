//
//  OutcomeEntryViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 30/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import AudioToolbox
protocol protocolFromOutComeEntryScreen {
    
    func doneButtonAction(actionButton:String)
}

class OutcomeEntryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,protocolFromOutComeEntryScreen{
    
    @IBOutlet weak var scheduledCareLbl: UILabel!
    
    @IBOutlet weak var serviceLbl: UILabel!
    
    @IBOutlet weak var serviceImage: UIImageView!
    
    @IBOutlet weak var serviceNameLbl: UILabel!
    
    @IBOutlet weak var startLbl: UILabel!
    
    @IBOutlet weak var startDateLbl: UILabel!
    
    @IBOutlet weak var endLbl: UILabel!
    
    @IBOutlet weak var endDateLbl: UILabel!
    
    @IBOutlet weak var frequencyLbl: UILabel!
    
    @IBOutlet weak var frequencyTypeLbl: UILabel!
    
    @IBOutlet weak var nextLbl: UILabel!
    
    @IBOutlet weak var nextDateLbl: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var outcomesTableView: UITableView!
    
    @IBOutlet weak var outcomeResidentDetails: UILabel!
    
    @IBOutlet weak var outcomeCareImage: UIImageView!

    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var buttonsViewBorder: UILabel!
    
    let scheduledCareView = UIView()

    var timer: Timer?

    var outcomeResidentDetailsStr = String()
    var outcomesArray = NSMutableArray()
    var care = String()
    var activatedIndexPath =  IndexPath()
    var activatedIndexPathArray = [IndexPath]()
    var noteStr =  String()
    var imageAndText = NSMutableDictionary()
    var outcomeDictionary = ["Bathing": ["Performed", "Refused", "Notes"],
                             "Whirlpool":["Performed", "Refused", "Notes"],
                             "Escort": ["Performed", "Refused", "Notes"],
                             "TEDS": ["On", "Off", "Notes"],
                             "Room Trays": ["Performed","Notes"],
                             "ACCU": ["Performed", "Refused", "Out-of-Facility", "Call Nurse", "Notes"],
                             "AM/PM Cares": ["Performed", "Refused", "Out-of-Facility", "Notes"],
                             "Treatments": ["Performed", "Refused", "Out-of-Facility", "Notes"],
                             "Eye Drops": ["Performed", "Refused", "Out-of-Facility", "Notes"],
                             "Medication": ["Performed", "Refused", "Out-of-Facility", "Notes"],
                             "Toileting": ["Performed", "Refused", "Notes"],
                             "Blood Pressure": ["Performed", "Refused", "Out-of-Facility", "Call Nurse", "Notes"],
                             "Medication Reminder": ["Performed", "Out-of-Facility", "Notes"],
                             "Room Cleaning": ["Performed", "Notes"],
                             "Laundry": ["Performed", "Notes"],
                             "Medication Set-Up": ["Performed", "Notes"],
                             "Fall": ["Performed", "Notes"]]
    
    var defaultOutcomeStatus =   [String:String]()
    
    //for beacon Detection
    var acceptableDistance = Double()
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false) { 
        
    }
    
    var beaconsArray = NSArray()
    var responseBeacon = NSDictionary()

    var audioPlayer = AVAudioPlayer()
    
    let roomUrl = Bundle.main.url(forResource: "Room", withExtension: "mp3")
    let hallwayUrl = Bundle.main.url(forResource: "Hallway", withExtension:"mp3")

    override func viewDidLoad() {
        super.viewDidLoad()
        defaultOutcomeStatus = UserDefaults.standard.value(forKey: "defaultOutComes") as! [String : String]
        layOuts()
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(outcomesTableView.frame.size.width), height: CGFloat(px))
        let line = UIView(frame: frame)
        self.outcomesTableView.tableHeaderView = line
        line.backgroundColor = self.outcomesTableView.separatorColor
        outcomesArray = outcomeDictionary["\(UserDefaults.standard.value(forKey: "CareImage")!)"] as! NSMutableArray
        if UserDefaults.standard.value(forKey: "Came From") as! String == "DashBoardViewController" || UserDefaults.standard.value(forKey: "Came From") as! String == "RecentVisitsViewController" {
            
            outcomeResidentDetails.text = UserDefaults.standard.value(forKey: "ResidentDetails") as? String
            outcomeResidentDetailsStr = (UserDefaults.standard.value(forKey: "ResidentDetails") as? String)!
        }else{
            outcomeResidentDetails.text = UserDefaults.standard.value(forKey: "nameRoom") as? String
            outcomeResidentDetailsStr = (UserDefaults.standard.value(forKey: "nameRoom") as? String)!
        }
        outcomeCareImage.image = UIImage(named:"\((UserDefaults.standard.value(forKey: "CareImage")) as! String)")

        let residents =  ResidentDetails.response.value(forKey: "_residents") as! NSArray
        
        let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
        
        var residentName = String()
        
        for resident in residents {
            
            if (resident as! NSDictionary).value(forKey: "_id") as! String == UserDefaults.standard.value(forKey: "resident_id") as! String {
                
                residentName = "\((resident as! NSDictionary).value(forKey: "first_name") as! String) \((resident as! NSDictionary).value(forKey: "last_name") as! String).\(residentRoom.value(forKey: "room") as! String)"
            }
        }

        outcomeResidentDetails.text = residentName

        // to detect beacons
        
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)
        acceptableDistance = 2.0

        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
        
        
        
        
        if outcomeResidentDetailsStr == "Edward J.310" {
            
            self.outcomesTableView.tableFooterView = scheduledCareView
 
        }else{
            
            self.outcomesTableView.tableFooterView = UIView()

        }
        //UserDefaults.standard.setValue(defaultOutcomeStatus, forKey: "defaultOutComes")

    }
    override func viewWillAppear(_ animated: Bool) {
        
    
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return outcomesArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height/15.159
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! OutComeTableViewCell
        cell.separatorInset = UIEdgeInsets.zero
        cell.selectingButton.isSelected = false
        cell.outcomeNameLabel.text = outcomeDictionary["\(UserDefaults.standard.value(forKey: "CareImage")!)"]?[indexPath.row]
        cell.selectingButton.addTarget(self, action: #selector(self.moneyButtonClicked), for: .touchUpInside)
        cell.selectingButton.backgroundColor = UIColor.clear
        if outcomeResidentDetailsStr == "Edward J.310" {
        cell.selectingButton.setImage(#imageLiteral(resourceName: "scheduleCheckedMark").withRenderingMode(.alwaysOriginal), for: .selected)
        }else{
            cell.selectingButton.setImage(#imageLiteral(resourceName: "checkedMark").withRenderingMode(.alwaysOriginal), for: .selected)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if activatedIndexPathArray.count > 0 {
            if activatedIndexPathArray[0] == indexPath {
                cell.selectingButton.isSelected = true
            }
            
        }else{
            if cell.outcomeNameLabel.text == defaultOutcomeStatus["\(UserDefaults.standard.value(forKey: "CareImage")!)"] {
                let i  = ((outcomeDictionary["\(UserDefaults.standard.value(forKey: "CareImage")!)"] as NSArray?)?.index(of: (defaultOutcomeStatus["\(UserDefaults.standard.value(forKey: "CareImage")!)"])! as NSString))!
                activatedIndexPath = IndexPath(item: i, section: 0)
                activatedIndexPathArray = [activatedIndexPath]
                
                cell.selectingButton.isSelected = true

            }
            
        }
        

        //if outcomeDictionary["\(UserDefaults.standard.value(forKey: "CareImage")!)"]?[indexPath.row] == defaultOutcomeStatus["\(UserDefaults.standard.value(forKey: "CareImage")!)"]
//        if cell.outcomeNameLabel.text == defaultOutcomeStatus["\(UserDefaults.standard.value(forKey: "CareImage")!)"]
//        {
//            
//            let i  = ((outcomeDictionary["\(UserDefaults.standard.value(forKey: "CareImage")!)"] as NSArray?)?.index(of: (defaultOutcomeStatus["\(UserDefaults.standard.value(forKey: "CareImage")!)"])! as NSString))!
//            activatedIndexPath = IndexPath(item: i, section: 0)
//            activatedIndexPathArray = [activatedIndexPath]
//            //if cell.selectingButton.isSelected {
//                
//               // cell.selectingButton.isSelected = false
//            //}else {
//                
//                cell.selectingButton.isSelected = true
//            //}
//            
//        }
        
        
        if outcomeDictionary["\(UserDefaults.standard.value(forKey: "CareImage")!)"]?[indexPath.row] == "Notes"{
            let rightArrowButton = UIButton()
            rightArrowButton.frame = CGRect(x: cell.contentView.frame.width/1.136, y: cell.contentView.frame.height/5.5, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.height/1.517)
            rightArrowButton.setImage(#imageLiteral(resourceName: "RightArrow"), for: UIControlState.normal)
            rightArrowButton.addTarget(self, action: #selector(self.rightArrowButtonAction(_:)), for: .touchUpInside)
            cell.contentView.addSubview(rightArrowButton)
            self.noteStr = UserDefaults.standard.value(forKey: "Note") as! String
            if self.noteStr.characters.count > 0{
                cell.noteLabel.text = self.noteStr
                if cell.selectingButton.isSelected {
                    
                    cell.selectingButton.isSelected = false
                }else {
                    
                    cell.selectingButton.isSelected = true
                }
                
            }
        }
        else{
            
        }

        cell.selectingButton.frame = CGRect(x: cell.contentView.frame.width/46.875, y: cell.contentView.frame.height/6.285, width: cell.contentView.frame.width/12.5, height: cell.contentView.frame.width/12.5)
        cell.selectingButton.layer.cornerRadius = cell.selectingButton.frame.height/2
        cell.outcomeNameLabel.frame = CGRect(x: cell.selectingButton.frame.origin.x+cell.selectingButton.frame.width+cell.contentView.frame.width/31.25, y: cell.contentView.frame.height/6.285, width: cell.contentView.frame.width/2.038, height: cell.contentView.frame.height/1.466)
        cell.noteLabel.frame = CGRect(x: cell.outcomeNameLabel.frame.origin.x+cell.contentView.frame.width/6.355, y: cell.contentView.frame.height/3.666, width: cell.contentView.frame.width/1.744, height: cell.contentView.frame.height/2.095)
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell: OutComeTableViewCell = outcomesTableView.cellForRow(at:(indexPath)) as! OutComeTableViewCell
        if cell.outcomeNameLabel.text == "Notes" {
            if cell.selectingButton.isSelected == false{
                cell.selectingButton.isSelected = true
            }
        
        let NVC = self.storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
        NVC.careName =  "\(UserDefaults.standard.value(forKey: "CareImage")!)"
        NVC.residentNameDetailsStr =  outcomeResidentDetailsStr
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)

        self.present(NVC, animated: false, completion: nil)
        }
    }
    func rightArrowButtonAction(_ sender: Any) {
        
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.outcomesTableView)
        let indexpath: IndexPath? = self.outcomesTableView.indexPathForRow(at: buttonPosition)
        let cell: OutComeTableViewCell = outcomesTableView.cellForRow(at:(indexpath)!) as! OutComeTableViewCell
        if cell.selectingButton.isSelected == false{
            cell.selectingButton.isSelected = true
        }

        let NVC = self.storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
//        NVC.careName =  "\(UserDefaults.standard.value(forKey: "CareImage")!)"
//        NVC.residentNameDetailsStr =  "\(UserDefaults.standard.value(forKey: "nameRoom")!)"
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)

        self.present(NVC, animated: false, completion: nil)
        
        
        
    }
    @IBAction func moneyButtonClicked(_ sender: Any) {
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.outcomesTableView)
        let indexpath: IndexPath? = self.outcomesTableView.indexPathForRow(at: buttonPosition)
        let cell: OutComeTableViewCell = outcomesTableView.cellForRow(at:(indexpath)!) as! OutComeTableViewCell
        
        if cell.outcomeNameLabel.text != "Notes" {
            let cell: OutComeTableViewCell = outcomesTableView.cellForRow(at:(activatedIndexPath) as IndexPath) as! OutComeTableViewCell
            if cell.selectingButton.isSelected {
                cell.selectingButton.isSelected = false
            }else {
                cell.selectingButton.isSelected = true
            }
            activatedIndexPath =  indexpath!
            activatedIndexPathArray = [activatedIndexPath]
            
            let button = sender as? UIButton
            button?.isSelected = !(button?.isSelected)!
            
            let activatedCell: OutComeTableViewCell = outcomesTableView.cellForRow(at:(indexpath!) as IndexPath) as! OutComeTableViewCell
            defaultOutcomeStatus.updateValue(activatedCell.outcomeNameLabel.text!, forKey: UserDefaults.standard.value(forKey: "CareImage") as! String)
            UserDefaults.standard.setValue(defaultOutcomeStatus, forKey: "defaultOutComes")


            
        }else{
            
            //if cell.selectingButton.isSelected == false{
                cell.selectingButton.isSelected = true
            //}

            let NVC = self.storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)

            self.present(NVC, animated: false, completion: nil)
        }
        
    }
    @IBAction func cancelAction(_ sender: Any) {
        let msg = "Are you sure you want to Delete your entry?"
        let attString = NSMutableAttributedString(string: msg)
        let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
        
        attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msg.characters.count - 18 , length: 6))
        
        
        popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
            
        })
        
        let deleteButton = CancelButton(title: "Delete", action: {
            
            let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
            CSVC.residentNameRoom = self.outcomeResidentDetails.text!
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.locationManager.stopRangingBeacons(in: self.region)
            self.locationManager.stopMonitoring(for: self.region)
            
            self.present(CSVC, animated: false, completion: nil)
            
        })
        let cancelButton = CancelButton(title: "Cancel", action: {
            
        })
        deleteButton.tintColor = UIColor.red
        deleteButton.titleColor = UIColor.red
        popup.addButtons([deleteButton,cancelButton])
        
        self.present(popup, animated: true, completion: nil)

    }
    
    @IBAction func backButton(_ sender: Any) {
        
        let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
        CSVC.residentNameRoom = outcomeResidentDetails.text!
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)
        
        self.present(CSVC, animated: false, completion: nil)

    }
    
    @IBAction func doneButton(_ sender: Any) {

        var endTime = Date()
        let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
        if previousBeaconArray.count == 0 {
            endTime = Times.Leaving_Time
        }
        let vc  = AlertViewController()
        vc.alertDelegate = self
        if Times.Previous_End_Time.count > 0 {
            vc.counter = Int(endTime.timeIntervalSince(Times.Previous_End_Time[0]))
            vc.startTime = Times.Previous_End_Time[0]
            
        }else{
            vc.counter = Int(endTime.timeIntervalSince(Times.Constant_Start_Time))
            vc.startTime = Times.Constant_Start_Time
            
        }
        vc.screenFrame = self.view.frame
        vc.outcomeDone = true
        vc.residentName = UserDefaults.standard.value(forKey: "nameRoom") as! String 
        
        self.present(vc, animated: true, completion: {
        })

    }
    
    @IBAction func menuAction(_ sender: Any) {
        
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("OutcomeEntryViewController", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(menuVC, animated: false, completion: nil)

    }
    func layOuts(){
        
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        backBtn.frame = CGRect(x: screenWidth/23.437, y: screenHeight/23, width: screenWidth/18.75, height: screenHeight/33.35)
        
        eveyTitle.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.size.width+screenWidth/3.712, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.213, y: screenHeight/23.437, width: screenWidth/11.363, height: screenHeight/31.761)
        
        outcomeCareImage.frame = CGRect(x: screenWidth/31.25, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/35.105, width: screenWidth/10.416, height: screenHeight/18.527)
        
        
        outcomeResidentDetails.frame = CGRect(x: outcomeCareImage.frame.origin.x+outcomeCareImage.frame.width, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/35.105, width: screenWidth/1.518, height: screenHeight/18.527)
        
        
        outcomesTableView.frame =  CGRect(x: 0, y: outcomeResidentDetails.frame.origin.y+outcomeResidentDetails.frame.size.height+screenHeight/44.466, width: screenWidth, height: screenHeight/1.355)
        
        buttonsView.frame = CGRect(x: 0, y: screenHeight-screenHeight/12.584, width: screenWidth, height: screenHeight/12.584)
        
        cancelBtn.frame = CGRect(x: screenWidth/15, y: buttonsView.frame.size.height/4.818, width: screenWidth/5.281, height: buttonsView.frame.size.height/1.766)
        
        doneBtn.frame = CGRect(x: cancelBtn.frame.origin.x+cancelBtn.frame.size.width+screenWidth/1.963, y: buttonsView.frame.size.height/4.818, width: screenWidth/5.281, height: buttonsView.frame.size.height/1.766)
        
        buttonsViewBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: buttonsView.frame.height/buttonsView.frame.height)
        
        
        scheduledCareLbl.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight/31.761)
        
        serviceLbl.frame = CGRect(x: screenWidth/24.352, y: scheduledCareLbl.frame.origin.y+scheduledCareLbl.frame.height+screenHeight/95.285, width: screenWidth/6.786, height: screenHeight/32)
        
        serviceImage.frame = CGRect(x: serviceLbl.frame.origin.x+serviceLbl.frame.width+screenWidth/69, y: scheduledCareLbl.frame.origin.y+scheduledCareLbl.frame.height+screenHeight/95.285, width: screenWidth/15.333, height: screenWidth/15.333)
        
        serviceNameLbl.frame = CGRect(x: serviceImage.frame.origin.x+serviceImage.frame.width+screenWidth/41.4, y:scheduledCareLbl.frame.origin.y+scheduledCareLbl.frame.height+screenHeight/95.285, width: screenWidth/2.539, height: screenHeight/32)
        
        startLbl.frame = CGRect(x: screenWidth/24.352, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/10.35, height: screenHeight/32)
        
        startDateLbl.frame = CGRect(x: startLbl.frame.origin.x+startLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/5.914, height: screenHeight/32)
        
        endLbl.frame = CGRect(x: startDateLbl.frame.origin.x+startDateLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/12.937, height: screenHeight/32)
        
        endDateLbl.frame = CGRect(x: endLbl.frame.origin.x+endLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/5.914, height: screenHeight/32)
        
        frequencyLbl.frame = CGRect(x: endDateLbl.frame.origin.x+endDateLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/5.447, height: screenHeight/32)
        
        frequencyTypeLbl.frame = CGRect(x: frequencyLbl.frame.origin.x+frequencyLbl.frame.width, y: serviceNameLbl.frame.origin.y+serviceNameLbl.frame.height, width: screenWidth/4.6, height: screenHeight/32)
        
        nextLbl.frame = CGRect(x: screenWidth/24.352, y: frequencyLbl.frame.origin.y+frequencyLbl.frame.height, width: screenWidth/9.857, height: screenHeight/32)
        
        nextDateLbl.frame = CGRect(x: nextLbl.frame.origin.x+nextLbl.frame.width+screenWidth/103.5, y: frequencyLbl.frame.origin.y+frequencyLbl.frame.height, width: screenWidth/1.344, height: screenHeight/32)
        
        descriptionTextView.frame = CGRect(x: screenWidth/31.846, y: nextDateLbl.frame.origin.y+nextDateLbl.frame.height, width: screenWidth/1.128, height: screenHeight/2.991)
        
        var frame = self.descriptionTextView.frame
        frame.size.height = self.descriptionTextView.contentSize.height
        self.descriptionTextView.frame = frame
        
        scheduledCareView.addSubview(scheduledCareLbl)
        scheduledCareView.addSubview(serviceLbl)
        scheduledCareView.addSubview(serviceImage)
        scheduledCareView.addSubview(serviceNameLbl)
        scheduledCareView.addSubview(startLbl)
        scheduledCareView.addSubview(startDateLbl)
        scheduledCareView.addSubview(endLbl)
        scheduledCareView.addSubview(endDateLbl)
        scheduledCareView.addSubview(frequencyLbl)
        scheduledCareView.addSubview(frequencyTypeLbl)
        scheduledCareView.addSubview(nextLbl)
        scheduledCareView.addSubview(nextDateLbl)
        scheduledCareView.addSubview(descriptionTextView)

        scheduledCareView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: descriptionTextView.frame.origin.y+descriptionTextView.frame.height)


        
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
        if (knownBeacons.count>0) {
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
                                        
                                        Times.Previous_End_Time.removeAll()
                                        
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
                                                
                                                print(re)
                                                
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
                                                    
                                                    let startDate = Date()
                
                                                    
                                                    Times.Constant_Start_Time = startDate
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
                                
                                
                                Times.Previous_End_Time.removeAll()
                                
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
                                        
                                        print(re)
                                        
                                        DispatchQueue.main.async( execute: {
                                            
                                            //let beaconsData = NSKeyedArchiver.archivedData(withRootObject: re)
                                            
                                            //UserDefaults.standard.set(beaconsData, forKey: "Residents_List")
                                            
                                            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                            
                                            let transition = CATransition()
                                            transition.duration = 0.3
                                            transition.type = kCATransitionPush
                                            transition.subtype = kCATransitionFromRight
                                            self.view.window!.layer.add(transition, forKey: kCATransition)
                                            
                                            let startDate = Date()
        
                                            
                                            Times.Constant_Start_Time = startDate
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
                                    print("minor")
                                    otherBeacon = aaaaaaa.value(forKey: "type") as! String
                                }
                            }
                            
                            if otherBeacon == "hallway" {

                            
                            UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                            let msg = "Are you finished with your visit or are you continuing care?"
                            let attString = NSMutableAttributedString(string: msg)
                            
                            popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                                
                            })

                                let pauseButton = CancelButton(title: "Pause", action: {
                                    
                                    self.timer?.invalidate()

                                    UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
  
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
                                    
                                    
                                })
                            
                                let continueButton = CancelButton(title: "Continue", action: {
                                    
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
                                    
                                })
                                
                                let completeButton = CancelButton(title: "Complete") {
                                    
                                    UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                    
                                    self.timer?.invalidate()
                                    
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

                                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                                
                                                UserDefaults.standard.set([Int(dic?.value(forKey: "major") as! String)], forKey: "HallwayBeaconArray")
                                                
                                                UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                                UserDefaults.standard.set("", forKey: "Came From")

                                                self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: true)

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

                                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
                                                
                                                UserDefaults.standard.set([Int(dic?.value(forKey: "major") as! String)], forKey: "HallwayBeaconArray")
                                                
                                                UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                                UserDefaults.standard.set("", forKey: "Came From")

                                                self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: true)

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
    func doneButtonAction(actionButton: String) {
        if actionButton == "No" {
            let deafaultTimesForCares = ["Treatments":15,"Escort":30,"Bathing":45,"TEDS":5,"Room Trays":10,"ACCU":5,"Eye Drops":5] as NSDictionary
            
            if UserDefaults.standard.value(forKey: "Came From") as! String == "DashBoardViewController" {
                
                
            }else{
                
                let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
                
                var careIds = NSDictionary()
                
                let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
                
                if let careIDs = careIDs {
                    careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
                }
                
                let care_Id = careIds.value(forKey: (UserDefaults.standard.value(forKey: "CareImage")) as! String) as! String
                
                let outcomeStatus = UserDefaults.standard.value(forKey: "defaultOutComes") as! NSDictionary
                
                let care_Value = outcomeStatus.value(forKey: (UserDefaults.standard.value(forKey: "CareImage")) as! String) as! String
                
                let care_Note = UserDefaults.standard.value(forKey: "Note") as! String
                
                
                let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
                
                let resident_ID = UserDefaults.standard.value(forKey: "resident_id") as! String
                
                let roomId = residentRoom.value(forKey: "_id") as! String
                
                var param = NSMutableDictionary()
                
                if ResidentDetails.openCareIDsArray.contains(care_Id){
                    var id = String()
                    let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
                    
                    for i in 0..<openVisits.count{
                        if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
                            id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
                        }
                    }
                    param = ["_id":id,
                             "user_id": user_Id,
                             "room_id": roomId,
                             "resident_id": resident_ID,
                             "care_id": care_Id,
                             "care_value": care_Value,
                             "care_notes": care_Note,
                             "care_type": "Track",
                             "care_status": "Closed",
                             "time_track": ""
                    ]
                }else{
                    param = ["user_id": user_Id,
                             "room_id": roomId,
                             "resident_id": resident_ID,
                             "care_id": care_Id,
                             "care_value": care_Value,
                             "care_notes": care_Note,
                             "care_type": "Track",
                             "care_status": "Closed",
                             "time_track": ""
                    ]
                }
                if ResidentDetails.storedCares.count > 0 {
                    var elementIndex = [Int]()
                    for i in 0..<ResidentDetails.storedCares.count{
                        let element = ResidentDetails.storedCares[i]
                        if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
                            elementIndex = [i]
                        }
                    }
                    if elementIndex.count > 0 {
                        ResidentDetails.storedCares.remove(at: elementIndex[0])
                        
                        ResidentDetails.storedCares.append(param)
                        
                    }else{
                        ResidentDetails.storedCares.append(param)
                    }
                }else{
                    ResidentDetails.storedCares.append(param)
                }
                
                print(ResidentDetails.storedCares)
                var defaultTimesArray = [Int]()
                
                for i in 0..<ResidentDetails.storedCares.count {
                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                    
                    defaultTimesArray.append(deafaultTimesForCares.value(forKey: careName.first as! String) as! Int)
                    
                    
                }
                let min = defaultTimesArray.min()
                
                var timeRatios: [Int] = []
                for value in defaultTimesArray { timeRatios.append(value/min!) }
                
                let sumOfTimeRatios = timeRatios.reduce(0, +)
                
                var startTime = Date()
                if Times.Previous_End_Time.count > 0 {
                    startTime = Times.Previous_End_Time[0]
                }else{
                    startTime = Times.Constant_Start_Time
                }
                let endTime = Date()
                Times.Previous_End_Time = [endTime]
                let totalTime = Int(endTime.timeIntervalSince(startTime))
                
                let onePartOfTime = totalTime/sumOfTimeRatios
                
                var timesWithRespectToRatios : [Int] = []
                
                for value in timeRatios {
                    timesWithRespectToRatios.append(value*onePartOfTime)
                }
                
                let careTimesDictionary = NSMutableDictionary()
                
                for i in 0..<ResidentDetails.storedCares.count {
                    if i == 0 {
                        
                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let end_time = startTime.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
                        careTimesDictionary.setValue(["start_time":startTime,"end_time":end_time], forKey: careName.first as! String)
                        
                    }else {
                        let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let beforeCareName = careIds.allKeys(for: (ResidentDetails.storedCares[i-1] as NSDictionary).value(forKey: "care_id") as! String)
                        
                        let times_array = careTimesDictionary.value(forKey: beforeCareName.first as! String) as! NSDictionary
                        
                        let start_time = times_array.value(forKey: "end_time") as! Date
                        
                        let end_time = start_time.addingTimeInterval(TimeInterval(timesWithRespectToRatios[i]))
                        
                        careTimesDictionary.setValue(["start_time":start_time,"end_time":end_time], forKey: careName.first as! String)
                        
                    }
                }
                for i in 0..<ResidentDetails.storedCares.count {
                    let careName = careIds.allKeys(for: (ResidentDetails.storedCares[i] as NSDictionary).value(forKey: "care_id") as! String)
                    
                    let careTimes = careTimesDictionary.value(forKey: careName.first as! String) as! NSDictionary
                    
                    (ResidentDetails.storedCares[i] as NSMutableDictionary).setValue(["start_time":"\(careTimes.value(forKey: "start_time") as! Date)","end_time":"\(careTimes.value(forKey: "end_time") as! Date)"], forKeyPath: "time_track")
                }
                print(ResidentDetails.storedCares)
                
                Times.Previous_End_Time = [Date()]
                //create the url with URL
                let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/\(serviceConstants.trackCares)")! //change the url
                
                //create the session object
                let session = URLSession.shared
                
                //now create the URLRequest object using the url object
                var request = URLRequest(url: url)
                request.httpMethod = "POST" //set http method as POST
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: ResidentDetails.storedCares, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
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
                        let previousBeaconArray : [String] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [String]
                        if previousBeaconArray.count == 0 {
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
                                    
                                })
                                
                                
                            })
                            
                        }else{
                            let url:NSURL = NSURL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/\(((UserDefaults.standard.value(forKey: "PreviousBeaconArray")) as! NSArray)[0] as! String)")!
                            
                            let session = URLSession.shared
                            let request = NSMutableURLRequest (url: url as URL)
                            request.httpMethod = "Get"
                            
                            request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
                            
                            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
                                if let data = data {
                                    
                                    let re = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                                    //print(re)
                                    ResidentDetails.response = re
                                    DispatchQueue.main.async( execute: {
                                        let reDirectingVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                        
                                        self.locationManager.stopMonitoring(for: self.region)
                                        self.locationManager.stopRangingBeacons(in: self.region)
                                        let transition = CATransition()
                                        transition.duration = 0.3
                                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                        transition.type = kCATransitionMoveIn
                                        transition.subtype = kCATransitionFromLeft
                                        self.view.window!.layer.add(transition, forKey: kCATransition)
                                        
                                        self.present(reDirectingVC, animated: false, completion: {
                                            UserDefaults.standard.set("", forKey: "Came From")
                                            
                                        })
                                        
                                        
                                    })
                                }
                            }
                            task.resume()
                        }
                    }
                })
                task.resume()
            }
            ResidentDetails.storedCares.removeAll()
            
        }else if actionButton == "Yes" {
            let user_Id = UserDefaults.standard.value(forKey: "user_Id") as! String
            var careIds = NSDictionary()
            
            let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
            
            if let careIDs = careIDs {
                careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
            }
            
            let care_Id = careIds.value(forKey: (UserDefaults.standard.value(forKey: "CareImage")) as! String) as! String
            
            let outcomeStatus = UserDefaults.standard.value(forKey: "defaultOutComes") as! NSDictionary
            
            let care_Value = outcomeStatus.value(forKey: (UserDefaults.standard.value(forKey: "CareImage")) as! String) as! String
            
            let care_Note = UserDefaults.standard.value(forKey: "Note") as! String
            
            let residentRoom = ResidentDetails.response.value(forKey: "_room") as! NSDictionary
            print(residentRoom)
            //let residentRoom = residentsArray.value(forKey: "_room") as! NSDictionary
            
            let resident_ID = UserDefaults.standard.value(forKey: "resident_id") as! String

            let roomId = residentRoom.value(forKey: "_id") as! String
            
            
            var param = NSMutableDictionary()
            if ResidentDetails.openCareIDsArray.contains(care_Id){
                var id = String()
                let openVisits = ResidentDetails.openCaresFromServer.value(forKey: resident_ID) as! NSArray
                for i in 0..<openVisits.count{
                    if ((openVisits[i]) as! NSDictionary).value(forKey: "care_id") as! String == care_Id{
                        id = ((openVisits[i]) as! NSDictionary).value(forKey: "_id") as! String
                    }
                }
                param = ["_id":id,
                         "user_id": user_Id,
                         "room_id": roomId,
                         "resident_id": resident_ID,
                         "care_id": care_Id,
                         "care_value": care_Value,
                         "care_notes": care_Note,
                         "care_type": "Track",
                         "care_status": "Closed",
                         "time_track": ""
                ]
            }else{
                param = ["user_id": user_Id,
                         "room_id": roomId,
                         "resident_id": resident_ID,
                         "care_id": care_Id,
                         "care_value": care_Value,
                         "care_notes": care_Note,
                         "care_type": "Track",
                         "care_status": "Closed",
                         "time_track": ""
                ]
            }
            if ResidentDetails.storedCares.count > 0 {
                var elementIndex = [Int]()
                for i in 0..<ResidentDetails.storedCares.count{
                    let element = ResidentDetails.storedCares[i]
                    if element.value(forKey: "resident_id") as! String == resident_ID && element.value(forKey: "care_id") as! String == care_Id {
                        elementIndex = [i]
                    }else{
                        
                    }
                }
                if elementIndex.count > 0 {
                    ResidentDetails.storedCares.remove(at: elementIndex[0])
                    
                    ResidentDetails.storedCares.append(param)
                    
                }else{
                    ResidentDetails.storedCares.append(param)
                }
            }else{
                ResidentDetails.storedCares.append(param)
            }
            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
            
            self.locationManager.stopMonitoring(for: self.region)
            
            self.locationManager.stopRangingBeacons(in: self.region)
            
            let transition = CATransition()
            
            transition.duration = 0.3
            
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            transition.type = kCATransitionMoveIn
            
            transition.subtype = kCATransitionFromLeft
            
            self.view.window!.layer.add(transition, forKey: kCATransition)
            // to check any performed visits
            
            
            self.present(nvc, animated: false, completion: {
                
            })
            
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
