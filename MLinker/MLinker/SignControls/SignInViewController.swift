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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    let firebaseAuth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.layer.cornerRadius = 4
        
        setSignInButtonEnabled(value: false)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
            signInButton.layer.borderColor = UIColor.blue.cgColor
            signInButton.setTitleColor(.white, for: .normal)
        }
        else
        {
            signInButton.isEnabled = false
            signInButton.layer.borderColor = UIColor.gray.cgColor
            signInButton.setTitleColor(.gray, for: .normal)
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
                let alert = UIAlertController(title: "error", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "loggedIn")
        }
    }
    
    //will beremoved after implementing
    func signeOut() {
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.emailTextField.text? = "bmwe3@hanmail.net"
        self.passwordTextField.text? = "@1234asdf"
        setSignInButtonEnabled(value: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
}

