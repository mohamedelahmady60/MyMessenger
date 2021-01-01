//
//  NewConversationViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {

    //MARK: - search bar
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()

    //MARK: - Table view
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NewConversationTableViewCell.self,
                           forCellReuseIdentifier: NewConversationTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    //MARK: - Spinner
    private let spinner = JGProgressHUD(style: .dark)

    //MARK: - label
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    //MARK: - users array
    private var users = [[String: String]]()
    private var hasFetchedUsers = false
    private var results = [SearchResults]()
    
    
    public var completion: ((SearchResults) -> (Void))?


    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //set the view color
        view.backgroundColor = .systemBackground
        
        //set the table view delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        //set the searchBar delegae
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        //set the search bar on the top of the navigation controller
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        //set cancel button so the user can dismiss the view
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapCancelButton))
        
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
    }
    
    //MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //set the table view frame
        tableView.frame = view.bounds
        
        //set the noResultsLabel  frame
        let noResultsLabelWidth = view.width / 2.0
        let noResultsLabelheight: CGFloat = 200
        noResultsLabel.frame = CGRect(x: (view.width - noResultsLabelWidth) / 2.0,
                                      y: (view.height - noResultsLabelheight) / 2.0,
                                      width: noResultsLabelWidth,
                                      height: noResultsLabelheight)

    }
    
    
    //MARK: - Actions
    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }

}


//MARK: - UISearchBarDelegate methods and our created helper methods
extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //remove the keyboard
        self.searchBar.resignFirstResponder()
        
        // check there is text and remove its spaces
        guard let text = searchBar.text, !text.replacingOccurrences(of:" ", with: "").isEmpty else {
            return
        }
        //remove all the previous results
        results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: text)
    }
    
    
    
    //search the users and update the table view
    private func searchUsers(query: String) {
        
        // 1- check if we fetched the user before
        if hasFetchedUsers {
            //if it does: go and search for the query
            self.filterUsers(searchName: query)
        }
        else {
            //if not: fetch the the users from database and then seach for the query
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .failure(let error):
                    print("Failed to get users: \(error)")
                case .success(let usersCollection):
                    self?.hasFetchedUsers = true
                    self?.users = usersCollection
                    self?.filterUsers(searchName: query)
                }
            })
        }
    }
    
    //filter the users according the search term
    private func filterUsers(searchName: String) {
        
        //1- get the current user email
        guard hasFetchedUsers, let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let currentSafeEmail = ChatAppUser.safeEmail(emailAddress: currentEmail)
        self.spinner.dismiss()
        
        // search for the query
        let results: [SearchResults] = self.users.filter({
            guard let email = $0["email"], email != currentSafeEmail,
                  let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(searchName.lowercased())
            
        }).compactMap({
            
            guard let email = $0["email"],
                  let name = $0["name"] else {
                return nil
            }
            return SearchResults(recipientName: name, recipientEmail: email)
        })
        self.results = results
        
        //update the UI: either show results or show no results label
        self.updateUI()
    }
    
    //update the UI after searching
    private func updateUI() {
        if results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}// end of class




//MARK: - UITableViewDelegate, UITableViewDataSource methods
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationTableViewCell.identifier,
                                                 for: indexPath) as! NewConversationTableViewCell
        let currentResultModel = results[indexPath.row]
        cell.configure(with: currentResultModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //TODO: start a conversation with the selected user
        let tergetUserData = self.results[indexPath.row]
        
        //dismiss the curent view
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(tergetUserData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}



//MARK: - Serach results Model
struct SearchResults {
    let recipientName: String
    let recipientEmail: String
}
