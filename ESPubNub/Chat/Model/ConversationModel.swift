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
        var lastMessage: Message?
    }
}

struct Message {
    let fromID: String?
    let message: String?
    let toID: String?
    let timestamp: Double?
    let channel: String
}
