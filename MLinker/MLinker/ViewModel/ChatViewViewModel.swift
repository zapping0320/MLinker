//
//  ChatViewViewModel.swift
//  MLinker
//
//  Created by DONGHYUN KIM on 2020/07/14.
//  Copyright © 2020 John Kim. All rights reserved.
//

import Foundation
import Firebase

class ChatViewViewModel {

    public var didNotificationUpdated: (() -> Void)?
     public var updatedChatModel: ((ChatModel) -> Void)?
    
    func getRelatedUserModels()
       {
        
        let selectedChatModel   = UserContexManager.shared.getLastChatRoom()
        
           for userID in selectedChatModel.chatUserIdDic.keys { Database.database().reference().child("users").child(userID).observeSingleEvent(of: DataEventType.value) {
               (datasnapShot) in
               if let userDic = datasnapShot.value as? [String:AnyObject] {
                   let userModel = UserModel(JSON: userDic)
                   //self.selectedChatModel.chatUserModelDic.updateValue(userModel!, forKey: userID)
                    selectedChatModel.chatUserModelDic.updateValue(userModel!, forKey: userID)
                self.updatedChatModel?(selectedChatModel)
               }
               
//               DispatchQueue.main.async {
//                   self.commentTableView.reloadData()
//                   self.scrollTableView()
//               }
               
               }
               
           }
       }
    
}
