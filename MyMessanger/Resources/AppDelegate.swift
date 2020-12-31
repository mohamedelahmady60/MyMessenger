//
//  AppDelegate.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        //configure the fire base
        FirebaseApp.configure()
        
        //facebook sign in 
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        //google sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    
    //MARK: - google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let  error = error {
            print("Failed to sign in with google: \(error)")
            return
        }
        
        print("Did sign in with google")
        
        //get the user information
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName,
              user.profile.hasImage == true,
              let profileImageURL = user.profile.imageURL(withDimension: 200)  else {
            
            return
        }
        
        
        //save the user's email address and name
        UserDefaults.standard.setValue(email, forKey: "email")
        UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")


        
        //check if this user is exists in the database
        DatabaseManager.shared.userExists(with: email) { (exists) in
            //if doesn't exist add it to the data base and complete the code to log him in
            if !exists {
                let chatAppUser = ChatAppUser(firstName: firstName,
                                              lastName: lastName,
                                              emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatAppUser) { (success) in
                    if success{
                        //Upload the profile image
                        
                        //download the image data
                        URLSession.shared.dataTask(with: profileImageURL) { (data, _, _) in
                            guard let data = data else {
                                return
                            }
                            let fileName = chatAppUser.profilePictureFileName
                            //upload the picture
                            StrorageManager.shared.uploadProfilePicture(with: data,
                                                                        fileName: fileName) { (result) in
                                
                                switch result {
                                case .success(let downloadURL):
                                    UserDefaults.standard.setValue(downloadURL, forKey: "Profile_Picture_URL")
                                    print(downloadURL)
                                case .failure(let error):
                                    print("Storage manager error : \(error)")
                                }
                                
                            }
                            
                        }.resume()
                        
                    }
                
                }
            
            }
            //else if he exists complete the login in without saving the user data
        }
        
        //get the authentication from google
        guard let authentication = user.authentication else {
            print("Missing auth object of google user")
            return
        }
        // get the credential
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        
        
        // give the credential to the firebase so we can sign the in
        FirebaseAuth.Auth.auth().signIn(with: credential) {(authResult, error) in
            
            guard authResult != nil, error == nil else {
                print("Google credential login failed ")
                return
            }
            
            print("successfully signed in with google credential")
            // fire the notification so the loginview can dismisses itself
            NotificationCenter.default.post(name: .didLoginNotification, object: nil)

        }
        
    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        print("Google user was disconnected")
    }
    
    
    
}
