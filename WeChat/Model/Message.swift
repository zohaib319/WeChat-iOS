//
//  Message.swift
//  WeChat
//
//  Created by Zohaib on 28/03/2022.
//

import Foundation
import MessageKit

struct Message: MessageType{
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    
}
