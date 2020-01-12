//
//  UserContexManager.swift
//  MLinker
//
//  Created by 김동현 on 03/10/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import Foundation

class UserContexManager{
    
    private var permissionCode : String
    private var currentUserModel = UserModel()
    private var currentUid : String?
    
    private var lastChatRoom = ChatModel()
    
    static let shared = UserContexManager()
    private init(){
        permissionCode = "!@#$ASDF"
    }
    
    func setCurrentUserModel(model : UserModel)
    {
        currentUserModel = model
    }
    
    func getCurrentUserModel() -> UserModel
    {
        return currentUserModel
    }
    
    func setCurrentUid(uid : String?)
    {
        currentUid = uid
    }
    
    func getCurrentUid() -> String
    {
        return currentUid == nil ? "" : currentUid!
    }
    
    func getPermissionCode() -> String
    {
        return permissionCode
    }
    
    func setPersmissionCode(code : String)
    {
        permissionCode = code
    }
    
    func setLastChatRoom(model : ChatModel)
    {
        lastChatRoom = model
    }
    
    func getLastChatRoom() -> ChatModel
    {
        return lastChatRoom
    }
    
    func isAdminUser() -> Bool
    {
        return currentUserModel.isAdminAccount
    }
}
