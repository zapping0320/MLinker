//
//  SignUpViewController.swift
//  SignIn
//
//  Created by 김동현 on 09/07/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var permissionCodeTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var isPickedProfileImage: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImageView.layer.cornerRadius = 41
        self.profileImageView.clipsToBounds = true
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickProfileImageFromImageView)))
        
        self.cameraButton.layer.cornerRadius = 16

        setSignUpButtonEnabled(value: false)
     
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
    
    @IBAction func pickImageFromButton(_ sender: Any) {
        self.pickImage()
    }
    
    @objc func pickProfileImageFromImageView() {
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
    
    @IBAction func cancel(_ sender: Any) {
        popVC()
    }
    
    func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func signUpInfoChanged(_ sender: Any) {
        if(emailTextField.text?.isEmpty == true ||
            passwordTextField.text?.isEmpty == true ||
            confirmPasswordTextField.text?.isEmpty == true ||
            userNameTextField.text?.isEmpty == true)
        {
            setSignUpButtonEnabled(value: false)
        }
        else
        {
            setSignUpButtonEnabled(value: true)
        }
    }
    
    func setSignUpButtonEnabled(value : Bool) {
        if(value){
            signUpButton.isEnabled = true
            signUpButton.layer.borderColor = UIColor.blue.cgColor
            signUpButton.setTitleColor(.white, for: .normal)
        }
        else
        {
            signUpButton.isEnabled = false
            signUpButton.layer.borderColor = UIColor.gray.cgColor
            signUpButton.setTitleColor(.gray, for: .normal)
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        var isPermitted = false
        if(passwordTextField.text != confirmPasswordTextField.text)
        {
            let alert = UIAlertController(title: "Sign Up", message: "Please check password are they are not the same", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if(permissionCodeTextField.text?.isEmpty == false)
        {
            if(permissionCodeTextField.text! != UserContexManager.shared.getPermissionCode())
            {
                let alert = UIAlertController(title: "Sign Up", message: "Please check permission code. If you don't know it, remove and re-try to sign up", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            isPermitted = true
        }
        
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            guard let user = authResult?.user, error == nil else {
                let alert = UIAlertController(title: "Sign Up", message: "Used Email has already registered. Please check your email", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    
                }))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            let uid = user.uid
            
            let signupValue : Dictionary<String, Any> = [
                "uid": uid,
                "name": self.userNameTextField.text!,
                "email": self.emailTextField.text!,
                "comment" : "",
                "isAdminAccount" : isPermitted,
                "timestamp" : ServerValue.timestamp()
            ]
            
            Database.database().reference().child("users").child(uid).setValue(signupValue) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                } else {
                    print("Data saved successfully!")
                    
                    if(self.isPickedProfileImage == false)
                    {
                        self.getNewUserInfo(isAdmin: isPermitted)
                        return
                    }
                    
                    let image = self.profileImageView.image?.jpegData(compressionQuality: 0.1)
                    
                    let storageRef = Storage.storage().reference()
                    
                    var userDownloadURL:String?
                    
                    storageRef.child("profileImages").child(uid).putData(image!, metadata: nil, completion: { (metadata, error) in
                        
                        guard let _ = metadata else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        storageRef.child("profileImages").child(uid).downloadURL{ (url, error) in
                            guard let downloadURL = url else {
                                // Uh-oh, an error occurred!
                                return
                            }
                            userDownloadURL = downloadURL.absoluteString
                            Database.database().reference().child("users").child(uid).updateChildValues(["profileURL": userDownloadURL!] ) {
                                (error:Error?, ref:DatabaseReference) in
                                if let error = error {
                                    print("profileURL could not be saved: \(error).")
                                } else {
                                    print("profileURL saved successfully!")
                                }
                                self.getNewUserInfo(isAdmin: isPermitted)
                            }
                            
                        }
                    })
                }
            }
            
        }
    }
    
    func getNewUserInfo(isAdmin : Bool)
    {
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
             for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let userDic = item.value as? [String:AnyObject] {
                    let userModel = UserModel(JSON: userDic)
                    userModel?.uid = item.key
                    if(userModel?.email != self.emailTextField.text!){
                        continue
                    }
                    
                    if(isAdmin == true)
                    {
                        //add friends of all users except self
                        self.makeAllFriendsAtNewAdmin(newUserModel: userModel!)
                    }
                    else
                    {
                        //add admin friends at newbie
                        self.makeAdminFriendsAtNewbie(newUserModel : userModel!)
                    }
                    
                }
            }
        }
       
    }
    
    func makeAllFriendsAtNewAdmin(newUserModel : UserModel)
    {
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let userDic = item.value as? [String:AnyObject] {
                    let userModel = UserModel(JSON: userDic)
                    userModel?.uid = item.key
                    if(userModel?.uid == newUserModel.uid || userModel?.isAdminAccount == true){
                        continue
                    }
                    
                    self.makeRelationConnected(newUserModel: newUserModel, existedUserModel: userModel!)
                }
            }
            self.popVC()
        }
    }
        
    func makeRelationConnected(newUserModel : UserModel, existedUserModel : UserModel)
    {
        addFriendshipInfoAtFriend(targetUserModel: existedUserModel, sourceUserModel: newUserModel)
        
        addFriendshipInfoAtFriend(targetUserModel: newUserModel, sourceUserModel: existedUserModel)
        
    }
        
    func addFriendshipInfoAtFriend(targetUserModel : UserModel, sourceUserModel : UserModel) {
        var sourceUserValue : Dictionary<String, Any> = [
            "uid": sourceUserModel.uid!,
            "name": sourceUserModel.name!,
            "email": sourceUserModel.email!,
            "isAdminAccount": sourceUserModel.isAdminAccount,
        ]
        
        if let profileURL = sourceUserModel.profileURL {
            sourceUserValue.updateValue(profileURL, forKey: "profileURL")
        }
        
        if let comment = sourceUserModel.comment {
            sourceUserValue.updateValue(comment, forKey: "comment")
        }
        
        
        let receiveValue : Dictionary<String, Any> = [
            "status" : 3,
            "friendId" : sourceUserModel.uid!,
            "friendEmail" : sourceUserModel.email!,
            "friendUserModel" : sourceUserValue,
            "timestamp" : ServerValue.timestamp()
        ]
        Database.database().reference().child("friendInformations").child(targetUserModel.uid!).child("friendshipList").childByAutoId().setValue(receiveValue) {
            (err, ref) in
            if(err == nil) {
              
            }
        }
    }
    
    func makeAdminFriendsAtNewbie(newUserModel : UserModel)
    {
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let userDic = item.value as? [String:AnyObject] {
                    let userModel = UserModel(JSON: userDic)
                    userModel?.uid = item.key
                    if(userModel?.uid == newUserModel.uid || userModel?.isAdminAccount == false){
                        continue
                    }
                    
                    self.makeRelationConnected(newUserModel: newUserModel, existedUserModel: userModel!)
                }
            }
            self.popVC()
        }
    }
    
    
}
