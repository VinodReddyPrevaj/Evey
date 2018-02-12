//
//  ScheduledVisitsTableViewCell.swift
//  Evey
//
//  Created by PROJECTS on 01/02/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit

class ScheduledVisitsTableViewCell: UITableViewCell {

    @IBOutlet weak var residentNameLbl: UILabel!
    @IBOutlet weak var serviceLbl: UILabel!
    
    @IBOutlet weak var serviceImageView: UIImageView!
    
    @IBOutlet weak var serviceNameLbl: UILabel!
    
    @IBOutlet weak var startLbl: UILabel!
    
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var endLbl: UILabel!
    
    @IBOutlet weak var endDateLbl: UILabel!
    
    @IBOutlet weak var frequencyLbl: UILabel!
    
    @IBOutlet weak var frequencyTypeLbl: UILabel!
    
    @IBOutlet weak var nextLbl: UILabel!
    
    @IBOutlet weak var nextDateLbl: UILabel!
    
    @IBOutlet weak var briefDescriptionLbl: UILabel!
    
    @IBOutlet weak var scheduleImage: UIImageView!
    
    @IBOutlet weak var forwardArrow: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
