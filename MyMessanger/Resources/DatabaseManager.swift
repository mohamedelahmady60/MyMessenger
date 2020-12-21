//
//  DatabaseManager.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 17/12/2020.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    //sengleton (only one shared object)
    static  let shared = DatabaseManager()
    
    //refrence to our database
    private let database = Database.database().reference()
    
    
    /// checks if user email is already exists
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        //(child:) Must be a non-empty string and not contain '.' '#' '$' '[' or ']''
        var safeEmail = email.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        
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
    
    
    
    /// insert new user to database
    public func insertUser (with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        self.database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ]) { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    
    
}


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
    
}
