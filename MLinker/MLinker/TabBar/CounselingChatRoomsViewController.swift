//
//  CounselingChatRoomsViewController.swift
//  MLinker
//
//  Created by 김동현 on 13/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class CounselingChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var chatRoomTableView: UITableView!{
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.chatRoomViewModel.loadChatRoomsList(isIncludeAdminAccount: true)
    }
    
}

extension CounselingChatRoomsViewController {
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
