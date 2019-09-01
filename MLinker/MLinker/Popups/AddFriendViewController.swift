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
     
        let friendshipModel = self.getFriendshipModel()
        if(friendshipModel != nil)
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
        }
        else {
            let requestInfo : Dictionary<String, Any> = [
                "ownerUserId" : self.currnetUserUid!
            ]

            Database.database().reference().child("friendships").childByAutoId().setValue(requestInfo) {
                (err, ref) in
                if(err == nil) {
                    //request friendship
//                    let reqeustValue : Dictionary<String, Any> = [
//                        "status" : 1,
//                        "friendId" : "",
//                        "friendEmail" : self.friendEmailTextField.text!,
//                        "timestamp" : ServerValue.timestamp()
//                        
//                    ]
//
//                    Database.database().reference().child("friendships").child(self.currnetUserUid!).child("comments").childByAutoId().setValue(requestInfo) {
//                        (err, ref) in
//                        if(err == nil) {
//                            
//                        }
//                    }
                    
                }
            }

            
        }
    }
    
    func getFriendshipModel() -> FriendshipModel? {
        
        var friendshipModel:FriendshipModel?
        
        Database.database().reference().child("friendships").queryOrdered(byChild: "users/" + self.currnetUserUid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let friendshipDic = item.value as? [String:AnyObject] {
                    friendshipModel = FriendshipModel(JSON: friendshipDic)
                    if(friendshipModel?.friendEmail == self.friendEmailTextField.text)
                    {
                        break
                    }
                }

            }
        }
        
        return friendshipModel
    }
}
