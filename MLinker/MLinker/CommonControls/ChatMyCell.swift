//
//  ChatMyCell.swift
//  MLinker
//
//  Created by 김동현 on 24/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class ChatMyCell: UITableViewCell {

    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
