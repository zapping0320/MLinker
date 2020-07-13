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
    
    func getNumberOfRowsInSection(section : Int) -> Int{
        if section == 0 {
            return self.defaultUserModels.count
        }
        else {
            return self.availableUserModels.count
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
}
