//
//  ChatRoomTableViewCell.swift
//  MLinker
//
//  Created by 김동현 on 18/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Kingfisher

class ChatRoomTableViewCell: UITableViewCell {

    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var lastCommentDateLabel: UILabel!
    @IBOutlet weak var lastCommentLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selfLabelButton: UIButton!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.roomImageView.layer.cornerRadius = 20
        self.roomImageView.clipsToBounds = true
        
        self.selfLabelButton.layer.cornerRadius = 6
        self.selfLabelButton.clipsToBounds = true
        self.selfLabelButton.setTitle(NSLocalizedString("Me", comment: ""), for: .normal) 
        
        self.unreadMessageCountLabel.layer.cornerRadius = 6
        self.unreadMessageCountLabel.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setStandAlone(value : Bool ) {
        self.selfLabelButton.isHidden = !value
        if value == false {
            self.selfLabelButton.widthAnchor.constraint(equalToConstant: 0.0).isActive = true
        }
    }
    
    func setUnreadMessageCount(value : Int) {
        if value > 0 {
            self.unreadMessageCountLabel.isHidden = false
            self.unreadMessageCountLabel.text = String(value)
            //self.unreadMessageCountLabel.sizeToFit()
        }
        else
        {
            self.unreadMessageCountLabel.isHidden = true
        }
    }
    
    func updateUI(chatRoom : ChatModel) {
        self.setStandAlone(value: chatRoom.isStandAlone)
    
        nameLabel.text = chatRoom.name
        memberCountLabel.text = String(chatRoom.chatUserIdDic.count)
        
        let commentInfo = chatRoom.getCommentInfo()
        lastCommentLabel.text = commentInfo.recentComment.message
        if let timeStamp = commentInfo.recentComment.timestamp {
            lastCommentDateLabel.text = timeStamp.toChatRoomCellDayTime
        }else {
             lastCommentDateLabel.text = ""
        }
        
        self.setUnreadMessageCount(value: commentInfo.unreadMessageCount)

/***************************************/
//if implement chatroom image, must do this comment codes
//        var hasImage = false
//               var imageURL:String = ""
//               if let chatroomImage = chatRoom.chatRoomImageURL {
//                   hasImage = true
//                   imageURL = chatroomImage
//               }
//        if hasImage == false {
//            if let lastCommentUserProfile = chatRoom.chatUserModelDic[recentComment.sender!]?.profileURL {
//                hasImage = true
//                imageURL = lastCommentUserProfile
//            }
//        }
//
//        if hasImage == true
//        {
//            let profileImageURL = URL(string: imageURL)
//            let processor = DownsamplingImageProcessor(size: CGSize(width: 80, height: 80))
//                |> RoundCornerImageProcessor(cornerRadius: 40)
//            roomImageView?.kf.indicatorType = .activity
//            roomImageView?.kf.setImage(
//                with: profileImageURL,
//                placeholder: UIImage(named: "defaultChatRoomCell"),
//                options: [
//                    .processor(processor),
//                    .scaleFactor(UIScreen.main.scale),
//                    .transition(.fade(1)),
//                    .cacheOriginalImage
//                ])
//            {
//                result in
//                switch result {
//                case .success(let value):
//                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
//                case .failure(let error):
//                    print("Job failed: \(error.localizedDescription)")
//                }
//            }
//
//        }
/***************************************/
    }
}

extension Int {
    var toChatRoomCellDayTime : String {
        let date = Date(timeIntervalSince1970: Double(self) / 1000)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        if(Calendar.current.isDateInToday(date))
        {
            dateFormatter.dateFormat = "hh:mm"
        }
        else
        {
            dateFormatter.dateFormat = "yyyy.MM.dd"
        }
        return dateFormatter.string(from: date)
    }
}
