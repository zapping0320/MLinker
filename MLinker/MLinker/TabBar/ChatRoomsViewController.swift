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
    @IBOutlet weak var chatRoomTableView: UITableView! {
        didSet {
            self.chatRoomTableView.delegate = self
            self.chatRoomTableView.dataSource = self
        }
    }
    var currnetUserUid: String!
    var chatRooms: [ChatModel]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatRoomCell")
        
        self.currnetUserUid = Auth.auth().currentUser?.uid
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage (named: "addChatRoom"), for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        button.addTarget(self, action: #selector(addChatRoom),for: UIControl.Event.touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItems = [barButtonItem]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(moveChatView), name: .nsStartChat, object: nil)
        
        self.getChatRoomsList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getChatRoomsList() {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "timestamp").observeSingleEvent(of: DataEventType.value) {
            (datasnapShot) in
            self.chatRooms.removeAll()
            for item in datasnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    chatModel?.uid = item.key
                    if((chatModel?.chatUserIdDic.keys.contains(self.currnetUserUid!)) == true)
                    {
                        //self.chatRooms.append(chatModel!)
                        self.chatRooms.insert(chatModel!, at: 0)
                    }
                }
            }
            DispatchQueue.main.async {
                self.chatRoomTableView.reloadData()
            }
        }
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
                //chatVC.selectedChatRoomUid = String(indexPath.row)
                chatVC.selectedChatModel = chatModel
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }
}

extension ChatRoomsViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath) as! ChatRoomTableViewCell
        
        let chatRoom = self.chatRooms[indexPath.row]
        
        cell.setStandAlone(value: chatRoom.standAlone) 
        cell.nameLabel.text = chatRoom.name
        var hasImage = false
        var imageURL:String = ""
        if let chatroomImage = chatRoom.chatRoomImageURL {
            hasImage = true
            imageURL = chatroomImage
        }
        
        if(chatRoom.comments.isEmpty == false)
        {
            var recentComment : ChatModel.Comment = ChatModel.Comment()
            for key in chatRoom.comments.keys {
                if let comment = chatRoom.comments[key] {
                    if recentComment.timestamp == nil || recentComment.timestamp! < comment.timestamp! {
                        recentComment = comment
                    }
                }
            }
            
            cell.lastCommentLabel.text = recentComment.message
            if let timeStamp = recentComment.timestamp {
                cell.lastCommentDateLabel.text = timeStamp.toChatRoomCellDayTime
            }
            
            if hasImage == false {
                if let lastCommentUserProfile = chatRoom.chatUserModelDic[recentComment.sender!]?.profileURL {
                    hasImage = true
                    imageURL = lastCommentUserProfile
                }
            }
            
        }
        else
        {
            cell.lastCommentLabel.text = ""
            cell.lastCommentDateLabel.text = ""
        }
        
        if hasImage == true
        {
            let profileImageURL = URL(string: imageURL)
            let processor = DownsamplingImageProcessor(size: CGSize(width: 80, height: 80))
                >> RoundCornerImageProcessor(cornerRadius: 40)
            cell.roomImageView?.kf.indicatorType = .activity
            cell.roomImageView?.kf.setImage(
                with: profileImageURL,
                placeholder: UIImage(named: "defaultChatRoomCell"),
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
        let chatVC = UIStoryboard(name: "ChatView", bundle: nil).instantiateViewController(withIdentifier: "IdChatView") as! ChatViewController
        chatVC.selectedChatModel = self.chatRooms[indexPath.row]
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
