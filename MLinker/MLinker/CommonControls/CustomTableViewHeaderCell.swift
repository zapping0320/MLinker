//
//  CustomTableViewHeaderCell.swift
//  MLinker
//
//  Created by 김동현 on 15/01/2020.
//  Copyright © 2020 John Kim. All rights reserved.
//

import UIKit

class CustomTableViewHeaderCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
