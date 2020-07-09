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
            
//            DispatchQueue.main.async {
//                self.updateProfileInfo()
//            }
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
}
