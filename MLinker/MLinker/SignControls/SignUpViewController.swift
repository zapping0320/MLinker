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
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var isPickedProfileImage: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickProfileImage)))

        //set style at buttons
        signupButton.layer.cornerRadius = signupButton.bounds.size.height / 2
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = UIColor.blue.cgColor
        
        cancelButton.layer.cornerRadius = signupButton.bounds.size.height / 2
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
    
    @IBAction func signupApiCAll(_ sender: Any) {

    }
}
