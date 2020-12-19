//
//  ConversationsViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //check if the user is already logged in
        validateAuth()
    }
    
    
    private func validateAuth() {
        if Auth.auth().currentUser == nil {
           //jump to log in view
            let nextVC = LoginViewController()
            let nav = UINavigationController(rootViewController: nextVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }

    }
}
