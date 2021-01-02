//
//  ConversationTableViewCell.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 28/12/2020.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {

    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()

    private let userMessegeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // add the IBoutlets
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessegeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // set the frames
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)
        
        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20) / 2.0)
        
        userMessegeLabel.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLabel.bottom + 10,
                                        width: contentView.width - 20 - userImageView.width,
                                        height: (contentView.height - 20) / 2.0)
        
        
    }
    
    public func configure(with model: Conversation) {
        userMessegeLabel.text = model.latestMessege.text
        userNameLabel.text = model.recipientName
        
        let imagePath = "images/\(model.recipientEmail)_profile_picture.png"
        StrorageManager.shared.downloadURL(path: imagePath, completion: { [weak self] result in
            
            switch result {
            case .success(let downloadURL):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: downloadURL, completed: nil)
                }
            case.failure(let error):
            print("failed to get image url \(error)")
            }
        })
    }
}
