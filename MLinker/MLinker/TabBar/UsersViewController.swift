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
    
    fileprivate var filteredUsersArray = [UserModel]()
 
    var isFiltered : Bool = false
    
    let userViewModel = UserViewModel()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userViewModel.didNotificationUpdated = { [weak self] in
            self?.usersTableView.reloadData()
        }
        
        userViewModel.checkTabControllerUpdate = { [weak self] in
            if self?.tabBarController?.viewControllers?.count == 4 {
                self?.tabBarController?.viewControllers?.remove(at: 1)
            }
        }
        
        
        let searchControl = UISearchController(searchResultsController: nil)
        searchControl.searchResultsUpdater = self
        searchControl.obscuresBackgroundDuringPresentation = false
        searchControl.searchBar.placeholder = NSLocalizedString("Search friends", comment: "")
        //self.navigationItem.searchController = searchControl
        
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
       
        self.userViewModel.currentUserUid = Auth.auth().currentUser?.uid
        UserContexManager.shared.setCurrentUid(uid: Auth.auth().currentUser?.uid)
      
         self.userViewModel.loadSelfInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        //self.loadUsersInfo()
        self.userViewModel.loadSelfInfo()
        self.userViewModel.loadUsersInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       
    }
    
    @objc func popupAddFriend() {
        let addFriendVC = UIStoryboard(name: "AddFriend", bundle: nil).instantiateViewController(withIdentifier: "addFriend")
        addFriendVC.modalPresentationStyle = .fullScreen
        self.present(addFriendVC, animated: true, completion: nil)
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
                self.filteredUsersArray = self.userViewModel.getFilteredFriendModels(searchText: hasText)
            }
            DispatchQueue.main.async {
                self.usersTableView.reloadData()
            }
            
        }
    }
}


extension UsersViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.userViewModel.getNumOfSection(isFiltered: self.isFiltered)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.userViewModel.getTableHeaderString(section: section, isFiltered: self.isFiltered)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userViewModel.getNumberOfRowsInSection(section: section, isFiltered: self.isFiltered)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        
        //isFiltered list
        let currentUser = self.userViewModel.getCurrentUserData(indexPath: indexPath, isFiltered: self.isFiltered)
       
        cell.setAdminAccount(value: currentUser.isAdminAccount)
        cell.nameLabel?.text = currentUser.name
        if currentUser.comment!.isEmpty {
            cell.commentLabel?.text = NSLocalizedString("No comments", comment: "")
        }
        else {
            cell.commentLabel?.text = currentUser.comment
        }
        
        if let profileImageString = currentUser.profileURL {
            let profileImageURL = URL(string: profileImageString)
            if profileImageURL == nil {
                return cell
            }
            
            let processor = DownsamplingImageProcessor(size: CGSize(width: 44, height: 44))
                |> RoundCornerImageProcessor(cornerRadius: 40)
            cell.profileImageView?.kf.indicatorType = .activity
            cell.profileImageView?.kf.setImage(
                with: profileImageURL,
                placeholder: UIImage(named: "defaultProfileCell"),
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
        
        profileVC.selectedUserModel = self.userViewModel.getCurrentUserData(indexPath: indexPath, isFiltered: self.isFiltered)
        profileVC.modalPresentationStyle = .fullScreen
        self.present(profileVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! CustomTableViewHeaderCell
       
        cell.titleLabel.text = self.userViewModel.getTableHeaderString(section: section, isFiltered: self.isFiltered)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let titleString = self.userViewModel.getTableHeaderString(section: section, isFiltered: self.isFiltered)
                
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
