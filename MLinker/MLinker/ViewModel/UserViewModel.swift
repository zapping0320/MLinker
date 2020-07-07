//
//  UserViewModel.swift
//  MLinker
//
//  Created by DONGHYUN KIM on 2020/07/07.
//  Copyright © 2020 John Kim. All rights reserved.
//

import Foundation
import Firebase

class UserViewModel {
    
    var currnetUserUid: String!
    
    public var didNotificationUpdated: (() -> Void)?
    
    var selfUserModel = UserModel()
    var processingUserModels = [UserModel]()
    var friendsUserModels = [UserModel]()
    
    func getNumOfSection(isFiltered: Bool ) -> Int{
        if (isFiltered == true) {
            return 3
        }
        else
        {
            return 3 // 0 - self 1 - requesting 2 - friends
        }
    }
    
    func getNumberOfRowsInSection(section : Int, isFiltered: Bool) -> Int {
        if(isFiltered == true){
            if(section != 0){
                return 0
            }
            return 1
        }
        else
        {
            if section == 0 {
                return 1
            }
            else if section == 1 {
                return self.friendsUserModels.count
            }
            else {
                return self.processingUserModels.count
            }
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
                if processingUserModels.count > 0 {
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
        
    func getCurrentUserData(indexPath: IndexPath, isFiltered:Bool) -> UserModel
    {
        if(isFiltered == true)
        {
//                if(indexPath.row >= self.filteredUsersArray.count)
//                {
//                    return UserModel()
//                }
//                return self.filteredUsersArray[indexPath.row]
            return self.selfUserModel
        }
        else
        {
            if(indexPath.section == 0)
            {
                return self.selfUserModel
            }
            else if(indexPath.section == 1)
            {
                return self.friendsUserModels[indexPath.row]
            }
            else
            {
                return self.processingUserModels[indexPath.row]
            }
        }
    }
    
    
    @objc func loadSelfInfo() { Database.database().reference().child("users").child(self.currnetUserUid).observeSingleEvent(of: DataEventType.value) {
        (datasnapShot) in
        if let userDic = datasnapShot.value as? [String:AnyObject] {
            let userModel = UserModel(JSON: userDic)
//            if userModel?.isAdminAccount == true && self.tabBarController?.viewControllers?.count == 4 {
//                self.tabBarController?.viewControllers?.remove(at: 1)
//            }
             
            if self.selfUserModel.uid != nil && self.selfUserModel.timestamp! >= (userModel?.timestamp!)! {
                    return
                }
            
          //  self.usersArray[0] = [UserModel]()
            UserContexManager.shared.setCurrentUserModel(model: userModel!)
            self.selfUserModel = userModel!
            //self.usersArray[0]!.append(userModel!)
            self.didNotificationUpdated?()
//            DispatchQueue.main.async {
//                self.usersTableView.reloadData()
//            }
        }
    }
    }
    
    func loadUsersInfo() {
        print("loadUsersInfo")
        
        didNotificationUpdated?()
    }
}
