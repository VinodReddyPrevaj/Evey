//
//  selectionTableViewCell.swift
//  Evey
//
//  Created by PROJECTS on 28/05/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit

class selectionTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var rowButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
