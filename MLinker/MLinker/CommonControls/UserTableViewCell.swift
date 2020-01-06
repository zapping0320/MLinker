//
//  UserTableViewCell.swift
//  MLinker
//
//  Created by 김동현 on 27/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var adminAccountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImageView.layer.cornerRadius = 22
        self.profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAdminAccount(value : Bool) {
         self.adminAccountLabel.isHidden = !value
        if(value == false)
        {
            self.adminAccountLabel.text = ""
        }
    }
    
}
