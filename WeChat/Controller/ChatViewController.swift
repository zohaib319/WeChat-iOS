//
//  ChatViewController.swift
//  WeChat
//
//  Created by Zohaib on 28/03/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    public static var dateFormatter: DateFormatter =  {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    var isNewConversation = false
    let otherUserEmail: String
    var otherUserName: String
    var conversationId: String?
    var userDefaults = UserDefaults(suiteName: "userDefaults")
    
    
    
    private var messages = [Message]()
    private var selfSender : Sender? {
        guard let senderEmail = userDefaults?.string(forKey: "user_email") else{
            return nil
        }
        let safeEmail = DatabaseManager.getSafeEmail(email: senderEmail)
        guard let senderName = userDefaults?.string(forKey: "username") else{
            return nil
        }
        
        return Sender(senderId: safeEmail, displayName: senderName, photoURL: "")
    }
    init(with email: String, name: String,conversationId: String? , isNewConversation: Bool){
        self.otherUserEmail = email
        self.otherUserName = name
        self.conversationId = conversationId
        self.isNewConversation = isNewConversation
        super.init(nibName: nil, bundle: nil)
        
        // conversation is not nil. Load the conversation and listed for message changes, otherwise it will be a new conversation
        if !isNewConversation {
            guard let conversationId = conversationId else {
                return
            }
            print("conversation id to fetch other messages \(conversationId)")
            self.listenForMessages(id: conversationId)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        if isNewConversation {
            print("new conversation")
        }else{
            print("old")
        }
        
    }
    private func listenForMessages(id: String){
        DatabaseManager.shared.fetchAllMessages(for: id, completion: {[weak self]result in
            
            guard let strongSelf = self else{
                return
            }
            
            switch(result){
            case .success(let messages):
                guard !messages.isEmpty else{
                    return
                }
                strongSelf.messages = messages
                DispatchQueue.main.async {
                    strongSelf.messagesCollectionView.reloadDataAndKeepOffset()
                }
                
            case .failure(let error):
                print("failed to get messages from database \(error)")
                
            }
        })
    }
    
    /// This method creates a message id and returns it.
    private func createMessageId() -> String?{
        // date
        // otherUserEmail
        // senderEmail
        // random Int
        
        // sender email
        guard let currentUserEmail = userDefaults?.string(forKey: "user_email") else{
            print("Could not get current user email")
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.getSafeEmail(email: currentUserEmail)
        
//        // current date
//        let currentDate = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)"
        print(newIdentifier)
        return newIdentifier
        
        
    }

}

extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageId = createMessageId() else{
            return
        }
        
        guard let title = self.title else{
            print("please set title to the controller")
            return
        }
        
        let message = Message(sender: selfSender as SenderType,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
       
        
        // Send a Message now here.
        if isNewConversation {
            // Create a new converation in the firebase database.
            print("New Conversation")
           
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: title, firstMessage: message, completion: {success in
                if success {
                    print("message sent")
                    self.isNewConversation = false
                }else{
                    print("could not send message")
                }
            })
            
            
        }else{
            print("Old Conversation")
            
            // append to already added conversation.
            guard let conversationId = conversationId else{
                return
            }
            DatabaseManager.shared.sendANewMessage(to: conversationId, email: otherUserEmail, name: otherUserName, newMessage: message, completion: {success in
                if success {
                    print("message sent")
                }else{
                    print("failed to send a message")
                }
            })
        }
    }
}


extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        if let sender =  selfSender{
            return sender
        }
        fatalError("You need to cache the user email to send a message")
        
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}


