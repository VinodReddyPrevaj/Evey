//
//  ResidentSelectTestTableViewCell.swift
//  EveyDemo
//
//  Created by PROJECTS on 24/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class ResidentSelectTestTableViewCell: UITableViewCell {
    @IBOutlet weak var scheduledCareImage: UIButton!
    @IBOutlet weak var vistStatus: UIButton!
    @IBOutlet weak var caresView: UIView!
    @IBOutlet weak var careImage: UIImageView!
    @IBOutlet weak var careNameLabel: UILabel!
    @IBOutlet weak var residentNameLbl: UILabel!

    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var careResult: UIImageView!
    @IBOutlet weak var rightArrowBtn: UIButton!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var residentRoomLbl: UILabel!
    @IBOutlet weak var upBordelLabel: UILabel!
    @IBOutlet weak var bottomBorderLabel: UILabel!
    var visitstatus = UIImageView()
    var visitStatusImage = UIImageView()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
