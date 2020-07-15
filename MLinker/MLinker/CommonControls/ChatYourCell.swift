//
//  ChatYourCell.swift
//  MLinker
//
//  Created by 김동현 on 24/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Kingfisher

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
    
    func updateUI(comment : ChatModel.Comment, remainUserCount : Int, currentUserModel : UserModel) {
        selectionStyle = .none
        
        commentTextView.text = comment.message
        if let timeStamp = comment.timestamp {
            commentDateLabel.text = timeStamp.toChatCellDayTime
        }
        
        setShowReadUserCountLabel(remainUserCount: remainUserCount)
        
        var nameString = currentUserModel.name
        
        if currentUserModel.isAdminAccount {
            nameString = nameString! + NSLocalizedString("Official", comment: "")
        }
        nameLabel.text = nameString
        
        if let profileImageString = currentUserModel.profileURL {
            let profileImageURL = URL(string: profileImageString)
            let processor = DownsamplingImageProcessor(size: CGSize(width: 50, height: 50))
                |> RoundCornerImageProcessor(cornerRadius: 25)
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
