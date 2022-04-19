//
//  UsersTableViewCell.swift
//  WeChat
//
//  Created by Zohaib on 29/03/2022.
//

import UIKit

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUser(name: String){
        userName.text = name
    }

}
