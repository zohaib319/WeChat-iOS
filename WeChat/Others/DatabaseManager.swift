//
//  DatabaseManager.swift
//  WeChat
//
//  Created by Zohaib on 26/03/2022.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    /// This function validates if there is an account already registered with the provided email.
    public func userExists(email: String, completion: @escaping ((Bool) ->Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    static func getSafeEmail(email: String) -> String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
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
            completion(true)
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
