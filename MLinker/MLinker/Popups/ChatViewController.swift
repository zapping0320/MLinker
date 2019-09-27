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

    @IBOutlet weak var commentTableView: UITableView! {
        didSet {
            self.commentTableView.delegate = self
            self.commentTableView.dataSource = self
            self.commentTableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var chatInputView: UITextView!
    @IBOutlet weak var inputViewBottomMargin: NSLayoutConstraint!
    
    public var selectedChatModel:ChatModel = ChatModel()
    public var selectedChatRoomUid:String!
    
    //temp for UI
    var chatDatas : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentTableView.register(UINib(nibName: "ChatYourCell", bundle: nil), forCellReuseIdentifier: "ChatYourCell")
        self.commentTableView.register(UINib(nibName: "ChatMyCell", bundle: nil), forCellReuseIdentifier: "ChatMyCell")
        
        //keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(noti : Notification){
        if let notiInfo = noti.userInfo {
            let keyboardFrame = notiInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            let height = keyboardFrame.size.height - self.view.safeAreaInsets.bottom
            
            let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            
            UIView.animate(withDuration: animationDuration) {
                self.inputViewBottomMargin.constant = height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(noti : Notification){
        if let notiInfo = noti.userInfo {
            let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            
            UIView.animate(withDuration: animationDuration) {
                self.inputViewBottomMargin.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        if(self.chatInputView.text.isEmpty){
            return
        }
        chatDatas.append(self.chatInputView.text)
        self.chatInputView.text = ""
        
        let lastIndexPath = IndexPath(row: chatDatas.count - 1, section: 0)
        
        commentTableView.insertRows(at: [lastIndexPath], with: UITableView.RowAnimation.automatic)
        
        commentTableView.scrollToRow(at: lastIndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        
    }
}

extension ChatViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row % 2 == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMyCell", for: indexPath) as! ChatMyCell
            cell.commentTextView.text = chatDatas[indexPath.row]
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatYourCell", for: indexPath) as! ChatYourCell
            cell.commentTextView.text = chatDatas[indexPath.row]
            return cell
        }
    }
}
