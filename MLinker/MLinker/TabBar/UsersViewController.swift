//
//  UsersViewController.swift
//  MLinker
//
//  Created by 김동현 on 13/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating{
    
    @IBOutlet weak var usersTableView: UITableView!
    
    fileprivate var usersArray: [Int:[UserModel]] = [Int:[UserModel]]()
    fileprivate var filteredUsersArray = [UserModel]()
    var currnetUserUid: String!
    var isFiltered : Bool = false
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchControl = UISearchController(searchResultsController: nil)
        searchControl.searchResultsUpdater = self
        searchControl.obscuresBackgroundDuringPresentation = false
        searchControl.searchBar.placeholder = "Search friends"
        self.navigationItem.searchController = searchControl
        
        //self.navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        self.usersTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        self.usersTableView.register(UINib(nibName: "CustomTableViewHeaderCell", bundle: nil), forCellReuseIdentifier: "HeaderCell")
        
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage (named: "addFriend"), for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        button.addTarget(self, action: #selector(popupAddFriend),for: UIControl.Event.touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItems = [barButtonItem]
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveChatView), name: .nsStartChat, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUsersInfo), name: .nsUpdateUsersTable, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadSelfInfo), name: .nsUpdateSelf, object: nil)
        
        
        self.currnetUserUid = Auth.auth().currentUser?.uid
        UserContexManager.shared.setCurrentUid(uid: Auth.auth().currentUser?.uid)
        self.loadSelfInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadUsersInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       
    }
    
    @objc func popupAddFriend() {
        let addFriendVC = UIStoryboard(name: "AddFriend", bundle: nil).instantiateViewController(withIdentifier: "addFriend")
        addFriendVC.modalPresentationStyle = .fullScreen
        self.present(addFriendVC, animated: true, completion: nil)
    }
    
    @objc func loadSelfInfo() {
        self.usersArray[0] = [UserModel]()
        Database.database().reference().child("users").child(self.currnetUserUid).observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            if let userDic = datasnapShot.value as? [String:AnyObject] {
                let userModel = UserModel(JSON: userDic)
                UserContexManager.shared.setCurrentUserModel(model: userModel!)
                self.usersArray[0]!.append(userModel!)
                DispatchQueue.main.async {
                    self.usersTableView.reloadData()
                }
            }
        }
    }
    
    @objc func loadUsersInfo() {
      
        var processingFriendList = [UserModel]()
        self.usersArray[1] = [UserModel]()
        self.usersArray[2] = [UserModel]()
    Database.database().reference().child("friendInformations").child(self.currnetUserUid!).child("friendshipList").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let friendshipDic = item.value as? [String:AnyObject] {
                    
                    let friendshipModel = FriendshipModel(JSON: friendshipDic)
                    friendshipModel?.uid = item.key
                    if(friendshipModel == nil){
                        continue
                    }
                    
                    if(friendshipModel?.status == FriendStatus.cancelled ||
                        friendshipModel?.status == FriendStatus.rejected)
                    {
                        continue
                    }
                    
                    if(friendshipModel?.status == FriendStatus.Connected)
                    {
                        //select friend info
                    Database.database().reference().child("users").child(friendshipModel!.friendId!).observeSingleEvent(of: DataEventType.value) {
                            (datasnapShot) in
                            if let userDic = datasnapShot.value as? [String:AnyObject] {
                                let userModel = UserModel(JSON: userDic)
                                self.usersArray[2]!.append(userModel!)
                                DispatchQueue.main.async {
                                    self.usersTableView.reloadData()
                                }
                            }
                        }
                        
                    }
                    else {
                        let userModel = UserModel()
                        userModel.uid = friendshipModel?.friendId
                        userModel.name = friendshipModel?.friendEmail
                        userModel.profileURL = friendshipModel?.friendUserModel?.profileURL
                        userModel.comment = "processing"
                        processingFriendList.append(userModel)
                    }
                }
            }
        
            self.usersArray[1] = processingFriendList
        
            DispatchQueue.main.async {
                self.usersTableView.reloadData()
            }
        }
    }
    
    @objc func moveChatView(_ notification : Notification) {
       
        if let dict = notification.userInfo as NSDictionary? {
            if let chatModel = dict["chatmodel"] as? ChatModel{
                self.tabBarController?.selectedIndex = 0
                let chatVC = UIStoryboard(name: "ChatView", bundle: nil).instantiateViewController(withIdentifier: "IdChatView") as! ChatViewController
                chatVC.selectedChatModel = chatModel
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }
   
}

extension UsersViewController {
    func updateSearchResults(for searchController: UISearchController) {
        if let hasText = searchController.searchBar.text {
            if hasText.isEmpty {
                isFiltered = false
                
            }
            else
            {
                isFiltered = true
                self.filteredUsersArray = self.usersArray[2]!.filter({(element) -> Bool in
                    return element.containsText(text: hasText)
                })
            }
            DispatchQueue.main.async {
                self.usersTableView.reloadData()
            }
            
        }
    }
}


extension UsersViewController {
    func getNumberOfSections() -> Int{
        if (isFiltered == true) {
            return 3
        }
        else
        {
            return 3 // 0 - self 1 - requesting 2 - friends
        }
    }
    
    func getTableHeaderString(section :Int) -> String {
        if (isFiltered == true) {
            if(section != 0){
                return ""
            }
            if  UserContexManager.shared.isAdminUser() {
                return "Customers"
            }
            else {
                return "Friends"
            }
        }
        else {
            if section == 0 {
                return ""
            }
            
            if section == 1 {
                guard let dataList = usersArray[section] else {
                    return ""
                }
                if dataList.count > 0 {
                    return "Current processing"
                }
                else {
                    return ""
                }
            }
            else {
                if  UserContexManager.shared.isAdminUser() {
                    return "Customers"
                }
                else {
                    return "Friends"
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.getNumberOfSections()
    }
    
    func getNumberOfRowsInSection(section : Int) -> Int {
        if(isFiltered == true){
            if(section != 0){
                return 0
            }
            return filteredUsersArray.count
        }
        else
        {
            guard let dataList = usersArray[section] else {
                return 0
            }
            return dataList.count
        }
    }
    
    func getCurrentUserData(indexPath: IndexPath) -> UserModel
    {
        if(isFiltered == true)
        {
            if(indexPath.row >= self.filteredUsersArray.count)
            {
                return UserModel()
            }
            return self.filteredUsersArray[indexPath.row]
        }
        else
        {
            return self.usersArray[indexPath.section]![indexPath.row] as UserModel
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getTableHeaderString(section: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //isFiltered
       return getNumberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        
        //isFiltered list
        let currentUser = getCurrentUserData(indexPath: indexPath)
       
        cell.setAdminAccount(value: currentUser.isAdminAccount)
        cell.nameLabel?.text = currentUser.name
        cell.commentLabel?.text = currentUser.comment
        
        if let profileImageString = currentUser.profileURL {
            let profileImageURL = URL(string: profileImageString)
            if profileImageURL == nil {
                return cell
            }
            
            let processor = DownsamplingImageProcessor(size: CGSize(width: 44, height: 44))
                >> RoundCornerImageProcessor(cornerRadius: 40)
            cell.profileImageView?.kf.indicatorType = .activity
            cell.profileImageView?.kf.setImage(
                with: profileImageURL,
                placeholder: UIImage(named: "defaulProfileCell"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
            {
                result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "profileNavi") as! ProfileViewController
        
        profileVC.selectedUserModel = getCurrentUserData(indexPath: indexPath)
        profileVC.modalPresentationStyle = .fullScreen
        self.present(profileVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! CustomTableViewHeaderCell
       
        cell.titleLabel.text = self.getTableHeaderString(section: section)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let titleString = self.getTableHeaderString(section: section)
                
        if titleString.isEmpty {
            return 0
        }
        else {
            return 32.0
        }
    }

}

extension Notification.Name {
    static let nsStartChat = Notification.Name("startChat")
    static let nsUpdateUsersTable = Notification.Name("updateUsersTable")
    static let nsUpdateSelf = Notification.Name("updateSelf")
    
}
