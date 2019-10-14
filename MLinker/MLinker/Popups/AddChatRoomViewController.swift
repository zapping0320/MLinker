//
//  AddChatRoomViewController.swift
//  MLinker
//
//  Created by 김동현 on 14/10/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class AddChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var usersTableView: UITableView!{
        didSet {
            self.usersTableView.delegate = self
            self.usersTableView.dataSource = self
            self.usersTableView.allowsMultipleSelectionDuringEditing = true
            self.usersTableView.setEditing(true, animated: false)
        }
    }
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    fileprivate var usersArray: [Int:[UserModel]] = [Int:[UserModel]]()
    var currnetUserUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usersTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")

        currnetUserUid = UserContexManager.shared.getCurrentUid()
        
        self.doneButton.isEnabled = false
        
        self.loadUsersInfo()
    }
    
    func loadUsersInfo() {
        self.usersArray[0] = [UserModel]()
        Database.database().reference().child("friendInformations").child(self.currnetUserUid!).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let friendshipDic = item.value as? [String:AnyObject] {
                    
                    let friendshipModel = FriendshipModel(JSON: friendshipDic)
                    friendshipModel?.uid = item.key
                    if(friendshipModel == nil){
                        continue
                    }
                    
                    if(friendshipModel?.status != FriendStatus.Connected)
                    {
                        continue
                    }
                Database.database().reference().child("users").child(friendshipModel!.friendId!).observeSingleEvent(of: DataEventType.value) {
                        (datasnapShot) in
                        if let userDic = datasnapShot.value as? [String:AnyObject] {
                            let userModel = UserModel(JSON: userDic)
                            self.usersArray[0]!.append(userModel!)
                            DispatchQueue.main.async {
                                self.usersTableView.reloadData()
                            }
                        }
                    }
                    
                }
            }
            
            DispatchQueue.main.async {
                self.usersTableView.reloadData()
            }
        }
    }
    
    @IBAction func cancelAddChatRoom(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAddChatRoom(_ sender: Any) {
        self.findChatRoom()
    }
    
    func findChatRoom()
    {
        guard let indexes = self.usersTableView.indexPathsForSelectedRows else{
             return
         }
        
         var selectedUsersDic : Dictionary<String, Bool> = [
             self.currnetUserUid : false,
         ]
         
         for indexPath in indexes {
             let selectedUser = self.usersArray[indexPath.section]![indexPath.row] as UserModel
             selectedUsersDic.updateValue(false, forKey: selectedUser.uid!)
         }
         
         Database.database().reference().child("chatRooms").observeSingleEvent(of: DataEventType.value) {
             (datasnapShot) in
             var foundRoom = false
             var foundRoomInfo = ChatModel()
             for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                 if let chatRoomdic = item.value as? [String:AnyObject] {
                     let chatModel = ChatModel(JSON: chatRoomdic)
                     chatModel?.uid = item.key
                     if(chatModel?.chatUserIdDic == selectedUsersDic)
                     {
                         foundRoom = true
                         foundRoomInfo = chatModel!
                         break
                     }
                     
                 }
             }
             
             if(foundRoom == true)
             {
                 //if true > move chatview
                 self.moveChatView(chatModel: foundRoomInfo)
             }
             else
             {
                 //else make chatroom and move chat view
                 self.createChatRoom()
             }
             
         }
    }
    
    func createChatRoom()
    {
        guard let indexes = self.usersTableView.indexPathsForSelectedRows else{
            return
        }
        
        var selectedUsersDic : Dictionary<String, Bool> = [
            self.currnetUserUid : false,
        ]
        
        var profileDic : Dictionary<String, String> = [
            self.currnetUserUid : "",
        ]
        
        if let currentUserProfile = UserContexManager.shared.getCurrentUserModel().profileURL {
                   profileDic[self.currnetUserUid] = currentUserProfile
               }
        
        var isIncludeAdmin = UserContexManager.shared.getCurrentUserModel().isAdminAccount
        var chatRoomName = UserContexManager.shared.getCurrentUserModel().name!
        
        for indexPath in indexes {
            let selectedUser = self.usersArray[indexPath.section]![indexPath.row] as UserModel
            selectedUsersDic.updateValue(false, forKey: selectedUser.uid!)
            isIncludeAdmin = isIncludeAdmin && selectedUser.isAdminAccount
            chatRoomName += ","
            chatRoomName += selectedUser.name!
            if let selectedUserProfile = selectedUser.profileURL {
                profileDic.updateValue(selectedUserProfile, forKey: selectedUser.uid!)
            }
        }
        
        
        
        let chatRoomValue : Dictionary<String, Any> = [
            "isIncludeAdminAccount" :  isIncludeAdmin ? true : false,
            "chatUserIdDic" : selectedUsersDic,
            "chatUserProfiles" : profileDic,
            "name" : chatRoomName,
            "timestamp" : ServerValue.timestamp()
        ]
        
    Database.database().reference().child("chatRooms").childByAutoId().setValue(chatRoomValue) {
            (err, ref) in
            if(err == nil) {
                self.findChatRoom()
            }
            else {
                
            }
        }
    }
    
    func moveChatView(chatModel : ChatModel)
    {
        let chatModelDic = ["chatmodel" : chatModel]
        
        NotificationCenter.default.post(name: .nsStartChat, object: nil, userInfo: chatModelDic)
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddChatRoomViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        self.doneButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard self.usersTableView.indexPathsForSelectedRows != nil else {
            self.doneButton.isEnabled = false
            return
        }
        
        self.doneButton.isEnabled = true
    }

}
