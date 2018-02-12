//
//  OutComeTableViewCell.swift
//  EveyDemo
//
//  Created by PROJECTS on 30/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class OutComeTableViewCell: UITableViewCell {
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var outcomeNameLabel: UILabel!

    @IBOutlet weak var selectingButton: UIButton!
    var high = UIButton()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
