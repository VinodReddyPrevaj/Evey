//
//  ResidentVisitsTableViewCell.swift
//  Evey
//
//  Created by PROJECTS on 06/02/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit

class ResidentVisitsTableViewCell: UITableViewCell {
    // resident name button for resident resident contact viewcontroller's resident tableview 
    @IBOutlet weak var residentName: UIButton!
    
    @IBOutlet weak var pauseTime: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceLbl: UILabel!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var pauseTimeLbl: UILabel!
    @IBOutlet weak var totalTimeSpent: UILabel!
    @IBOutlet weak var totalTimeSpentLbl: UILabel!

    @IBOutlet weak var residentNameLbl: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    
    @IBOutlet weak var scheduleResidentName: UILabel!
    
    
    @IBOutlet weak var scheduledService: UILabel!
    
    
    @IBOutlet weak var scheduleServiceImage: UIImageView!
    
    @IBOutlet weak var scheduleServiceName: UILabel!
    
    @IBOutlet weak var scheduleStart: UILabel!
    
    @IBOutlet weak var scheduleStartDate: UILabel!
    
    @IBOutlet weak var scheduleEnd: UILabel!
    
    @IBOutlet weak var scheduleEndDate: UILabel!
    
    @IBOutlet weak var scheduleFrequency: UILabel!
    
    @IBOutlet weak var scheduleFrequencyType: UILabel!
    
    @IBOutlet weak var scheduleNextService: UILabel!
    
    @IBOutlet weak var scheduleNextServiceDate: UILabel!
    
    @IBOutlet weak var checkinTime: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var checkinServiceLabel: UILabel!
    @IBOutlet weak var checkinService: UILabel!
    @IBOutlet weak var checkinResidentName: UILabel!
    @IBOutlet weak var checkinImage: UIImageView!
    @IBOutlet weak var checkInTypeImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
