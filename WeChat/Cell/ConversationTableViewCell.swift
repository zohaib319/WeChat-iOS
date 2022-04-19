//
//  ConversationTableViewCell.swift
//  WeChat
//
//  Created by Zohaib on 28/03/2022.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userFullName: UILabel!
    
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var imageLoader: UIActivityIndicatorView!
    @IBOutlet weak var timeStamp: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setConversation(conversationItem: ConversationsModel){
        userFullName.text = conversationItem.name
        latestMessageLabel.text = conversationItem.latestMessage.message
        timeStamp.text = conversationItem.latestMessage.date
        
//        let safeEmail = DatabaseManager.getSafeEmail(email: conversationItem.otherUserEmail)
        
        
        let avatarPath = "images/\(conversationItem.otherUserEmail)_profile_picture.png"
        
        StorageManager.shared.getDownloadURl(from: avatarPath, completion: {[weak self]result in
            guard let strongSelf = self else{
                print("could not get refrence to strong self")
                return
            }
            switch(result){
            case .success(let url):
                DispatchQueue.main.async {
                    strongSelf.userAvatar.sd_setImage(with: url, completed: nil)
                    strongSelf.imageLoader.stopAnimating()
                    strongSelf.imageLoader.isHidden = true
                }
            case .failure(let error):
                print("failed to get download url \(error)")
            }
            
        })
    }
}
