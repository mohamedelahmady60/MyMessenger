//
//  ChatViewController.swift
//  MyMessanger
//  Created by Mo Elahmady on 19/12/2020.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewconversation = false
    public let recipientUserEmail: String
    private var conversationId: String?
    
    private var senderPhotoUrl: URL?
    private var recipientPhotoUrl: URL?

    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = ChatAppUser.safeEmail(emailAddress: email)
        
        return Sender(photoURL: "",
                      senderId: safeEmail,
                      displayName: "Me")
    }
    
    
    init(with email: String, id: String?) {
        self.conversationId = id
        self.recipientUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
        if let conversId = conversationId {
            // get all of the messages
            startListeningForMessages(conversationId: conversId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad Chats")
        view.backgroundColor = .red
        
        //set the Message delegates
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        // send image button
        setupInoutButton()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    
    //MARK: - functions
    
    
    private func setupInoutButton() {
        
        let button = InputBarButtonItem()
        
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        
        button.onTouchUpInside({ [weak self] _ in
            self?.presentAttachMediaActionSheet()
        })
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        
    }
    
    
    private func presentAttachMediaActionSheet() {
        
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoActionSheetOptions()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoActionSheetOptions()
        }))

        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self]_ in
            self?.presentLocationActionSheetOptions()
        }))

        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { _ in
            
            
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        present(actionSheet, animated: true)
        
    }
    
    private func presentLocationActionSheetOptions() {
        // present a map so the user can choose the location
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        // pass the completion
        vc.completion = { [weak self] selectedCoordinates in
            
            guard let strongSelf = self else {
                return
            }
            // 1- get the longitude and the latitude
            let longitude = selectedCoordinates.longitude
            let latitude = selectedCoordinates.latitude
            
            // 2- create location media item
            let locationItem = LocationMediaItem(location: CLLocation(latitude: latitude, longitude: longitude),
                                                 size: .zero)
            //3- create the message
            guard let messageId = strongSelf.createMessageId(),
                  let conversationId = strongSelf.conversationId,
                  let recipientName = strongSelf.title,
                  let selfSender = strongSelf.selfSender else {
                return
            }
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .location(locationItem))
            
            // 4- send the message
            DatabaseManager.shared.sendMessage(conversationId: conversationId, otherUserName: recipientName, oherUserEmail: strongSelf.recipientUserEmail, newMessage: message, completion: {success in
                if success {
                    print("Sent location successfully")
                }
                else {
                    print("failed to sent location")
                }
            })
        }
        
        // present the LocationPickerView
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func presentPhotoActionSheetOptions() {
        
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where whould you like to attach a photo from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }

    
    private func presentVideoActionSheetOptions() {
        
        let actionSheet = UIAlertController(title: "Attach Vidoe",
                                            message: "Where whould you like to attach a Vidoe from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }

    
    private func startListeningForMessages(conversationId: String) {
        
        DatabaseManager.shared.getAllMessagesForConversation(conversationId: conversationId, completion: { [weak self] result in
            
            switch result {
            case.success(let observedMessages):
                guard !observedMessages.isEmpty else {
                    return
                }
                self?.messages = observedMessages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
                
            case .failure(let error):
                print("Failed to get messages: \(error)")
            }
        })
    }
}


//MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //when user canels taking photo or photo selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //when the user takes a phote or selects a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        // these varaibles we're gonna use for pictures and videoa
        guard let messageId = createMessageId(),
              let conversationId = conversationId,
              let name = title,
              let selfSender = selfSender else {
            return
        }
        
        // if we have an image
        if let selectedImage = info[.editedImage] as? UIImage, let imageData = selectedImage.pngData() {
            
            // 1- upload the image
            let filename = "photo_meesage_" + messageId.replacingOccurrences(of: " ", with: "_") + ".png"
            StrorageManager.shared.uploadMessagePhoto(data: imageData, fileName: filename, completion: { [weak self] result in
                guard let StrongSelf = self else {
                    return
                }
                switch result {
                case .success(let downUrlString):
                    // 2- send the image message (ready to send message)
                    guard let placeholder = UIImage(named: "photoPlaceholder"),
                          let imageUrl = URL(string: downUrlString) else {
                        return
                    }
                    //create media item
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    //create the message
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    DatabaseManager.shared.sendMessage(conversationId: conversationId, otherUserName: name, oherUserEmail: StrongSelf.recipientUserEmail, newMessage: message, completion: {success in
                        if success {
                            print("Sent Photo successfully")
                        }
                        else {
                            print("failed to sent photo")
                        }
                    })
                case .failure(let error):
                    print("Message photo upload error: \(error)")
                    return
                }
            })
        }
        else if let videoUrl = info[.mediaURL] as? URL{
            // if we have a video
            
            //1- upload the video
            let filename = "video_meesage_" + messageId.replacingOccurrences(of: " ", with: "_") + ".mov"
            StrorageManager.shared.uploadMessageVideo( fileUrl: videoUrl, fileName: filename, completion: { [weak self] result in
                guard let StrongSelf = self else {
                    return
                }
                switch result {
                case .success(let downUrlString):
                    // 2- send the video message (ready to send message)
                    guard let placeholder = UIImage(named: "videoPlaceholder"),
                          let imageUrl = URL(string: downUrlString) else {
                        return
                    }
                    //create media item
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    //create the message
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    DatabaseManager.shared.sendMessage(conversationId: conversationId, otherUserName: name, oherUserEmail: StrongSelf.recipientUserEmail, newMessage: message, completion: {success in
                        if success {
                            print("Sent Photo successfully")
                        }
                        else {
                            print("failed to sent photo")
                        }
                    })
                case .failure(let error):
                    print("Message photo upload error: \(error)")
                    return
                }
            })
        }
      }
    
}// end of extension



//MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    //when user presses send button
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // first check the message
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
        }
        
        //create converation and database
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
        
        // send messege
        if isNewconversation {
            // create new conversation
            DatabaseManager.shared.createNewConversation(otherUserEmail: recipientUserEmail, otherUserName: self.title ?? "user", firstMessage: message, completion: {[weak self] success in
                
                if success {
                    print("Message sent")
                    self?.isNewconversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.startListeningForMessages(conversationId: newConversationId)
                    self?.messageInputBar.inputTextView.text = nil
                }else {
                    print("failed to send")
                }
            })
        }
        else {
            // add to message to the exisiting email conversations
            guard let conversId = conversationId,
                  let name = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(conversationId: conversId, otherUserName: name, oherUserEmail: recipientUserEmail, newMessage: message, completion: { [weak self] success in
                if success {
                    print("Message Sent")
                    self?.messageInputBar.inputTextView.text = nil
                }
                else  {
                    print("Failed to sent")
                }
                
            })
        }
    }
    
    //creates a message id according to date, otherUserEmail, and SenderEmail
    private func createMessageId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let currentUserSafeEmail = ChatAppUser.safeEmail(emailAddress: currentUserEmail)
        let dateString = ChatViewController.dateFormatter.string(from: Date())
        let newIdentifier = "\(recipientUserEmail)_\(currentUserSafeEmail)_\(dateString)"
        print("Created messageId: \(newIdentifier)")
        return newIdentifier
    }
    
}// end of extension



//MARK: - MessagesDataSource, MessagesLayoutDelegate and MessagesDisplayDelegate Methods
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("self sender is nil")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    // configure the image message
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //download and update the image view
        guard let currentMessage = message as? Message else {
            return
        }
        switch currentMessage.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
    
    // set the message background color
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            //our message that we've sent
            return .link
        }
        return .lightGray
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // show current sender image
            if let senderImageUrl = self.senderPhotoUrl {
                avatarView.sd_setImage(with: senderImageUrl, completed: nil)
            }
            else {
                // fetch the url and show it
                guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                let safeSenderEmail = ChatAppUser.safeEmail(emailAddress: senderEmail)
                let path = "images/\(safeSenderEmail)_profile_picture.png"
                StrorageManager.shared.downloadURL(path: path, completion: { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case.success(let url):
                        self?.senderPhotoUrl = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    }
                })
            }
        }
        else {
            // show recipient user image
            if let recipientImageUrl = self.recipientPhotoUrl {
                avatarView.sd_setImage(with: recipientImageUrl, completed: nil)
            }
            else {
                // fetch the url and show it
                // fetch the url and show it
                let recipientEmail = self.recipientUserEmail
                let safeRecipientEmail = ChatAppUser.safeEmail(emailAddress: recipientEmail)
                let path = "images/\(safeRecipientEmail)_profile_picture.png"
                StrorageManager.shared.downloadURL(path: path, completion: { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case.success(let url):
                        self?.recipientPhotoUrl = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    }
                })
            }
        }
    }
    
} // end of extension


//MARK: - MessageCellDelegate methods
extension ChatViewController: MessageCellDelegate {
    
    // if the user taps on the photo message so we can show it
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]        
        switch message.kind {
        //photo
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewerViewController(url: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        //video
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }

    }
    
    
    // if the user taps on any message so we can show the location
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        switch message.kind {
        //location
        case .location(let locationItem):
            let coordinates = locationItem.location.coordinate
            // go to the LocationPickerViewController which has a map so we can show the location
            let vc = LocationPickerViewController(coordinates: coordinates)
            vc.title = "Location"
            // pass the location
            
            // present the vc
            self.navigationController?.pushViewController(vc, animated: true)
            
            
        default:
            break
        }

    }

} // end of extension



//MARK: - Message Kind extension
extension MessageKind {
    
    var string: String {
        
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}



//MARK: - define the message model that comes from MessageKit
struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}


struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}


struct LocationMediaItem: LocationItem {
    var location: CLLocation
    var size: CGSize
}
