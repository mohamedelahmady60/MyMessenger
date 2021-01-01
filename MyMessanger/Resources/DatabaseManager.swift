//
//  DatabaseManager.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 17/12/2020.
//

import Foundation
import FirebaseDatabase
import MessageKit
import CoreLocation

final class DatabaseManager {
    
    //sengleton (only one shared object)
    static  let shared = DatabaseManager()
    
    //refrence to our database
    private let database = Database.database().reference()
    
    
    
}// end of class


//MARK: - Deals with Users informations
extension DatabaseManager {
    
    
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
                // add the user to email child
        self.addNewUserToEmailChild(user: user, completion: { success in
            if success {
                completion(true)
            }else {
                completion(false)
            }
        })
        // add the user to users child
        self.addNewUserToUsersChilld(user: user, completion: { success in
            if success {
                completion(true)
            }else {
                completion(false)
            }
        })
    }
    
    
    
    /// Checks if user email is already exists
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        // 1- get the safe email
        let safeEmail = ChatAppUser.safeEmail(emailAddress: email)
        // 2- check if the safe email exists in the database
        self.database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    
    /// Get all Users From the database
    public func getAllUsers(completion: @escaping (Result<[[String: String]],Error>) -> Void) {
        //get all users
        self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    /// Gets  data for a specific child
    public func getDataForChild(childPath: String, completion: @escaping (Result<Any, Error>)-> Void) {
        self.database.child(childPath).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }

}// end of extension


//MARK: - Deals with Users informations (helper methods)
extension DatabaseManager {
    
    
    //add a new user to the email child
    private func addNewUserToEmailChild(user: ChatAppUser, completion: @escaping (Bool) -> Void){
        let newUser = [
            "first_name": user.firstName,
            "last_name": user.lastName
        ]
        //add the user to the (userEmail) Child
        self.database.child(user.safeEmail).setValue(newUser, withCompletionBlock: {error , _ in
            guard error == nil else {
                completion(false)
                return
            }
        })
    }
    
    
    
