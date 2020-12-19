//
//  ProfileViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    //MARK: - table view
    @IBOutlet var tableview: UITableView!
    
    
    let data = ["Log Out"]
    
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the table view cell identifier
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //set table view data sources and delegates
        tableview.dataSource = self
        tableview.delegate = self
        
    }
    
}



//MARK: - Tableview delegate and datasource methods
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        
        
        //create an alert to ask the user to conform logging out
        let actionSheet = UIAlertController(title: "Log out?",
                                            message: "",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                            style: .destructive,
                                            handler: { [weak self ]_ in
                                                
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                
                                                //log out from facebook
                                                FBSDKLoginKit.LoginManager().logOut()
                                                
                                                //log out from google
                                                GIDSignIn.sharedInstance()?.signOut()
                                                
                                                //log out from firebase
                                                do {
                                                    try Auth.auth().signOut()
                                                    //got to log in screen again
                                                    //jump to log in view
                                                    let nextVC = LoginViewController()
                                                    let nav = UINavigationController(rootViewController: nextVC)
                                                    nav.modalPresentationStyle = .fullScreen
                                                    strongSelf.present(nav, animated: true)
                                                    
                                                    
                                                } catch  {
                                                    print ("Failed to log out:\(error) ")
                                                }
                                                
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
        
    }
}
