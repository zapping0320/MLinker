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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyButton.layer.cornerRadius = applyButton.bounds.size.height / 2
        applyButton.layer.borderWidth = 1
        applyButton.layer.borderColor = UIColor.blue.cgColor
        
        setApplyButtonEnabled(value: false)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.currnetUserUid = Auth.auth().currentUser?.uid

    }
    
    func setApplyButtonEnabled(value : Bool) {
        if(value){
            applyButton.isEnabled = true
            applyButton.layer.borderColor = UIColor.blue.cgColor
            applyButton.setTitleColor(.white, for: .normal)
        }
        else
        {
            applyButton.isEnabled = false
            applyButton.layer.borderColor = UIColor.gray.cgColor
            applyButton.setTitleColor(.gray, for: .normal)
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
                let key =   fchild.key
                let value = fchild.value
                print("key = \(key)  value = \(value!)")
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
                //userModel.setValuesForKeys(fchild.value as! [String: Any])
                let userModel = UserModel()
                userModel.uid = uid
                userModel.email = email
                userModel.name = userName
                userModel.profileURL = profileURL
                userModel.comment = dataDic?["comment"] as? String ?? ""
                
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
                var popupMessage:String = "This email is yours. Please check email"
                if(isSelfEmail == false) {
                    popupMessage = "This email isn't registered.Please check email"
                }
                
                let alert = UIAlertController(title: "FriendShip", message: popupMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    
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
                    if(friendshipModel?.friendEmail == trimmedEmail)
                    {
                        var popupMessage:String = ""
                        if(friendshipModel?.status == FriendStatus.Requesting)
                        {
                            popupMessage = "You'd already requested friendship."
                        }
                        else if(friendshipModel?.status == FriendStatus.ReceivingRequest)
                        {
                            popupMessage = "You'd already received friendship."
                        }
                        else if(friendshipModel?.status == FriendStatus.Connected)
                        {
                            popupMessage = "You'd already made friendship."
                        }
                        
                        let alert = UIAlertController(title: "FriendShip", message: popupMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            
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
                        let alert = UIAlertController(title: "FriendShip", message: "You have applied for a friend.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        self.friendEmailTextField.text = ""
                        }
                        }
                    }
                }
            }
        }
    }
}
