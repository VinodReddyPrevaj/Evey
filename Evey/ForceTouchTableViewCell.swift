//
//  ForceTouchTableViewCell.swift
//  EveyDemo
//
//  Created by PROJECTS on 21/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class ForceTouchTableViewCell: UITableViewCell {

    @IBOutlet weak var pauseTimeLbl: UILabel!
    @IBOutlet weak var pauseTime: UILabel!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var serviceLbl: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var service: UILabel!
    
    @IBOutlet weak var service1: UILabel!
    
    @IBOutlet weak var serviceImage1: UIImageView!
    
    @IBOutlet weak var serviceLbl1: UILabel!
    
    @IBOutlet weak var startTime1: UILabel!
    
    @IBOutlet weak var startTimeLbl1: UILabel!
    
    @IBOutlet weak var endTime: UILabel!
    
    @IBOutlet weak var endTimeLBL: UILabel!
    
    @IBOutlet weak var frequency: UILabel!
    
    @IBOutlet weak var frequencyLbl: UILabel!
    
    @IBOutlet weak var notes: UILabel!

    @IBOutlet weak var nextLbl: UILabel!
    @IBOutlet weak var nextServiceDateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
