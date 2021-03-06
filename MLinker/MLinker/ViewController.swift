//
//  ViewController.swift
//  MLinker
//
//  Created by 김동현 on 26/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController {

    var remoteConfig : RemoteConfig!
    
    @IBOutlet weak var appVersionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        self.appVersionLabel.text = appVersion

        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = RemoteConfigSettings()
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(0)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate(completionHandler: nil)
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.displayWelcome()
        }
    }

    func displayWelcome() {
        let color = remoteConfig["splash_background"].stringValue
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        if let permissionCode = remoteConfig["permissionCode"].stringValue {
            UserContexManager.shared.setPersmissionCode(code: permissionCode)
        }
        
        
        if(caps){
            let alert = UIAlertController(title: NSLocalizedString("Notice", comment: ""), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action) in
                exit(0)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }else {
            let signInVC = UIStoryboard(name: "SigninStoryboard", bundle: nil).instantiateViewController(withIdentifier: "naviSignin")
            signInVC.modalPresentationStyle = .fullScreen
            self.present(signInVC, animated: true, completion: nil)
        }
        self.view.backgroundColor = UIColor(hex: color!)
    }


}
