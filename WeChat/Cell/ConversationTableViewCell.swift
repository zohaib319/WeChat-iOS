//
//  ConversationTableViewCell.swift
//  WeChat
//
//  Created by Zohaib on 28/03/2022.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var conversationTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setConversation(conversationItem:ConversationsModel){
        conversationTitle.text = conversationItem.title
        
    }

}
