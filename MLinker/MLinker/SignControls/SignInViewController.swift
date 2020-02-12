//
//  SignInViewController.swift
//  SignIn
//
//  Created by 김동현 on 08/07/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    @IBOutlet weak var appMainTitle: UILabel!
    @IBOutlet weak var appMainTitleTopMargin: NSLayoutConstraint!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    let firebaseAuth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.layer.cornerRadius = 4
        
        setSignInButtonEnabled(value: false)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
               
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let defaults = UserDefaults.standard
        let loggedIn = defaults.bool(forKey: "loggedIn")
        if(loggedIn == false)
        {
            signeOut()
        }
        
        firebaseAuth.addStateDidChangeListener {
            (auth, user)
            in
            if(user != nil) {
                let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: false, completion: nil)
                InstanceID.instanceID().instanceID { (result, error) in
                  if let error = error {
                    print("Error fetching remote instance ID: \(error)")
                  } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                    let uid = Auth.auth().currentUser?.uid
                    let token  = result.token
                    Database.database().reference().child("users").child(uid!).updateChildValues(["pushToken":token])
                  }
                }
            }
        }
        
    }
    
    @IBAction func signInInfoChanged(_ sender: Any) {
        if(self.emailTextField.text?.isEmpty == false && self.passwordTextField.text?.isEmpty == false)
        {
            setSignInButtonEnabled(value: true)
        }else {
            setSignInButtonEnabled(value: false)
        }
    }
    
    func setSignInButtonEnabled(value : Bool) {
        if(value){
            signInButton.isEnabled = true
            signInButton.backgroundColor = ColorHelper.getButtonNormalBackgroundColor()
        }
        else
        {
            signInButton.isEnabled = false
            signInButton.backgroundColor = ColorHelper.getButtonDisabledBackgroundColor()
        }
    }
  
    @IBAction func moveToSignup(_ sender: Any) {
        let signupVC = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController")
        
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @IBAction func signIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) {
            (user, error) in
            
            if( error != nil ) {
               
                var errorMessage = error.debugDescription
                if errorMessage.contains("17009")
                {
                    errorMessage = NSLocalizedString("Password is wrong. Please check your password", comment: "")
                }
                else if(errorMessage.contains("17011"))
                {
                    errorMessage = NSLocalizedString("This email is not registered. Please check your email", comment: "")
                }
                else if(errorMessage.contains("17008"))
                {
                    errorMessage = NSLocalizedString("This email format is invalid. Please check your email", comment: "")
                }
                
                
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: errorMessage, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "loggedIn")
            }
          
        }
    }
    
    //will beremoved after implementing
    func signeOut() {
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(noti : Notification){
        let viewHeight = UIScreen.main.bounds.height
        if viewHeight > 667 {
            return
        }
        if let notiInfo = noti.userInfo {
            let keyboardFrame = notiInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            let height = keyboardFrame.size.height - self.view.safeAreaInsets.bottom
            
            
            
            let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            
            UIView.animate(withDuration: animationDuration) {
                self.appMainTitleTopMargin.constant = 200 - height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(noti : Notification){
        let viewHeight = UIScreen.main.bounds.height
        if viewHeight > 667 {
            return
        }
        if let notiInfo = noti.userInfo {
            let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            
            UIView.animate(withDuration: animationDuration) {
                self.appMainTitleTopMargin.constant = 200
                self.view.layoutIfNeeded()
            }
        }
    }
}

