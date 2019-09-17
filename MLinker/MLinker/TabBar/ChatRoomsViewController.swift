//
//  ChatRoomsViewController.swift
//  MLinker
//
//  Created by 김동현 on 13/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatRoomsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var chatRoomTableView: UITableView!
    var currnetUserUid: String!
    var chatRooms: [ChatModel]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatRoomCell")
        self.chatRoomTableView.delegate = self
        self.chatRoomTableView.dataSource = self
        
        self.currnetUserUid = Auth.auth().currentUser?.uid
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getChatRoomsList()
    }
    
    func getChatRoomsList() {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "users/" + self.currnetUserUid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            self.chatRooms.removeAll()
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    chatModel?.uid = item.key
                    self.chatRooms.append(chatModel!)
                }
            }
            
            DispatchQueue.main.async {
                self.chatRoomTableView.reloadData()
            }
        }
    }

    @IBAction func addChatRoom(_ sender: Any) {
    }
}

extension ChatRoomsViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2//chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath) as! ChatRoomTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = UIStoryboard(name: "ChatView", bundle: nil).instantiateViewController(withIdentifier: "IdChatView") as! ChatViewController
        chatVC.selectedChatRoomUid = String(indexPath.row)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
