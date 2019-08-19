//
//  SignInViewController.swift
//  SignIn
//
//  Created by 김동현 on 08/07/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        SignInButton.layer.cornerRadius = SignInButton.bounds.size.height / 2
        SignInButton.layer.borderWidth = 1
        SignInButton.layer.borderColor = UIColor.blue.cgColor
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var SignInButton: UIButton!
    @IBAction func moveToSignup(_ sender: Any) {
        let signupVC = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController")
        
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @IBAction func signinAPICall(_ sender: Any) {
//        //params
//        //get post
//        //URL Session
//        let param = [
//            "userName" : userNameTextField.text ?? "",
//            "password" : passwordTextField.text ?? ""
//        ]
//        
//        //query string
//     
//        //http://localhost:3000/loginUsers
//        
//         //let loginURL = URL(string: loginURLString + "?" + param.queryString)
//        
//        //URL Components
//        var urlComponents = URLComponents(string: loginURLString)
//        
//        urlComponents?.query = param.queryString
//        
//        guard let hasURL = urlComponents?.url else {
//            return
//        }
//        
//        URLSession.shared.dataTask(with: hasURL) { (data, response, error) in
//            
//            guard let data = data else {
//                return
//            }
//            
//            let decoder = JSONDecoder()
//            do {
//                let users = try decoder.decode([LoginUser].self, from: data)
//                if let hasUserInfo = users.first {
//                    User.shared.info = hasUserInfo
//                    
//                    self.dismiss(animated: true, completion: nil)
//                    
//                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "UserInfoLoad"), object: nil)
//                    
//                }else {
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController.init(title: "No User Info", message: nil, preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                }
//            }catch {
//                //error
//                print("error = \(error)")
//            }
//           
//        }.resume()
//        
        
    }
}

