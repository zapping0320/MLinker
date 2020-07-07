//
//  UserViewModel.swift
//  MLinker
//
//  Created by DONGHYUN KIM on 2020/07/07.
//  Copyright © 2020 John Kim. All rights reserved.
//

import Foundation

class UserViewModel {
    
    fileprivate var usersArray: [Int:[UserModel]] = [Int:[UserModel]]()
    
    func getNumOfSection(isFiltered: Bool ) -> Int{
        if (isFiltered == true) {
            return 3
        }
        else
        {
            return 3 // 0 - self 1 - requesting 2 - friends
        }
    }
    
    func getTableHeaderString(section :Int, isFiltered: Bool) -> String {
        if (isFiltered == true) {
            if(section != 0){
                return ""
            }
            if  UserContexManager.shared.isAdminUser() {
                return NSLocalizedString("Customers", comment: "")
            }
            else {
                return NSLocalizedString("Friends", comment: "")
            }
        }
        else {
            if section == 0 {
                return ""
            }
            
            if section == 1 {
                guard let dataList = usersArray[section] else {
                    return ""
                }
                if dataList.count > 0 {
                    return NSLocalizedString("Current processing", comment: "")
                }
                else {
                    return ""
                }
            }
            else {
                if  UserContexManager.shared.isAdminUser() {
                    return NSLocalizedString("Customers", comment: "")
                }
                else {
                    return NSLocalizedString("Friends", comment: "")
                }
            }
        }
    }
}
