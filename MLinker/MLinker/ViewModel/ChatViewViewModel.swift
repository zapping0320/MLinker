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
    
    var comments: [ChatModel.Comment] = []
    var dateStrings : [String] = []
    
    func getNumberOfRowsInSection() -> Int {
        return comments.count
    }
    
    func getCommentData(indexPath: IndexPath) -> ChatModel.Comment {
        return comments[indexPath.row]
    }
    
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
//                       DispatchQueue.main.async {
//                           //self.commentTableView.reloadData()
//                           //self.scrollTableView()
//                       }
                   })

               }else {
                    self.didNotificationUpdated?()
//                   DispatchQueue.main.async {
//                       //self.commentTableView.reloadData()
//                       //self.scrollTableView()
//
//                 }
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
}
