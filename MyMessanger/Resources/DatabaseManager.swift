//
//  DatabaseManager.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 17/12/2020.
//

import Foundation
import FirebaseDatabase
import MessageKit

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
        let safeEmail = ChatAppUser.safeEmail(emailAddress: email)
        self.database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            // Get user value
            let value = snapshot.value as? NSDictionary
            guard value?["first_name"] != nil else {
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
        
        
        // Create the current user conversation and upload it to the database
        
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
        
        //add it to the database in the "conversation" child under the currentUserSafeEmail
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
        
        // Create the other  user conversation and upload it to the database
        
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
        
        //add it to the database in the "conversation" child under the currentUserSafeEmail
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
    public func getAllConversation(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        
        // get all the conversations to the current email
        self.database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return completion(.failure(DatabaseErrors.failedToFetch))
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMassege = dictionary["latest_message"] as? [String: Any],
                      let isRead = latestMassege["is_read"] as? Bool,
                      let date = latestMassege["date"] as? String,
                      let message = latestMassege["message"] as? String else {

                    return nil
                }
                
                let latestMessageObject = LatestMessege(date: date,
                                                        text: message,
                                                        isRead: isRead)
                
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessege: latestMessageObject)
                      
            })
            
            completion(.success(conversations))
            
        })
    }

    
    
    ///Gets all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        // get all the conversations to the current email
        self.database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return completion(.failure(DatabaseErrors.failedToFetch))
            }
            
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
                  
                
                
                //check the message type
                var messageKind: MessageKind?
                
                if messageType == "text" {
                    messageKind = .text(content)
                }
                else if messageType == "photo" {
                    // photo
                    guard let imageUrl = URL(string: content),
                          let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300, height: 300))
                    messageKind = .photo(media)
                }
                else if messageType == "location" {
                    //TODO: complete this
                }
                
                guard let finalMessageKind = messageKind else {
                    return nil
                }
                
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageId,
                               sentDate: date,
                               kind: finalMessageKind)
            })
            
            completion(.success(messages))
            
        })

    }
    
    ///Sends a message with target conversation and message
    public func sendMessage(conversationId: String, name: String, oherUserEmail: String, newMessage: Message,completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
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

        
        // 1- add new message to messages
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
        
        let updatedLatestMessage: [String: Any] = [
            "date": messageDateString,
            "is_read": false,
            "message": messageContent
        ]

        updateLatestMessageForEmail(email: currentSafeEmail, conversationId: conversationId, newLatestMessage: updatedLatestMessage, completion: { success in
            if !success {
                completion(false)
            }
            
        })
        
        
        
        // 3- update recipient latest message
        updateLatestMessageForEmail(email: otherUserSafeEmail, conversationId: conversationId, newLatestMessage: updatedLatestMessage, completion: { success in
            if !success {
                completion(false)
            }
        })
        completion(true)
    }
    
    
    



}//end of extension



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
        case .video(_):
            break
        case .location(_):
            break
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
    
    private func updateLatestMessageForEmail(email: String, conversationId: String, newLatestMessage: [String: Any], completion: @escaping (Bool) ->Void ) {
        
        self.database.child("\(email)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
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
            
            requiredConversation?["latest_message"] = newLatestMessage
            guard let updatedConversation = requiredConversation else {
                completion(false)
                return
            }
            
            currentUserConversations[position] = updatedConversation
            strongSelf.database.child("\(email)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
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
