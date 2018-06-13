//
//  ContactsTableViewCell.swift
//  Evey
//
//  Created by PROJECTS on 31/01/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var forwardArrowBtn: UIButton!
    @IBOutlet weak var contactType: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
