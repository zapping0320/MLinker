//
//  SignUpViewController.swift
//  SignIn
//
//  Created by 김동현 on 09/07/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var SignUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        SignUpButton.layer.cornerRadius = SignUpButton.bounds.size.height / 2
        SignUpButton.layer.borderWidth = 1
        SignUpButton.layer.borderColor = UIColor.blue.cgColor
    }
    @IBAction func popVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func signupApiCAll(_ sender: Any) {
//        let param = [
//            "userName"  : userName.text ?? "",
//            "password"  : password.text ?? "",
//            "email"     : email.text ?? ""
//        ]
//
//        //HTTP Method -> POST
//        if let url = URL(string: "http://localhost:3000/loginUsers") {
//            var request = URLRequest.init(url: url)
//
//            request.httpMethod = "POST"
//            request.httpBody = param.queryString.data(using: .utf8)
//
//            URLSession.shared.dataTask(with: request) { (data, response, error) in
//                guard let data = data else {
//                    return
//                }
//
//                let decoder = JSONDecoder()
//                do {
//                    let user = try decoder.decode(LoginUser.self, from: data)
//
//                    User.shared.info = user
//
//                    self.dismiss(animated: true, completion: nil)
//
//                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "UserInfoLoad"), object: nil)
//
//                }catch {
//                    //error
//                    print("error = \(error)")
//                }
//
//
//            }.resume()
//        }
//
    }
}
