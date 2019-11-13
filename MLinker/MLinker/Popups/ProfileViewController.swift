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

class ProfileViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var adminAccountLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commetTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var subButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    public var selectedUserModel: UserModel = UserModel()
    public var selectedFriendshipModel : FriendshipModel?
    
    private var currnetUserUid: String!
    
    var changedFriendInfo : Bool = false
    
    var isPickedProfileImage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.profileImageView.layer.cornerRadius = 75
        //self.profileImageView.clipsToBounds = true
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickProfileImage)))
        
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
        self.setUIEditMode(mode: false)
        
        self.nameLabel.text = self.selectedUserModel.name
        self.commentLabel.text = self.selectedUserModel.comment
        
        if let profileImageString = self.selectedUserModel.profileURL {
            let profileImageURL = URL(string: profileImageString)
            profileImageView.kf.setImage(with: profileImageURL)
        }
    }
    
    @IBAction func closeVC(_ sender: Any) {
        closeProfileVC()
    }
    
    func closeProfileVC()
    {
        if(self.changedFriendInfo == true)
        {
             NotificationCenter.default.post(name: .nsUpdateUsersTable, object: nil, userInfo: nil)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mainButtonAction(_ sender: Any) {
        if(selectedFriendshipModel != nil)
        {
            self.changedFriendInfo = true
            if(selectedFriendshipModel?.status == FriendStatus.Requesting)
            {
               //cancel
                self.cancelFriendshipRequest()
            }else if(selectedFriendshipModel?.status == FriendStatus.ReceivingRequest)
            {
                //accept
                self.acceptFriendshipRequest()
            }
        }
        else
        {
            if(self.currnetUserUid == self.selectedUserModel.uid)
            {
                //edit profile
                self.enterEditMode()
            }else {
                //start chat
                self.findChatRoom()
            }
        }
    }
    
    @IBAction func subButtonAction(_ sender: Any) {
        if(selectedFriendshipModel != nil)
        {
             if(selectedFriendshipModel?.status == FriendStatus.ReceivingRequest){
                //reject
                self.rejectFriendshipRequest()
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
                                    
                                }
                            }
                        }
                        
                    }
                }
            }else {
                print("error update self freindshipmodel")
            }
            self.closeProfileVC()
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
                                    self.closeProfileVC()
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
        self.closeProfileVC()
    }
    
    func rejectFriendshipRequest() {
        //update self
        let updateSelfValue : Dictionary<String, Any> = [
            "status" : 5,
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
                                   
                                }
                            }
                        }
                        
                    }
                }
            }else {
                print("error update self freindshipmodel")
            }
           self.closeProfileVC()
        }
    }
    
    func enterEditMode() {
        self.setUIEditMode(mode: true)
        self.nameTextField.text = self.selectedUserModel.name
        self.commetTextField.text = self.selectedUserModel.comment
        
    }
    
    func setUIEditMode(mode : Bool) {
        self.closeButton.isHidden = mode
        self.commentLabel.isHidden = mode
        self.commetTextField.isHidden = !mode
        self.nameLabel.isHidden = mode
        self.nameTextField.isHidden = !mode
        
        self.profileImageView.isUserInteractionEnabled = mode
        
        self.mainButton.isHidden = mode
        self.cancelButton.isHidden = !mode
        self.saveButton.isHidden = !mode
    }
    
    @objc func pickProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion:  nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.isPickedProfileImage = true
        profileImageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelProfileEdit(_ sender: Any) {
        self.setUIEditMode(mode: false)
    }
    
    @IBAction func saveProfileChangedInfo(_ sender: Any) {
        self.setUIEditMode(mode: false)
        
        let updateInfoValue : Dictionary<String, Any> = [
            "name": self.nameTextField.text!,
            "comment" : self.commetTextField.text!,
            "timestamp" : ServerValue.timestamp()
        ]
        
    Database.database().reference().child("users").child(self.selectedUserModel.uid!).updateChildValues(updateInfoValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                self.selectedUserModel.name = self.nameTextField.text!
                self.nameLabel.text = self.nameTextField.text!
                self.selectedUserModel.comment = self.commetTextField.text!
                self.commentLabel.text = self.commetTextField.text!
                self.updateProfileImage()
                
            }else {
                print("update userinfo error")
            }
            
            
        }
    }
        
    func updateProfileImage() {
        if(self.isPickedProfileImage == false)
        {
            return
        }
        
        let image = self.profileImageView.image?.jpegData(compressionQuality: 0.1)
        
        let storageRef = Storage.storage().reference()
        
        var userDownloadURL:String?
        
        storageRef.child("profileImages").child(self.selectedUserModel.uid!).putData(image!, metadata: nil, completion: { (metadata, error) in
            
            guard let _ = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            storageRef.child("profileImages").child(self.selectedUserModel.uid!).downloadURL{ (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                userDownloadURL = downloadURL.absoluteString
                Database.database().reference().child("users").child(self.selectedUserModel.uid!).updateChildValues(["profileURL": userDownloadURL!] ) {
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("profileURL could not be saved: \(error).")
                    } else {
                        print("profileURL saved successfully!")
                        self.selectedUserModel.profileURL = userDownloadURL
                    }
                }
                
            }
        })
    }
    
}
