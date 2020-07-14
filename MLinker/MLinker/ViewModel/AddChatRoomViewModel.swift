//
//  AddChatRoomViewModel.swift
//  MLinker
//
//  Created by DONGHYUN KIM on 2020/07/13.
//  Copyright © 2020 John Kim. All rights reserved.
//

import Foundation
import Firebase
import Kingfisher

class AddChatRoomViewModel {
    
    public var didNotificationUpdated: (() -> Void)?
    public var moveChatRoom: ((ChatModel) -> Void)?
 
    var defaultUserModels    = [UserModel]()
    var availableUserModels = [UserModel]()
    
    func loadChatRoomMembers() {
        let currnetUserUid      = UserContexManager.shared.getCurrentUid()
        let selectedChatModel   = UserContexManager.shared.getLastChatRoom()
        
        defaultUserModels   = [UserModel]()
        availableUserModels = [UserModel]()
        
        Database.database().reference().child("friendInformations").child(currnetUserUid).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let friendshipDic = item.value as? [String:AnyObject] {
                    
                    let friendshipModel = FriendshipModel(JSON: friendshipDic)
                    friendshipModel?.uid = item.key
                    if(friendshipModel == nil){
                        continue
                    }
                    
                    if(friendshipModel?.status != FriendStatus.Connected)
                    {
                        continue
                    }
                    Database.database().reference().child("users").child(friendshipModel!.friendId!).observeSingleEvent(of: DataEventType.value) {
                        (datasnapShot) in
                        if let userDic = datasnapShot.value as? [String:AnyObject] {
                            let userModel = UserModel(JSON: userDic)
                            
                            let uid = userModel?.uid
                            if (selectedChatModel.isValid()) {
                                if(selectedChatModel.chatUserIdDic.keys.contains(uid!) == true)
                                {
                                    self.defaultUserModels.append(userModel!)
                                }
                                else
                                {
                                    self.availableUserModels.append(userModel!)
                                }
                            }
                            else {
                                self.defaultUserModels.append(userModel!)
                            }
                            
                            self.didNotificationUpdated?()
                        }
                    }
                    
                }
            }
            
            self.didNotificationUpdated?()
        }
    }
    
    func getNumOfSection() -> Int{
        let selectedChatModel   = UserContexManager.shared.getLastChatRoom()
        if(selectedChatModel.isValid()){
            return 2
        }
        else
        {
            return 1
        }
    }
    
    func getNumberOfRowsInSection(section : Int) -> Int{
        if section == 0 {
            return self.defaultUserModels.count
        }
        else {
            return self.availableUserModels.count
        }
    }
    
    func getTableHeaderString(section :Int) -> String {
        let selectedChatModel   = UserContexManager.shared.getLastChatRoom()
        if(selectedChatModel.isValid())
        {
            if(section == 0)
            {
                return NSLocalizedString("Current Members", comment: "")
            }
            else
            {
                return NSLocalizedString("Add Members", comment: "")
            }
        }
        else
        {
            return ""
        }
    }
    
    func getCurrentUserData(indexPath: IndexPath) -> UserModel
    {
        if indexPath.section == 0 {
            return self.defaultUserModels[indexPath.row]
        }
        else {
            return self.availableUserModels[indexPath.row]
        }
        
    }
    
    func isCanEditRowAt(indexPath : IndexPath) -> Bool  {
        let selectedChatModel   = UserContexManager.shared.getLastChatRoom()
        if(selectedChatModel.isValid() && indexPath.section == 0){
            return false
        }
        else
        {
            return true
        }
    }
    
    func addMemberstoChatRoom(isIncludeAdmin : Bool, chatUserIdDic: Dictionary<String,Bool>, membersAdded : [String])
    {
        let selectedChatModel   = UserContexManager.shared.getLastChatRoom()
        let chatRoomValue : Dictionary<String, Any> = [
            "isIncludeAdminAccount" :  isIncludeAdmin,
            "standAlone" : false,
            "chatUserIdDic" : chatUserIdDic,
            "timestamp" : ServerValue.timestamp()
        ]
        
        Database.database().reference().child("chatRooms").child(selectedChatModel.uid).updateChildValues(chatRoomValue) {
            (err, ref) in
            if(err == nil) {
                self.addCommentAboutAddingMemebers(relatedUsers: membersAdded)
            }
            else {
                print("[error] addMemberstoChatRoom ")
            }
        }
        
    }
    
    func addCommentAboutAddingMemebers(relatedUsers : [String])
    {
        let currnetUserUid      = UserContexManager.shared.getCurrentUid()
        let selectedChatModel   = UserContexManager.shared.getLastChatRoom()
        
        var commentDic : Dictionary<String, Any> = [
            "sender"    : currnetUserUid,
            "timestamp" : ServerValue.timestamp()
        ]
        
        let noticeDic : Dictionary<String, Any> = [
            "noticeType" : 1,
            "relatedUsers" : relatedUsers
        ]
        
        commentDic.updateValue(true, forKey: "isNotice")
        commentDic.updateValue(noticeDic, forKey: "notice")
        
        Database.database().reference().child("chatRooms").child(selectedChatModel.uid).child("comments").childByAutoId().setValue(commentDic, withCompletionBlock: {
            (err, ref) in
            //self.moveChatView(chatModel: selectedChatModel)
            self.moveChatRoom?(selectedChatModel)
        })
    }
}
