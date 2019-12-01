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
        self.commentLabel.text = currentUserModel.comment
    }
    
    @IBAction func editProfile(_ sender: Any) {
        
        
    }
    
    @IBAction func updateApp(_ sender: Any) {
        
    }
    
}
