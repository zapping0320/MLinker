//
//  UserFriendList.swift
//  MLinker
//
//  Created by 김동현 on 31/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import ObjectMapper

enum FriendStatus : Int {
    case None = 0
    case Requesting = 1
    case ReceivingRequest = 2
    case Connected = 3
    case cancelled = 4
    case rejected = 5
}

class FriendshipModel : Mappable {
    public var uid: String?
    public var status: FriendStatus
    public var friendId: String?
    public var friendEmail: String?
    public var friendUserModel: UserModel?
    public var timestamp: Int?
    public required init?(map: Map) {
        self.status = FriendStatus.None
    }
    
    init() {
        self.status = FriendStatus.None
    }
    
    public func mapping(map: Map) {
        uid             <- map["uid"]
        status          <- map["status"]
        friendId        <- map["friendId"]
        friendEmail     <- map["friendEmail"]
        friendUserModel <- map["friendUserModel"]
        timestamp       <- map["timestamp"]
    }
}
