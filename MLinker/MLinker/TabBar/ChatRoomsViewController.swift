//
//  ChatRoomsViewController.swift
//  MLinker
//
//  Created by 김동현 on 13/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class ChatRoomsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var chatRoomTableView: UITableView! {
        didSet {
            self.chatRoomTableView.delegate = self
            self.chatRoomTableView.dataSource = self
        }
    }
    
    let chatRoomViewModel = ChatRoomViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatRoomCell")
        
        chatRoomViewModel.currentUserUid = UserContexManager.shared.getCurrentUid()
        chatRoomViewModel.didNotificationUpdated = { [weak self] in
            self?.chatRoomTableView.reloadData()
        }
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage (named: "addChatRoom"), for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        button.addTarget(self, action: #selector(addChatRoom),for: UIControl.Event.touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItems = [barButtonItem]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(moveChatView), name: .nsStartChat, object: nil)
      
        self.chatRoomViewModel.loadChatRoomsList(isIncludeAdminAccount: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func addChatRoom() {
        UserContexManager.shared.setLastChatRoom(model: ChatModel())
        let addChatRoomVC = UIStoryboard(name: "AddChatRoomSB", bundle: nil).instantiateViewController(withIdentifier: "addChatRoom")
        addChatRoomVC.modalPresentationStyle = .fullScreen
        self.present(addChatRoomVC, animated: true, completion: nil)
    }
    
    @objc func moveChatView(_ notification : Notification) {
        print("chatRoomsVC - moveChatView")
        if let dict = notification.userInfo as NSDictionary? {
            if let chatModel = dict["chatmodel"] as? ChatModel{
                let chatVC = UIStoryboard(name: "ChatView", bundle: nil).instantiateViewController(withIdentifier: "IdChatView") as! ChatViewController
               
                chatVC.selectedChatModel = chatModel
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }
}

extension ChatRoomsViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatRoomViewModel.getNumberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath) as! ChatRoomTableViewCell
       
        let chatRoom = self.chatRoomViewModel.getChatRoomData(indexPath: indexPath)
        
        cell.updateUI(chatRoom: chatRoom)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = UIStoryboard(name: "ChatView", bundle: nil).instantiateViewController(withIdentifier: "IdChatView") as! ChatViewController
      
        chatVC.selectedChatModel = self.chatRoomViewModel.getChatRoomData(indexPath: indexPath)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
