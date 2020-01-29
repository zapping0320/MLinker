//
//  ChatDateDisplayCell.swift
//  MLinker
//
//  Created by 김동현 on 30/01/2020.
//  Copyright © 2020 John Kim. All rights reserved.
//

import UIKit

class ChatDateDisplayCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.dateLabel.layer.cornerRadius = 10
        self.dateLabel.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
