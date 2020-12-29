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
        tableView.register(ConversationTableViewCell.self,
                           forCellReuseIdentifier: ConversationTableViewCell.identifier)
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
    
    //MARK: - the conversations Array
    private var conversations = [Conversation]()
    
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
        startListeningForConversations()
 
        
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
    
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = ChatAppUser.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversation(for: safeEmail, completion: { [weak self] result in
            
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableview.reloadData()
                }
            case .failure(let error):
                print("Failed to get conversations: \(error)")
            }
        })
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
        vc.completion = { [weak self] result in
            self?.createNewConversation(result: result)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    
    public func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        
        //go to the selected Chat view
        let vc = ChatViewController(with: email, id: nil) 
        vc.isNewconversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)

    }
    
}




//MARK: - table view delegate and data source methods
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = conversations[indexPath.row]
        let cell = tableview.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]

        
        //go to the selected Chat view
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}


struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessege: LatestMessege
}

struct LatestMessege {
    let date: String
    let text: String
    let isRead: Bool
}
