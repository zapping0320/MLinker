//
//  chatRoomViewModel.swift
//  MLinker
//
//  Created by DONGHYUN KIM on 2020/07/08.
//  Copyright © 2020 John Kim. All rights reserved.
//

import Foundation
import Firebase

class ChatRoomViewModel {
    
    public var didNotificationUpdated: (() -> Void)?
    
    var currnetUserUid: String!
    
    var chatRooms: [ChatModel]! = []
    
    func getChatRoomsList() {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "timestamp").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            self.chatRooms.removeAll()
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    chatModel?.uid = item.key
                    if((chatModel?.chatUserIdDic.keys.contains(self.currnetUserUid!)) == true)
                    {
                        self.chatRooms.insert(chatModel!, at: 0)
                    }
                }
            }
            self.didNotificationUpdated?()
        }
    }
    
    func getNumberOfRowsInSection() -> Int {
        return chatRooms.count
    }
    
    func getChatRoomData(indexPath: IndexPath) -> ChatModel {
        return chatRooms[indexPath.row]
    }
    
}
