//
//  ConversationsViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {

   //MARK: - tableview
    private let tableview: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    //MARK: - Labeles
    let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    //MARK: - Spinner
    let spinner = JGProgressHUD(style: .dark)
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //set up the table view
        setupTableView()
        
        //set up the right bar button so the user can start a new conversation
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        
        
        //add subViews
        view.addSubview(tableview)
        view.addSubview(noConversationsLabel)
        
        
        //fetch the conversations
        fetchConversations()
 
        
    }

    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //check if the user is already logged in
        validateAuth()
    }
    
    //MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        tableview.frame = view.bounds
    }
    
    
    //MARK: - Functions
    private func validateAuth() {
        if Auth.auth().currentUser == nil {
           //jump to log in view
            let nextVC = LoginViewController()
            let nav = UINavigationController(rootViewController: nextVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }

    }
    
    private func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    private func fetchConversations() {
        tableview.isHidden = false
    }
    
    
    //MARK: - Actions
    @objc private func didTapComposeButton() {
        //go to newConversationController
        let vc = NewConversationViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}


//MARK: - table view delegate and data source methods
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello World"
        cell.accessoryType = .disclosureIndicator
        return cell        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //go to the selected Chat view
        let vc = ChatViewController()
        vc.title = "Ali magdy"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    
    }
}
