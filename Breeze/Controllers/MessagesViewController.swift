//
//  MessagesViewController.swift
//  Breeze
//
//  Created by HAIYING WENG on 7/31/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController {
    
    var addButton: UIButton!
    var profileButton: UIButton!
    
    var messagesTableView: UITableView!
    let messageReuseIdentifier = "messageCellReuse"
    
    var timer: Timer?
    
    var messages = [Message]()
    var messagesDict = [String: Message]()
    
    let ref = Database.database().reference()
    
    let navBarItemSize: CGFloat = 35
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "Messages"
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.barTintColor = .baseBlue
        navigationController?.navigationBar.isTranslucent = false
        
        addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(named:"cir_add_white"), for: .normal)
        addButton.addTarget(self, action: #selector(addPressed), for: .touchUpInside)
        let addBarItem = UIBarButtonItem(customView: addButton)
        self.navigationItem.rightBarButtonItem = addBarItem
        
        profileButton = UIButton(type: .custom)
        profileButton.setImage(UIImage(named:"profile"), for: .normal)
        profileButton.addTarget(self, action: #selector(profilePressed), for: .touchUpInside)
        let profileBarItem = UIBarButtonItem(customView: profileButton)
        self.navigationItem.leftBarButtonItem = profileBarItem
        
        
        messagesTableView = UITableView()
        messagesTableView.separatorStyle = .none
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        messagesTableView.register(MessagesTableViewCell.self, forCellReuseIdentifier: messageReuseIdentifier)
        view.addSubview(messagesTableView)
        
        setupConstraints()
        getUserMessages()
    }
    
    func setupConstraints() {
        
        addButton.snp.makeConstraints { make in
            make.height.equalTo(navBarItemSize)
            make.width.equalTo(navBarItemSize)
        }
        
        profileButton.snp.makeConstraints { make in
            make.height.equalTo(navBarItemSize)
            make.width.equalTo(navBarItemSize)
        }
        
        messagesTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalTo(view)
        }
        
    }
    
    @objc func addPressed() {
        let addChatVC = AddChatViewController()
        navigationController?.pushViewController(addChatVC, animated: true)
    }
    
    @objc func profilePressed() {
        let profileVC = EditProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    
    func getUserMessages() {
        messages = []
        messagesDict = [:]
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        let childRef = ref.child("user-messages").child(currentUid)
        childRef.observe(.childAdded, with: { (snapshot) in
            let friendId = snapshot.key
            let friendMessagesRef = self.ref.child("user-messages").child(currentUid).child(friendId)
            friendMessagesRef.observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                let messagesRef = self.ref.child("messages").child(messageId)
                messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let messageDict = snapshot.value as? [String:Any] {
                        let message = Message(dictionary: messageDict)
                        if let friendID = message.getFriendID() {
                            self.messagesDict[friendID] = message
                        }
                        self.reloadTableWithTimer()
                    }
                }, withCancel: nil)
            }, withCancel: nil)
            return
        }, withCancel: nil)
    }
    
    private func reloadTableWithTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.reloadTableViewData), userInfo: nil, repeats: false)
    }
    
    @objc func reloadTableViewData() {
        self.messages = Array(self.messagesDict.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            if let time1 = Double(message1.time!), let time2 = Double(message2.time!) {
                return time1 > time2
            } else {
                return true
            }
        })
        DispatchQueue.main.async {
            self.messagesTableView.reloadData()
        }
    }
}


extension MessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messagesTableView.dequeueReusableCell(withIdentifier: messageReuseIdentifier, for: indexPath) as! MessagesTableViewCell
        let message = messages[indexPath.row]
        cell.configure(for: message)
        cell.selectionStyle = .none 
        return cell
    }
    
    
}

extension MessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let friendID = message.getFriendID() else {return}
        let childRef = ref.child("users").child(friendID)
        childRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                let user = User(dictionary: userDict)
                user.uid = friendID
                let convoVC = ConversationViewController(friend: user)
                self.navigationController?.pushViewController(convoVC, animated: true)
            }
        }, withCancel: nil)

    }

}


