//
//  NoticeStringHelper.swift
//  MLinker
//
//  Created by 김동현 on 22/10/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import Foundation

class NoticeStringHelper {
    static func makeNoticeString(notice : Notice) -> String
    {
        var resultString = ""
        switch notice.noticeType {
        case NoticeType.EnterMember:
            resultString = "entered newly"
            var members = ""
            if(notice.relatedUsers.count > 0)
            {
                for user in notice.relatedUsers {
                    if(members.isEmpty == false)
                    {
                        members = members + ", "
                    }
                    members = members + user
                }
            }
            resultString = members + resultString
            break
        case NoticeType.ExitMember:
            resultString = " exited"
            var members = ""
            if(notice.relatedUsers.count > 0)
            {
                for user in notice.relatedUsers {
                    if(members.isEmpty == false)
                    {
                        members = members + ", "
                    }
                    members = members + user
                }
            }
            resultString = members + resultString
            break
        default:
            resultString = "not defined"
        }
        
        return resultString
        
    }

}
