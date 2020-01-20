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
    @IBOutlet weak var selfLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.roomImageView.layer.cornerRadius = 20
        self.roomImageView.clipsToBounds = true
        
        self.selfLabel.layer.cornerRadius = 8
        self.selfLabel.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setStandAlone(value : Bool ) {
        self.selfLabel.isHidden = !value
        if value == false {
            self.selfLabel.widthAnchor.constraint(equalToConstant: 0.0).isActive = true
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
