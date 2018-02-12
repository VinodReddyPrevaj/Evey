//
//  ResidentDetailsViewController.swift
//  Evey
//
//  Created by PROJECTS on 06/02/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit

class ResidentDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var residentLbl: UILabel!
    
    @IBOutlet weak var residentNameBtn: UIButton!
    
    @IBOutlet weak var residentNameLbl: UILabel!
    
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var homeLbl: UILabel!
    
    @IBOutlet weak var numberBtn: UIButton!
    
    @IBOutlet weak var borderLbl: UILabel!
    
    @IBOutlet weak var addressTextView: UITextView!
    
    @IBOutlet weak var residentVisitsTableView: UITableView!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var buttonViewBorder: UILabel!
    
    var residentName = "vinod Reddy"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layOuts()
        
        residentVisitsTableView.delegate = self
        residentVisitsTableView.dataSource = self
        
        residentNameLbl.text =  residentName
        let stringInputArr = residentName.components(separatedBy:" ")
        var stringNeed = ""
        
        for string in stringInputArr {
            stringNeed = stringNeed + String(string.characters.first!)
        }
        
        residentNameBtn.setTitle(stringNeed, for: .normal)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(addressTextView.frame)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ResidentVisitsTableViewCell()
        if residentName == "Edward J" {
            cell = residentVisitsTableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath) as! ResidentVisitsTableViewCell
                    let cellWidth =  cell.contentView.frame.size.width
                    let cellHeight = cell.contentView.frame.size.height
            
            
            
                    cell.scheduleResidentName.frame = CGRect(x: cellWidth/34.5, y: cellHeight/19, width: cellWidth/2.049, height: cellHeight/3.677)
            
                    cell.scheduledService.frame = CGRect(x: cellWidth/34.5, y: cell.scheduleResidentName.frame.origin.y+cell.scheduleResidentName.frame.size.height+cellHeight/42, width: cellWidth/6.677, height: cellHeight/5.478)
            
                    cell.scheduleServiceImage.frame = CGRect(x: cell.scheduledService.frame.origin.x+cell.scheduledService.frame.size.width+cellWidth/82.8, y: cell.scheduleResidentName.frame.origin.y+cell.scheduleResidentName.frame.size.height+cellHeight/42, width: cellWidth/15.333, height: cellWidth/15.333)
            
                    cell.scheduleServiceName.frame = CGRect(x: cell.scheduleServiceImage.frame.origin.x+cell.scheduleServiceImage.frame.size.width+cellWidth/46, y: cell.scheduleResidentName.frame.origin.y+cell.scheduleResidentName.frame.size.height+cellHeight/42, width: cellWidth/4.019, height: cellHeight/5.478)
            
                    cell.scheduleStart.frame = CGRect(x: cellWidth/34.5, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/10.35, height: cellHeight/5.428)
            
                    cell.scheduleStartDate.frame = CGRect(x: cell.scheduleStart.frame.origin.x+cell.scheduleStart.frame.size.width, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/5.914, height: cellHeight/5.428)
            
                    cell.scheduleEnd.frame = CGRect(x: cell.scheduleStartDate.frame.origin.x+cell.scheduleStartDate.frame.size.width, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/12.937, height: cellHeight/5.428)
            
                    cell.scheduleEndDate.frame = CGRect(x: cell.scheduleEnd.frame.origin.x+cell.scheduleEnd.frame.size.width, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/5.914, height: cellHeight/5.428)
            
                    cell.scheduleFrequency.frame = CGRect(x: cell.scheduleEndDate.frame.origin.x+cell.scheduleEndDate.frame.size.width, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/5.240, height: cellHeight/5.428)
            
                    cell.scheduleFrequencyType.frame = CGRect(x: cell.scheduleFrequency.frame.origin.x+cell.scheduleFrequency.frame.size.width, y: cell.scheduledService.frame.origin.y+cell.scheduledService.frame.size.height, width: cellWidth/4.6, height: cellHeight/5.428)
            
                    cell.scheduleNextService.frame = CGRect(x: cellWidth/34.5, y: cell.scheduleStart.frame.origin.y+cell.scheduleStart.frame.size.height, width: cellWidth/3.066, height: cellHeight/5.428)
                    
                    cell.scheduleNextServiceDate.frame = CGRect(x: cell.scheduleNextService.frame.origin.x+cell.scheduleNextService.frame.size.width, y: cell.scheduleStart.frame.origin.y+cell.scheduleStart.frame.size.height, width: cellWidth/2.156, height: cellHeight/5.428)

        }else{
        cell = residentVisitsTableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ResidentVisitsTableViewCell
        
        let cellWidth =  cell.contentView.frame.size.width
        let cellHeight = cell.contentView.frame.size.height
        
        
        cell.typeImage.frame = CGRect(x: cellWidth/46, y: cellHeight/10.5, width: cellWidth/18.818, height: cellWidth/18.818)
        
        cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.4, y: 0, width: cellWidth/2.049, height: cellHeight/2.680)
        
        cell.serviceLbl.frame = CGRect(x: cellWidth/46, y: cell.typeImage.frame.origin.y+cell.typeImage.frame.size.height+cellHeight/14, width: cellWidth/6.677, height: cellHeight/5.478)
        
        cell.serviceImage.frame = CGRect(x: cell.serviceLbl.frame.origin.x+cell.serviceLbl.frame.size.width+cellWidth/82.8, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/18, width: cellWidth/15.333, height: cellWidth/15.333)
        
        cell.serviceNameLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/31.5, width: cellWidth/4.019, height: cellHeight/5.478)
        
        cell.startTime.frame = CGRect(x: cellWidth/46, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.111, height: cellHeight/5.478)
        
        cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
        
        
        cell.pauseTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+screenWidth/37.5, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/4.6875, height: cellHeight/5.478)
        
        cell.pauseTimeLbl.frame = CGRect(x: cell.pauseTime.frame.origin.x+cell.pauseTime.frame.size.width, y: cell.serviceLbl.frame.origin.y+cell.serviceLbl.frame.size.height+cellHeight/126, width: cellWidth/5.52, height: cellHeight/5.478)
        
        cell.totalTimeSpent.frame = CGRect(x: cellWidth/46, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.234, height: cellHeight/5.478)
        
        cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/4.224, height: cellHeight/5.478)
        }
        

        cell.separatorInset = UIEdgeInsets.zero
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return CGFloat(self.residentVisitsTableView.frame.height/26.285)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: self.residentVisitsTableView.frame.height/26.285))
        let title = UILabel(frame: CGRect(x: self.residentVisitsTableView.frame.width/27.6, y: 0, width: tableView.bounds.size.width, height: headerView.bounds.size.height))
            title.font = UIFont.systemFont(ofSize:17, weight: UIFontWeightMedium)
            if residentName == "Edward J"{
                title.text="Scheduled Care"
                title.textColor = #colorLiteral(red: 0.3921568627, green: 0.7333333333, blue: 0.8392156863, alpha: 1)
                //title.textColor = UIColor.init(red: 100.0/255.0, green: 187.0/255.0, blue: 214/255.0, alpha: 1.0)
                headerView.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.9098039216, blue: 0, alpha: 1)

            }else{
                title.text="Today"
                title.textColor = UIColor.white
                headerView.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.462745098, blue: 0.7333333333, alpha: 1)
            }
            headerView.addSubview(title)
            //  headerView.backgroundColor = UIColor.init(red: 29.0/255.0, green: 118.0/255.0, blue: 187.0/255.0, alpha: 1.0)
            
        return headerView
    }
    func layOuts(){
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        backBtn.frame = CGRect(x: screenWidth/23.437, y: screenHeight/23, width: screenWidth/18.75, height: screenHeight/33.35)
        
        eveyTitle.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.size.width+screenWidth/3.712, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.213, y: screenHeight/23.437, width: screenWidth/11.363, height: screenHeight/31.761)

        let headerView = UIView()
        

        //header heaight 397    fhvbsdfhj   62
        
        residentLbl.frame = CGRect(x: screenWidth/23.437, y: screenHeight/66.7, width: screenWidth/1.518, height: screenHeight/19.057)
        
        residentNameBtn.frame = CGRect(x: screenWidth/2.622, y: residentLbl.frame.origin.y+residentLbl.frame.height+screenHeight/29, width: screenWidth/4.166, height: screenWidth/4.166)
        
        residentNameBtn.layer.cornerRadius = residentNameBtn.frame.height/2
        
        residentNameLbl.frame = CGRect(x: screenWidth/23.437, y: residentNameBtn.frame.origin.y+residentNameBtn.frame.height+screenHeight/66.7, width: screenWidth/1.093, height: screenHeight/18.527)
        
        statusImage.frame = CGRect(x: screenWidth/2.118, y: residentNameLbl.frame.origin.y+residentNameLbl.frame.height+screenHeight/83.375, width: screenWidth/18.75, height: screenWidth/18.75)
        
        homeLbl.frame = CGRect(x: screenWidth/23.437, y: statusImage.frame.origin.y+statusImage.frame.height+screenHeight/29, width: screenWidth/2.313, height: screenHeight/29)
        
        numberBtn.frame = CGRect(x: screenWidth/23.437, y: homeLbl.frame.origin.y+homeLbl.frame.height, width: screenWidth/1.363, height: screenHeight/29)
        
        borderLbl.frame = CGRect(x: 0, y: numberBtn.frame.origin.y+numberBtn.frame.height+headerView.frame.height/66.166, width: screenWidth, height: 1)
        
        addressTextView.frame = CGRect(x: screenWidth/34.090, y: borderLbl.frame.origin.y+borderLbl.frame.height, width: screenWidth/1.062, height: 100)
       
        addressTextView.text = "home \n2421 Windcove Manner \nRoom 1209 \nWashington DC, 87780"

        
        
        
        var frame = self.addressTextView.frame
        frame.size.height = self.addressTextView.contentSize.height
        self.addressTextView.frame = frame
                
        headerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: addressTextView.frame.origin.y+addressTextView.frame.height)
        headerView.addSubview(residentLbl)
        headerView.addSubview(residentNameBtn)
        headerView.addSubview(residentNameLbl)
        headerView.addSubview(statusImage)
        headerView.addSubview(homeLbl)
        headerView.addSubview(numberBtn)
        headerView.addSubview(borderLbl)
        headerView.addSubview(addressTextView)

        residentVisitsTableView.tableHeaderView = headerView

        residentVisitsTableView.frame = CGRect(x: 0, y: screenHeight/10.758, width: screenWidth, height: screenHeight/1.208)
        
        buttonView.frame = CGRect(x: 0, y: residentVisitsTableView.frame.origin.y+residentVisitsTableView.frame.height, width: screenWidth, height: screenHeight/12.584)
        buttonViewBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        backButton.frame = CGRect(x: screenWidth/1.315, y: buttonView.frame.height/5.3, width: screenWidth/5.281, height: buttonView.frame.height/1.606)
        
    }
    @IBAction func backButtonAction(_ sender: Any) {
        
        let residentContactsVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentsContactsViewController") as! ResidentsContactsViewController
        
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(residentContactsVC, animated: false, completion: nil)

    }
}
