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
    @IBOutlet weak var commentEditButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameEditButton: UIButton!
    @IBOutlet weak var emailLabelButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
   
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
   
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    public var selectedUserModel: UserModel = UserModel()
    public var isChatView : Bool = false
    
    private var selectedFriendshipModel : FriendshipModel?
    
    private var currentUserUid: String!
    
    var changedFriendInfo : Bool = false
    
    var isPickedProfileImage: Bool = false
    
    let profileViewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImageView.layer.cornerRadius = 46
        self.profileImageView.clipsToBounds = true
        self.cameraButton.layer.cornerRadius = 16
        
        self.emailLabelButton.layer.borderWidth = 1
        self.emailLabelButton.layer.borderColor = ColorHelper.getGray300Color().cgColor
        self.emailLabelButton.layer.cornerRadius = 12
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickProfileImage)))
        
        self.leftButton.alignImageAndTitleVertically()
        self.leftButton.isHidden = true
        self.rightButton.alignImageAndTitleVertically()
        self.rightButton.isHidden = true
        
        self.adminAccountLabel.isHidden = true
        
        self.setUIEditMode(mode: false)
        
        self.currentUserUid = Auth.auth().currentUser?.uid
        profileViewModel.currentUserUid = Auth.auth().currentUser?.uid
        
        profileViewModel.didNotificationUpdated = { [weak self] in
            self?.updateProfileInfo()
        }
        
        profileViewModel.didFoundChatRoom = { [weak self] (chatModel) in
            self?.moveChatView(chatModel: chatModel)
        }
        
        profileViewModel.needCloseVC = { [weak self] in
            self?.closeProfileVC()
        }
        
        if(self.profileViewModel.isSelfCurrentUser())
        {
            self.updateProfileInfo()
        }
        else
        {
            self.profileViewModel.loadFriendShipInfo()
        }
    }
    
    public func setSelectedUserModel(selectedUserModel : UserModel) {
        profileViewModel.selectedUserModel = selectedUserModel
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
    
    @IBAction func closeVC(_ sender: Any) {
        closeProfileVC()
    }
    
    func updateProfileInfo()
    {
        let selectedUserModel = self.profileViewModel.selectedUserModel
        self.nameLabel.text = selectedUserModel.name
        self.emailLabelButton.setTitle(selectedUserModel.email, for: .normal)
        
        if selectedUserModel.comment?.isEmpty == false {
            self.commentLabel.text = selectedUserModel.comment
        }
        else
        {
            self.commentLabel.text = NSLocalizedString("No comments", comment: "")
        }
        
        if let profileImageString = selectedUserModel.profileURL {
            let profileImageURL = URL(string: profileImageString)
            self.profileImageView.kf.setImage(with: profileImageURL)
        }
        
        if(self.profileViewModel.isSelfCurrentUser())
        {
            if(self.currentUserUid != selectedUserModel.uid) {
                return
            }
            
            //self
            self.editProfileButton.isHidden = false
            self.leftButton.isHidden = false
            self.leftButton.setTitle(NSLocalizedString("ToMe", comment: ""), for: .normal)
            self.leftButton.setImage(UIImage (named: "chat"), for: .normal)
            self.rightButton.isHidden = true
            self.adminAccountLabel.isHidden = !selectedUserModel.isAdminAccount
            
        }
        else
        {
            guard let selectedFriendshipModel = self.profileViewModel.selectedFriendshipModel else { return }
            self.editProfileButton.isHidden = true
            if(selectedFriendshipModel.status == FriendStatus.Connected)
            {
                if self.isChatView == false {
                    self.leftButton.isHidden = false
                    self.leftButton.setTitle(NSLocalizedString("Start Chat", comment: ""), for: .normal)
                    self.leftButton.setImage(UIImage (named: "chat"), for: .normal)
                }
                else {
                    self.leftButton.isHidden = true
                }
                
                if(selectedUserModel.isAdminAccount == false &&
                    UserContexManager.shared.getCurrentUserModel().isAdminAccount == false)
                {
                    self.rightButton.isHidden = false
                    self.rightButton.setTitle(NSLocalizedString("Disconnect Friendship", comment: ""), for: .normal)
                    self.rightButton.setImage(UIImage (named: "cancelRequest"), for: .normal)
                }
                else
                {
                    self.rightButton.isHidden = true
                }
            }
            else
            {
                self.emailLabelButton.setTitle(self.selectedFriendshipModel?.friendEmail, for: .normal)
                if(selectedFriendshipModel.status == FriendStatus.Requesting){
                    self.leftButton.isHidden = false
                    self.leftButton.setTitle(NSLocalizedString("Cancel Request", comment: ""), for: .normal)
                    self.leftButton.setImage(UIImage (named: "cancelRequest"), for: .normal)
                    self.rightButton.isHidden = true
                }else if(selectedFriendshipModel.status == FriendStatus.ReceivingRequest){
                    self.leftButton.isHidden = false
                    self.leftButton.setTitle(NSLocalizedString("Accept Request", comment: ""), for: .normal)
                    self.leftButton.setImage(UIImage (named: "acceptRequest"), for: .normal)
                    self.rightButton.isHidden = false
                    self.rightButton.setTitle(NSLocalizedString("Reject Request", comment: ""), for: .normal)
                    self.rightButton.setImage(UIImage (named: "rejectRequest"), for: .normal)
                }
                else
                {
                    self.leftButton.isHidden = true
                    self.rightButton.isHidden = true
                }
            }
        }
        
    }
    
    func closeProfileVC()
    {
        if(self.changedFriendInfo == true)
        {
            self.profileViewModel.updateSelfUserModel()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func leftButtonAction(_ sender: Any) {
        if(self.profileViewModel.isSelfCurrentUser())
        {
            self.profileViewModel.findChatRoom(isStandAlone: true)
        }
        else
        {
            self.changedFriendInfo = true
            guard let selectedFriendshipModel = self.profileViewModel.selectedFriendshipModel else { return }
            
            if(selectedFriendshipModel.status == FriendStatus.Requesting)
            {
               //cancel
                self.profileViewModel.cancelFriendshipRequest()
            }
            else if(selectedFriendshipModel.status == FriendStatus.ReceivingRequest)
            {
                //accept
                self.profileViewModel.acceptFriendshipRequest()
            }
            else if(selectedFriendshipModel.status == FriendStatus.Connected)
            {
                //start chat
                self.profileViewModel.findChatRoom(isStandAlone: false)
            }
        }
        
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        guard let selectedFriendshipModel = self.profileViewModel.selectedFriendshipModel else { return }
        
        if(selectedFriendshipModel.status == FriendStatus.ReceivingRequest)
        {
            //reject
            self.rejectFriendshipRequest()
            
        }
        else if(selectedFriendshipModel.status == FriendStatus.Connected)
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
    
    func moveChatView(chatModel : ChatModel)
    {
        let chatModelDic = ["chatmodel" : chatModel]
        
        self.closeProfileVC()
        
        NotificationCenter.default.post(name: .nsStartChat, object: nil, userInfo: chatModelDic)
    }
    
    func rejectFriendship(includeChat : Bool)
    {
        self.changedFriendInfo = true
        //update self
            let updateSelfValue : Dictionary<String, Any> = [
                "status" : 5,
                "timestamp" : ServerValue.timestamp()
            ]
        Database.database().reference().child("friendInformations").child(self.currentUserUid!).child("friendshipList").child(self.selectedFriendshipModel!.uid!).updateChildValues(updateSelfValue) {
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
                                
                                if(friendshipModel?.friendId != self.currentUserUid!)
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
    
    @IBAction func enterEditModeAction(_ sender: Any) {
        self.enterEditMode()
    }
    
    func enterEditMode() {
        self.setUIEditMode(mode: true)
        self.nameTextField.text = self.selectedUserModel.name
        self.commetTextField.text = self.selectedUserModel.comment
        
    }
    
    func setUIEditMode(mode : Bool) {
        self.closeButton.isHidden = mode
        self.editProfileButton.isHidden = mode
        
        self.cancelButton.isHidden = !mode
        self.saveButton.isHidden = !mode
        
        self.commentLabel.isHidden = mode
        self.commetTextField.isHidden = !mode
        self.commentEditButton.isHidden = !mode

        self.nameLabel.isHidden = mode
        self.nameTextField.isHidden = !mode
        self.nameEditButton.isHidden = !mode
        
        self.profileImageView.isUserInteractionEnabled = mode
        self.cameraButton.isHidden = !mode
        
        self.leftButton.isHidden = mode
        self.rightButton.isHidden = mode
        
    }
    
    @IBAction func pickProfileAction(_ sender: Any) {
        self.pickImage()
    }
    
    @objc func pickProfileImage() {
        self.pickImage()
    }
    
    func pickImage() {
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
                self.changedFriendInfo = true
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
        
        guard let image = self.profileImageView.image?.jpegData(compressionQuality: 0.1) else { return }
        
        self.profileViewModel.updateProfileImageUrl(image: image)

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
                        
                        let updateChatRoomValue : Dictionary<String, Any> = [
                            "chatUserIdDic" : chatModel!.chatUserIdDic,
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

extension UIButton {
  func alignImageAndTitleVertically(padding: CGFloat = 4.0) {
        let imageSize = imageView!.frame.size
        let titleSize = titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding

        imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )

        titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
}
