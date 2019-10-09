//
//  ChatRoomTableViewCell.swift
//  MLinker
//
//  Created by 김동현 on 18/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {

    @IBOutlet weak var lastCommentDateLabel: UILabel!
    @IBOutlet weak var lastCommentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
