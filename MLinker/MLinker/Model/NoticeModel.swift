//
//  NoticeModel.swift
//  MLinker
//
//  Created by 김동현 on 22/10/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import ObjectMapper

public enum NoticeType : Int {
    case None = 0
    case EnterMember = 1
    case ExitMember = 2
}

public class Notice : Mappable {
    public var noticeType : NoticeType
    public var relatedUsers : [String] = []
    
    init() {
        self.noticeType = NoticeType.None
    }
    
    public required init?(map: Map) {
        self.noticeType = NoticeType.None
    }
    
    public func mapping(map: Map) {
        noticeType    <- map["noticeType"]
        relatedUsers  <- map["relatedUsers"]
    }
}
