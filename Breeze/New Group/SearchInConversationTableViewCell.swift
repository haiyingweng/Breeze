//
//  SearchInConversationTableViewCell.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/15/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase

class SearchInConversationTableViewCell: UITableViewCell {
    
    var profilePicView: UIImageView!
    var usernameLabel: UILabel!
    var messageLabel: UILabel!
    var timeLabel: UILabel!
    
    let profilePicSize: CGFloat = 50
    
    let ref = Database.database().reference()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        profilePicView = UIImageView()
        profilePicView.contentMode = .scaleAspectFill
        profilePicView.clipsToBounds = true
        profilePicView.backgroundColor = .white
        profilePicView.layer.masksToBounds = true
        profilePicView.layer.cornerRadius = profilePicSize/2
        contentView.addSubview(profilePicView)
        
        usernameLabel = UILabel()
        usernameLabel.sizeToFit()
        usernameLabel.textColor = .darkerBlue
        usernameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        contentView.addSubview(usernameLabel)
        
        messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .darkGray
        messageLabel.font = .systemFont(ofSize: 14)
        contentView.addSubview(messageLabel)
        
        timeLabel = UILabel()
        timeLabel.textColor = .gray
        timeLabel.font = .systemFont(ofSize: 15)
        contentView.addSubview(timeLabel)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        
        profilePicView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(10)
            make.height.width.equalTo(profilePicSize)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(profilePicView.snp.right).offset(10)
            make.right.equalTo(timeLabel.snp.right).offset(-5)
            make.top.equalTo(contentView).offset(15)
            make.height.equalTo(20)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.top.equalTo(contentView).offset(15)
            make.height.equalTo(20)
            make.width.equalTo(80)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(profilePicView.snp.right).offset(10)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.top.equalTo(usernameLabel.snp.bottom).offset(5)
            make.bottom.equalTo(contentView).offset(-10)
        }
    }
    
    func configure(for message: Message, for searchText: String) {
        if let messageText = message.message {
            messageLabel.changeColorOfSubstring(string: messageText, substring: searchText, color: .darkerBlue)
        }
        timeLabel.text = message.getTime()
        let senderID = message.senderID
        if let uid = senderID {
            let userRef = ref.child("users").child(uid)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDict = snapshot.value as? [String:Any] {
                    let user = User(dictionary: userDict)
                    if let url = user.profilePic {
                        self.profilePicView.getImagesFromUrl(url: url)
                        self.usernameLabel.text = user.username
                    }
                }
            }, withCancel: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
}
