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
    @IBOutlet weak var readUserLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        readUserLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func updateUI(comment : ChatModel.Comment, remainUserCount : Int) {
        selectionStyle = .none
        commentTextView.text = comment.message
        if let timeStamp = comment.timestamp {
            commentDateLabel.text = timeStamp.toChatCellDayTime
        }
        setShowReadUserCountLabel(remainUserCount: remainUserCount)
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

extension Int {
    var toChatCellDayTime : String {
        let date = Date(timeIntervalSince1970: Double(self) / 1000)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        dateFormatter.dateFormat = "hh:mm"
        
        return dateFormatter.string(from: date)
    }
    
    var toChatDisplayDate : String {
        let date = Date(timeIntervalSince1970: Double(self) / 1000)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
       
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        return dateFormatter.string(from: date)
    }
}
