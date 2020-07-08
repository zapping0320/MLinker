//
//  ChatModel.swift
//  MLinker
//
//  Created by 김동현 on 08/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import ObjectMapper
import Firebase

public enum CommentType : Int {
    case None       = 0
    case Comment    = 1
    case Notice     = 2
    case Date       = 3
}

class ChatModel: Mappable {
    public class Comment : Mappable {
        public var commentType : CommentType = CommentType.None
        public var uid: String?
        public var sender: String?
        public var message: String?
        public var timestamp: Int?
        public var readUsers : Dictionary<String, Bool> = [:]
        public var isNotice: Bool = false
        public var notice:Notice = Notice()
        
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
            isNotice    <- map["isNotice"]
            notice      <- map["notice"]
        }
    }
    
    var uid : String = ""
    public var isIncludeAdminAccount: Bool = false
    public var isStandAlone: Bool = false
    public var chatUserIdDic: Dictionary<String,Bool> = [:]
    public var chatUserModelDic : Dictionary<String, UserModel> = [:]
    public var name: String = ""
    public var comments : Dictionary<String, Comment> = [:]
    public var timestamp: Int?
    public var chatRoomImageURL : String?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        uid                     <- map["uid"]
        isIncludeAdminAccount   <- map["isIncludeAdminAccount"]
        isStandAlone            <- map["standAlone"]
        chatUserIdDic           <- map["chatUserIdDic"]
        name                    <- map["name"]
        comments                <- map["comments"]
        timestamp               <- map["timestamp"]
        chatRoomImageURL        <- map["chatRoomImageURL"]
    }
    
    public func isValid() -> Bool {
        return uid.isEmpty == false
    }
    
    public func getCommentInfo() -> (unreadMessageCount : Int, recentComment: ChatModel.Comment) {
         var unreadMessageCount = 0
        
        if(self.comments.isEmpty)
        {
            return (unreadMessageCount: 0, recentComment: ChatModel.Comment())
        }
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {
            return (unreadMessageCount: 0, recentComment: ChatModel.Comment())
        }
        
        var recentComment : ChatModel.Comment = ChatModel.Comment()
        for key in self.comments.keys {
            if let comment = self.comments[key] {
                if comment.readUsers.keys.contains(currentUserUid) == false
                    || comment.readUsers[currentUserUid] == false {
                    unreadMessageCount = unreadMessageCount + 1
                }

                if recentComment.timestamp == nil || recentComment.timestamp! < comment.timestamp! {
                    recentComment = comment
                }
            }
        }
        
        return (unreadMessageCount: unreadMessageCount, recentComment: recentComment)
    }
    
}
