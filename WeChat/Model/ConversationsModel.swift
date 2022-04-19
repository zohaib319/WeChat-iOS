//
//  ConversationsModel.swift
//  WeChat
//
//  Created by Zohaib on 28/03/2022.
//

import Foundation
struct ConversationsModel{
    var id: String
    var name: String
    var otherUserEmail: String
    var latestMessage: LatestMessage   
}


struct LatestMessage{
    var message: String
    var date: String
    var isRead: Bool
}
