//
//  ChatModel.swift
//  MLinker
//
//  Created by 김동현 on 08/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import ObjectMapper

class ChatModel: Mappable {
    public class Comment : Mappable {
        public var uid: String?
        public var sender: String?
        public var message: String?
        public var timestamp: Int?
        public var readUsers : Dictionary<String, Bool> = [:]
        
        init() {
        }
        
        public required init?(map: Map) {
            
        }
        
        public func mapping(map: Map) {
            uid         <- map["uid"]
            sender      <- map["sender"]
            message     <- map["message"]
            timestamp   <- map["timestamp"]
            readUsers   <- map["readUsers"]
        }
    }
    
    var uid : String = ""
    public var isIncludeAdminAccount: Bool = false
    public var chatUserIdDic: Dictionary<String,Bool> = [:]
    public var chatUserProfiles : Dictionary<String,String> = [:]
    public var name: String = ""
    public var comments : Dictionary<String, Comment> = [:]
    public var timestamp: Int?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        uid                     <- map["uid"]
        isIncludeAdminAccount   <- map["isIncludeAdminAccount"]
        chatUserIdDic           <- map["chatUserIdDic"]
        chatUserProfiles        <- map["chatUserProfiles"]
        name                    <- map["name"]
        comments                <- map["comments"]
        timestamp               <- map["timestamp"]
    }
    
}
