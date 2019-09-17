//
//  ChatViewController.swift
//  MLinker
//
//  Created by 김동현 on 18/09/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    
    public var selectedChatRoomUid:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("selecteduid = \(String(describing: selectedChatRoomUid))")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
