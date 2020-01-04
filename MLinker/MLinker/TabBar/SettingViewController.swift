//
//  SettingViewController.swift
//  MLinker
//
//  Created by 김동현 on 13/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var adminAccountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var updateAppButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updaeProfileInfo()
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        self.appVersionLabel.text = appVersion
        
    }
    
    func updaeProfileInfo()
    {
        let currentUserModel = UserContexManager.shared.getCurrentUserModel()
        if(currentUserModel.isAdminAccount != true)
        {
            self.adminAccountLabel.isHidden = true
        }
        
        if let profileImageString = currentUserModel.profileURL {
            let profileImageURL = URL(string: profileImageString)
            profileImageView.kf.setImage(with: profileImageURL)
        }
        
        self.emailLabel.text = currentUserModel.email
        self.nameLabel.text = currentUserModel.name
        
        if currentUserModel.comment?.isEmpty == false {
            self.commentLabel.text = currentUserModel.comment
        }
        else
        {
            self.commentLabel.text = "No comments"
        }
    }
    
    @IBAction func editProfile(_ sender: Any) {
        let alert = UIAlertController(title: "Coming soon", message: "This function has not been supporting yet", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func updateApp(_ sender: Any) {
        let alert = UIAlertController(title: "Coming soon", message: "This function has not been supporting yet", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: title,
                                      message: NSLocalizedString("Logout", comment: ""),
                                      preferredStyle: .alert)
        let actionCheck = UIAlertAction(title: NSLocalizedString("Are you sure to logout?", comment: ""),
            style: .default, handler: {result in
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "loggedIn")
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        })
        alert.addAction(actionCheck)
        
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel, handler: nil)
        
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
        
       
    }
}
