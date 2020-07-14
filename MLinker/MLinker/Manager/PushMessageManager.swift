//
//  PushMessageManager.swift
//  MLinker
//
//  Created by 김동현 on 06/02/2020.
//  Copyright © 2020 John Kim. All rights reserved.
//

import Foundation
import Alamofire

class PushMessageManager {
    
    static func sendGCM(params : Parameters) {
        let gcmUrl = "https://fcm.googleapis.com/fcm/send"
        let gcmHeader : HTTPHeaders = [
                   "Content-Type":"application/json",
                   "Authorization": "key=AAAAYORzEGs:APA91bFTd1_Y-gV-lLkbHGEayd5LSiI5hrErPlxERgvo37uMRCAZgYBcVvchK8B7eUomwcSZdXj7n9OqNQ6wZEVVvwVPwK96jV8RQC9I-X6VGotebzqm2fD-Yk9aOPnz3tKZMcEowhQj"
               ]
        Alamofire.request(gcmUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: gcmHeader).responseJSON { (response) in
            guard let data = response.result.value else { return }
            print(data)
            
        }
    }
}
