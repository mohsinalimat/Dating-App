//
//  CustomTableViewCell.swift
//  SimpleTable
//
//  Created by Ravi on 17/06/15.
//  Copyright (c) 2015 AppTuitions. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var imageVW: UIImageView!
    @IBOutlet var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
