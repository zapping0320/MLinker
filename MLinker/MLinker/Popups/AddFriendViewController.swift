//
//  AddFriendViewController.swift
//  MLinker
//
//  Created by 김동현 on 29/08/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController {

    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var friendEmailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyButton.layer.cornerRadius = applyButton.bounds.size.height / 2
        applyButton.layer.borderWidth = 1
        applyButton.layer.borderColor = UIColor.blue.cgColor
        
        setApplyButtonEnabled(value: false)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    
    func setApplyButtonEnabled(value : Bool) {
        if(value){
            applyButton.isEnabled = true
            applyButton.layer.borderColor = UIColor.blue.cgColor
            applyButton.setTitleColor(.white, for: .normal)
        }
        else
        {
            applyButton.isEnabled = false
            applyButton.layer.borderColor = UIColor.gray.cgColor
            applyButton.setTitleColor(.gray, for: .normal)
        }
    }

    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyFriendShip(_ sender: Any) {
        
    }
}
