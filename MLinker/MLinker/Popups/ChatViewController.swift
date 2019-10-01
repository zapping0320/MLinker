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

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet weak var commentTableView: UITableView! {
        didSet {
            self.commentTableView.delegate = self
            self.commentTableView.dataSource = self
            self.commentTableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var chatInputView: UITextView! {
        didSet {
            self.chatInputView.delegate = self
        }
    }
    @IBOutlet weak var chatInputViewHeight: NSLayoutConstraint!
    @IBOutlet weak var inputViewBottomMargin: NSLayoutConstraint!
    
    public var selectedChatModel:ChatModel = ChatModel()
    public var selectedChatRoomUid:String!
    
    private var currnetUserUid: String!
    var comments: [ChatModel.Comment] = []
    var databaseRef: DatabaseReference?
    var observe : UInt?
    
    //temp for UI
    //var chatDatas : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentTableView.register(UINib(nibName: "ChatYourCell", bundle: nil), forCellReuseIdentifier: "ChatYourCell")
        self.commentTableView.register(UINib(nibName: "ChatMyCell", bundle: nil), forCellReuseIdentifier: "ChatMyCell")
        
        //keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.currnetUserUid = Auth.auth().currentUser?.uid
        
        self.getMessageList()
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
        //chatDatas.append(self.chatInputView.text)
        
        let value : Dictionary<String, Any> = [
            "sender": self.currnetUserUid!,
            "message" : self.chatInputView.text!,
            "timestamp" : ServerValue.timestamp()
        ]
    Database.database().reference().child("chatRooms").child(self.selectedChatModel.uid).child("comments").childByAutoId().setValue(value, withCompletionBlock: {
            (err, ref) in
            self.chatInputView.text = ""
            self.chatInputViewHeight.constant = 40
        })
       
        
        //let lastIndexPath = IndexPath(row: chatDatas.count - 1, section: 0)
        
        //commentTableView.insertRows(at: [lastIndexPath], with: UITableView.RowAnimation.automatic)
        
//        commentTableView.scrollToRow(at: lastIndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        
    }
    
    func scrollTableView()
    {
        if self.comments.count > 0 {
            self.commentTableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.contentSize.height <= 40) {
            self.chatInputViewHeight.constant = 40
        }
        else if(self.chatInputViewHeight.constant >= 100)
        {
            self.chatInputViewHeight.constant = 100
        }
        else {
            self.chatInputViewHeight.constant = textView.contentSize.height
        }
    }
    
    func getMessageList() {
        self.databaseRef = Database.database().reference().child("chatRooms").child(self.selectedChatModel.uid).child("comments")
        
        self.observe = self.databaseRef!.observe(DataEventType.value, with: {
            (snapshot) in
            self.comments.removeAll()
            var readUsersDic : Dictionary<String,AnyObject> = [:]
            
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let key = item.key as String
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                let comment_modify = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                //comment_modify?.readUsers[self.uid!] = true
                //readUsersDic[key] = comment_modify?.toJSON() as! NSDictionary
                self.comments.append(comment!)
            }
            
            let nsDic = readUsersDic as NSDictionary
            
            if(self.comments.last?.readUsers.keys == nil){
                return
            }
            
//            if(!(self.comments.last?.readUsers.keys.contains(self.uid!))!){
//                snapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.scrollTableView()
//
//                    }
//                })
//
//
//            }else {
                DispatchQueue.main.async {
                    self.commentTableView.reloadData()
                    self.scrollTableView()
                    
              //  }
            }
        })
    }
}

extension ChatViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let selectedComment = self.comments[indexPath.row]
        
        if(selectedComment.sender == self.currnetUserUid){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMyCell", for: indexPath) as! ChatMyCell
            cell.selectionStyle = .none
            cell.commentTextView.text = self.comments[indexPath.row].message//chatDatas[indexPath.row]
            if let timeStamp = self.comments[indexPath.row].timestamp {
                cell.commentDateLabel.text = timeStamp.toChatCellDayTime
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatYourCell", for: indexPath) as! ChatYourCell
            cell.commentTextView.text = self.comments[indexPath.row].message//chatDatas[indexPath.row]
            cell.selectionStyle = .none
            if let timeStamp = self.comments[indexPath.row].timestamp {
                cell.commentDateLabel.text = timeStamp.toChatCellDayTime
            }
            return cell
        }
    }
}
