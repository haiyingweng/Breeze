//
//  ConversationTableViewCell.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/4/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase

class ConversationTableViewCell: UITableViewCell {
    
    var message: Message!
    
    var convoBubbleLabel: UILabel!
    var bubbleView: UIView!
    var profilePicView: UIImageView!
    var messageImageView: UIImageView!
    
    let profilePicSize: CGFloat = 34
    
    let currentUser = Auth.auth().currentUser?.uid
    
    weak var imageDelegate: ImageZoomDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        
        bubbleView = UIView()
        bubbleView.layer.cornerRadius = 20
        contentView.addSubview(bubbleView)
        
        convoBubbleLabel = UILabel()
        convoBubbleLabel.numberOfLines = 0
        convoBubbleLabel.sizeToFit()
        bubbleView.addSubview(convoBubbleLabel)
        
        profilePicView = UIImageView()
        profilePicView.contentMode = .scaleAspectFill
        profilePicView.clipsToBounds = true
        profilePicView.backgroundColor = .white
        profilePicView.layer.masksToBounds = true
        profilePicView.layer.cornerRadius = profilePicSize/2
        contentView.addSubview(profilePicView)
        
        messageImageView = UIImageView()
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.clipsToBounds = true
        messageImageView.backgroundColor = .white
        messageImageView.layer.masksToBounds = true
        messageImageView.layer.cornerRadius = 20
        messageImageView.isUserInteractionEnabled = true
        contentView.addSubview(messageImageView)
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTappedToZoom))
        messageImageView.addGestureRecognizer(tap)
    }
    
    func setupConstraints() {
        bubbleView.snp.remakeConstraints { make in
            make.top.equalTo(contentView).offset(5)
            make.bottom.equalTo(contentView).offset(-5)
            if message.senderID == currentUser {
                make.right.equalTo(contentView).offset(-10)
                make.width.lessThanOrEqualTo(300)
            } else {
                make.left.equalTo(profilePicView.snp.right).offset(10)
                make.width.lessThanOrEqualTo(260)
            }
        }
        
        convoBubbleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(bubbleView).offset(10)
            make.right.bottom.equalTo(bubbleView).offset(-10)
        }
        
        profilePicView.snp.makeConstraints { make in
            make.bottom.equalTo(bubbleView.snp.bottom)
            make.left.equalTo(contentView).offset(10)
            make.height.width.equalTo(profilePicSize)
        }
        
        messageImageView.snp.remakeConstraints { make in
            make.top.equalTo(contentView).offset(5)
            make.bottom.equalTo(contentView).offset(-5)
            if let imageHeight = message.imageHeight, let imageWidth = message.imageWidth {
                if imageWidth > imageHeight {
                    make.width.equalTo(200)
                } else {
                    make.width.equalTo(CGFloat(imageWidth/imageHeight*200))
                }
            }
            if message.senderID == currentUser {
                make.right.equalTo(contentView).offset(-10)
            } else {
                make.left.equalTo(profilePicView.snp.right).offset(10)
            }
        }
    }
    
    func configure(for message: Message, for friend: User) {
        self.message = message
        convoBubbleLabel.text = message.message
        if message.senderID == currentUser {
            bubbleView.backgroundColor = .baseBlue
            profilePicView.isHidden = true
        } else {
            bubbleView.backgroundColor = .veryLightGray
            profilePicView.isHidden = false
            if let url = friend.profilePic {
                profilePicView.getImagesFromUrl(url: url)
            }
        }
        if let imageUrl = message.imageUrl {
            messageImageView.isHidden = false
            messageImageView.getImagesFromUrl(url: imageUrl)
            bubbleView.isHidden = true
            convoBubbleLabel.isHidden = true
        } else {
            messageImageView.isHidden = true
            bubbleView.isHidden = false
            convoBubbleLabel.isHidden = false 
        }
        setupConstraints()
    }
    
    @objc func imageTappedToZoom(tap: UITapGestureRecognizer) {
        if let imageView = tap.view as? UIImageView {
            imageDelegate?.performImageZoom(imageView: imageView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
