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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var isPickedProfileImage: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickProfileImage)))

        //set style at buttons
        signUpButton.layer.cornerRadius = signUpButton.bounds.size.height / 2
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.blue.cgColor
        setSignUpButtonEnabled(value: false)
        
        cancelButton.layer.cornerRadius = signUpButton.bounds.size.height / 2
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.blue.cgColor
     
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
    
    @IBAction func cancel(_ sender: Any) {
        popVC()
    }
    
    func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func signUpInfoChanged(_ sender: Any) {
        if(emailTextField.text?.isEmpty == true ||
            passwordTextField.text?.isEmpty == true ||
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
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            guard let user = authResult?.user, error == nil else {
                return
            }
            let uid = user.uid
            
            let signupValue : Dictionary<String, Any> = [
                "uid": uid,
                "name": self.userNameTextField.text!,
                "email": self.emailTextField.text!,
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
                        self.popVC()
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
                                self.popVC()
                            }
                            
                        }
                    })
                }
            }
            
        }
    }
}
