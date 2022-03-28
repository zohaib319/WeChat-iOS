//
//  UsersViewController.swift
//  WeChat
//
//  Created by Zohaib on 28/03/2022.
//

import UIKit

class UsersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
}
