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
    
    var currentUserUid: String!
    
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
            else if section == 2 {
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
            
            if section == 2 {
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
            else if(indexPath.section == 2)
            {
                return self.friendsUserModels[indexPath.row]
            }
            else
            {
                return self.processingUserModels[indexPath.row]
            }
        }
    }
    
    
    @objc func loadSelfInfo()
    {
        Database.database().reference().child("users").child(self.currentUserUid).observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            if let userDic = datasnapShot.value as? [String:AnyObject] {
                let userModel = UserModel(JSON: userDic)
                //            if userModel?.isAdminAccount == true && self.tabBarController?.viewControllers?.count == 4 {
                //                self.tabBarController?.viewControllers?.remove(at: 1)
                //            }
                
                if self.selfUserModel.uid != nil && self.selfUserModel.timestamp! >= (userModel?.timestamp!)! {
                    return
                }
                
                
                UserContexManager.shared.setCurrentUserModel(model: userModel!)
                self.selfUserModel = userModel!
                
                self.didNotificationUpdated?()
                
            }
        }
    }
    
    @objc func loadUsersInfo()
    {
        print("loadUsersInfo")
        var processingFriendList = [UserModel]()
        
        Database.database().reference().child("friendInformations").child(self.currentUserUid).child("friendshipList").observeSingleEvent(of: DataEventType.value)
        {
            (datasnapShot)
            in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let friendshipDic = item.value as? [String:AnyObject] {
                    let friendshipModel = FriendshipModel(JSON: friendshipDic)
                    friendshipModel?.uid = item.key
                    if(friendshipModel == nil){
                        continue
                    }
                    
                    if(friendshipModel?.status == FriendStatus.cancelled ||
                        friendshipModel?.status == FriendStatus.rejected)
                    {
                        let index = self.findUserModel(key: friendshipModel!.friendEmail!)
                        if index != -1 {
                            //self.usersArray[2]!.remove(at: index)
                            //self.usersTableView.reloadData()
                            self.friendsUserModels.remove(at: index)
                            self.didNotificationUpdated?()
                        }
                        continue
                    }
                    
                    if(friendshipModel?.status == FriendStatus.Connected)
                    {
                        //select friend info
                        Database.database().reference().child("users").child(friendshipModel!.friendId!).observeSingleEvent(of: DataEventType.value) {
                            (datasnapShot) in
                            if let userDic = datasnapShot.value as? [String:AnyObject] {
                                let userModel = UserModel(JSON: userDic)
                                
                                guard let email = userModel!.email else {
                                    return
                                }
                                
                                //find same usermodel
                                let index = self.findUserModel(key: email)
                                //check timestamp
                                if index != -1 {
                                    let foundUserModel = self.friendsUserModels[index]
                                    if foundUserModel.timestamp! >= userModel!.timestamp! {
                                        return
                                    }
                                }
                                //DispatchQueue.main.async {
                                    if index == -1 {
                                        //                                                            self.usersArray[2]!.append(userModel!)
                                        //                                                            self.usersTableView.reloadData()
                                        self.friendsUserModels.append(userModel!)
                                    }
                                    else {
                                        //                                                            self.usersArray[2]![index] = userModel!
                                        //                                                            self.usersTableView.rectForRow(at: IndexPath.init(row: index, section: 2))
                                        self.friendsUserModels[index] = userModel!
                                    }
                                    self.didNotificationUpdated?()
                                //}
                            }
                        }
                        
                    }
                    else {
                        let userModel = UserModel()
                        userModel.uid = friendshipModel?.friendId
                        userModel.name = friendshipModel?.friendEmail
                        userModel.profileURL = friendshipModel?.friendUserModel?.profileURL
                        userModel.comment = NSLocalizedString("Processing", comment: "")
                        processingFriendList.append(userModel)
                    }
                }
                
                
            }
            
            
            if self.processingUserModels.count != processingFriendList.count {
                
                //self.usersArray[1] = processingFriendList
                
                self.didNotificationUpdated?()
                
                //                DispatchQueue.main.async {
                //                    self.usersTableView.reloadData()
                //                }
            }
        }
    }
    
    func findUserModel(key : String) -> Int {
//        guard let userModelList = self.usersArray[2] else {
//            return -1
//        }
//
        for (index, userModel) in self.friendsUserModels.enumerated() {
            if userModel.email == key {
                return index
            }
            
        }
        
        return -1
    }
    
    func getFilteredFriendModels(searchText : String) -> [UserModel] {
        return self.friendsUserModels.filter({(element) -> Bool in
            return element.containsText(text: searchText)
        })
    }
}
