//
//  AddChatRoomViewController.swift
//  MLinker
//
//  Created by 김동현 on 14/10/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase
//import Kingfisher

class AddChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var usersTableView: UITableView!{
        didSet {
            self.usersTableView.delegate = self
            self.usersTableView.dataSource = self
            self.usersTableView.allowsMultipleSelectionDuringEditing = true
            self.usersTableView.setEditing(true, animated: false)
        }
    }
    
    public var selectedChatModel:ChatModel = ChatModel()
    
    private var doneBarButton: UIBarButtonItem = UIBarButtonItem()
    
    let addChatRoomViewModel = AddChatRoomViewModel()
    let chatRoomViewModel = ChatRoomViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usersTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        selectedChatModel = UserContexManager.shared.getLastChatRoom()
        
        addChatRoomViewModel.didNotificationUpdated = { [weak self] in
            self?.usersTableView.reloadData()
        }
        
        chatRoomViewModel.currentUserUid = UserContexManager.shared.getCurrentUid()
        
        chatRoomViewModel.didFoundChatRoom = { [weak self] (chatModel) in
            self?.moveChatView(chatModel: chatModel)
        }
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setImage(UIImage (named: "close"), for: .normal)
        cancelButton.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        cancelButton.addTarget(self, action: #selector(cancelAddChatRoom),for: UIControl.Event.touchUpInside)
        
        let leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        self.navigationItem.leftBarButtonItems = [leftBarButtonItem]
        
        
        let doneButton = UIButton(type: .custom)
        doneButton.setImage(UIImage (named: "done"), for: .normal)
        doneButton.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        doneButton.addTarget(self, action: #selector(doneAddChatRoom),for: UIControl.Event.touchUpInside)
        
        doneBarButton = UIBarButtonItem(customView: doneButton)
        self.navigationItem.rightBarButtonItems = [doneBarButton]
        
        self.addChatRoomViewModel.loadChatRoomMembers()
        
    }
    
    @objc func cancelAddChatRoom() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneAddChatRoom() {
        if(self.selectedChatModel.isValid())
        {
            self.addMemberstoChatRoom()
        }
        else
        {
            self.findChatRoom()
        }
    }
    
    func addMemberstoChatRoom()
    {
        guard let indexes = self.usersTableView.indexPathsForSelectedRows else{
            return
        }
        
        self.addChatRoomViewModel.moveChatRoom = { [weak self] (chatModel) in
            self?.moveChatView(chatModel: chatModel)
        }
        
        //add members
        var membersAdded:[String] = []
        var isIncludeAdmin = self.selectedChatModel.isIncludeAdminAccount
        for indexPath in indexes {
            let selectedUser = self.addChatRoomViewModel.getCurrentUserData(indexPath: indexPath)
            self.selectedChatModel.chatUserIdDic.updateValue(false, forKey: selectedUser.uid!)
            
            membersAdded.append(selectedUser.name!)
            
            if(selectedUser.isAdminAccount == true)
            {
                isIncludeAdmin = true
            }
        }
        
        self.addChatRoomViewModel.addMemberstoChatRoom(isIncludeAdmin: isIncludeAdmin, chatUserIdDic: self.selectedChatModel.chatUserIdDic, membersAdded: membersAdded)
    }

    
    func findChatRoom()
    {
        guard let indexes = self.usersTableView.indexPathsForSelectedRows else{
             return
         }
        
        var selectedUserModels = [UserModel]()
        for indexPath in indexes {
            let selectedUser = self.addChatRoomViewModel.getCurrentUserData(indexPath: indexPath)
            selectedUserModels.append(selectedUser)
        }
        
        self.chatRoomViewModel.findChatRoom(isStandAlone: false, selectedUserModels: selectedUserModels)

    }
    
    func moveChatView(chatModel : ChatModel)
    {
        let chatModelDic = ["chatmodel" : chatModel]
        
        NotificationCenter.default.post(name: .nsStartChat, object: nil, userInfo: chatModelDic)
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddChatRoomViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.addChatRoomViewModel.getNumOfSection()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.addChatRoomViewModel.getTableHeaderString(section: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addChatRoomViewModel.getNumberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        let currentUser = self.addChatRoomViewModel.getCurrentUserData(indexPath: indexPath)
        
        cell.updateUI(userModel: currentUser)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.doneBarButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard self.usersTableView.indexPathsForSelectedRows != nil else {
            self.doneBarButton.isEnabled = false
            return
        }
        
        self.doneBarButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.addChatRoomViewModel.isCanEditRowAt(indexPath: indexPath)
    }

}
