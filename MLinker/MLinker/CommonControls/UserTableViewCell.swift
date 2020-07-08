//
//  UserTableViewCell.swift
//  MLinker
//
//  Created by 김동현 on 27/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Kingfisher

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
        self.adminAccountLabel.text = NSLocalizedString("Official", comment: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(userModel : UserModel) {
        self.nameLabel.text = userModel.name
        self.setAdminAccount(value: userModel.isAdminAccount)
        
        if userModel.comment!.isEmpty {
            commentLabel?.text = NSLocalizedString("No comments", comment: "")
        }
        else {
            commentLabel?.text = userModel.comment
        }

        if let profileImageString = userModel.profileURL {
            guard let profileImageURL = URL(string: profileImageString) else { return }
            
            let processor = DownsamplingImageProcessor(size: CGSize(width: 44, height: 44))
                |> RoundCornerImageProcessor(cornerRadius: 40)
            profileImageView?.kf.indicatorType = .activity
            profileImageView?.kf.setImage(
                with: profileImageURL,
                placeholder: UIImage(named: "defaultProfileCell"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
            {
                result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }

        }
    }
    
    func setAdminAccount(value : Bool) {
        self.adminAccountLabel.isHidden = !value
        if(value == false)
        {
            self.adminAccountLabel.text = ""
        }
    }
    
}
