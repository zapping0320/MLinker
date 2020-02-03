//
//  NotificationModel.swift
//  MLinker
//
//  Created by 김동현 on 02/02/2020.
//  Copyright © 2020 John Kim. All rights reserved.
//

import ObjectMapper

class NotificationModel : Mappable {
    
    public var to:String?
    public var notification : Notification = Notification()
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        to <- map["to"]
        notification <- map["notification"]
    }
    
    class Notification : Mappable {
        public var title : String?
        public var body : String?
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            body <- map["body"]
        }
    }
    
}
