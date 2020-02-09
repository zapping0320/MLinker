//
//  ChatYourCell.swift
//  MLinker
//
//  Created by 김동현 on 24/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class ChatYourCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentDateLabel: UILabel!
    @IBOutlet weak var readUserLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        readUserLabel.isHidden = true
        self.profileImageView.layer.cornerRadius = 18
        self.profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setShowReadUserCountLabel(remainUserCount : Int) {
        if(remainUserCount > 0)
        {
            self.readUserLabel.isHidden = false
            self.readUserLabel.text = String(remainUserCount)
        }
        else
        {
            self.readUserLabel.isHidden = true
        }
    }
}