    //add a new user to the users child
    private func addNewUserToUsersChilld(user: ChatAppUser, completion: @escaping (Bool) -> Void){
        self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            // if the "users" child already exists
            if var usersCollection = snapshot.value as? [[String: String]] {
                //apppend the new users
                let newElement = [
                    "name": user.firstName + " " + user.lastName,
                    "email": user.safeEmail
                ]
                usersCollection.append(newElement)
                //update the users child to add the new user
                self.database.child("users").setValue(usersCollection, withCompletionBlock:{ error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
            // if the "users" child does not exist
            else {
                //create the dictionary
                let newCollection:[[String: String]] = [
                    [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                        
                    ]
                ]
                // add the users
                self.database.child("users").setValue(newCollection, withCompletionBlock:{ error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
        })
    }
   
    
}// end of extension


//MARK: - Deals with conversations

extension DatabaseManager {
    
    
    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(otherUserEmail: String, otherUserName:String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
        let commonConversationId = "conversation_\(firstMessage.messageId)"
        let messageDate = firstMessage.sentDate
        let messageDateString = ChatViewController.dateFormatter.string(from: messageDate)
        let messageContent = getMessageContent(message: firstMessage)
        
        
        // 1- Create the current user conversation to upload it to the database
        // create the conversation
        let currentUserNewConversationData: [String: Any] = [
            "id": commonConversationId,
            "other_user_email": otherUserEmail,
            "name": otherUserName,
            "latest_message": [
                "date": messageDateString,
                "message":messageContent,
                "is_read": false
            ]
        ]
        
        // 2- upload it to the database in the "conversation" child under the currentUserSafeEmail
        //get the current user email
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUserName = UserDefaults.standard.value(forKey: "name") as? String else {
            completion(false)
            return
        }
        let currentUserSafeEmail = ChatAppUser.safeEmail(emailAddress: currentUserEmail)
        createNewConversationForEmail(email: currentUserSafeEmail, newConversation: currentUserNewConversationData, completion: { [weak self] success in
            guard let strongSelf = self else { return }
            if success {
                // create the "conversationId" child and upload the message int it
                strongSelf.finishCreatingConversation(name: otherUserName,
                                                      conversationId: commonConversationId,
                                                      firstMessage: firstMessage,
                                                      completion: { success in
                                                        
                                                        if !success {completion(false)}
                                                      })
            }
            else {
                completion(false)
            }
        })
        
        // 3- Create the other  user conversation to upload it to the database
        // create the conversation
        let recepientUsernewConversationData: [String: Any] = [
            "id": commonConversationId,
            "other_user_email": currentUserSafeEmail,
            "name": currentUserName,
            "latest_message": [
                "date": messageDateString,
                "message":messageContent,
                "is_read": false
            ]
        ]
        
        // 4- upload it to the database in the "conversation" child under the recipientUserSafeEmail
        //get the current user email
        let recipientUserEmail = otherUserEmail
        let recipientUserSafeEmail = ChatAppUser.safeEmail(emailAddress: recipientUserEmail)
        createNewConversationForEmail(email: recipientUserSafeEmail, newConversation: recepientUsernewConversationData, completion: { success in
            if success {
                completion(true)
            }else {
                completion(false)
            }
        })
    }

    
    
    
    /// Fetches and returns all conversation for the user with passed in email
    public func getAllConversation(completion: @escaping (Result<[Conversation], Error>) -> Void) {
        
        // 1- get the current user email
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = ChatAppUser.safeEmail(emailAddress: email)
        // 2- get all the conversations to the current email
        self.database.child("\(safeEmail)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            // create the conversation arry from the value we got
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMassege = dictionary["latest_message"] as? [String: Any],
                      let latestMassegeIsRead = latestMassege["is_read"] as? Bool,
                      let latestMassegeDate = latestMassege["date"] as? String,
                      let latestMassegeContent = latestMassege["message"] as? String else {
                    return nil
                }
                let latestMessageObject = LatestMessege(date: latestMassegeDate,
                                                        text: latestMassegeContent,
                                                        isRead: latestMassegeIsRead)
                return Conversation(id: conversationId,
                                    recipientName: name,
                                    recipientEmail: otherUserEmail,
                                    latestMessege: latestMessageObject)
                      
            })
            // 3- return the conversations
            completion(.success(conversations))
            
        })
    }

    
    
    ///Gets all messages for a given conversation
    public func getAllMessagesForConversation(conversationId: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        // 1- get all the conversations to the current email
        self.database.child("\(conversationId)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return completion(.failure(DatabaseErrors.failedToFetch))
            }
            
            // 2- walk through evey message
            let messages: [Message] = value.compactMap({ dictionary in
                
                guard let name = dictionary["name"] as? String,
                      let content = dictionary["content"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let messageType = dictionary["type"] as?String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                    
                    return nil
                }
                
                // 3- check the message type
                var messageKind: MessageKind?
                // text
                if messageType == "text" {
                    messageKind = .text(content)
                }
                // photo
                else if messageType == "photo" {
                    guard let imageUrl = URL(string: content),
                          let placeHolder = UIImage(named: "photoPlaceholder") else {
                        return nil
                    }
                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300, height: 300))
                    messageKind = .photo(media)
                }
                // video
                else if messageType == "video" {
                    guard let videoUrl = URL(string: content),
                          let placeHolder = UIImage(named: "videoPlaceholder") else {
                        return nil
                    }
                    let media = Media(url: videoUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300, height: 300))
                    messageKind = .video(media)
                }
                // location
                else if messageType == "location" {
                    // get the longitude and the latiude
                    // remove the comma between the longitude and latitude
                    let locationComponent = content.components(separatedBy: ",")
                    
                    guard let longitude = Double(locationComponent[0]),
                          let latitude = Double(locationComponent[1]) else {
                        return nil
                    }
                    
                    // create the LocationItem
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    let locationItem = LocationMediaItem(location: location,
                                                         size: CGSize(width: 300, height: 300))
                    messageKind = .location(locationItem)
                }
                guard let finalMessageKind = messageKind else {
                    return nil
                }
                
                // create the message
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageId,
                               sentDate: date,
                               kind: finalMessageKind)
            })
            // 4- return all messages
            completion(.success(messages))
        })
    }
    
    
    /// Sends a message with target conversation and message
    public func sendMessage(conversationId: String, otherUserName: String, oherUserEmail: String, newMessage: Message,completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUserName = UserDefaults.standard.value(forKey: "name") as? String else {
            completion(false)
            return
        }
        let currentSafeEmail = ChatAppUser.safeEmail(emailAddress: currentEmail)
        let otherUserSafeEmail = ChatAppUser.safeEmail(emailAddress: oherUserEmail)
        let messageDate = newMessage.sentDate
        let messageDateString = ChatViewController.dateFormatter.string(from: messageDate)
        let messageContent = getMessageContent(message: newMessage)
        
        let newMessageEntry: [String: Any] = [
            "id": newMessage.messageId,
            "type": newMessage.kind.string,
            "content": messageContent,
            "date": messageDateString,
            "sender_email": currentSafeEmail,
            "is_read": false,
            "name": ""
        ]
        // 1- add new message to messages ("conversationID" child)
        self.database.child("\(conversationId)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String: Any]] else  {
                completion(false)
                return
            }
            // create the message
            currentMessages.append(newMessageEntry)
            strongSelf.database.child("\(conversationId)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                } 
            })
        })
        // 2- update sender latest message
        updateLatestMessageForEmail(currentUserEmail: currentSafeEmail, otherUserEmail: otherUserSafeEmail, otherUserName: otherUserName, conversationId: conversationId, newMessage: newMessage, completion: { [weak self] success in
            
            if success {
                // 3- update recipient latest message
                self?.updateLatestMessageForEmail(currentUserEmail: otherUserSafeEmail, otherUserEmail: currentSafeEmail, otherUserName: currentUserName, conversationId: conversationId, newMessage: newMessage, completion: { success in
                    if success {
                        completion(true)
                        return
                    }
                    else {
                        completion(false)
                        return
                    }
                })
            }
            else {
                completion(false)
                return
            }
        })
    }
    


    /// delete a specific conversation according conversationId
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void){
        
        // 1- get the user email
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let currentSafeEmail = ChatAppUser.safeEmail(emailAddress: currentEmail)
        
        // 2- get all conversations for the current user
        let ref = self.database.child("\(currentSafeEmail)/conversations")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            guard var conversations = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            // 3- delete the required conversation
            var positionToRemove = 0
            for conversation in conversations {
                if let convId = conversation["id"] as? String,
                   convId == conversationId {
                    break
                }
                positionToRemove += 1
            }
            conversations.remove(at: positionToRemove)
            // 4- reset those conversarions for the user in database
            ref.setValue(conversations, withCompletionBlock: {error,_ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
        })
    }
    
    public func conversationExists(RecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void ) {
        
        // 1- get the safe recipient email
        let safeRecipientEmail = ChatAppUser.safeEmail(emailAddress: RecipientEmail)
        
        // 2- get the sender safe email
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = ChatAppUser.safeEmail(emailAddress: senderEmail)
        
        // 3- get all the conversation in the "recipientEmail" child
        self.database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let recipientEmailConversations = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            // 3- check if there is a conversation exists with the senderUser
            if let currentConversation = recipientEmailConversations.first(where: {
                guard let currentConversationSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return currentConversationSenderEmail == safeSenderEmail
            }){
                // if it the conversation exists then we want the convId
                guard let currentConversationId = currentConversation["id"] as? String else {
                    completion(.failure(DatabaseErrors.failedToFetch))
                    return
                }
                completion(.success(currentConversationId))
                return
            }
            completion(.failure(DatabaseErrors.failedToFetch))
            return

            
        })
    }


}// end of extension



