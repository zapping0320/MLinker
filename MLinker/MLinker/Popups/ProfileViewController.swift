//
//  ProfileViewController.swift
//  MLinker
//
//  Created by 김동현 on 03/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    public var selectedUserModel: UserModel = UserModel()
    public var selectedFriendshipModel : FriendshipModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(selectedFriendshipModel != nil)
        {
            print(self.selectedFriendshipModel?.friendEmail)
        }
        
    }
    
    @IBAction func closeVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
