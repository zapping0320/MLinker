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
    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var subButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    
    public var selectedUserModel: UserModel = UserModel()
    private var selectedFriendshipModel : FriendshipModel?
    
    private var currnetUserUid: String!
    
    var changedFriendInfo : Bool = false
    
    var isPickedProfileImage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.profileImageView.layer.cornerRadius = 75
        //self.profileImageView.clipsToBounds = true
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickProfileImage)))
        
        self.currnetUserUid = Auth.auth().currentUser?.uid
        
        adminAccountLabel.isHidden = true
        
        self.setUIEditMode(mode: false)
        if(self.selectedUserModel.uid == UserContexManager.shared.getCurrentUid())
        {
            self.updateProfileInfo()
        }
        else
        {
            self.loadFriendShipInfo()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
    
    @IBAction func closeVC(_ sender: Any) {
        closeProfileVC()
    }
    
    func loadFriendShipInfo()
    { Database.database().reference().child("friendInformations").child(self.currnetUserUid!).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let friendshipDic = item.value as? [String:AnyObject] {
                    let friendshipModel = FriendshipModel(JSON: friendshipDic)
                    friendshipModel?.uid = item.key
                    if(friendshipModel?.friendId == self.selectedUserModel.uid)
                    {
                        self.selectedFriendshipModel = friendshipModel
                        break
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.updateProfileInfo()
            }
        }
    }
    
    func updateProfileInfo()
    {
        self.titleNameLabel.text = self.selectedUserModel.name
        self.nameLabel.text = self.selectedUserModel.name
        self.emailLabel.text = self.selectedUserModel.email
        
        if self.selectedUserModel.comment?.isEmpty == false {
            self.commentLabel.text = self.selectedUserModel.comment
        }
        else
        {
            self.commentLabel.text = "No comments"
        }
        
        if(selectedFriendshipModel != nil)
        {
            if(selectedFriendshipModel?.status == FriendStatus.Requesting){
                self.mainButton.setTitle("cancel Request", for: .normal)
                self.subButton.isHidden = true
            }else if(selectedFriendshipModel?.status == FriendStatus.ReceivingRequest){
                self.mainButton.setTitle("accept Request", for: .normal)
                self.subButton.setTitle("reject Request", for: .normal)
            }
            else if(selectedFriendshipModel?.status == FriendStatus.Connected)
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
            else
            {
                self.mainButton.isHidden = true
                self.subButton.isHidden = true
            }
        }
        else
        {
            if let profileImageString = self.selectedUserModel.profileURL {
                let profileImageURL = URL(string: profileImageString)
                self.profileImageView.kf.setImage(with: profileImageURL)
            }
            
            if(self.currnetUserUid == self.selectedUserModel.uid)
            {
                //self
                self.mainButton.setTitle("edit Profile", for: .normal)
                self.subButton.isHidden = true
                self.adminAccountLabel.isHidden = !self.selectedUserModel.isAdminAccount
            }
            
        }
    }
    
    func closeProfileVC()
    {
        if(self.changedFriendInfo == true)
        {
            if(self.selectedUserModel.uid == UserContexManager.shared.getCurrentUid())
            {
                UserContexManager.shared.setCurrentUserModel(model:  self.selectedUserModel)
            }
            
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
            }
            else if(selectedFriendshipModel?.status == FriendStatus.ReceivingRequest)
            {
                //accept
                self.acceptFriendshipRequest()
            }
            else if(selectedFriendshipModel?.status == FriendStatus.Connected)
            {
                //start chat
                self.findChatRoom()
            }
        }
        else
        {
            if(self.currnetUserUid == self.selectedUserModel.uid)
            {
                //edit profile
                self.enterEditMode()
            }
        }
    }
    
    @IBAction func subButtonAction(_ sender: Any) {
        if(selectedFriendshipModel == nil)
        {
            return
        }
        
        if(selectedFriendshipModel?.status == FriendStatus.ReceivingRequest){
            //reject
            self.rejectFriendshipRequest()
            
        }
        else if(selectedFriendshipModel?.status == FriendStatus.Connected)
        {
            
            let alert = UIAlertController(title: title,
                                          message: NSLocalizedString("Friendship", comment: ""),
                                          preferredStyle: .alert)
            let actionCheck = UIAlertAction(title: NSLocalizedString("Are you sure to disconnect friendship?", comment: ""),
                                            style: .default, handler: {result in
                                                //disconnect friendship
                                                self.disconnectFriendship()
            })
            alert.addAction(actionCheck)
            
            let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                             style: .cancel, handler: nil)
            
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true, completion: nil)
            
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
    
    func rejectFriendship(includeChat : Bool)
    {
        self.changedFriendInfo = true
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
                                        if(includeChat == true)
                                        {
                                            self.removeFriendInfoFromChatRooms(selfUid: self.selectedFriendshipModel!.uid!, friendUid: friendUid)
                                        }
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
    
    func rejectFriendshipRequest() {
        self.rejectFriendship(includeChat: false)
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
             NotificationCenter.default.post(name: .nsUpdateSelf, object: nil, userInfo: nil)
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
                         NotificationCenter.default.post(name: .nsUpdateSelf, object: nil, userInfo: nil)
                    }
                }
                
            }
        })
    }
    
    func disconnectFriendship()
    {
        self.rejectFriendship(includeChat: true)
    }
    
    func removeFriendInfoFromChatRooms(selfUid: String, friendUid : String)
    {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "timestamp").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    chatModel?.uid = item.key
                    if(((chatModel?.chatUserIdDic.keys.contains(selfUid)) == true) && (chatModel?.chatUserIdDic.keys.contains(friendUid) == true))
                    {
                        chatModel?.chatUserIdDic.removeValue(forKey: friendUid)
                        if(chatModel?.chatUserProfiles.keys.contains(friendUid) == true)
                        {
                            chatModel?.chatUserProfiles.removeValue(forKey: friendUid)
                        }
                        
                        let updateChatRoomValue : Dictionary<String, Any> = [
                            "chatUserIdDic" : chatModel?.chatUserIdDic,
                            "chatUserProfiles" :  chatModel?.chatUserProfiles,
                            "timestamp" : ServerValue.timestamp()
                        ]
                        
                        datasnapShot.ref.updateChildValues(updateChatRoomValue, withCompletionBlock: { (err, ref) in
                                if(err == nil)
                                {
                                    print("chat room update success")
                            }
                            else
                                {
                                    print("error update self freindshipmodel")
                            }
                            
                        })
                    }
                }
            }
        }
    }
    
}
