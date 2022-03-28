//
//  StorageManager.swift
//  WeChat
//
//  Created by Zohaib on 28/03/2022.
//

import Foundation
import FirebaseStorage

/// Storage Manager Class to perform different operations with Firebase Storage.
class StorageManager{
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias uploadPictureCompletion = ((Result<String, Error>) -> Void)
    
    /// Function to put profile picture to Firebase.
    public func uploadProfilePictureToFirebase(with data: Data, fileName: String, completion: @escaping uploadPictureCompletion){
        
        // uploading picture to Firebase Storage.
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {metaData, error in
            
            
            
            // if there is an error while uploading the picture.
            guard error ==  nil else{
                completion(.failure(StorageError.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    completion(.failure(StorageError.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                completion(.success(urlString))
            })
        })
    }
    
    /// Get Download URL Providing a path. 
    func getDownloadURl(from path: String, completion:@escaping ((Result<URL, Error>) -> Void)){
        let reference = storage.child(path)
        
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageError.failedToGetDownloadURL))
                return
            }
            
            completion(.success(url))
        })
    }
    
    
    /// Enum to display Storage Errors from Firebase.
    public enum StorageError: Error{
        case failedToUpload
        case failedToGetDownloadURL
    }
}
