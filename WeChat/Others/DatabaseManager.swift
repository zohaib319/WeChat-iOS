//
//  DatabaseManager.swift
//  WeChat
//
//  Created by Zohaib on 26/03/2022.
//

import Foundation
import FirebaseDatabase
import AVFoundation

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    private let userDefaults = UserDefaults(suiteName: "userDefaults")
    
    
    /// This function validates if there is an account already registered with the provided email.
    public func userExists(email: String, completion: @escaping ((Bool) ->Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            if snapshot.exists() {
                print("value is present")
                completion(true)
                
            }
            else{
                print("value is not present.")
                completion(false)
                
            }
        })
    }
    
    static func getSafeEmail(email: String) -> String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    /// This function fetches all the users available on the firebase database.
    public func fetchAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            
            guard let value = snapshot.value as? [[String: String]] else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            print(value)
            completion(.success(value))
        })
    }
    
    
    /// This function inserts our newely created user into database.
    public func inserUserIntoFirebaseDatabase(with user: User, completion: @escaping ((Bool) -> Void)){
        
        database.child(user.safeEmail).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ],withCompletionBlock: {error, _ in
            guard error ==  nil else{
                completion(false)
                return
            }
            
            
            // check if the users array exists.
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // array exists; append to that array
                    
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: {error, _ in
                        guard error ==  nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    
                }else{
                    // array does not exits, create that new array and add data.
                    let newCollection : [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: {error, _ in
                        guard error ==  nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
            
            
        })
        
        
    }
    
    
    // Database Schema
    /*
     
     "conID1234" {
     "messages": [
     {
     "id": String,
     "type": text, photo, video,
     "content": URL/text etc
     "date": Date(),
     "sender_email": String,
     "is_read": true/false
     
     
     }
     ]
     }
     
     
     conversation => [
     conversation_id : conID1234,
     other_user_email: String,
     latest_messageL: {
     date: Date(),
     latest_message: String,
     is_read: true/false
     }
     ]
     */
    
    
    /// This function starts a new conversation with other user's email.
    func createNewConversation(with otherUserEmail: String,name: String, firstMessage: Message, completion: @escaping ((Bool) -> Void)){
        
        guard let currentUserEmail = userDefaults?.string(forKey: "user_email") else{
            print("Could not get cached user email")
            return
            
        }
        
        guard let currentName = userDefaults?.string(forKey: "username") else{
            print("could not get user name")
            return
        }
        let safeEmail = DatabaseManager.getSafeEmail(email: currentUserEmail)
        
        // changes here.
        // from safe Email to otherUserEmail
        let databaseRef = database.child("\(safeEmail)")
        
        // Observe single value event
        databaseRef.observeSingleEvent(of: .value, with: {[weak self]snapshot in
            
            guard let strongSelf = self else{
                return
            }
            
            guard var userNode = snapshot.value as? [String: Any] else{
                print("could not find user")
                return
            }
            // new conversation schema
            let date = firstMessage.sentDate
            let formattedDate = ChatViewController.dateFormatter.string(from: date)
            
            var message = ""
            switch firstMessage.kind{
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData : [String: Any] = [
                "id": "\(conversationId)",
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": formattedDate,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let reciepientConversationData : [String: Any] = [
                "id": "\(conversationId)",
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": formattedDate,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // update recipient conversation entries.
            strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: {[weak self]snapshot in
                
                guard let strongSelf = self else{
                    print("could not get reference to strong self")
                    return
                }
                
                if var conversations = snapshot.value as? [[String: Any]]{
                    // append to the conversation
                    conversations.append(reciepientConversationData)
                    strongSelf.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                    // changed here
                }else{
                    // create new conversation
                    strongSelf.database.child("\(otherUserEmail)/conversations").setValue([reciepientConversationData])
                    
                }
            })
            
            
            
            
            // user found, let's check the conversations.
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                // conversations found, we have to append to these.
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                databaseRef.setValue(userNode, withCompletionBlock: {[weak self]error, _ in
                    guard let strongSelf = self else{
                        print("could not get strong self reference")
                        return
                    }
                    guard error ==  nil else{
                        completion(false)
                        return
                    }
                    strongSelf.finishCreatingConversations(name: name,conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                })
                
            }else{
                // conversations not found, create a new one with schema
                userNode["conversations"] = [newConversationData]
                
                databaseRef.setValue(userNode, withCompletionBlock: {[weak self]error, _ in
                    guard let strongSelf = self else{
                        print("could not get strong self reference")
                        return
                    }
                    
                    guard error ==  nil else{
                        completion(false)
                        return
                    }
                    strongSelf.finishCreatingConversations(name: name,conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                })
            }
            
            
        })// observe single value closure
        
        
        
        
        
    }
    /// Finish creating conversations.
    public func finishCreatingConversations(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
        print("conversation id is \(conversationID)")
        var message = ""
        switch firstMessage.kind{
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        let date = firstMessage.sentDate
        let formattedDate = ChatViewController.dateFormatter.string(from: date)
        
        guard let currentUserEmail = userDefaults?.string(forKey: "user_email") else{
            completion(false)
            return
        }
        let safeUserEmail = DatabaseManager.getSafeEmail(email: currentUserEmail)
        
        let messageToSend: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": formattedDate,
            "sender_email": safeUserEmail,
            "is_read": false,
            "name": name
        ]
        
        
        let value : [String: Any] = [
            "messages": [
                messageToSend
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: {error, _ in
            guard error ==  nil else{
                print("cannot create conversation")
                completion(false)
                return
            }
            completion(true)
            
        })
    }
    
    
    /// This function fetches all the conversations available on the firebase database.
    func fetchAllConversations(for email: String, completion: @escaping ((Result<[ConversationsModel], Error>) -> Void)){
        database.child("\(email)/conversations").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            let conversations : [ConversationsModel] = value.compactMap({dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                          completion(.failure(DatabaseErrors.failedToFetch))
                          return nil
                      }
                
                let latestMessageObj = LatestMessage(message: message,
                                                     date: date,
                                                     isRead: isRead)
                
                let conversationObj = ConversationsModel(id: conversationId,
                                                         name: name,
                                                         otherUserEmail: otherUserEmail,
                                                         latestMessage: latestMessageObj)
                
                return conversationObj
            })
            completion(.success(conversations))
            
        })
    }
    /// This function fetches all the messages for a single conversation.
    func fetchAllMessages(for id: String, completion: @escaping ((Result<[Message], Error>) -> Void)){
        
        
        database.child("\(id)/messages").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                print("inside top block")
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            let messages : [Message] = value.compactMap({dictionary in
                guard let content = dictionary["content"] as? String,
                      let date = dictionary["date"] as? String,
                      let dateString = ChatViewController.dateFormatter.date(from: date),
                      let id = dictionary["id"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let name = dictionary["name"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String else{
                          print("inside lower block")
                          completion(.failure(DatabaseErrors.failedToFetch))
                          return nil
                      }
                let sender = Sender(senderId: senderEmail, displayName: name, photoURL: "")
                return Message(sender: sender, messageId: id, sentDate: dateString, kind: .text(content))
                
            })
            completion(.success(messages))
            
        })
        
        
        
    }
    /// This function sends a message to already created conversation
    /// conversation: conversationId
    /// email: OtherUserEmail
    /// name: Other User Name
    /// new Message: Message Object
    /// completion: completion object
    func sendANewMessage(to conversationID: String,email: String,name: String, newMessage: Message, completion: @escaping ((Bool) -> Void)){
        // add message to messages array
        // update sender latest message
        // update recipient latest message
        
        database.child("\(conversationID)/messages").observeSingleEvent(of: .value, with: {[weak self]snapshot in
            
            
            guard let strongSelf = self else{
                return
            }
            
            
            
            guard var currentMessagesArray = snapshot.value as? [[String: Any]] else{
                return
            }
            
            let date = newMessage.sentDate
            let formattedDate = ChatViewController.dateFormatter.string(from: date)
            
            guard let currentUserEmail = strongSelf.userDefaults?.string(forKey: "user_email") else{
                completion(false)
                return
            }
            let safeCurrentUserEmail = DatabaseManager.getSafeEmail(email: currentUserEmail)
            
            
            var message = ""
            switch newMessage.kind{
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let messageToSend: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": formattedDate,
                "sender_email": safeCurrentUserEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessagesArray.append(messageToSend)
            
            strongSelf.database.child("\(conversationID)/messages").setValue(currentMessagesArray, withCompletionBlock: {error, _ in
                guard error == nil else{
                    completion(false)
                    return
                }
                // update sender latest message, current user
                strongSelf.database.child("\(safeCurrentUserEmail)/conversations").observeSingleEvent(of: .value, with: {snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else{
                        completion(false)
                        print("could not find the current user conversation to update the latest message")
                        return
                    }
                    let updatedValue : [String: Any] = [
                        "is_read": false,
                        "date": formattedDate,
                        "message": message
                    ]
                    var targetConversation : [String: Any]?
                    var position = 0
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentId  = conversationDictionary["id"] as? String, currentId == conversationID{
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                        
                    }
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else{
                        print("could not update the latest message for the current user.")
                        completion(false)
                        return
                    }
                    
                    currentUserConversations[position] = finalConversation
                    // call the firebase method to update that value which we just edited.
                    strongSelf.database.child("\(safeCurrentUserEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: {error, _ in
                        guard error ==  nil else{
                            completion(false)
                            print("could not update the latest message for the current user")
                            return
                        }
                        
                        strongSelf.database.child("\(email)/conversations").observeSingleEvent(of: .value, with: {snapshot in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else{
                                completion(false)
                                print("could not find the other user conversation to update the latest message")
                                return
                            }
                            let updatedValue : [String: Any] = [
                                "is_read": false,
                                "date": formattedDate,
                                "message": message
                            ]
                            var targetConversation : [String: Any]?
                            var position = 0
                            
                            for conversationDictionary in otherUserConversations {
                                if let currentId  = conversationDictionary["id"] as? String, currentId == conversationID{
                                    targetConversation = conversationDictionary
                                    break
                                }
                                position += 1
                                
                            }
                            targetConversation?["latest_message"] = updatedValue
                            guard let finalConversation = targetConversation else{
                                print("could not update the latest message for the current user.")
                                completion(false)
                                return
                            }
                            
                            otherUserConversations[position] = finalConversation
                            // call the firebase method to update that value which we just edited.
                            strongSelf.database.child("\(email)/conversations").setValue(otherUserConversations, withCompletionBlock: {error, _ in
                                print("inside updating other")
                                guard error ==  nil else{
                                    completion(false)
                                    print("could not update the latest message for the current user")
                                    return
                                }
                                
                                
                                completion(true)
                            })
                        })
                        
                    })
                })
            })
            
        })// added message to messages array and updated.
        
    }
    
    /// this function fetches the data from firebase given the parent node name.
    func getDataFromNode(path: String, completion: @escaping ((Result<Any, Error>) -> Void)){
        database.child("\(path)").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
}


struct User{
    let firstName: String
    let lastName: String
    let email: String
    
    var safeEmail: String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
        
    }
    var profilePictureFileName: String{
        return "\(safeEmail)_profile_picture.png"
    }
    
    
    //  let profilePicture: String
}


public enum DatabaseErrors: Error{
    case failedToFetch
    
}
