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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set the view color
        view.backgroundColor = .white
        
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
        
    }
    
    
    //MARK: - Actions
    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }

}


extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
