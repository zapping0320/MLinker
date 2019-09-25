//
//  ChatViewController.swift
//  MLinker
//
//  Created by 김동현 on 18/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var chatInputView: UITextView!
    @IBOutlet weak var inputViewBottomMargin: NSLayoutConstraint!
    
    public var selectedChatModel:ChatModel = ChatModel()
    public var selectedChatRoomUid:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentTableView.delegate = self
        self.commentTableView.dataSource = self
        
        self.commentTableView.register(UINib(nibName: "ChatYourCell", bundle: nil), forCellReuseIdentifier: "ChatYourCell")
        self.commentTableView.register(UINib(nibName: "ChatMyCell", bundle: nil), forCellReuseIdentifier: "ChatMyCell")
        
    }
    @IBAction func sendMessage(_ sender: Any) {
    }
}

extension ChatViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row % 2 == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMyCell", for: indexPath) as! ChatMyCell
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatYourCell", for: indexPath) as! ChatYourCell
            
            return cell
        }
    }
}
