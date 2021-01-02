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
import SDWebImage



final class ProfileViewController: UIViewController {
    
    //MARK: - table view
    @IBOutlet var tableview: UITableView!
    
    //MARK: - profile data
    var data = [ProfileViewModel]()
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register the table view cell
        tableview.register(profileTableViewCell.self, forCellReuseIdentifier: profileTableViewCell.identifier)
        
        // append the profile data
        let userName = UserDefaults.standard.value(forKey: "name") as? String
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Name: \(userName ?? "No name")", handler: nil))
        
        let userEmail = UserDefaults.standard.value(forKey: "email") as? String
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Email: \(userEmail ?? "No Email")", handler: nil))

        
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log Out", handler: { [weak self] in
            self?.didTapLogout()
        }))

 
        //set the table view cell identifier
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //set table view data sources and delegates
        tableview.dataSource = self
        tableview.delegate = self
        //set the table view header
        tableview.tableHeaderView = createTableHeader()
        
    }
    
    
    //MARK: - Actions
    private func didTapLogout() {
        //create an alert to ask the user to conform logging out
        let actionSheet = UIAlertController(title: "Log out?",
                                            message: "",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self ] _ in
            guard let strongSelf = self else {
                return
            }
            // remove the cashed data
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.setValue(nil, forKey: "name")
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
        
        StrorageManager.shared.downloadURL(path: imagePath) { (result) in
            switch result {
            case .success(let url):
                // download the user image view
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url\(error)")
            }
        }
        return headerView
    }
    
}// end of class
    


//MARK: - Tableview delegate and datasource methods
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: profileTableViewCell.identifier,
                                                 for: indexPath) as! profileTableViewCell
        let viewModel = self.data[indexPath.row]
        cell.setup(viewModel: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        // call the handler to the selected row
        data[indexPath.row].handler?()
    }
    
} // end of extension


class profileTableViewCell: UITableViewCell {
    
    static let identifier = "profileTableViewCell"
    
    
    public func setup(viewModel: ProfileViewModel) {
        
        self.textLabel?.text = viewModel.title
        
        switch viewModel.viewModelType {
        case .info:
            self.textLabel?.textAlignment = .left
            self.selectionStyle = .none
        case .logout:
            self.textLabel?.textColor = .red
            self.textLabel?.textAlignment = .center
        }
    }
}
