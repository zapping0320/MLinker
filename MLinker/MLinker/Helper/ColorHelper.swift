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
    
    static let buttonNormalBackgroundColor = UIColor(red: 0/255, green: 118/255, blue: 206/255, alpha: 1)
    
    static let buttonDisabledBackgroundColor = UIColor(red: 217/255, green: 218/255, blue: 221/255, alpha: 1)
    
    
    static let darkModeMainAlertTextColor = UIColor.lightGray
    
    static func getMainAlertTextColor () -> UIColor
    {
        return mainAlertTextColor
    }
    
    static func getCancelTextColor() -> UIColor
    {
        return cancelTextColor
    }
    
    static func getButtonNormalBackgroundColor () -> UIColor
    {
        return buttonNormalBackgroundColor
    }
    
    static func getButtonDisabledBackgroundColor() -> UIColor
    {
        return buttonDisabledBackgroundColor
    }
}
