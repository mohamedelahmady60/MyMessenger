//
//  ConversationModels.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 02/01/2021.
//

import Foundation

struct Conversation {
    let id: String
    let recipientName: String
    let recipientEmail: String
    let latestMessege: LatestMessege
}

struct LatestMessege {
    let date: String
    let text: String
    let isRead: Bool
}
