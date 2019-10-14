//
//  ProfileViewController.swift
//  MLinker
//
//  Created by 김동현 on 03/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ProfileViewController: UIViewController {

    @IBOutlet weak var adminAccountLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var subButton: UIButton!
   
    public var selectedUserModel: UserModel = UserModel()
    public var selectedFriendshipModel : FriendshipModel?
    
    private var currnetUserUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.profileImageView.layer.cornerRadius = 75
        //self.profileImageView.clipsToBounds = true
        
        self.currnetUserUid = Auth.auth().currentUser?.uid
        
        mainButton.layer.cornerRadius = mainButton.bounds.size.height / 2
        mainButton.layer.borderWidth = 1
        mainButton.layer.borderColor = UIColor.blue.cgColor
        
        subButton.layer.cornerRadius = subButton.bounds.size.height / 2
        subButton.layer.borderWidth = 1
        subButton.layer.borderColor = UIColor.blue.cgColor
        
        
        adminAccountLabel.isHidden = true
        
        if(selectedFriendshipModel != nil)
        {
            if(selectedFriendshipModel?.status == FriendStatus.Requesting){
                self.mainButton.setTitle("cancel Request", for: .normal)
                self.subButton.isHidden = true
            }else if(selectedFriendshipModel?.status == FriendStatus.ReceivingRequest){
                self.mainButton.setTitle("accept Request", for: .normal)
                self.subButton.setTitle("reject Request", for: .normal)
            }
        }
        else
        {
            if(self.currnetUserUid == self.selectedUserModel.uid)
            {
                //self
                self.mainButton.setTitle("edit Profile", for: .normal)
                self.subButton.isHidden = true
                self.adminAccountLabel.isHidden = !self.selectedUserModel.isAdminAccount
            }
            else
            {
                self.mainButton.setTitle("start Chat", for: .normal)
                if(self.selectedUserModel.isAdminAccount == false)
                {
                    self.subButton.setTitle("disconnect Friendship", for: .normal)
                }
                else
                {
                    self.subButton.isHidden = true
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.commentLabel.text = self.selectedUserModel.comment
        
        if let profileImageString = self.selectedUserModel.profileURL {
            let profileImageURL = URL(string: profileImageString)
            profileImageView.kf.setImage(with: profileImageURL)
        }
    }
    
    @IBAction func closeVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mainButtonAction(_ sender: Any) {
        if(selectedFriendshipModel != nil)
        {
            if(selectedFriendshipModel?.status == FriendStatus.Requesting)
            {
               //cancel
                self.cancelFriendshipRequest()
            }else if(selectedFriendshipModel?.status == FriendStatus.ReceivingRequest)
            {
                //accept
                self.acceptFriendshipRequest()
            }
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            if(self.currnetUserUid == self.selectedUserModel.uid)
            {
                //edit profile
            }else {
                //start chat
                self.findChatRoom()
            }
        }
    }
    
    @IBAction func subButtonAction(_ sender: Any) {
        if(selectedFriendshipModel != nil)
        {
             if(selectedFriendshipModel?.status == FriendStatus.Requesting){
                //reject
            }
        }
        else
        {
            //disconnect friendship
            
            //remove friend uid from each chat
            
        }
    }
    
    func cancelFriendshipRequest() {
        //update self
        let updateSelfValue : Dictionary<String, Any> = [
            "status" : 4,
            "timestamp" : ServerValue.timestamp()
        ]
    Database.database().reference().child("friendInformations").child(self.currnetUserUid!).child("friendshipList").child(self.selectedFriendshipModel!.uid!).updateChildValues(updateSelfValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                let friendUid = self.selectedFriendshipModel!.friendId!
            Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
                    (datasnapShot) in
                    for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                        if let friendshipDic = item.value as? [String:AnyObject] {
                            
                            let friendshipModel = FriendshipModel(JSON: friendshipDic)
                            friendshipModel?.uid = item.key
                            
                            if(friendshipModel?.friendId != self.currnetUserUid!)
                            {
                                continue
                            }
                        Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").child(item.key).removeValue() {
                                (deleteErr, ref) in
                                if(deleteErr == nil) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                        
                    }
                }
            }else {
                print("error update self freindshipmodel")
            }
        }
    }
    
    func acceptFriendshipRequest() {
        //update self
        let updateValue : Dictionary<String, Any> = [
            "status" : 3,
            "timestamp" : ServerValue.timestamp()
        ]
    Database.database().reference().child("friendInformations").child(self.currnetUserUid!).child("friendshipList").child(self.selectedFriendshipModel!.uid!).updateChildValues(updateValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                let friendUid = self.selectedFriendshipModel!.friendId!
            Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
                    (datasnapShot) in
                    for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                        if let friendshipDic = item.value as? [String:AnyObject] {
                            
                            let friendshipModel = FriendshipModel(JSON: friendshipDic)
                            friendshipModel?.uid = item.key
                            
                            if(friendshipModel?.friendId != self.currnetUserUid!)
                            {
                                continue
                            }
                        Database.database().reference().child("friendInformations").child(friendUid).child("friendshipList").child(item.key).updateChildValues(updateValue) {
                                (friendUpdateErr, ref) in
                                if(friendUpdateErr == nil) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                        
                    }
                }
            }else {
                print("error update self freindshipmodel")
            }
        }
    }
    
    func findChatRoom()
    {
        //find same users' chat room
        Database.database().reference().child("chatRooms").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            var foundRoom = false
            var foundRoomInfo = ChatModel()
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    chatModel?.uid = item.key
                    if(chatModel?.chatUserIdDic.count == 2 &&
                      (chatModel?.chatUserIdDic[self.currnetUserUid] != nil) &&
                      chatModel?.chatUserIdDic[self.selectedUserModel.uid!] != nil)
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
        let userIdDic : Dictionary<String, Bool> = [
            self.currnetUserUid : false,
            self.selectedUserModel.uid! : false
        ]
        
        var profileDic : Dictionary<String, String> = [
            self.currnetUserUid : "",
        ]
        if let currentUserProfile = UserContexManager.shared.getCurrentUserModel().profileURL {
            profileDic[self.currnetUserUid] = currentUserProfile
        }
        
        if let selectedUserProfile = self.selectedUserModel.profileURL {
            profileDic.updateValue(selectedUserProfile, forKey: self.selectedUserModel.uid!)
        }
        
        
        let chatRoomName = self.selectedUserModel.name!
        let chatRoomValue : Dictionary<String, Any> = [
            "isIncludeAdminAccount" : self.selectedUserModel.isAdminAccount ? true : false,
            "chatUserIdDic" : userIdDic,
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
