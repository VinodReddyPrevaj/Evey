//
//  VisitsTableViewCell.swift
//  EveyDemo
//
//  Created by PROJECTS on 03/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class VisitsTableViewCell: UITableViewCell {
    //reuseIdentifier

    @IBOutlet weak var arrow: UIButton!
    @IBOutlet weak var service: UILabel!

    @IBOutlet weak var startTime: UILabel!
    
    @IBOutlet weak var endTime: UILabel!
    
    @IBOutlet weak var totalTimeSpent: UILabel!
    
    // reuseIdentifier value's labels
    
    @IBOutlet weak var startTimeLbl: UILabel!
    
    @IBOutlet weak var endTiemLbl: UILabel!
    
    @IBOutlet weak var totalTimeSpentLbl: UILabel!
    
    @IBOutlet weak var residentNameLbl: UILabel!
    
    
    
    //reuse
    @IBOutlet weak var arrow1: UIButton!
    
    @IBOutlet weak var startDate: UILabel!
    
    @IBOutlet weak var endDate: UILabel!
    
    @IBOutlet weak var frequency: UILabel!
    
    @IBOutlet weak var nextServiceTime: UILabel!
    
    // reuse value's Labels
    
    
    @IBOutlet weak var startDateLbl: UILabel!
    
    @IBOutlet weak var endDateLbl: UILabel!
    
    @IBOutlet weak var frequencyLbl: UILabel!
    
    @IBOutlet weak var nextServiceTiemLbl: UILabel!
    
    
    @IBOutlet weak var residentNameLbl1: UILabel!
    
    
    
    
    // reuseIdentifier
    
    @IBOutlet weak var typeImage: UIImageView!
    
   // reuseIdentifier & reuse
    
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
