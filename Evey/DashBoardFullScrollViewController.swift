//
//  DashBoardFullScrollViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 18/12/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class DashBoardFullScrollViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {
    @IBOutlet var descriptionTextView: [UITextView]!
    @IBOutlet weak var menuBtn: UIButton!
    
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
    override func viewDidLoad() {
        super.viewDidLoad()

        layOuts()
        cellHeight = tableView.frame.height/3.570
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognizerAction(_gesture:)))
        self.desView.addGestureRecognizer(panGestureRecognizer)
        
        
        
        self.tableView.isScrollEnabled = false
        self.scrollView.delegate=self
        self.scrollView.bounces = false
        self.tableView.bounces = false
        
        
        
        if hint == true {
            self.desView.isHidden=true
            
            self.tableView.frame=CGRect(x: CGFloat(0.0), y: CGFloat(nameLabel.frame.origin.y+nameLabel.frame.size.height+self.scrollView.frame.size.height/101.166), width: (self.scrollView.frame.size.width), height: CGFloat(self.scrollView.frame.size.height-self.scrollView.frame.origin.y-(nameLabel.frame.origin.y+nameLabel.frame.size.height+self.scrollView.frame.size.height/101.166)))
            
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        self.scrollView.contentSize = CGSize(width: CGFloat(self.view.frame.size.width), height: (self.scrollView.frame.size.height+self.scrollView.frame.size.height/3.019))
        
        self.tableView.frame=CGRect(x: CGFloat(0.0), y: CGFloat(self.desView.frame.origin.y+self.desView.frame.size.height), width: CGFloat(self.scrollView.frame.size.width), height: CGFloat(self.view.frame.height-(self.eveyTitle.frame.origin.y+self.eveyTitle.frame.size.height)))
        cellHeight = self.tableView.frame.height/5.385
        
        if hint == true {
            self.desView.isHidden=true
            
            self.tableView.frame=CGRect(x: CGFloat(0.0), y: CGFloat(nameLabel.frame.origin.y+nameLabel.frame.size.height+self.scrollView.frame.size.height/101.166), width: (self.scrollView.frame.size.width), height: CGFloat(self.scrollView.frame.size.height))
            
            cellHeight = self.tableView.frame.height/5.324
        }
        
        
    }
    func panGestureRecognizerAction(_gesture:UIPanGestureRecognizer) {
        
        let translate = _gesture.translation(in: self.view)
        if _gesture.state == UIGestureRecognizerState.changed {
            _gesture.view!.center = CGPoint(x:_gesture.view!.center.x + translate.x, y:CGFloat(Float(String(format: "%.1f", self.scrollView.frame.size.height/3.849080) )!))
            _gesture.setTranslation(CGPoint.zero, in: self.view)
            
        }
        if _gesture.state == UIGestureRecognizerState.ended {
            let velocity = _gesture.velocity(in: self.view)
            if velocity.x <= -100 {
                self.desView.isHidden=true
                hint = true
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.tableView.frame=CGRect(x: CGFloat(0.0), y: CGFloat(self.nameLabel.frame.origin.y+self.nameLabel.frame.size.height+self.scrollView.frame.size.height/101.166), width: (self.scrollView.frame.size.width), height: CGFloat(self.scrollView.frame.size.height))
                    self.cellHeight = self.tableView.frame.height/5.324
                    
                })
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.desView.frame.origin = CGPoint(x: CGFloat(0.0), y: CGFloat(self.nameLabel.frame.origin.y+self.nameLabel.frame.size.height+self.scrollView.frame.size.height/101.166))
                    
                })
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hint == true {
            if scrollView == self.scrollView {
                self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.width, height: (self.cellHeight * 6) + 69)
                self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.tableView.frame.origin.y+self.tableView.frame.height)

            }
        }else{
            if scrollView == self.scrollView {
                self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.width, height: (self.cellHeight * 6) + 69)
                self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.tableView.frame.origin.y+self.tableView.frame.height)
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
            
            cell.typeImage.image = UIImage(named:"openVisitIcon")
            
            if (indexPath.row == 0) {
                cell.serviceLabel.text="Bathing"
                cell.serviceImage.image=UIImage(named:"Bathing")
            }else{
                cell.serviceImage.image=UIImage(named:"Treatments")
                cell.serviceLabel.text="Treatment"
                
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            // layOuts
            
            let cellWidth =  cell.contentView.frame.size.width
            let cellHeight = cell.contentView.frame.size.height
            
            
            cell.typeImage.frame = CGRect(x: cellWidth/46.875, y: cellHeight/10.363, width: cellWidth/18.75, height: cellHeight/5.7)
            
            cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.666, y: 0, width: cellWidth/2.049, height: cellHeight/2.651)
            
            cell.service.frame = CGRect(x: cellWidth/46.875, y: cell.typeImage.frame.origin.y+cell.typeImage.frame.size.height+cellHeight/14.25, width: cellWidth/6.696, height: cellHeight/5.428)
            
            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/75, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/19, width: cellWidth/15, height: cellHeight/4.56)
            
            cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46.875, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/28.5, width: cellWidth/3.989, height: cellHeight/5.428)
            
            cell.startTime.frame = CGRect(x: cellWidth/46.875, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/114, width: cellWidth/5.067, height: cellHeight/5.428)
            
            cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/114, width: cellWidth/5.514, height: cellHeight/5.428)
            
            cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+cellWidth/26.785, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/114, width: cellWidth/5.681, height: cellHeight/5.428)
            
            cell.endTiemLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/114, width: cellWidth/5.514, height: cellHeight/5.428)
            
            cell.totalTimeSpent.frame = CGRect(x: cellWidth/46.875, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.232, height: cellHeight/5.428)
            
            cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/4.213, height: cellHeight/5.428)
            
            cell.arrow.frame = CGRect(x: cellWidth/1.136, y: cellHeight/3.257, width: cellWidth/12.5, height: cellHeight/4.071)
            
            
            
            cell.separatorInset = UIEdgeInsets.zero
            return cell
            
        }  else if (indexPath.section==1) {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath) as! VisitsTableViewCell
            
            
            if (indexPath.row == 0) {
                cell.serviceImage.image=UIImage(named:"Medication")
                cell.serviceLabel.text="Medication"
                
            }else{
                cell.serviceImage.image=UIImage(named:"Treatments")
                cell.serviceLabel.text="Treatments"
                
            }
            cell.separatorInset = UIEdgeInsets.zero
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            // layOuts
            
            let cellWidth =  cell.contentView.frame.size.width
            let cellHeight = cell.contentView.frame.size.height
            
            
            
            cell.residentNameLbl1.frame = CGRect(x: cellWidth/34.090, y: cellHeight/19, width: cellWidth/2.049, height: cellHeight/3.677)
            
            cell.service.frame = CGRect(x: cellWidth/34.090, y: cell.residentNameLbl1.frame.origin.y+cell.residentNameLbl1.frame.size.height+cellHeight/57, width: cellWidth/6.696, height: cellHeight/5.428)
            
            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/75, y: cell.residentNameLbl1.frame.origin.y+cell.residentNameLbl1.frame.size.height+cellHeight/57, width: cellWidth/15, height: cellHeight/4.56)
            
            cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46.875, y: cell.residentNameLbl1.frame.origin.y+cell.residentNameLbl1.frame.size.height+cellHeight/57, width: cellWidth/3.989, height: cellHeight/5.428)
            
            cell.startDate.frame = CGRect(x: cellWidth/34.090, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/9.375, height: cellHeight/5.428)
            
            cell.startDateLbl.frame = CGRect(x: cell.startDate.frame.origin.x+cell.startDate.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/6.944, height: cellHeight/5.428)
            
            cell.endDate.frame = CGRect(x: cell.startDateLbl.frame.origin.x+cell.startDateLbl.frame.size.width+cellWidth/23.437, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/11.718, height: cellHeight/5.428)
            
            cell.endDateLbl.frame = CGRect(x: cell.endDate.frame.origin.x+cell.endDate.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/6.944, height: cellHeight/5.428)
            
            cell.frequency.frame = CGRect(x: cell.endDateLbl.frame.origin.x+cell.endDateLbl.frame.size.width+cellWidth/23.437, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/4.746, height: cellHeight/5.428)
            
            cell.frequencyLbl.frame = CGRect(x: cell.frequency.frame.origin.x+cell.frequency.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height, width: cellWidth/8.720, height: cellHeight/5.428)
            
            cell.nextServiceTime.frame = CGRect(x: cellWidth/34.090, y: cell.startDate.frame.origin.y+cell.startDate.frame.size.height, width: cellWidth/3.048, height: cellHeight/5.428)
            
            cell.nextServiceTiemLbl.frame = CGRect(x: cell.nextServiceTime.frame.origin.x+cell.nextServiceTime.frame.size.width, y: cell.startDate.frame.origin.y+cell.startDate.frame.size.height, width: cellWidth/2.155, height: cellHeight/5.428)
            
            cell.arrow1.frame = CGRect(x: cellWidth/1.136, y: cellHeight/3.257, width: cellWidth/12.5, height: cellHeight/4.071)
            
            
            
            
            
            
            return cell
            
        }  else   {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! VisitsTableViewCell
            
            cell.typeImage.image = UIImage(named:"performedVisitIcon")
            if (indexPath.row == 0) {
                cell.serviceImage.image=UIImage(named:"Medication")
                cell.serviceLabel.text="Medication"
                
            }else{
                cell.serviceImage.image=UIImage(named:"Eye Drops")
                cell.serviceLabel.text="eyeDrops"
                
            }
            cell.separatorInset = UIEdgeInsets.zero
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            
            // layOuts
            
            let cellWidth =  cell.contentView.frame.size.width
            let cellHeight = cell.contentView.frame.size.height
            
            
            cell.typeImage.frame = CGRect(x: cellWidth/46.875, y: cellHeight/10.363, width: cellWidth/18.75, height: cellHeight/5.7)
            
            cell.residentNameLbl.frame = CGRect(x: cell.typeImage.frame.origin.x+cell.typeImage.frame.size.width+cellWidth/41.666, y: 0, width: cellWidth/2.049, height: cellHeight/2.651)
            
            cell.service.frame = CGRect(x: cellWidth/46.875, y: cell.typeImage.frame.origin.y+cell.typeImage.frame.size.height+cellHeight/14.25, width: cellWidth/6.696, height: cellHeight/5.428)
            
            cell.serviceImage.frame = CGRect(x: cell.service.frame.origin.x+cell.service.frame.size.width+cellWidth/75, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/19, width: cellWidth/15, height: cellHeight/4.56)
            
            cell.serviceLabel.frame = CGRect(x: cell.serviceImage.frame.origin.x+cell.serviceImage.frame.size.width+cellWidth/46.875, y: cell.residentNameLbl.frame.origin.y+cell.residentNameLbl.frame.size.height-cellHeight/28.5, width: cellWidth/3.989, height: cellHeight/5.428)
            
            cell.startTime.frame = CGRect(x: cellWidth/46.875, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/114, width: cellWidth/5.067, height: cellHeight/5.428)
            
            cell.startTimeLbl.frame = CGRect(x: cell.startTime.frame.origin.x+cell.startTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/114, width: cellWidth/5.514, height: cellHeight/5.428)
            
            cell.endTime.frame = CGRect(x: cell.startTimeLbl.frame.origin.x+cell.startTimeLbl.frame.size.width+cellWidth/26.785, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/114, width: cellWidth/5.681, height: cellHeight/5.428)
            
            cell.endTiemLbl.frame = CGRect(x: cell.endTime.frame.origin.x+cell.endTime.frame.size.width, y: cell.service.frame.origin.y+cell.service.frame.size.height+cellHeight/114, width: cellWidth/5.514, height: cellHeight/5.428)
            
            cell.totalTimeSpent.frame = CGRect(x: cellWidth/46.875, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/3.232, height: cellHeight/5.428)
            
            cell.totalTimeSpentLbl.frame = CGRect(x: cell.totalTimeSpent.frame.origin.x+cell.totalTimeSpent.frame.size.width, y: cell.startTime.frame.origin.y+cell.startTime.frame.size.height, width: cellWidth/4.213, height: cellHeight/5.428)
            
            cell.arrow.frame = CGRect(x: cellWidth/1.136, y: cellHeight/3.257, width: cellWidth/12.5, height: cellHeight/4.071)
            
            
            
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section==2) {
            return "Visits Today"
            
        }
        return "Open Visits"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return CGFloat(23.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 23))
        let title = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.size.width, height: headerView.bounds.size.height))
        title.font = UIFont.systemFont(ofSize:17, weight: UIFontWeightMedium)
        if (section==0) {
            title.text="Open Visits"
            
            title.textColor = UIColor.white
            headerView.backgroundColor = UIColor.init(red: 29.0/255.0, green: 118.0/255.0, blue: 187.0/255.0, alpha: 1.0)
            
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
    
    @IBAction func menuBtnAction(_ sender: Any) {
        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        UserDefaults.standard.set("DashBoardViewController", forKey: "EntryScreen")
        
        self.present(menuViewController, animated: false, completion: nil)
    }
    
    func layOuts(){
        
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        eveyTitle.frame = CGRect(x: screenWidth/2.757, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.166, y: screenHeight/23.821, width: screenWidth/11.363, height: screenHeight/31.761)
        
        scrollView.frame = CGRect(x: 0, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/83.375, width: screenWidth, height: screenHeight-scrollView.frame.origin.y)
        
        let scrollHeight = scrollView.frame.size.height
        
        welcomeLabel.frame = CGRect(x: screenWidth/23.437, y: scrollHeight/37.937, width: screenWidth/1.637, height: scrollHeight/12.14)
        
        nameLabel.frame = CGRect(x: screenWidth/23.437, y: welcomeLabel.frame.origin.y+welcomeLabel.frame.size.height-scrollHeight/75.875, width: screenWidth/1.112, height: scrollHeight/12.14)
        
        desView.frame = CGRect(x: 0, y: nameLabel.frame.origin.y+nameLabel.frame.size.height+scrollHeight/101.166, width: screenWidth, height: scrollHeight/6.977)
        
        tableView.frame = CGRect(x: 0, y: desView.frame.origin.y+desView.frame.size.height, width: screenWidth, height: scrollHeight-desView.frame.origin.y-desView.frame.size.height)
        
        
    }

}
