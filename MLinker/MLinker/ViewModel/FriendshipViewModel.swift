//
//  FriendshipViewModel.swift
//  MLinker
//
//  Created by DONGHYUN KIM on 2020/07/13.
//  Copyright © 2020 John Kim. All rights reserved.
//

import Foundation
import Firebase

class FriendshipViewModel {
   
    public var didNotificationUpdated: (() -> Void)?
    
    func acceptFriendshipRequest(selectedFriendshipModel : FriendshipModel) {
        //update self
        let updateValue : Dictionary<String, Any> = [
            "status" : 3,
            "timestamp" : ServerValue.timestamp()
        ]
        
        let currentUserUid = UserContexManager.shared.getCurrentUid()
    Database.database().reference().child("friendInformations").child(currentUserUid).child("friendshipList").child(selectedFriendshipModel.uid!).updateChildValues(updateValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                let friendUid = selectedFriendshipModel.friendId!
            Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
                    (datasnapShot) in
                    for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                        if let friendshipDic = item.value as? [String:AnyObject] {
                            
                            let friendshipModel = FriendshipModel(JSON: friendshipDic)
                            friendshipModel?.uid = item.key
                            
                            if(friendshipModel?.friendId != currentUserUid)
                            {
                                continue
                            }
                        Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").child(item.key).updateChildValues(updateValue) {
                                (friendUpdateErr, ref) in
                                if(friendUpdateErr == nil) {
                                    self.didNotificationUpdated?()
                                }
                                else {
                                    print("remove friendshipinfo is failed")
                                }
                            }
                        }
                        
                    }
                }
            }else {
                print("error update self freindshipmodel")
            }
        }
    }
    
    func cancelFriendshipRequest(selectedFriendshipModel : FriendshipModel) {
        //update self
        let updateSelfValue : Dictionary<String, Any> = [
            "status" : 4,
            "timestamp" : ServerValue.timestamp()
        ]
        
        let currentUserUid = UserContexManager.shared.getCurrentUid()
        Database.database().reference().child("friendInformations").child(currentUserUid).child("friendshipList").child(selectedFriendshipModel.uid!).updateChildValues(updateSelfValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                let friendUid = selectedFriendshipModel.friendId!
                Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
                    (datasnapShot) in
                    for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                        if let friendshipDic = item.value as? [String:AnyObject] {
                            
                            let friendshipModel = FriendshipModel(JSON: friendshipDic)
                            friendshipModel?.uid = item.key
                            
                            if(friendshipModel?.friendId != currentUserUid)
                            {
                                continue
                            }
                            Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").child(item.key).removeValue() {
                                (deleteErr, ref) in
                                if(deleteErr == nil) {
                                    
                                }
                            }
                        }
                        
                    }
                }
            }else {
                print("error update self freindshipmodel")
            }
           
            self.didNotificationUpdated?()
        }
    }
    
    func rejectFriendship(includeChat : Bool, selectedFriendshipModel : FriendshipModel)
    {
        //update self
        let updateSelfValue : Dictionary<String, Any> = [
            "status" : 5,
            "timestamp" : ServerValue.timestamp()
        ]
        
        
        let currentUserUid = UserContexManager.shared.getCurrentUid()
        Database.database().reference().child("friendInformations").child(currentUserUid).child("friendshipList").child(selectedFriendshipModel.uid!).updateChildValues(updateSelfValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                let friendUid = selectedFriendshipModel.friendId!
                Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
                    (datasnapShot) in
                    for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                        if let friendshipDic = item.value as? [String:AnyObject] {
                            
                            let friendshipModel = FriendshipModel(JSON: friendshipDic)
                            friendshipModel?.uid = item.key
                            
                            if(friendshipModel?.friendId != currentUserUid)
                            {
                                continue
                            }
                            Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").child(item.key).removeValue() {
                                (deleteErr, ref) in
                                if(deleteErr == nil) {
                                    if(includeChat == true)
                                    {
                                        self.removeFriendInfoFromChatRooms(selfUid: selectedFriendshipModel.uid!, friendUid: friendUid)
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }else {
                print("error update self freindshipmodel")
            }
           
            self.didNotificationUpdated?()
        }
    }
    
    func removeFriendInfoFromChatRooms(selfUid: String, friendUid : String)
    {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "timestamp").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    chatModel?.uid = item.key
                    if(((chatModel?.chatUserIdDic.keys.contains(selfUid)) == true) && (chatModel?.chatUserIdDic.keys.contains(friendUid) == true))
                    {
                        chatModel?.chatUserIdDic.removeValue(forKey: friendUid)
                        
                        let updateChatRoomValue : Dictionary<String, Any> = [
                            "chatUserIdDic" : chatModel!.chatUserIdDic,
                            "timestamp" : ServerValue.timestamp()
                        ]
                        
                        datasnapShot.ref.updateChildValues(updateChatRoomValue, withCompletionBlock: { (err, ref) in
                            if(err == nil)
                            {
                                print("chat room update success")
                            }
                            else
                            {
                                print("error update self freindshipmodel")
                            }
                            
                        })
                    }
                }
            }
        }
    }
}
