//
//  ChatRoomsViewController.swift
//  MLinker
//
//  Created by 김동현 on 13/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class ChatRoomsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var chatRoomTableView: UITableView!
    var chatRooms: [ChatModel]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatRoomCell")
        self.chatRoomTableView.delegate = self
        self.chatRoomTableView.dataSource = self
    }

}

extension ChatRoomsViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath) as! ChatRoomTableViewCell
        
        return cell
    }
}
