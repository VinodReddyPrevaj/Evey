//
//  ClosedVisitsTableViewCell.swift
//  EveyDemo
//
//  Created by PROJECTS on 08/12/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class ClosedVisitsTableViewCell: UITableViewCell {
    @IBOutlet weak var closedVisitImage: UIImageView!
    @IBOutlet weak var residentNameLbl: UILabel!
    
    @IBOutlet weak var service: UILabel!
    
    @IBOutlet weak var serviceImage: UIImageView!
    
    @IBOutlet weak var serviceName: UILabel!
    
    @IBOutlet weak var startTime: UILabel!
    
    @IBOutlet weak var startTimeLbl: UILabel!
    
    @IBOutlet weak var endTime: UILabel!
    
    @IBOutlet weak var endTimeLbl: UILabel!
    
    @IBOutlet weak var arrow: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
