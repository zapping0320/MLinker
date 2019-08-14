//
//  UsersViewController.swift
//  MLinker
//
//  Created by 김동현 on 13/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         //self.displayWelcome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.displayWelcome()
    }
    
    func displayWelcome() {
        //        let color = remoteConfig["splash_background"].stringValue
        //        let caps = remoteConfig["splash_message_caps"].boolValue
        //        let message = remoteConfig["splash_message"].stringValue
        //
        //        if(caps){
        //            let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        //            alert.addAction(UIAlertAction(title:"OK", style: .default, handler: { (action) in
        //                exit(0)
        //            }))
        //
        //            self.present(alert, animated: true, completion: nil)
        //        }else {
        if(true) {//not signed in
            let signInVC = UIStoryboard(name: "SigninStoryboard", bundle: nil).instantiateViewController(withIdentifier: "naviSignin")
            self.present(signInVC, animated: true, completion: nil)
        //let signupVC = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController")
            
        //self.present(signupVC, animated: true, completion: nil)
        }else {
            //signed in
        }
        //        }
        //        self.view.backgroundColor = UIColor(hex: color!)
    }


}
