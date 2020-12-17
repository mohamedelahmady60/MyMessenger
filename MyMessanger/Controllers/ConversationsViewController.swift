//
//  ConversationsViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //check if the user alredy logged in
        let isLogged = UserDefaults.standard.bool(forKey: "logged_in")
        if !isLogged {
           //jump to log in view
            let nextVC = LoginViewController()
            let nav = UINavigationController(rootViewController: nextVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        } else {
            
        }
        
        
    }
}
