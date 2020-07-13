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
    public var didFoundChatRoom: ((ChatModel) -> Void)?
    
    var currentUserUid: String!
    
    var chatRooms: [ChatModel]! = []
    
    func loadChatRoomsList(isIncludeAdminAccount : Bool) {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "timestamp").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            self.chatRooms.removeAll()
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    chatModel?.uid = item.key
                    if((chatModel?.chatUserIdDic.keys.contains(self.currentUserUid!)) != true || chatModel?.isIncludeAdminAccount != isIncludeAdminAccount)
                    {
                        continue
                    }
                    self.chatRooms.insert(chatModel!, at: 0)
                    
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
    
    func findChatRoom(isStandAlone : Bool, selectedUserModel:UserModel)
    {
        //find same users' chat room
        Database.database().reference().child("chatRooms").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            var foundRoom = false
            var foundRoomInfo = ChatModel()
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    chatModel?.uid = item.key
                    if(isStandAlone)
                    {
                        if(chatModel?.chatUserIdDic.count == 1 && (chatModel?.chatUserIdDic[self.currentUserUid] != nil))
                        {
                            if let standAloneChat = chatModel?.isStandAlone {
                                if standAloneChat {
                                    foundRoom = true
                                    foundRoomInfo = chatModel!
                                    break
                                }
                            }
                        }
                    }
                    else
                    {
                        if(chatModel?.chatUserIdDic.count == 2 &&
                            (chatModel?.chatUserIdDic[self.currentUserUid] != nil) &&
                            chatModel?.chatUserIdDic[selectedUserModel.uid!] != nil)
                        {
                            foundRoom = true
                            foundRoomInfo = chatModel!
                            break
                        }
                    }

                }
            }

            if(foundRoom == true)
            {
                self.didFoundChatRoom?(foundRoomInfo)
            }
            else
            {
                self.createChatRoom(isStandAlone: false, selectedUserModel: selectedUserModel)
            }
            
        }
        
    }
    
    func createChatRoom(isStandAlone : Bool, selectedUserModel:UserModel)
    {
        var userIdDic : Dictionary<String, Bool> = [
            self.currentUserUid : false
        ]
        
        if(isStandAlone == false)
        {
            userIdDic.updateValue(false, forKey: selectedUserModel.uid!)
        }
        
        var profileDic : Dictionary<String, String> = [
            self.currentUserUid : "",
        ]
        
        if let currentUserProfile = UserContexManager.shared.getCurrentUserModel().profileURL {
            profileDic[self.currentUserUid] = currentUserProfile
        }
        
        var isAdminAccount = UserContexManager.shared.getCurrentUserModel().isAdminAccount
        if(isStandAlone == false && selectedUserModel.isAdminAccount)
        {
            isAdminAccount = true
        }
        
        let chatRoomName = selectedUserModel.name!
        let chatRoomValue : Dictionary<String, Any> = [
            "isIncludeAdminAccount" : isAdminAccount,
            "standAlone" : isStandAlone,
            "chatUserIdDic" : userIdDic,
            "name" : chatRoomName,
            "timestamp" : ServerValue.timestamp()
        ]
        
        Database.database().reference().child("chatRooms").childByAutoId().setValue(chatRoomValue) {
            (err, ref) in
            if(err == nil) {
                self.findChatRoom(isStandAlone: isStandAlone, selectedUserModel: selectedUserModel)
            }
            else {
                print("createChatRoom is failed")
            }
        }
    }
    
}
