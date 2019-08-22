//
//  UserProfileViewController.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/13/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {
    
    var user: User!

    var profilePicView: UIImageView!
    var usernameLabel: UILabel!
    var bioLabel: UILabel!
    var emailLabel: UILabel!
    var messageButton: UIButton!
    
    let profilePicSize: CGFloat = 130
    
    init (user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = user.username
        
        view.backgroundColor = .white
        
        navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.tintColor = .white
        
        profilePicView = UIImageView()
        profilePicView.contentMode = .scaleAspectFill
        profilePicView.clipsToBounds = true
        profilePicView.backgroundColor = .white
        profilePicView.layer.masksToBounds = true
        profilePicView.layer.cornerRadius = profilePicSize/2
        view.addSubview(profilePicView)
        
        usernameLabel = UILabel()
        usernameLabel.textColor = .darkerBlue
        usernameLabel.textAlignment = .center
        usernameLabel.font = .systemFont(ofSize: 25, weight: .bold)
        view.addSubview(usernameLabel)
        
        emailLabel = UILabel()
        emailLabel.textColor = .darkerBlue
        emailLabel.textAlignment = .center
        emailLabel.font = .systemFont(ofSize: 15, weight: .light)
        view.addSubview(emailLabel)
        
        bioLabel = UILabel()
        bioLabel.sizeToFit()
        bioLabel.numberOfLines = 0
        bioLabel.textColor = .darkerBlue
        bioLabel.textAlignment = .center
        bioLabel.font = .systemFont(ofSize: 18, weight: .regular)
        view.addSubview(bioLabel)
        
        messageButton = UIButton()
        messageButton.setTitle("Message", for: .normal)
        messageButton.setTitleColor(.white, for: .normal)
        messageButton.titleLabel?.textAlignment = .center
        messageButton.layer.cornerRadius = 15
        messageButton.backgroundColor = .darkerBlue
        messageButton.addTarget(self, action: #selector(messageUser), for: .touchUpInside)
        view.addSubview(messageButton)
        
        setupConstraints()
        getUserProfile()
        
    }
    
    func setupConstraints() {
        profilePicView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.height.width.equalTo(profilePicSize)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(profilePicView.snp.bottom).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(200)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(usernameLabel.snp.bottom).offset(5)
            make.height.equalTo(25)
            make.width.equalTo(300)
        }
        
        bioLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(emailLabel.snp.bottom).offset(10)
            make.width.equalTo(300)
            make.height.equalTo(100)
        }
        
        messageButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(bioLabel.snp.bottom).offset(10)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
    }
    
    func getUserProfile() {
        guard let uid = user.uid else {return}
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let userDict = snapshot.value as? [String: Any]{
                let user = User(dictionary: userDict)
                if let url = user.profilePic {
                    self.profilePicView.getImagesFromUrl(url: url)
                }
                if let bio = user.bio {
                    self.bioLabel.text = bio
                }
                self.usernameLabel.text = user.username
                self.emailLabel.text = user.email
            }
        }
    }
    
    @objc func messageUser() {
        let conversationVC = ConversationViewController(friend: user)
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
    

}
