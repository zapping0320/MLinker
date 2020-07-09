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
    public var didFoundChatRoom: ((ChatModel) -> Void)?
    
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
}
