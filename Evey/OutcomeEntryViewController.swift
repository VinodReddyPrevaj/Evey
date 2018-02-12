//
//  OutcomeEntryViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 30/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class OutcomeEntryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate{
    
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

    
    var outcomeResidentDetailsStr = String()
    var notesHint = Bool()
    var outcomesArray = NSMutableArray()
    var care = String()
    var activatedIndexPath =  IndexPath()
    var activatedIndexPathArray = [IndexPath]()
    var noteStr =  String()
    var imageAndText = NSMutableDictionary()
    var outcomeDictionary = ["Treatments": ["Performed", "Refused", "Out-of-Facility", "Notes"],
                             "Escort": ["Performed", "Refused", "Notes"],
                             "Bathing": ["Performed", "Refused", "Notes"],
                             "TEDS": ["On", "Off", "Notes"],
                             "Room Trays": ["Performed","Notes"],
                             "ACCU": ["Performed", "Refused", "Out-of-Facility", "Call Nurse", "Notes"],
                             "Cares": ["Performed", "Refused", "Out-of-Facility", "Notes"],
                             "Eye Drops": ["Performed", "Refused", "Out-of-Facility", "Notes"]]
    
    var defaultOutcomeStatus =   ["Treatments": "Refused","Escort": "Refused",
                                  "Bathing": "Refused","TEDS": "Off",
                                  "Room Trays": "Performed","ACCU": "Refused",
                                  "Cares": "Refused","Eye Drops": "Refused"]
    
    //for beacon Detection
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false) { 
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        outcomeResidentDetails.text = outcomeResidentDetailsStr

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
        
        
        
        
        if outcomeResidentDetailsStr == "Edward J.310" {
            
            self.outcomesTableView.tableFooterView = scheduledCareView
 
        }else{
            
            self.outcomesTableView.tableFooterView = UIView()

        }
        


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
            cell.noteLabel.text = self.noteStr
            if notesHint == true {
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
            transition.duration = 0
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
        transition.duration = 0
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
        }else{
            
            //if cell.selectingButton.isSelected == false{
                cell.selectingButton.isSelected = true
            //}

            let NVC = self.storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransition)
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)

            self.present(NVC, animated: false, completion: nil)
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
        CSVC.residentNameRoom = outcomeResidentDetails.text!
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        locationManager.stopRangingBeacons(in: region)
        locationManager.stopMonitoring(for: region)

        self.present(CSVC, animated: false, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        let msg = "I have marked your visit with \((self.outcomeResidentDetails.text)!) as Completed"
        let attString = NSMutableAttributedString(string: msg)
        let font_bold = UIFont(name: ".SFUIText-Bold", size: 17.0)
        
        attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: msg.characters.count-10, length: 10))

        
        
        let popup = PopupDialog(title: "", message: attString,  buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
            
        }
        let okButton =  DefaultButton(title:"OK"){
            let previousBeaconArray : [Int] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [Int]
            if previousBeaconArray.count == 0{
            let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.locationManager.stopRangingBeacons(in: self.region)
            self.locationManager.stopMonitoring(for: self.region)
            
            
                self.present(RSVC, animated: false, completion: {
                    UserDefaults.standard.set([], forKey: "SelectedArray")
                    UserDefaults.standard.set([], forKey: "NamesArray")
                    UserDefaults.standard.set("", forKey: "Came From")

                })
            }else{
                let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                let transition = CATransition()
                transition.duration = 0
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.locationManager.stopRangingBeacons(in: self.region)
                self.locationManager.stopMonitoring(for: self.region)
                
                // to check any performed visits
                var namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                if namesArray.contains(UserDefaults.standard.value(forKey: "nameRoom") as! String){
                    
                }else{
                    namesArray.append(UserDefaults.standard.value(forKey: "nameRoom") as! String)
                    
                }
                UserDefaults.standard.set(namesArray, forKey: "NamesArray")
                
                self.present(RSVC, animated: false, completion: {
                    
                    UserDefaults.standard.set([], forKey: "SelectedArray")
                    
                })

                
  
            }
        }
        let cancelButton = CancelButton(title:"Cancel"){
            let CSVC = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
            CSVC.residentNameRoom = self.outcomeResidentDetails.text!
            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.locationManager.stopMonitoring(for: self.region)
            self.locationManager.stopRangingBeacons(in: self.region)
            self.present(CSVC, animated: false, completion: nil)
        }

        popup.addButtons([cancelButton,okButton])
        self.present(popup, animated: true, completion: nil)
    }
    @IBAction func menuAction(_ sender: Any) {
        let MenuVC = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("OutcomeEntryViewController", forKey: "EntryScreen")
        locationManager.stopMonitoring(for: region)
        locationManager.stopRangingBeacons(in: region)

        self.present(MenuVC, animated: false, completion: nil)

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
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                        self.present(RSVC, animated: false, completion: {
                                            UserDefaults.standard.set([], forKey: "NamesArray")
                                            UserDefaults.standard.set([], forKey: "SelectedArray")
                                            UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                            UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        })
                                    
                                }else{
                                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "nameRoom"), forKey: "ResidentDetails")

                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForPause = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
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
                                    
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    RSVC.alertForContinue = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(RSVC, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    })
                                    
                                }else{
                                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "nameRoom"), forKey: "ResidentDetails")
 
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForContinue = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
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
                                    
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    RSVC.alertForComplete = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    self.view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(RSVC, animated: false, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    })
                                    
                                }else{
                                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "nameRoom"), forKey: "ResidentDetails")

                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForComplete = true
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
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
                                    let transition = CATransition()
                                    transition.duration = 0
                                    transition.type = kCATransitionPush
                                    transition.subtype = kCATransitionFromLeft
                                    view.window!.layer.add(transition, forKey: kCATransition)

                                    self.present(DVC, animated: false, completion: nil)
                                }else{
                                    


                                    self.present(popup, animated: true, completion: {
                                        UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                        //UserDefaults.standard.set([closeBeacon.major.intValue], forKey: "HallwayBeaconArray")
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
