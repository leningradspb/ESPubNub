//
//  ConversationModel.swift
//  ESPubNub
//
//  Created by Eduard Sinyakov on 03.06.2021.
//

import Foundation

struct ConversationData {
    var conversations: [Conversation]?

  
    
    struct Conversation {
        let lastMessage: Message?
    }
}

struct Message {
    let formID: String?
    let message: String?
    let toID: String?
    let timestamp: Double?
}
