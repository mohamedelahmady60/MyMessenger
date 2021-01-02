//
//  ChatModels.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 02/01/2021.
//

import Foundation
import CoreLocation
import MessageKit

//MARK: - Message Kind extension
extension MessageKind {
    
    var string: String {
        
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}



//MARK: - define the message model that comes from MessageKit
struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}


struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}


struct LocationMediaItem: LocationItem {
    var location: CLLocation
    var size: CGSize
}
