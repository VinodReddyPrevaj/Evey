//
//  ForceTouchPeekViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 17/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
class ForceTouchPeekViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var delegate:SampleProtocol?
    var typeOfPeek = String()
    var frame = CGRect()

    var residentID = String()

    @IBOutlet weak var visitTypeAndNum: UILabel!
    @IBOutlet weak var forceTouchTableView: UITableView!
    @IBOutlet weak var residentNameAndRoom: UILabel!
    @IBOutlet weak var careTypeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headerview: UIView!

    var residentNameStr =  String()
    
    var openCaresOfResident = [NSMutableDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forceTouchTableView.tableFooterView = UIView()
         openCaresOfResident = ResidentDetails.openCaresFromServer.value(forKey: residentID) as! [NSMutableDictionary]
        print(openCaresOfResident)
        residentNameAndRoom.text = residentNameStr
        let fullName    = residentNameStr
        let fullNameArr = fullName.components(separatedBy: " ")
        nameLabel.text = "\((fullNameArr[0].characters.first)!)\((fullNameArr[1].characters.first)!)"


//        if residentNameStr == "Edward J.310" {
//            headerview.backgroundColor = UIColor(red: 254.0/255.0, green: 232.0/255.0, blue: 0/255.0, alpha: 1)
//            careTypeImage.image = UIImage(named: "scheduleVisit2")
//            nameLabel.text = "EJ"
//            residentNameAndRoom.text = residentNameStr
//            visitTypeAndNum.text = "Scheduled Care (1)"
//        }
        
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.frame.width), height: CGFloat(px))
        let line = UIView(frame: frame)
        self.forceTouchTableView.tableHeaderView = line
        line.backgroundColor = self.forceTouchTableView.separatorColor
        
        if typeOfPeek == "longPress"{
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height/1.5511)
            let screenWidth = self.view.frame.width
            let screenHeight = self.view.frame.height
            
            headerview.frame = CGRect(x: self.headerview.frame.origin.x, y: self.headerview.frame.origin.y, width: self.view.frame.width, height: self.view.frame.size.height/8.3375)
            
            careTypeImage.frame = CGRect(x: screenWidth/22.058, y: headerview.frame.height/2.904, width: headerview.frame.height/2.44, height: headerview.frame.height/2.44)
            
            visitTypeAndNum.frame = CGRect(x: self.careTypeImage.frame.origin.x+self.careTypeImage.frame.width+screenWidth/53.571, y: headerview.frame.height/2.904, width: screenWidth/2.0833, height: headerview.frame.height/2.44)
            
            nameLabel.frame = CGRect(x: self.view.frame.width/3.191, y: headerview.frame.origin.y+headerview.frame.height+self.view.frame.height/15.925, width: screenHeight/4, height: screenHeight/4)
            
            nameLabel.layer.masksToBounds = true
            nameLabel.layer.cornerRadius = nameLabel.frame.height/2
            
            residentNameAndRoom.frame = CGRect(x: screenWidth/20.294, y: nameLabel.frame.origin.y+nameLabel.frame.height, width: self.view.frame.width/1.205, height: self.view.frame.height/10.75)
            forceTouchTableView.frame = CGRect(x: 0, y: residentNameAndRoom.frame.origin.y+residentNameAndRoom.frame.height+screenHeight/47.77, width: self.view.frame.width-30, height: screenHeight/2.324)
        }else{

            let screenWidth = self.view.frame.width
            let screenHeight = self.view.frame.height
            headerview.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight/11.553)
            
            careTypeImage.frame = CGRect(x: screenWidth/22.058, y: headerview.frame.height/2.904, width: headerview.frame.height/2.44, height: headerview.frame.height/2.44)
            
            visitTypeAndNum.frame = CGRect(x: self.careTypeImage.frame.origin.x+self.careTypeImage.frame.width+screenWidth/53.571, y: headerview.frame.height/2.904, width: screenWidth/2.0833, height: headerview.frame.height/2.44)
            
            nameLabel.frame = CGRect(x: self.view.frame.width/2.803, y: headerview.frame.origin.y+headerview.frame.height+self.view.frame.height/23.962, width: screenWidth/3.3482, height: screenWidth/3.3482)
            nameLabel.layer.masksToBounds = true
            nameLabel.layer.cornerRadius = nameLabel.frame.height/2
            
            residentNameAndRoom.frame = CGRect(x: screenWidth/8.426, y: nameLabel.frame.origin.y+nameLabel.frame.height, width: self.view.frame.width/1.3111, height: self.view.frame.height/16.175)
            forceTouchTableView.frame = CGRect(x: 0, y: residentNameAndRoom.frame.origin.y+residentNameAndRoom.frame.height+screenHeight/71.888, width: self.view.frame.width, height: screenHeight/3.080)

        }

    }
    override func viewDidAppear(_ animated: Bool) {


    }
    override func viewWillAppear(_ animated: Bool) {
        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

    }

    override var previewActionItems : [UIPreviewActionItem] {
//        if residentNameStr == "Edward J.310"{
//            
//            let View = UIPreviewAction(title: "View Scheduled Visits", style: .default) { (action, viewController) -> Void in
//                self.delegate?.someMethod(message: "View Scheduled Visits", name: self.residentNameStr)
//
//            }
//            let Enter = UIPreviewAction(title: "Enter a Visit", style: .default) { (action, viewController) -> Void in
//                self.delegate?.someMethod(message: "Enter a Visit", name: self.residentNameStr)
//            }
//            let Cancel = UIPreviewAction(title: "Cancel", style:.default) { (action, viewController) -> Void in
//            }
//            View.tintColor = #colorLiteral(red: 0.1137254902, green: 0.462745098, blue: 0.7333333333, alpha: 1)
//            Enter.tintColor = #colorLiteral(red: 0.1137254902, green: 0.462745098, blue: 0.7333333333, alpha: 1)
//            Cancel.tintColor = #colorLiteral(red: 0.1137254902, green: 0.462745098, blue: 0.7333333333, alpha: 1)
//
//            return [View, Enter, Cancel]
//
//        }else{
            let View = UIPreviewAction(title: "View Open Visits", style: .default) { (action, viewController) -> Void in
                self.delegate?.someMethod(message: "View Open Visits", name: self.residentID)
            }
            let Enter = UIPreviewAction(title: "Enter a Visit", style: .default) { (action, viewController) -> Void in
                self.delegate?.someMethod(message: "Enter a Visit", name: self.residentID)
                
            }
            
            let Cancel = UIPreviewAction(title: "Cancel", style:.default) { (action, viewController) -> Void in
            }

            View.tintColor = #colorLiteral(red: 0.1137254902, green: 0.462745098, blue: 0.7333333333, alpha: 1)
            Enter.tintColor = #colorLiteral(red: 0.1137254902, green: 0.462745098, blue: 0.7333333333, alpha: 1)
            Cancel.tintColor = #colorLiteral(red: 0.1137254902, green: 0.462745098, blue: 0.7333333333, alpha: 1)

            return [View, Enter, Cancel]
        //}

    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: view)
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if residentNameStr == "Edward J.310" {
            return 1
        }else{
            if openCaresOfResident.count > 3{
                return 3

            }else{
                return openCaresOfResident.count
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if typeOfPeek == "longPress"{
            if residentNameStr == "Edward J.310" {
                return forceTouchTableView.frame.height/1.8
            }else{

                return forceTouchTableView.frame.height/3.032
            }
        }
        else{
            print("tabel\(forceTouchTableView.frame.height)")
            if residentNameStr == "Edward J.310" {
                return forceTouchTableView.frame.height/1.553
            }else{
                return forceTouchTableView.frame.height/3.230
            }
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ForceTouchTableViewCell()
        cell.contentView.frame = CGRect(x: 0, y: 0, width: forceTouchTableView.frame.width, height: cell.contentView.frame.height)

        if residentNameStr == "Edward J.310" {

            cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath) as! ForceTouchTableViewCell
            let cellWidth = cell.contentView.frame.width
            let cellHeight = cell.contentView.frame.height

            
            cell.service1.frame = CGRect(x: cellWidth/28.846, y: cellHeight/10.692, width: cellWidth/5.514, height: cellHeight/6.619)
            
            cell.serviceImage1.frame = CGRect(x: cell.service1.frame.origin.x+cell.service1.frame.width+cellWidth/125, y: cellHeight/10.692, width: cellWidth/18.75, height: cellHeight/6.619)
            
            cell.serviceLbl1.frame = CGRect(x: cell.serviceImage1.frame.origin.x+cell.serviceImage1.frame.width+cellWidth/46.875, y: cellHeight/10.692, width: cellWidth/2.551, height: cellHeight/6.619)
            
            cell.startTime1.frame = CGRect(x: cellWidth/28.846, y: cell.serviceLbl1.frame.origin.y+cell.serviceLbl1.frame.height+cellHeight/46.333, width: cellWidth/8.333, height: cellHeight/6.619)
            
            cell.startTimeLbl1.frame = CGRect(x:cell.startTime1.frame.origin.x+cell.startTime1.frame.width , y: cell.serviceLbl1.frame.origin.y+cell.serviceLbl1.frame.height+cellHeight/46.333, width: cellWidth/5.952, height: cellHeight/6.619)
            
            cell.endTime.frame = CGRect(x:cell.startTimeLbl1.frame.origin.x+cell.startTimeLbl1.frame.width , y: cell.serviceLbl1.frame.origin.y+cell.serviceLbl1.frame.height+cellHeight/46.333, width: cellWidth/10.416, height: cellHeight/6.619)
            
            cell.endTimeLBL.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.width, y: cell.serviceLbl1.frame.origin.y+cell.serviceLbl1.frame.height+cellHeight/46.333, width: cellWidth/5.952, height: cellHeight/6.619)
            
            cell.frequency.frame = CGRect(x: cell.endTimeLBL.frame.origin.x+cell.endTimeLBL.frame.width+cellWidth/62.5, y: cell.serviceLbl1.frame.origin.y+cell.serviceLbl1.frame.height+cellHeight/46.333, width: cellWidth/4.261, height: cellHeight/6.619)
            
            cell.frequencyLbl.frame = CGRect(x: cell.frequency.frame.origin.x+cell.frequency.frame.width, y: cell.serviceLbl1.frame.origin.y+cell.serviceLbl1.frame.height+cellHeight/46.333, width: cellWidth/6.355, height: cellHeight/6.619)
            
            cell.nextLbl.frame = CGRect(x: cellWidth/28.846, y: cell.startTime1.frame.origin.y+cell.startTime1.frame.height+cellHeight/46.333, width: cellWidth/8.928, height: cellHeight/6.619)
            
            cell.nextServiceDateLbl.frame = CGRect(x: cell.nextLbl.frame.origin.x+cell.nextLbl.frame.width, y: cell.startTime1.frame.origin.y+cell.startTime1.frame.height+cellHeight/46.333, width: cellWidth/1.217, height: cellHeight/6.619)
            
            cell.notes.frame = CGRect(x: cellWidth/28.846, y: cell.nextLbl.frame.origin.y+cell.nextLbl.frame.height+cellHeight/46.333, width: cellWidth/1.059, height: cellHeight/3.021)
            
        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ForceTouchTableViewCell
            
            
            var careIds = NSDictionary()
            
            let careIDs = UserDefaults.standard.object(forKey: "Care_Ids") as? NSData
            
            if let careIDs = careIDs {
                careIds = (NSKeyedUnarchiver.unarchiveObject(with: careIDs as Data) as? NSDictionary)!
            }


            let care_id = openCaresOfResident[indexPath.row].value(forKey: "care_id") as! String
            
            let care_name = careIds.allKeys(for: care_id) as NSArray

            let _care = care_name.firstObject as! String
            
            let timeTrack = openCaresOfResident[indexPath.row].value(forKey: "total_time") as! NSDictionary
            
            let startTime = timeTrack.value(forKey: "start") as! String
            
            let endTime = timeTrack.value(forKey: "end") as! String
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
            
            let startDate = dateformatter.date(from: startTime)
            
            let endDate = dateformatter.date(from: endTime)
            
            let calendar = Calendar.current
            
            cell.serviceImage.image = UIImage(named: _care)
            cell.serviceLbl.text = _care
            
            if calendar.component(.minute, from: startDate!) < 10 {
                let hours = calendar.component(.hour, from: startDate!)
                if hours > 12 {
                    
                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!) - 12):0\(calendar.component(.minute, from: startDate!)) PM"
                    
                }else if hours == 12{
                    
                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):0\(calendar.component(.minute, from: startDate!)) PM"
                    
                }else{
                    
                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):0\(calendar.component(.minute, from: startDate!)) AM"
                }
                
            }else{
                let hours = calendar.component(.hour, from: startDate!)
                if hours > 12 {
                    
                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!) - 12):\(calendar.component(.minute, from: startDate!)) PM"
                    
                }else if hours == 12 {
                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):\(calendar.component(.minute, from: startDate!)) PM"
                }else{
                    cell.startTimeLbl.text = "\(calendar.component(.hour, from: startDate!)):\(calendar.component(.minute, from: startDate!)) AM"
                }
                
            }
            if calendar.component(.minute, from: endDate!) < 10 {
                let hours = calendar.component(.hour, from: endDate!)
                
                if hours > 12 {
                    
                    cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):0\(calendar.component(.minute, from: endDate!)) PM"
                    
                    
                }else if hours == 12 {
                    
                    cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) PM"
                    
                }else {
                    
                    cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):0\(calendar.component(.minute, from: endDate!)) AM"
                    
                }
            }else{
                let hours = calendar.component(.hour, from: endDate!)
                
                if hours > 12 {
                    
                    cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!) - 12):\(calendar.component(.minute, from: endDate!)) PM"
                    
                }else if hours == 12 {
                    
                    cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) PM"
                    
                }else{
                    
                    cell.pauseTimeLbl.text = "\(calendar.component(.hour, from: endDate!)):\(calendar.component(.minute, from: endDate!)) AM"
                    
                }
                
            }

            
            
            
            
            let cellWidth = cell.contentView.frame.width
            let cellHeight = cell.contentView.frame.height
            
            cell.service.frame = CGRect(x: cellWidth/28.846, y: cellHeight/7.625, width: cellWidth/5.514, height: cellHeight/2.904)
            
            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.width+cellWidth/125, y: cellHeight/7.625, width: cellWidth/18.75, height: cellWidth/18.75)
            
            cell.serviceLbl.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.width+cellWidth/46.875, y: cellHeight/7.625, width: cellWidth/2.551, height: cellHeight/2.904)
            
            cell.startTime.frame = CGRect(x: cellWidth/28.846, y:cell.service.frame.origin.y+cell.service.frame.height + cellHeight/15.25, width: cellWidth/4.464, height: cellHeight/2.904)
            
            cell.startTimeLbl.frame = CGRect(x:cell.startTime.frame.origin.x+cell.startTime.frame.width+cellWidth/187.5 , y: cell.service.frame.origin.y+cell.service.frame.height + cellHeight/15.25, width: cellWidth/4.573, height: cellHeight/2.904)
            
            cell.pauseTime.frame = CGRect(x:cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.width+cellWidth/46.875 , y: cell.service.frame.origin.y+cell.service.frame.height + cellHeight/15.25, width: cellWidth/4.032, height: cellHeight/2.904)
            
            cell.pauseTimeLbl.frame = CGRect(x: cell.pauseTime.frame.origin.x+cell.pauseTime.frame.width, y: cell.service.frame.origin.y+cell.service.frame.height + cellHeight/15.25, width: cellWidth/4.746, height: cellHeight/2.904)

        }
        self.forceTouchTableView.tableFooterView = UIView()

        cell.separatorInset = UIEdgeInsets.zero
     return cell
    }


}