//MARK: - Deals with conversations (helper methods)
extension DatabaseManager {
    
    // get the message content according to its kind
    private func getMessageContent(message: Message) -> Any {
        switch message.kind {
        case .text(let messageText):
            return messageText
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString {
                return targetUrlString
            }
        case .video(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString {
                return targetUrlString
            }
        case .location(let locationItem):
            let location = locationItem.location
            let longitude = location.coordinate.longitude
            let latitude = location.coordinate.latitude
            // the message content form will be
            return "\(longitude),\(latitude)"
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        return ""
    }

    
    // create a new conversastion to specific email
    private func createNewConversationForEmail(email: String, newConversation: [String: Any], completion: @escaping (Bool) -> Void) {

        self.database.child(email).observeSingleEvent(of: .value, with: { [weak self] snapshot in

            guard let strongSelf = self else { return }
            guard var UserNode = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }

            // if the "conversations" child already exists
            if var conversations = UserNode["conversations"] as? [[String: Any]] {
                // Append the new conversation
                conversations.append(newConversation)
                UserNode["conversations"] = conversations
                strongSelf.database.child(email).setValue(UserNode, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
            else {
                // if the "conversations" child does not exist
                // create "conversations" child and Append the new conversation
                UserNode["conversations"] = [newConversation]
                strongSelf.database.child(email).setValue(UserNode, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
        })
    }
    
    
    //create the "conversation" child with unique id
    private func finishCreatingConversation(name: String, conversationId: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentSafeEmail = ChatAppUser.safeEmail(emailAddress: currentEmail)

        
        let messageDate = firstMessage.sentDate
        let messageDateString = ChatViewController.dateFormatter.string(from: messageDate)
        let messageContent =  getMessageContent(message: firstMessage)
        
        
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.string,
            "content": messageContent,
            "date": messageDateString,
            "sender_email": currentSafeEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                message
            ]
        ]
        self.database.child(conversationId).setValue(value, withCompletionBlock: { error, _ in
            
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
        
    }
    
    private func updateLatestMessageForEmail(currentUserEmail: String, otherUserEmail: String,
                                             otherUserName: String, conversationId: String,
                                             newMessage: Message, completion: @escaping (Bool) ->Void ) {
        
        // create a new conversation
        let messageDate = newMessage.sentDate
        let messageDateString = ChatViewController.dateFormatter.string(from: messageDate)
        let messageContent = getMessageContent(message: newMessage)

        let updatedLatestMessage: [String: Any] = [
            "date": messageDateString,
            "is_read": false,
            "message": messageContent
        ]

        
        // 1- get the conversations for the current array
        var databaseEntryConversations = [[String: Any]]()
        self.database.child("\(currentUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            // if it is exists check for the reuired conversation
            if  var currentUserConversations = snapshot.value as? [[String: Any]]  {
                
                var requiredConversation: [String: Any]?
                var position = 0
                // search for the selected convesationId
                for currentUserConversation in currentUserConversations {
                    if let currentConversationId = currentUserConversation["id"] as? String ,
                       currentConversationId == conversationId {
                        requiredConversation = currentUserConversation
                        break
                    }
                    position += 1
                }
                // if exists update its latest message
                if var foundedRequiredConversations = requiredConversation {
                    foundedRequiredConversations["latest_message"] = updatedLatestMessage
                    currentUserConversations[position] = foundedRequiredConversations
                    databaseEntryConversations = currentUserConversations
                }
                //if it does not exist create a new conversations
                else {
                    let currentUserNewConversationData: [String: Any] = [
                        "id": conversationId,
                        "other_user_email": otherUserEmail,
                        "name": otherUserName,
                        "latest_message": updatedLatestMessage
                    ]
                    currentUserConversations.append(currentUserNewConversationData)
                    databaseEntryConversations = currentUserConversations
                }
            }
            else {
                //if it does not exist create a new conversations
                let currentUserNewConversationData: [String: Any] = [
                    "id": conversationId,
                    "other_user_email": otherUserEmail,
                    "name": otherUserName,
                    "latest_message": updatedLatestMessage
                ]
                databaseEntryConversations = [currentUserNewConversationData]
            }
            
            strongSelf.database.child("\(currentUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
        })
    }



}// end of extension




//MARK: - Chat app user struct
struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    
    var safeEmail: String {
        //(child:) Must be a non-empty string and not contain '.' '#' '$' '[' or ']''
        var safeEmail = self.emailAddress.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    //transform the email to a safe email
    static func safeEmail(emailAddress: String ) -> String {
        //(child:) Must be a non-empty string and not contain '.' '#' '$' '[' or ']''
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        return safeEmail
    }
    
    
}// end of class


//MARK: - database errors structs
public enum DatabaseErrors: Error {
    case failedToFetch
}
