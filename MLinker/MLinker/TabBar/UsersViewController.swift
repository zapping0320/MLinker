//
//  UsersViewController.swift
//  MLinker
//
//  Created by 김동현 on 13/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var usersTableView: UITableView!
    
    fileprivate var usersArray: [Int:[UserModel]] = [Int:[UserModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.usersTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadUsesInfo()
        
//        let userModel = UserModel()
//        userModel.uid = "123"
//        userModel.name = "kkk"
//        userModel.comment = "comment"
//        self.userArray.append(userModel)
//
//        let userModel2 = UserModel()
//        userModel2.uid = "123"
//        userModel2.name = "gggg"
//        userModel2.comment = "commentary"
//        self.userArray.append(userModel2)
//
//        DispatchQueue.main.async {
//            self.usersTableView.reloadData()
//        }
        
    }
    
    @IBAction func popupAddFriend(_ sender: Any) {
        let addFriendVC = UIStoryboard(name: "AddFriend", bundle: nil).instantiateViewController(withIdentifier: "addFriend")
        self.present(addFriendVC, animated: true, completion: nil)
    }
    
    func loadUsesInfo() {
        
        
        
        
    }
}


extension UsersViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // 0 - self 1 - requesting 2 - friends
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataList = usersArray[section] else {
            return 0
        }
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        let currentUser = self.usersArray[indexPath.section]![indexPath.row] as UserModel
        
        cell.nameLabel?.text = currentUser.name
        cell.commentLabel?.text = currentUser.comment
        
        return cell
    }
}
