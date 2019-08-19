//
//  UserTableViewCell.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/2/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    var user: User!
    
    var profilePicView: UIImageView!
    var usernameLabel: UILabel!
    var messageButton: UIButton!
    
    let profilePicSize: CGFloat = 50
    
    weak var delegate: CellDeletage? 
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        
        profilePicView = UIImageView()
        profilePicView.contentMode = .scaleAspectFill
        profilePicView.clipsToBounds = true
        profilePicView.backgroundColor = .white
        profilePicView.layer.masksToBounds = true
        profilePicView.layer.cornerRadius = profilePicSize/2
        contentView.addSubview(profilePicView)
        
        usernameLabel = UILabel()
        usernameLabel.textColor = .darkerBlue
        usernameLabel.sizeToFit()
        usernameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        contentView.addSubview(usernameLabel)
        
        messageButton = UIButton()
        messageButton.setImage(UIImage(named: "message"), for: .normal)
        messageButton.addTarget(self, action: #selector(messageUser), for: .touchUpInside)
        contentView.addSubview(messageButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        
        profilePicView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(15)
            make.height.width.equalTo(profilePicSize)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(profilePicView.snp.right).offset(10)
            make.right.equalTo(contentView.snp.right).offset(-60)
            make.height.equalTo(25)
        }
        
        messageButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView.snp.right).offset(-20)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
    
    }
    
    func configure(for user: User) {
        usernameLabel.text = user.username
        if let url = user.profilePic { 
            profilePicView.getImagesFromUrl(url: url)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func messageUser() {
        delegate?.messageButtonPressed(user: user)
    }
    

}
