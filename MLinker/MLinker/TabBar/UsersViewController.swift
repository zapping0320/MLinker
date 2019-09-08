//
//  UsersViewController.swift
//  MLinker
//
//  Created by 김동현 on 13/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var usersTableView: UITableView!
    
    fileprivate var usersArray: [Int:[UserModel]] = [Int:[UserModel]]()
    var processingFriendshipList : [FriendshipModel] = [FriendshipModel]()
    var currnetUserUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.usersTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
         self.currnetUserUid = Auth.auth().currentUser?.uid
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadUsesInfo()
        
//        let userModel = UserModel()
//        userModel.uid = "123"
//        userModel.name = "kkk"
//        userModel.comment = "comment"
//        self.userArray.append(userModel)
//
//        let userModel2 = UserModel()
//        userModel2.uid = "123"
//        userModel2.name = "gggg"
//        userModel2.comment = "commentary"
//        self.userArray.append(userModel2)
//
//        DispatchQueue.main.async {
//            self.usersTableView.reloadData()
//        }
        
    }
    
    @IBAction func popupAddFriend(_ sender: Any) {
        let addFriendVC = UIStoryboard(name: "AddFriend", bundle: nil).instantiateViewController(withIdentifier: "addFriend")
        self.present(addFriendVC, animated: true, completion: nil)
    }
    
    func loadUsesInfo() {
        self.usersArray = [Int:[UserModel]]()
        
        var processingFriendList = [UserModel]()
        self.processingFriendshipList = [FriendshipModel]()
    Database.database().reference().child("friendInformations").child(self.currnetUserUid!).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let friendshipDic = item.value as? [String:AnyObject] {
                    let friendshipModel = FriendshipModel(JSON: friendshipDic)
                    if(friendshipModel == nil){
                        continue
                    }
                    
                    if(friendshipModel?.status == FriendStatus.Connected)
                    {
                        //select friend info
                    }
                    else {
                        self.processingFriendshipList.append(friendshipModel!)
                        let userModel = UserModel()
                        userModel.uid = item.key
                        userModel.name = friendshipModel?.friendEmail
                        userModel.profileURL = friendshipModel?.friendUserModel?.profileURL
                        userModel.comment = "processing"
                        processingFriendList.append(userModel)
                    }
                }
            }
        
            self.usersArray[1] = processingFriendList
        
            DispatchQueue.main.async {
                self.usersTableView.reloadData()
            }
        }
        
    }
}


extension UsersViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // 0 - self 1 - requesting 2 - friends
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }
        
        if section == 1 {
            return "Current processing"
        }
        else {
            return "Friends"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataList = usersArray[section] else {
            return 0
        }
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        let currentUser = self.usersArray[indexPath.section]![indexPath.row] as UserModel
        
        cell.nameLabel?.text = currentUser.name
        cell.commentLabel?.text = currentUser.comment
        
        if let profileImageString = currentUser.profileURL {
            let profileImageURL = URL(string: profileImageString)
            cell.imageView?.kf.setImage(with: profileImageURL)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select \(indexPath)")
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "profileNavi") as! ProfileViewController
        
        profileVC.selectedUserModel = self.usersArray[indexPath.section]![indexPath.row] as UserModel
        if(indexPath.section == 1) {
            profileVC.selectedFriendshipModel = self.processingFriendshipList[indexPath.row]
        }
        
        self.present(profileVC, animated: true, completion: nil)
        
        //need cell update or table update?
        
    }

}
