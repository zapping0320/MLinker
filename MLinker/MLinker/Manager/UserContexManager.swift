//
//  UserContexManager.swift
//  MLinker
//
//  Created by 김동현 on 03/10/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import Foundation

class UserContexManager{
    
    private var currentUserModel = UserModel()
    private var currentUid : String?
    
    static let shared = UserContexManager()
    private init(){
        
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
}
