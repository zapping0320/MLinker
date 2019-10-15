//
//  ColorHelper.swift
//  MLinker
//
//  Created by 김동현 on 16/10/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import Foundation
import UIKit

class ColorHelper {
    static let mainAlertTextColor = UIColor(red: 255/255, green: 142/255, blue: 87/255, alpha: 1)
    
    static let cancelTextColor = UIColor.lightGray
    
    
    static let darkModeMainAlertTextColor = UIColor.lightGray
    
    static func getMainAlertTextColor () -> UIColor
    {
        //        let darkMode = false
        //        if(darkMode == true)
        //        {
        //            return darkModeMainAlertTextColor
        //        }
        //        else
        //        {
        return mainAlertTextColor
        //}
    }
    
    static func getCancelTextColor() -> UIColor
    {
        return cancelTextColor
    }
}
