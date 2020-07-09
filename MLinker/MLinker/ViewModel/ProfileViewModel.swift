//
//  ProfileViewModel.swift
//  MLinker
//
//  Created by DONGHYUN KIM on 2020/07/09.
//  Copyright © 2020 John Kim. All rights reserved.
//

import Foundation
import Firebase

class ProfileViewModel {
    
    public var didNotificationUpdated: (() -> Void)?
    public var updateTextInfo: (() -> Void)?
    public var didFoundChatRoom: ((ChatModel) -> Void)?
    public var needCloseVC: (() -> Void)?
    
    var currentUserUid: String!
    
    var selectedUserModel: UserModel = UserModel()
    
    var selectedFriendshipModel : FriendshipModel?
    
    func isSelfCurrentUser() -> Bool {
        return self.selectedUserModel.uid == UserContexManager.shared.getCurrentUid()
    }
    
    func loadFriendShipInfo()
    { Database.database().reference().child("friendInformations").child(self.currentUserUid!).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let friendshipDic = item.value as? [String:AnyObject] {
                    let friendshipModel = FriendshipModel(JSON: friendshipDic)
                    friendshipModel?.uid = item.key
                    if(friendshipModel?.friendId == self.selectedUserModel.uid)
                    {
                        self.selectedFriendshipModel = friendshipModel
                        break
                    }
                }
            }
        
        self.didNotificationUpdated?()
        }
    }
    
    func updateSelfUserModel() {
        if(isSelfCurrentUser() == false) {
            return
        }
        
        UserContexManager.shared.setCurrentUserModel(model:  self.selectedUserModel)
        
    }
    
    func saveChangedProfileInfo(updateInfoValue : Dictionary<String, Any>, imageData : Data?) {
        Database.database().reference().child("users").child(self.selectedUserModel.uid!).updateChildValues(updateInfoValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                
                self.selectedUserModel.name = updateInfoValue["name"] as? String ?? "" //self.nameTextField.text!
                self.selectedUserModel.comment = updateInfoValue["comment"] as? String ?? ""// self.commetTextField.text!
                self.selectedUserModel.timestamp = updateInfoValue["timestamp"] as? Int ?? 0
                guard let image = imageData else {
                    self.updateSelfUserModel()
                    self.updateTextInfo?()
                    return
                }
                self.updateProfileImageUrl(image: image)
                
            }else {
                print("update userinfo error")
            }
        }
    }
    
    func updateProfileImageUrl(image : Data) {
        
        let storageRef = Storage.storage().reference()
        
        var userDownloadURL:String?
        
        storageRef.child("profileImages").child(self.selectedUserModel.uid!).putData(image, metadata: nil, completion: { (metadata, error) in
            
            guard let _ = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            storageRef.child("profileImages").child(self.selectedUserModel.uid!).downloadURL{ (url, error) in
                guard let downloadURL = url else {
                    print("Downloading profileURL is failed!")
                    return
                }
                userDownloadURL = downloadURL.absoluteString
                Database.database().reference().child("users").child(self.selectedUserModel.uid!).updateChildValues(["profileURL": userDownloadURL!] ) {
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("profileURL could not be saved: \(error).")
                    } else {
                        print("profileURL saved successfully!")
                        self.selectedUserModel.profileURL = userDownloadURL
                        self.updateSelfUserModel()
                        self.updateTextInfo?()
                    }
                }
                
            }
        })
    }
    
    func findChatRoom(isStandAlone : Bool)
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
                            chatModel?.chatUserIdDic[self.selectedUserModel.uid!] != nil)
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
                self.createChatRoom(isStandAlone: isStandAlone)
            }
            
        }
        
    }
    
    func createChatRoom(isStandAlone : Bool)
    {
        var userIdDic : Dictionary<String, Bool> = [
            self.currentUserUid : false
        ]
        
        if(isStandAlone == false)
        {
            userIdDic.updateValue(false, forKey: self.selectedUserModel.uid!)
        }
        
        var profileDic : Dictionary<String, String> = [
            self.currentUserUid : "",
        ]
        
        if let currentUserProfile = UserContexManager.shared.getCurrentUserModel().profileURL {
            profileDic[self.currentUserUid] = currentUserProfile
        }
        
        var isAdminAccount = UserContexManager.shared.getCurrentUserModel().isAdminAccount
        if(isStandAlone == false && self.selectedUserModel.isAdminAccount)
        {
            isAdminAccount = true
        }
        
        let chatRoomName = self.selectedUserModel.name!
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
                self.findChatRoom(isStandAlone: isStandAlone)
            }
            else {
                print("createChatRoom is failed")
            }
        }
    }
    
    func acceptFriendshipRequest() {
        //update self
        let updateValue : Dictionary<String, Any> = [
            "status" : 3,
            "timestamp" : ServerValue.timestamp()
        ]
    Database.database().reference().child("friendInformations").child(self.currentUserUid!).child("friendshipList").child(self.selectedFriendshipModel!.uid!).updateChildValues(updateValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                let friendUid = self.selectedFriendshipModel!.friendId!
            Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
                    (datasnapShot) in
                    for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                        if let friendshipDic = item.value as? [String:AnyObject] {
                            
                            let friendshipModel = FriendshipModel(JSON: friendshipDic)
                            friendshipModel?.uid = item.key
                            
                            if(friendshipModel?.friendId != self.currentUserUid!)
                            {
                                continue
                            }
                        Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").child(item.key).updateChildValues(updateValue) {
                                (friendUpdateErr, ref) in
                                if(friendUpdateErr == nil) {
                                    self.needCloseVC?()
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
    
    func cancelFriendshipRequest() {
        //update self
        let updateSelfValue : Dictionary<String, Any> = [
            "status" : 4,
            "timestamp" : ServerValue.timestamp()
        ]
        Database.database().reference().child("friendInformations").child(self.currentUserUid!).child("friendshipList").child(self.selectedFriendshipModel!.uid!).updateChildValues(updateSelfValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                let friendUid = self.selectedFriendshipModel!.friendId!
                Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
                    (datasnapShot) in
                    for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                        if let friendshipDic = item.value as? [String:AnyObject] {
                            
                            let friendshipModel = FriendshipModel(JSON: friendshipDic)
                            friendshipModel?.uid = item.key
                            
                            if(friendshipModel?.friendId != self.currentUserUid!)
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
            self.needCloseVC?()
        }
    }
    
    func rejectFriendship(includeChat : Bool)
    {
        //update self
        let updateSelfValue : Dictionary<String, Any> = [
            "status" : 5,
            "timestamp" : ServerValue.timestamp()
        ]
        Database.database().reference().child("friendInformations").child(self.currentUserUid!).child("friendshipList").child(self.selectedFriendshipModel!.uid!).updateChildValues(updateSelfValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                let friendUid = self.selectedFriendshipModel!.friendId!
                Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
                    (datasnapShot) in
                    for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                        if let friendshipDic = item.value as? [String:AnyObject] {
                            
                            let friendshipModel = FriendshipModel(JSON: friendshipDic)
                            friendshipModel?.uid = item.key
                            
                            if(friendshipModel?.friendId != self.currentUserUid!)
                            {
                                continue
                            }
                            Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").child(item.key).removeValue() {
                                (deleteErr, ref) in
                                if(deleteErr == nil) {
                                    if(includeChat == true)
                                    {
                                        self.removeFriendInfoFromChatRooms(selfUid: self.selectedFriendshipModel!.uid!, friendUid: friendUid)
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }else {
                print("error update self freindshipmodel")
            }
            self.needCloseVC?()
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
