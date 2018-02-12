//
//  OpenVisitsTableViewCell.swift
//  EveyDemo
//
//  Created by PROJECTS on 20/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class OpenVisitsTableViewCell1: UITableViewCell {

    @IBOutlet weak var pauseTime: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceLbl: UILabel!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var pauseTimeLbl: UILabel!
    @IBOutlet weak var totalTimeSpent: UILabel!
    @IBOutlet weak var totalTimeSpentLbl: UILabel!
    
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
