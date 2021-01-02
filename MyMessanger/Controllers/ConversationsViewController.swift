//
//  ConversationsViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

final class ConversationsViewController: UIViewController {
    
    
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
    
    
    private var timer = Timer()

    public static var comesFromLoginOrRegister: Bool = false
    
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

    }


    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //check if the user is already logged in
        validateAuth()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if ConversationsViewController.comesFromLoginOrRegister == true {
            conversations.removeAll()
            tableview.isHidden = true
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
        // fetch all the conversations
        fetchAllTheConversations()
    }
    
    //MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        tableview.frame = view.bounds
        
        let noConversationsLabelWidth = view.width / 2.0
        let noConversationsLabelheight: CGFloat = 200
        noConversationsLabel.frame = CGRect(x: (view.width - noConversationsLabelWidth) / 2.0,
                                      y: (view.height - noConversationsLabelheight) / 2.0,
                                      width: noConversationsLabelWidth,
                                      height: noConversationsLabelheight)

    }
    
    
    //MARK: - Functions
    
    private func fetchAllTheConversations() {
        
        
        DatabaseManager.shared.getAllConversation(completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    strongSelf.noConversationsLabel.isHidden = false
                    strongSelf.tableview.isHidden = true
                    return
                }
                strongSelf.conversations = conversations
                if ConversationsViewController.comesFromLoginOrRegister {
                    // start a timer
                    strongSelf.spinner.show(in: strongSelf.view)
                    strongSelf.timer = Timer.scheduledTimer(timeInterval: 1.0, target: strongSelf, selector: #selector(strongSelf.timerISR), userInfo: nil, repeats: false)
                    ConversationsViewController.comesFromLoginOrRegister = false
                }
                else {
                    strongSelf.noConversationsLabel.isHidden = true
                    strongSelf.tableview.isHidden = false
                }
                
                DispatchQueue.main.async {
                    strongSelf.tableview.reloadData()
                }
            case .failure(let error):
                print("Failed to get conversations: \(error)")
                strongSelf.noConversationsLabel.isHidden = false
                strongSelf.tableview.isHidden = true
                
            }
        })
    }
    
    
    @objc private func timerISR() {
        timer.invalidate()
        spinner.dismiss()
        noConversationsLabel.isHidden = true
        tableview.isHidden = false
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
        
    
    //MARK: - Actions
    @objc private func didTapComposeButton() {
        //go to newConversationController
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            guard  let strongSelf = self else {
                return
            }
            // 1- get the recipient email
            let recipientEmail = result.recipientEmail
            let safeRecipientEmail = ChatAppUser.safeEmail(emailAddress: recipientEmail)
            
            // 1- check if there is already conversation exists in the Sender user conversations
            let currentConversations = strongSelf.conversations
            if let targetConversation = currentConversations.first(where: {
                $0.recipientEmail == safeRecipientEmail
            }){
                //if exists go to the exists Chat view
                let vc = ChatViewController(with: targetConversation.recipientEmail, id: targetConversation.id)
                vc.isNewconversation = false
                vc.title = targetConversation.recipientName
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
            else {

                // 1- check if there is already conversation exists in the recipient user conversations
                let recipientName = result.recipientName
                let safeRecipientEmail = ChatAppUser.safeEmail(emailAddress: result.recipientEmail)
                DatabaseManager.shared.conversationExists(RecipientEmail: safeRecipientEmail, completion: { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }
                    switch result {
                    // if exists pass its convId
                    case.success(let convId):
                        //go to the existing empty conv
                        let vc = ChatViewController(with: safeRecipientEmail, id: convId)
                        vc.isNewconversation = false
                        vc.title = recipientName
                        vc.navigationItem.largeTitleDisplayMode = .never
                        strongSelf.navigationController?.pushViewController(vc, animated: true)

                    case .failure(_):
                        //go to a new chat
                        let vc = ChatViewController(with: safeRecipientEmail, id: nil)
                        vc.isNewconversation = true
                        vc.title = recipientName
                        vc.navigationItem.largeTitleDisplayMode = .never
                        strongSelf.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
} // end of class




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
        opencConversation(model: model)

    }
    
    private func opencConversation(model: Conversation){
        //go to the selected Chat view
        let vc = ChatViewController(with: model.recipientEmail, id: model.id)
        vc.title = model.recipientName
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 1 - begin delete
            tableview.beginUpdates()
            

            // 2- delete the conversation from the tableview
            let currentConversation = conversations[indexPath.row]
            conversations.remove(at: indexPath.row)
            tableview.deleteRows(at: [indexPath], with: .left)
            // 3- delete the conversation from the database
            DatabaseManager.shared.deleteConversation(conversationId: currentConversation.id, completion: { success in
                if !success{
                    print("can't delete the message")
                }
            })
            // 4 - end delete
            tableview.endUpdates()
        }
    }
    
}

