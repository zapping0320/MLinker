//
//  UserModel.swift
//  MLinker
//
//  Created by 김동현 on 08/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import ObjectMapper

class UserModel: Mappable {
    var uid : String?
    var email : String?
    var profileURL : String?
    var name: String?
    //pushtoken
    var comment:String?
    var isAdminAccount : Bool = false
    public var timestamp: Int?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        uid      <- map["uid"]
        email    <- map["email"]
        name <- map["name"]
         profileURL <- map["profileURL"]
         comment <- map["comment"]
        isAdminAccount <- map["isAdminAccount"]
        timestamp   <- map["timestamp"]
    }
}
