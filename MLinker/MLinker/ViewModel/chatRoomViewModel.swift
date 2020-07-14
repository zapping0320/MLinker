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
    
    func findChatRoom(isStandAlone : Bool, selectedUserModels:[UserModel])
    {
        if(selectedUserModels.count < 1) {
            return
        }
        
        var targetUserModels = selectedUserModels
        let currentUserModel = UserContexManager.shared.getCurrentUserModel()
        targetUserModels.append(currentUserModel)
        
        var selectedUsersDic : Dictionary<String, Bool> = Dictionary<String, Bool>()
        for userModel in targetUserModels {
            selectedUsersDic.updateValue(false, forKey: userModel.uid!)
        }
        
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
                        if(chatModel?.chatUserIdDic == selectedUsersDic)
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
                self.createChatRoom(isStandAlone: isStandAlone, selectedUserModels: selectedUserModels)
            }
            
        }
        
    }
   
    
    func createChatRoom(isStandAlone : Bool, selectedUserModels:[UserModel])
    {
        if (selectedUserModels.count < 1) {
            return
        }
        
        
        var userIdDic : Dictionary<String, Bool> = Dictionary<String, Bool>()
        let currentUserModel = UserContexManager.shared.getCurrentUserModel()
        
        var isIncludeAdmin = false
        var chatRoomName = "No name"
        
        if(isStandAlone == true)
        {
            isIncludeAdmin = UserContexManager.shared.getCurrentUserModel().isAdminAccount
            chatRoomName = currentUserModel.name ?? ""
            userIdDic.updateValue(false, forKey: currentUserModel.uid!)
        }
        else {
            chatRoomName = ""
            var targetUserModels = selectedUserModels
            targetUserModels.append(currentUserModel)
            for userModel in targetUserModels {
                userIdDic.updateValue(false, forKey: userModel.uid!)
                isIncludeAdmin = isIncludeAdmin || userModel.isAdminAccount
                if chatRoomName.isEmpty == false {
                    chatRoomName += ","
                }
                chatRoomName += userModel.name!
            }
        }

        self.createChatRoomInfo(isStandAlone: isStandAlone, isIncludeAdmin: isIncludeAdmin, userIdDic: userIdDic, chatRoomName: chatRoomName, selectedUserModels: selectedUserModels)
        
    }
    
    func createChatRoomInfo(isStandAlone : Bool, isIncludeAdmin : Bool, userIdDic : Dictionary<String, Bool>, chatRoomName: String, selectedUserModels:[UserModel])
    {
        let chatRoomValue : Dictionary<String, Any> = [
            "isIncludeAdminAccount" : isIncludeAdmin,
            "standAlone" : isStandAlone,
            "chatUserIdDic" : userIdDic,
            "name" : chatRoomName,
            "timestamp" : ServerValue.timestamp()
        ]
        
        Database.database().reference().child("chatRooms").childByAutoId().setValue(chatRoomValue) {
            (err, ref) in
            if(err == nil) {
                self.findChatRoom(isStandAlone: isStandAlone, selectedUserModels: selectedUserModels)
            }
            else {
                print("createChatRoom is failed")
            }
        }
    }
    
}
