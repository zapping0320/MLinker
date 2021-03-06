//
//  ChatViewController.swift
//  MLinker
//
//  Created by 김동현 on 18/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

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
    
    let chatViewViewModel = ChatViewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentTableView.register(UINib(nibName: "ChatYourCell", bundle: nil), forCellReuseIdentifier: "ChatYourCell")
        self.commentTableView.register(UINib(nibName: "ChatMyCell", bundle: nil), forCellReuseIdentifier: "ChatMyCell")
        
        self.commentTableView.register(UINib(nibName: "ChatNoticeCell", bundle: nil), forCellReuseIdentifier: "ChatNoticeCell")
        
        self.commentTableView.register(UINib(nibName: "ChatDateDisplayCell", bundle: nil), forCellReuseIdentifier: "ChatDateDisplayCell")
       
        self.chatViewViewModel.didNotificationUpdated = { [weak self]  in
            self?.commentTableView.reloadData()
            self?.scrollTableView()
        }
        
        self.chatViewViewModel.clearTextInput = { [weak self] in
            self?.chatInputView.text = ""
            self?.chatInputViewHeight.constant = 40
        }
        
        self.chatViewViewModel.closeVC = { [weak self] in
            if let navController = self?.navigationController {
                navController.popViewController(animated: true)
            }
        }
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage (named: "setting"), for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        button.addTarget(self, action: #selector(barBtn_more_Action),for: UIControl.Event.touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItems = [barButtonItem]
        
        //keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.chatViewViewModel.getRelatedUserModels()
        
        self.chatViewViewModel.getMessageList()
       
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
        self.trySendMessageServer(isNotice: false)
    }
    
    func trySendMessageServer(isNotice:Bool)
    {
        if(isNotice == false && self.chatInputView.text.isEmpty){
            return
        }
        
        let textInputString = self.chatInputView.text!
        self.chatViewViewModel.sendMessageServer(isNotice: isNotice, textInputString: textInputString)
        
    }
    
    func scrollTableView()
    {
        if self.chatViewViewModel.getNumberOfRowsInSection() > 0 {
            self.commentTableView.scrollToRow(at: IndexPath(item: self.chatViewViewModel.getNumberOfRowsInSection() - 1, section: 0), at: .bottom, animated: false)
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
    
    @objc func barBtn_more_Action(){
        let alert = UIAlertController(title: title,
                                      message: NSLocalizedString("Setting", comment: ""),
                                      preferredStyle: UIAlertController.Style.actionSheet)
        
        let actionChangeTitle = UIAlertAction(title: NSLocalizedString("Change Title", comment: ""),
                                              style: .default, handler: {result in
                                                self.tryChangeChatRoomTitle()
        })
        actionChangeTitle.setValue(ColorHelper.getMainAlertTextColor(), forKey: "titleTextColor")
        alert.addAction(actionChangeTitle)
        
        if self.chatViewViewModel.selectedChatModel.isStandAlone == false {
            let actionExitChat = UIAlertAction(title: NSLocalizedString("Exit Chat", comment: ""),
                                               style: .default, handler: {result in
                                                self.exitChatRoom()
            })
            actionExitChat.setValue(ColorHelper.getMainAlertTextColor(), forKey: "titleTextColor")
            alert.addAction(actionExitChat)
            let actionAddMember = UIAlertAction(title: NSLocalizedString("Add Members", comment: ""),
                                                style: .default, handler: {result in
                                                    self.addMember()
            })
            actionAddMember.setValue(ColorHelper.getMainAlertTextColor(), forKey: "titleTextColor")
            alert.addAction(actionAddMember)
        }
        
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel, handler: nil)
        
        actionCancel.setValue(ColorHelper.getCancelTextColor(), forKey: "titleTextColor")
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tryChangeChatRoomTitle() {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Change Title", comment: ""), preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = self.chatViewViewModel.selectedChatModel.name
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: { (updateAction) in
            
            self.chatViewViewModel.changeChatRoomTitle(newTitle: alert.textFields!.first!.text!)
            
           
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: false)
    }
    
    func exitChatRoom() {
        self.chatViewViewModel.exitChatRoom()
    }
    
    func addMember() {
       
        let addChatRoomVC = UIStoryboard(name: "AddChatRoomSB", bundle: nil).instantiateViewController(withIdentifier: "addChatRoom")
        addChatRoomVC.modalPresentationStyle = .fullScreen
        self.present(addChatRoomVC, animated: true, completion: nil)
    }
}

extension ChatViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatViewViewModel.getNumberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let selectedComment = self.chatViewViewModel.getCommentData(indexPath: indexPath)
        
        if selectedComment.commentType == CommentType.Notice {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatNoticeCell", for: indexPath) as! ChatNoticeCell
            cell.noticeTextView.text = NoticeStringHelper.makeNoticeString(notice: selectedComment.notice)
            cell.selectionStyle = .none
            
            return cell
        }
       
        if selectedComment.commentType == CommentType.Date {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDateDisplayCell", for: indexPath) as! ChatDateDisplayCell
            cell.dateLabel.text = selectedComment.message
            cell.selectionStyle = .none
            return cell
        }
        
        let remainUserCount = self.chatViewViewModel.selectedChatModel.chatUserIdDic.count - selectedComment.readUsers.count
        
        if(selectedComment.sender == UserContexManager.shared.getCurrentUid()){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMyCell", for: indexPath) as! ChatMyCell

            cell.updateUI(comment: selectedComment, remainUserCount: remainUserCount)

            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatYourCell", for: indexPath) as! ChatYourCell
      
            let currentUserModel = self.chatViewViewModel.getCommentSenderUserModel(sender: selectedComment.sender!)
            
            cell.updateUI(comment: selectedComment, remainUserCount: remainUserCount, currentUserModel : currentUserModel)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedComment = self.chatViewViewModel.getCommentData(indexPath: indexPath)
        
        guard let selectedUserId = selectedComment.sender else {
            return
        }
        
        if (selectedUserId == UserContexManager.shared.getCurrentUid())
        {
            return
        }
        
        let userModel = self.chatViewViewModel.getCommentSenderUserModel(sender: selectedUserId)
        
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "profileNavi") as! ProfileViewController
        profileVC.setSelectedUserModel(selectedUserModel: userModel)
        profileVC.isChatView = true
        profileVC.modalPresentationStyle = .fullScreen
        self.present(profileVC, animated: true, completion: nil)
    }
}
