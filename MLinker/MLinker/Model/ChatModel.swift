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
        public var message: String?
        public var timestamp: Int?
        public var readUsers : Dictionary<String, Bool> = [:]
        public required init?(map: Map) {
            
        }
        
        public func mapping(map: Map) {
            uid         <- map["uid"]
            message     <- map["message"]
            timestamp   <- map["timestamp"]
            readUsers   <- map["readUsers"]
        }
    }
    
    public var users: Dictionary<String,Bool> = [:]
    public var comments : Dictionary<String, Comment> = [:]
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
        
    }
    
}
