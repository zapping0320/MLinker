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
    
    public var selectedChatModel:ChatModel = ChatModel()
    
    private var doneBarButton: UIBarButtonItem = UIBarButtonItem()
    
    fileprivate var usersArray: [Int:[UserModel]] = [Int:[UserModel]]()
    var currnetUserUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usersTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")

        currnetUserUid = UserContexManager.shared.getCurrentUid()
        selectedChatModel = UserContexManager.shared.getLastChatRoom()
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setImage(UIImage (named: "close"), for: .normal)
        cancelButton.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        cancelButton.addTarget(self, action: #selector(cancelAddChatRoom),for: UIControl.Event.touchUpInside)
        
        let leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        self.navigationItem.leftBarButtonItems = [leftBarButtonItem]
        
        //self.doneButton.isEnabled = false
        
               
       let doneButton = UIButton(type: .custom)
       doneButton.setImage(UIImage (named: "done"), for: .normal)
       doneButton.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
       doneButton.addTarget(self, action: #selector(doneAddChatRoom),for: UIControl.Event.touchUpInside)
       
       doneBarButton = UIBarButtonItem(customView: doneButton)
       self.navigationItem.rightBarButtonItems = [doneBarButton]
        
        self.loadUsersInfo()
    }
    
    func loadUsersInfo() {
        self.usersArray[0] = [UserModel]()
        self.usersArray[1] = [UserModel]()
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
                        if(self.selectedChatModel.isValid())
                        {
                            let uid = userModel?.uid
                            if(self.selectedChatModel.chatUserIdDic.keys.contains(uid!) == true)
                            {
                                self.usersArray[0]!.append(userModel!)
                            }
                            else
                            {
                                self.usersArray[1]!.append(userModel!)
                            }
                        }
                        else
                        {
                            self.usersArray[0]!.append(userModel!)
                        }
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
    
    @objc func cancelAddChatRoom() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneAddChatRoom() {
        if(self.selectedChatModel.isValid())
        {
            self.addMemberstoChatRoom()
        }
        else
        {
            self.findChatRoom()
        }
    }
    
    func addMemberstoChatRoom()
    {
        guard let indexes = self.usersTableView.indexPathsForSelectedRows else{
            return
        }
        
        //add members
        var membersAdded:[String] = []
        var isIncludeAdmin = self.selectedChatModel.isIncludeAdminAccount
        for indexPath in indexes {
            let selectedUser = self.usersArray[indexPath.section]![indexPath.row] as UserModel
            self.selectedChatModel.chatUserIdDic.updateValue(false, forKey: selectedUser.uid!)
            
            membersAdded.append(selectedUser.name!)
            
            if(selectedUser.isAdminAccount == true)
            {
                isIncludeAdmin = true
            }
        }
        
        let chatRoomValue : Dictionary<String, Any> = [
            "isIncludeAdminAccount" :  isIncludeAdmin,
            "standAlone" : false,
            "chatUserIdDic" : self.selectedChatModel.chatUserIdDic,
            "timestamp" : ServerValue.timestamp()
        ]
        
    Database.database().reference().child("chatRooms").child(self.selectedChatModel.uid).updateChildValues(chatRoomValue) {
            (err, ref) in
            if(err == nil) {
                 //add comment
                self.addCommentAboutAddingMemebers(relatedUsers: membersAdded)
            }
            else {
                
            }
        }
        //move chatview
        
    }
    
    func addCommentAboutAddingMemebers(relatedUsers : [String])
    {
        var commentDic : Dictionary<String, Any> = [
            "sender": self.currnetUserUid!,
            "timestamp" : ServerValue.timestamp()
        ]
        
        let noticeDic : Dictionary<String, Any> = [
            "noticeType" : 1,
            "relatedUsers" : relatedUsers
        ]
        
        commentDic.updateValue(true, forKey: "isNotice")
        commentDic.updateValue(noticeDic, forKey: "notice")
        
        Database.database().reference().child("chatRooms").child(self.selectedChatModel.uid).child("comments").childByAutoId().setValue(commentDic, withCompletionBlock: {
            (err, ref) in
            self.moveChatView(chatModel: self.selectedChatModel)
        })
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
            "standAlone" : false,
            "chatUserIdDic" : selectedUsersDic,
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
        if(self.selectedChatModel.isValid()){
            return 2
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(self.selectedChatModel.isValid())
        {
            if(section == 0)
            {
                return "Current Members"
            }
            else
            {
                return "Add Members"
            }
        }
        else
        {
            return ""
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
        self.doneBarButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard self.usersTableView.indexPathsForSelectedRows != nil else {
            self.doneBarButton.isEnabled = false
            return
        }
        
        self.doneBarButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(self.selectedChatModel.isValid() && indexPath.section == 0){
            return false
        }
        else
        {
            return true
        }
    }

}
