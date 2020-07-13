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
    
    let chatRoomViewModel = ChatRoomViewModel()
    let friendshipViewModel = FriendshipViewModel()
    
    func setUserID(userId : String) {
        self.currentUserUid = userId
        self.chatRoomViewModel.currentUserUid = userId
    }
    
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
        var updageDic = updateInfoValue
        updageDic.updateValue(ServerValue.timestamp(), forKey: "timestamp")
        
        Database.database().reference().child("users").child(self.selectedUserModel.uid!).updateChildValues(updageDic) {
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
        self.chatRoomViewModel.didFoundChatRoom = { [weak self] (chatModel) in
            self?.didFoundChatRoom?(chatModel)
        }
        
        self.chatRoomViewModel.findChatRoom(isStandAlone: false, selectedUserModel: self.selectedUserModel)
    }
    
    func acceptFriendshipRequest() {
        
        guard let selectedFriendshipModel = self.selectedFriendshipModel else {
            return
        }
        
        self.friendshipViewModel.didNotificationUpdated = { [weak self] in
            self?.needCloseVC?()
        }
        
        self.friendshipViewModel.acceptFriendshipRequest(selectedFriendshipModel: selectedFriendshipModel)
    }
    
    func cancelFriendshipRequest() {
        guard let selectedFriendshipModel = self.selectedFriendshipModel else {
            return
        }
        
        self.friendshipViewModel.didNotificationUpdated = { [weak self] in
            self?.needCloseVC?()
        }
        
        self.friendshipViewModel.cancelFriendshipRequest(selectedFriendshipModel: selectedFriendshipModel)
    }
    
    func rejectFriendship(includeChat : Bool)
    {
        guard let selectedFriendshipModel = self.selectedFriendshipModel else {
            return
        }
        
        self.friendshipViewModel.didNotificationUpdated = { [weak self] in
            self?.needCloseVC?()
        }
        
        self.friendshipViewModel.rejectFriendship(includeChat: includeChat, selectedFriendshipModel: selectedFriendshipModel)
    }
}
