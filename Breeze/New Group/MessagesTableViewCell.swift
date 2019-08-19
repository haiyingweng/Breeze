//
//  MessagesTableViewCell.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/2/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase

class MessagesTableViewCell: UITableViewCell {
    
    var profilePicView: UIImageView!
    var usernameLabel: UILabel!
    var lastMessageLabel: UILabel!
    var timeLabel: UILabel!
    
    let profilePicSize: CGFloat = 60
    
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
        
        lastMessageLabel = UILabel()
        lastMessageLabel.textColor = .darkGray
        lastMessageLabel.font = .systemFont(ofSize: 18)
        contentView.addSubview(lastMessageLabel)
        
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
        
        lastMessageLabel.snp.makeConstraints { make in
            make.left.equalTo(profilePicView.snp.right).offset(10)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.top.equalTo(usernameLabel.snp.bottom).offset(10)
            make.height.equalTo(20)
        }
        
    }
    
    func configure(for message: Message) {
        if message.imageUrl != nil {
            lastMessageLabel.text = "[Image]"
        } else {
            lastMessageLabel.text = message.message
        }
        timeLabel.text = message.getTime()
        let friendID = message.getFriendID()
        if let uid = friendID {
            let userRef = ref.child("users").child(uid)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDict = snapshot.value as? [String:Any] {
                    let friend = User(dictionary: userDict)
                    if let url = friend.profilePic {
                        self.profilePicView.getImagesFromUrl(url: url)
                        self.usernameLabel.text = friend.username
                    }
                }
            }, withCancel: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
