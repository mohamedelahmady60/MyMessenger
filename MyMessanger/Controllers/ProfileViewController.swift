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
        //set the table view header
        tableview.tableHeaderView = createTableHeader()
        
    }
    
    
    func createTableHeader() -> UIView? {
        
        // get the current user email
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else  {
            return nil
        }
        
        let safeEmail = ChatAppUser.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let imagePath = "images/" + fileName
        
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.view.width,
                                              height: self.view.height / 4.0))
        headerView.backgroundColor = .link
        let imageViewWidth = headerView.width / 3.0
        let imageView = UIImageView(frame: CGRect(x:  (headerView.width - imageViewWidth) / 2.0,
                                                  y:  (headerView.height - imageViewWidth) / 2.0,
                                                  width: imageViewWidth,
                                                  height:  imageViewWidth))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2.0
        
        headerView.addSubview(imageView)
        
        StrorageManager.shared.downloadURL(path: imagePath) { [weak self](result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                strongSelf.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to get download url\(error)")
            }
        }
        return headerView
    }
    
    
    
    func downloadImage(imageView: UIImageView, url: URL){
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
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
