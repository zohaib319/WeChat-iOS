//
//  AccountController.swift
//  WeChat
//
//  Created by Zohaib on 19/03/2022.
//

import Foundation
import SwiftKeychainWrapper

class AccountController{
    static let shared = AccountController()
    
    private(set) var accessToken: String?
    
    private init(){
        self.loadToken()
    }
    
    
    func save(accessToken: String) {
        self.accessToken = accessToken
        KeychainWrapper.standard.set(accessToken, forKey: Key.token)
        
    }
    
    func deleteAccessToken(){
        self.accessToken = nil
        KeychainWrapper.standard.removeObject(forKey: Key.token)
    }
    
    @discardableResult
    func loadToken() -> String? {
        self.accessToken = KeychainWrapper.standard.string(forKey: Key.token)
        return self.accessToken
    }
}



private extension AccountController {
    enum Key {
        static let token = "com.tampontribe.pickleup.userAccessToken"
    }
}
