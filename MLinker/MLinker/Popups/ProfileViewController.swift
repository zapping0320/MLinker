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

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var subButton: UIButton!
    
    var currnetUserUid: String!
    public var selectedUserModel: UserModel = UserModel()
    public var selectedFriendshipModel : FriendshipModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currnetUserUid = Auth.auth().currentUser?.uid
        
        mainButton.layer.cornerRadius = mainButton.bounds.size.height / 2
        mainButton.layer.borderWidth = 1
        mainButton.layer.borderColor = UIColor.blue.cgColor
        
        subButton.layer.cornerRadius = subButton.bounds.size.height / 2
        subButton.layer.borderWidth = 1
        subButton.layer.borderColor = UIColor.blue.cgColor
        
        if(selectedFriendshipModel != nil)
        {
            if(selectedFriendshipModel?.status == FriendStatus.Requesting){
                self.mainButton.setTitle("cancel Request", for: .normal)
                self.subButton.isHidden = true
            }else if(selectedFriendshipModel?.status == FriendStatus.Requesting){
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
            }
            else
            {
                self.mainButton.setTitle("start Chat", for: .normal)
                self.subButton.isHidden = true
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
        }
        
    }
}
