//
//  ChatNoticeCell.swift
//  MLinker
//
//  Created by 김동현 on 19/10/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class ChatNoticeCell: UITableViewCell {

    @IBOutlet weak var noticeTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
