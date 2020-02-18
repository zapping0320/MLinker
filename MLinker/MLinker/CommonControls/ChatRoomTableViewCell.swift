//
//  ChatRoomTableViewCell.swift
//  MLinker
//
//  Created by 김동현 on 18/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

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
