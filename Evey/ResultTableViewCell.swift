//
//  ResultTableViewCell.swift
//  Evey
//
//  Created by PROJECTS on 31/05/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    @IBOutlet weak var col4: UILabel!
    @IBOutlet weak var col5: UILabel!

    @IBOutlet weak var col3: UILabel!
    @IBOutlet weak var col2: UILabel!
    @IBOutlet weak var col1: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
