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
        UserContexManager.shared.setCurrentUid(uid: Auth.auth().currentUser?.uid)
        self.loadSelfInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
         NotificationCenter.default.addObserver(self, selector: #selector(moveChatView), name: .nsStartChat, object: nil)
        
        self.loadUsersInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func popupAddFriend(_ sender: Any) {
        let addFriendVC = UIStoryboard(name: "AddFriend", bundle: nil).instantiateViewController(withIdentifier: "addFriend")
        self.present(addFriendVC, animated: true, completion: nil)
    }
    
    func loadSelfInfo() {
        self.usersArray[0] = [UserModel]()
        Database.database().reference().child("users").child(self.currnetUserUid).observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            if let userDic = datasnapShot.value as? [String:AnyObject] {
                let userModel = UserModel(JSON: userDic)
                UserContexManager.shared.setCurrentUserModel(model: userModel!)
                self.usersArray[0]!.append(userModel!)
                DispatchQueue.main.async {
                    self.usersTableView.reloadData()
                }
            }
        }
    }
    
    func loadUsersInfo() {
        //var selfUserList = [UserModel]()
        var processingFriendList = [UserModel]()
        self.processingFriendshipList = [FriendshipModel]()
        self.usersArray[1] = [UserModel]()
        self.usersArray[2] = [UserModel]()
    Database.database().reference().child("friendInformations").child(self.currnetUserUid!).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
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
                        continue
                    }
                    
                    if(friendshipModel?.status == FriendStatus.Connected)
                    {
                        //select friend info
                    Database.database().reference().child("users").child(friendshipModel!.friendId!).observeSingleEvent(of: DataEventType.value) {
                            (datasnapShot) in
                            if let userDic = datasnapShot.value as? [String:AnyObject] {
                                let userModel = UserModel(JSON: userDic)
                                self.usersArray[2]!.append(userModel!)
                                DispatchQueue.main.async {
                                    self.usersTableView.reloadData()
                                }
                            }
                        }
                        
                    }
                    else {
                        self.processingFriendshipList.append(friendshipModel!)
                        let userModel = UserModel()
                        //userModel.uid = item.key
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
    
    @objc func moveChatView(_ notification : Notification) {
        print("UsersVC - moveChatView")
        if let dict = notification.userInfo as NSDictionary? {
            if let chatModel = dict["chatmodel"] as? ChatModel{
                let chatVC = UIStoryboard(name: "ChatView", bundle: nil).instantiateViewController(withIdentifier: "IdChatView") as! ChatViewController
                //chatVC.selectedChatRoomUid = String(indexPath.row)
                chatVC.selectedChatModel = chatModel
                self.navigationController?.pushViewController(chatVC, animated: true)
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
       
        cell.setAdminAccount(value: currentUser.isAdminAccount)
        cell.nameLabel?.text = currentUser.name
        cell.commentLabel?.text = currentUser.comment
        
        if let profileImageString = currentUser.profileURL {
            let profileImageURL = URL(string: profileImageString)
            let processor = DownsamplingImageProcessor(size: CGSize(width: 80, height: 80))
                >> RoundCornerImageProcessor(cornerRadius: 40)
            cell.profileImageView?.kf.indicatorType = .activity
            cell.profileImageView?.kf.setImage(
                with: profileImageURL,
                placeholder: UIImage(named: "defaultPhoto"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
            {
                result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
            
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
    }

}

extension Notification.Name {
    static let nsStartChat = Notification.Name("startChat")
}
