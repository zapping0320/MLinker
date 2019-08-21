//
//  SignUpViewController.swift
//  SignIn
//
//  Created by 김동현 on 09/07/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

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
    
    @IBAction func popVC(_ sender: Any) {
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
    
    @IBAction func signupApiCAll(_ sender: Any) {
        
    }
}
