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
    
    var databaseRef: DatabaseReference?
    var observe : UInt?
    
    public var didNotificationUpdated: (() -> Void)?
    public var updatedChatModel: ((ChatModel) -> Void)?
    public var clearTextInput: (() -> Void)?
    
    var selectedChatModel:ChatModel = ChatModel()
    var comments: [ChatModel.Comment] = []
    var dateStrings : [String] = []
    
    func getNumberOfRowsInSection() -> Int {
        return comments.count
    }
    
    func getCommentData(indexPath: IndexPath) -> ChatModel.Comment {
        return comments[indexPath.row]
    }
    
    func getCommentSenderUserModel(sender : String) -> UserModel {
        if self.selectedChatModel.chatUserModelDic[sender] == nil {
            return UserModel()
        }
        guard let senderModel = self.selectedChatModel.chatUserModelDic[sender] else { return UserModel() }
        
        return senderModel
    }
    
    func getRelatedUserModels()
    {
        let selectedChatModel   = UserContexManager.shared.getLastChatRoom()
        
        for userID in selectedChatModel.chatUserIdDic.keys { Database.database().reference().child("users").child(userID).observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            if let userDic = datasnapShot.value as? [String:AnyObject] {
                let userModel = UserModel(JSON: userDic)
                selectedChatModel.chatUserModelDic.updateValue(userModel!, forKey: userID)
                self.updatedChatModel?(selectedChatModel)
                self.selectedChatModel = selectedChatModel
            }
            }
        }
    }
    
    func getMessageList() {
        
        let currnetUserUid      = UserContexManager.shared.getCurrentUid()
        let selectedChatModel   = UserContexManager.shared.getLastChatRoom()
        
        self.databaseRef = Database.database().reference().child("chatRooms").child(selectedChatModel.uid).child("comments")
        
        var lastComment:ChatModel.Comment?
        
        self.observe = self.databaseRef!.observe(DataEventType.value, with: {
            (snapshot) in
            self.comments.removeAll()
            self.dateStrings.removeAll()
            
            var readUsersDic : Dictionary<String,AnyObject> = [:]
            
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let key = item.key as String
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                let comment_modify = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                comment_modify?.readUsers[currnetUserUid] = true
                readUsersDic[key] = comment_modify?.toJSON() as NSDictionary?
                if comment!.isNotice {
                    comment?.commentType = CommentType.Notice
                }
                else
                {
                    comment?.commentType = CommentType.Comment
                }
                self.addDateString(comment: comment!)
                self.comments.append(comment!)
                lastComment = comment!
            }
            
            let nsDic = readUsersDic as NSDictionary
            
            if(lastComment?.readUsers.keys == nil){
                return
            }
            
            if(!(lastComment?.readUsers.keys.contains(currnetUserUid))!){
                snapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                    self.didNotificationUpdated?()
                })
                
            }else {
                self.didNotificationUpdated?()
            }
        })
    }
    
    
    func addDateString(comment : ChatModel.Comment)
    {
        if let timeStamp = comment.timestamp {
            let dateString = timeStamp.toChatDisplayDate
            if self.dateStrings.contains(dateString) == false {
                self.dateStrings.append(dateString)
                let dateComment = ChatModel.Comment()
                dateComment.commentType = CommentType.Date
                dateComment.message = dateString
                self.comments.append(dateComment)
            }
        }
    }
    
    func sendMessageServer(isNotice:Bool, textInputString : String)
    {
        let currentUserUid = UserContexManager.shared.getCurrentUid()
        
        let readUsersDic : Dictionary<String,Any> = [
            currentUserUid : true
        ]
        
        
        var commentDic : Dictionary<String, Any> = [
            "sender"    : currentUserUid,
            "timestamp" : ServerValue.timestamp(),
            "readUsers" : readUsersDic
        ]
        
        
        if(isNotice == false)
        {
            commentDic.updateValue(textInputString, forKey: "message")
            self.sendGCM(notificationbody: textInputString)
        }
        else
        {
            let relatedUsers: [String] = [UserContexManager.shared.getCurrentUserModel().name!]
            
            let noticeDic : Dictionary<String, Any> = [
                "noticeType" : 2,
                "relatedUsers" : relatedUsers
            ]
            
            commentDic.updateValue(true, forKey: "isNotice")
            commentDic.updateValue(noticeDic, forKey: "notice")
        }
        
        Database.database().reference().child("chatRooms").child(self.selectedChatModel.uid).child("comments").childByAutoId().setValue(commentDic, withCompletionBlock: {
            (err, ref) in
            if err == nil {
                self.updateChatRoomTimeStamp()
            }
            else {
                print("error sendMessageServer")
            }
        })
    }
    
    func updateChatRoomTimeStamp() {
        let updateChatRoomValue : Dictionary<String, Any> = [
            "timestamp" : ServerValue.timestamp()
        ]
        Database.database().reference().child("chatRooms").child(self.selectedChatModel.uid).updateChildValues(updateChatRoomValue) {
            (updateErr, ref) in
            if(updateErr != nil)
            {
                print("update chatRoom name error")
            }
            else {
                self.clearTextInput?()
            }
        }
    }
    
    func sendGCM(notificationbody : String) {
        let currentUserUid = UserContexManager.shared.getCurrentUid()
        for key in self.selectedChatModel.chatUserModelDic.keys {
            if key == currentUserUid {
                continue
            }
            
            let currentUserModel = self.selectedChatModel.chatUserModelDic[key]
            let notificationModel = NotificationModel()
            notificationModel.to = currentUserModel?.pushToken
            notificationModel.notification.title = NSLocalizedString("Sender :", comment: "") + (currentUserModel?.name!)!
            notificationModel.notification.body = notificationbody
            
            let params = notificationModel.toJSON()
            PushMessageManager.sendGCM(params: params)
        }
    }
    
    func changeChatRoomTitle(newTitle : String) {
        let updateChatRoomValue : Dictionary<String, Any> = [
            "name" : newTitle,
            "timestamp" : ServerValue.timestamp()
        ]
        Database.database().reference().child("chatRooms").child(self.selectedChatModel.uid).updateChildValues(updateChatRoomValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                self.selectedChatModel.name = newTitle
            }
            else
            {
                print("update chatRoom name error")
            }
        }
    }
}
