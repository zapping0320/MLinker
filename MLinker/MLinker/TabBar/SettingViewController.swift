//
//  SettingViewController.swift
//  MLinker
//
//  Created by 김동현 on 13/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var adminAccountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var updateAppButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.profileImageView.layer.cornerRadius = 22
        self.profileImageView.clipsToBounds = true
        
        let logoutButton = UIButton(type: .custom)
        logoutButton.setImage(UIImage (named: "logout"), for: .normal)
        logoutButton.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        logoutButton.addTarget(self, action: #selector(tryLogout),for: UIControl.Event.touchUpInside)
        
        let editButton = UIButton(type: .custom)
        editButton.setImage(UIImage (named: "setting"), for: .normal)
        editButton.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        editButton.addTarget(self, action: #selector(editProfile),for: UIControl.Event.touchUpInside)
        
        let stackview = UIStackView.init(arrangedSubviews: [logoutButton, editButton])
        stackview.distribution = .equalSpacing
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.spacing = 24
        
        let rightBarButton = UIBarButtonItem(customView: stackview)
        
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.profileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editProfile)))
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        self.appVersionLabel.text = appVersion
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updaeProfileInfo()
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
        
        
        self.nameLabel.text = currentUserModel.name
        self.emailLabel.text = currentUserModel.email
       
    }
    
    @objc func editProfile() {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "profileNavi") as! ProfileViewController
        
        profileVC.selectedUserModel = UserContexManager.shared.getCurrentUserModel()
        profileVC.modalPresentationStyle = .fullScreen
        self.present(profileVC, animated: true, completion: nil)
        
    }
    
    @IBAction func updateApp(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Coming soon", comment: ""), message: NSLocalizedString("This function has not been supporting yet", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func tryLogout() {
        let alert = UIAlertController(title: NSLocalizedString("Logout", comment: ""),
                                      message: NSLocalizedString("Are you sure to logout?", comment: ""),
                                      preferredStyle: .alert)
        let actionCheck = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
            style: .default, handler: {result in
            self.logout()
        })
        alert.addAction(actionCheck)
        
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .default, handler: nil)
        
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
       
    }
    
    func logout() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "loggedIn")
        self.tabBarController?.selectedIndex = 0
        let signInVC = UIStoryboard(name: "SigninStoryboard", bundle: nil).instantiateViewController(withIdentifier: "naviSignin")
        signInVC.modalPresentationStyle = .fullScreen
        self.present(signInVC, animated: true, completion: nil)
    }
}
