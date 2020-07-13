//
//  AddFriendViewController.swift
//  MLinker
//
//  Created by 김동현 on 29/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase

class AddFriendViewController: UIViewController {

    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var friendEmailTextField: UITextField!
    
    var currnetUserUid: String!
    var currentUserModel : UserModel?
    var friendUserModel: UserModel?
    
    var changedFriendInfo : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyButton.layer.cornerRadius = 4
        
        setApplyButtonEnabled(value: false)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.currnetUserUid = Auth.auth().currentUser?.uid

    }
    
    func setApplyButtonEnabled(value : Bool) {
        if(value){
            applyButton.isEnabled = true
            applyButton.backgroundColor = ColorHelper.getButtonNormalBackgroundColor()
        }
        else
        {
            applyButton.isEnabled = false
            applyButton.backgroundColor = ColorHelper.getButtonDisabledBackgroundColor()
        }
    }

    @IBAction func emailTextChanged(_ sender: Any) {
        if(self.friendEmailTextField.text?.isEmpty == false)
        {
            setApplyButtonEnabled(value: true)
        }
        else
        {
            setApplyButtonEnabled(value: false)
        }
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyFriendShip(_ sender: Any) {
        self.findUserEmail()
    }
    
    func findUserEmail() {
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) {
            (snapshot) in
            var isSelfEmail = false
            var foundFriend = false
            var foundSelf = false
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let dataDic = fchild.value as? NSDictionary
                
                let uid = dataDic?["uid"] as? String ?? ""
                
                if(uid == ""){
                    continue
                }
                
                let email = dataDic?["email"] as? String ?? ""
                if(email.isEmpty){
                    continue
                }
                
                if(uid != self.currnetUserUid && email != self.friendEmailTextField.text!){
                    continue
                }
                
                let userName = dataDic?["name"] as? String ?? ""
                let profileURL = dataDic?["profileURL"] as? String ?? ""
                let userModel = UserModel()
                userModel.uid = uid
                userModel.email = email
                userModel.name = userName
                userModel.profileURL = profileURL
                userModel.comment = dataDic?["comment"] as? String ?? ""
                userModel.pushToken = dataDic?["pushToken"] as? String ?? ""
                
                if(uid == self.currnetUserUid)
                {
                    foundSelf = true
                    self.currentUserModel = userModel
                    if(email == self.friendEmailTextField.text!){
                        isSelfEmail = true
                        break
                    }
                    continue
                }
                
                foundFriend = true
                self.friendUserModel = userModel
                
                if(foundSelf == true && foundFriend == true){
                    break
                }
            }
            if(isSelfEmail == false && foundFriend == true)
            {
                self.getFriendshipModel()
            }
            else {
                var popupMessage:String = NSLocalizedString("This email is yours. Please check email", comment: "")
                if(isSelfEmail == false) {
                    popupMessage = NSLocalizedString("This email isn't registered.Please check email", comment: "")
                }
                
                let alert = UIAlertController(title: NSLocalizedString("FriendShip", comment: ""), message: popupMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action) in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getFriendshipModel(){ Database.database().reference().child("friendInformations").child(self.currnetUserUid!).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            var foundInfo = false
            let trimmedEmail = self.friendEmailTextField.text?.trimmingCharacters(in: .whitespaces)
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let friendshipDic = item.value as? [String:AnyObject] {
                    let friendshipModel = FriendshipModel(JSON: friendshipDic)
                    friendshipModel?.uid = item.key
                    if(friendshipModel?.friendEmail == trimmedEmail)
                    {
                        var popupMessage:String = ""
                        if(friendshipModel?.status == FriendStatus.cancelled){
                            //consider if cancelled friendship can be tried or not
                            self.updateCancelledRequest(friendshipModel: friendshipModel!)
                            return
                        }
                        else {
                            popupMessage = self.makePopupMessage(model: friendshipModel!)
                        }
                        
                        let alert = UIAlertController(title: NSLocalizedString("FriendShip", comment: ""), message: popupMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action) in
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        foundInfo = true
                        break
                    }
                }
            }
            if(foundInfo == false){
                
                let friendUserValue : Dictionary<String, Any> = [
                    "uid": self.friendUserModel!.uid!,
                    "name": self.friendUserModel!.name!,
                    "profileURL": self.friendUserModel!.profileURL!,
                    "email": self.friendUserModel!.email!,
                    "comment": self.friendUserModel!.comment!,
                    "isAdminAccount": self.friendUserModel!.isAdminAccount,
                ]
                
                
                let reqeustValue : Dictionary<String, Any> = [
                    "status" : 1,
                    "friendId" : self.friendUserModel!.uid!,
                    "friendEmail" : trimmedEmail!,
                    "friendUserModel" : friendUserValue,
                    "timestamp" : ServerValue.timestamp()
                    
                ]
                Database.database().reference().child("friendInformations").child(self.currnetUserUid!).child("friendshipList").childByAutoId().setValue(reqeustValue) {
                    (err, ref) in
                    if(err == nil) {
                        self.addFriendshipInfoAtFriend()
                        self.sendGCM()
                    }
                }
            }
        }
    }
    
    func sendGCM() {
       let notificationModel = NotificationModel()
        notificationModel.to = self.friendUserModel?.pushToken
       notificationModel.notification.title = NSLocalizedString("Sender :", comment: "") + (currentUserModel?.name!)!
        notificationModel.notification.body = (self.currentUserModel?.name!)! + NSLocalizedString(" requests a friendship", comment: "")
       
       let params = notificationModel.toJSON()
       PushMessageManager.sendGCM(params: params)
        
    }
    
    
    func makePopupMessage(model : FriendshipModel) -> String {
        var popupMessage = ""
        if(model.status == FriendStatus.Requesting)
        {
            popupMessage = NSLocalizedString("You'd already requested friendship.", comment: "")
        }
        else if(model.status == FriendStatus.ReceivingRequest)
        {
            popupMessage = NSLocalizedString("You'd already received friendship.", comment: "")
        }
        else if(model.status == FriendStatus.Connected)
        {
            popupMessage = NSLocalizedString("You'd already made friendship.", comment: "")
        }
        else if(model.status == FriendStatus.rejected)
        {
            popupMessage = NSLocalizedString("You'd been rejected friendship.", comment: "")
        }
        
        
        return popupMessage
    }
    
    func addFriendshipInfoAtFriend() {
        let userValue : Dictionary<String, Any> = [
            "uid": self.currentUserModel!.uid!,
            "name": self.currentUserModel!.name!,
            "profileURL": self.currentUserModel!.profileURL!,
            "email": self.currentUserModel!.email!,
            "comment": self.currentUserModel!.comment!,
            "isAdminAccount": self.currentUserModel!.isAdminAccount,
        ]
        
        
        let receiveValue : Dictionary<String, Any> = [
            "status" : 2,
            "friendId" : self.currentUserModel!.uid!,
            "friendEmail" : self.currentUserModel!.email!,
            "friendUserModel" : userValue,
            "timestamp" : ServerValue.timestamp()
        ]
        Database.database().reference().child("friendInformations").child(self.friendUserModel!.uid!).child("friendshipList").childByAutoId().setValue(receiveValue) {
            (err, ref) in
            if(err == nil) {
                let alert = UIAlertController(title: NSLocalizedString("FriendShip", comment: ""), message: NSLocalizedString("You have applied for a friend.", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    
                }))
                self.present(alert, animated: true, completion: nil)
                self.friendEmailTextField.text = ""
                self.changedFriendInfo = true
            }
        }
    }
    
    func updateCancelledRequest(friendshipModel : FriendshipModel) {
        let updateSelfValue : Dictionary<String, Any> = [
            "status" : 1,
            "timestamp" : ServerValue.timestamp()
        ]
        
        Database.database().reference().child("friendInformations").child(self.currnetUserUid!).child("friendshipList").child(friendshipModel.uid!).updateChildValues(updateSelfValue) {
            (updateErr, ref) in
            if(updateErr == nil)
            {
                 self.addFriendshipInfoAtFriend()
                
            }else {
                print("update friendship error")
            }
        }
    }
}
