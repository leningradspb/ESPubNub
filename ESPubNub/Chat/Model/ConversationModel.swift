//
//  ConversationModel.swift
//  ESPubNub
//
//  Created by Eduard Sinyakov on 03.06.2021.
//

import Foundation

struct ConversationData {
    var conversations: [Conversation]?

  /*  init?(with snapshot: DataSnapshot) {
        var conversations = [Conversation]()
        guard let snapDict = snapshot.value as? [String: [String: AnyObject]] else { return nil }
//        var conversation: Conversation?
        for snap in snapDict {
//            conversations.removeAll()
//            messagesWithInterlocutor.removeAll()
//            print(snap)
            let userID = snap.key
            var message: Message?
            var user: User?
            let dict = snap.value
            let values = dict.values

            conversations.append(Conversation(user: user, lastMessage: message))
        }
        self.conversations = conversations
    } */
    
    struct Conversation {
        let lastMessage: Message?
    }
}

struct Message {
    let formID: String?
    let message: String?
    let toID: String?
    let timestamp: Double?

    init?(dict: [String: AnyObject]) {

        guard let formID = dict["formID"] as? String,
        let message = dict["message"] as? String,
        let toID = dict["toID"] as? String,
        let timestamp = dict["timestamp"] as? Double
        else { return nil }
        self.formID = formID
        self.message = message
        self.toID = toID
        self.timestamp = timestamp
    }
}
