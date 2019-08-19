//
//  AddChatViewController.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/2/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase

protocol CellDeletage: class {
    func messageButtonPressed(user: User)
}

class AddChatViewController: UIViewController {

    var usersTableView: UITableView!
    var userReuseIdentifier = "userCellReuseIdentifier"
    
    var users = [User]()
    var searchedUsers = [User]()
    
    var searchBar: UISearchBar!
    var noSearchResultLabel: UILabel!
    var isSearching = false
    
    let cellHeight: CGFloat = 70
    
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Add Chat"
        
        view.backgroundColor = .white
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.barTintColor = .baseBlue
        navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        
        usersTableView = UITableView()
        usersTableView.separatorStyle = .none 
        usersTableView.dataSource = self
        usersTableView.delegate = self
        usersTableView.register(UserTableViewCell.self, forCellReuseIdentifier: userReuseIdentifier)
        view.addSubview(usersTableView)
        
        searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = " Search User..."
        searchBar.sizeToFit()
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchBar.isTranslucent = false
        searchBar.layer.cornerRadius = 10
        searchBar.layer.masksToBounds = true
        view.addSubview(searchBar)
        
        noSearchResultLabel = UILabel()
        noSearchResultLabel.textColor = .gray
        noSearchResultLabel.font = .systemFont(ofSize: 20, weight: .regular)
        noSearchResultLabel.isHidden = true
        view.addSubview(noSearchResultLabel)
        
        setupConstraints()
        getUsers()
        
    }
    
    func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
            make.height.equalTo(35)
        }
        
        usersTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(5)
            make.left.right.bottom.equalTo(view)
        }
        
        noSearchResultLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.height.equalTo(30)
        }
        
    }
    
    func getUsers() {
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            if let userDictionary = snapshot.value as? [String: Any]{
                let user = User(dictionary: userDictionary)
                user.uid = snapshot.key
                self.users.append(user)
                DispatchQueue.main.async {
                    self.usersTableView.reloadData()
                }
            }
        }, withCancel: nil)
    }

}


extension AddChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchedUsers.count
        } else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        noSearchResultLabel.isHidden = true
        let cell = usersTableView.dequeueReusableCell(withIdentifier: userReuseIdentifier, for: indexPath) as! UserTableViewCell
        var user: User!
        if isSearching {
            user = searchedUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        cell.delegate = self
        cell.user = user 
        cell.configure(for: user)
        cell.selectionStyle = .none
        return cell
    }
}

extension AddChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var user: User!
        if isSearching {
            user = searchedUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        let profileVC = UserProfileViewController(user: user)
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension AddChatViewController: CellDeletage {
    func messageButtonPressed(user: User) {
        let conversationVC = ConversationViewController(friend: user)
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
    
}

extension AddChatViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            usersTableView.reloadData()
        } else {
            isSearching = true
            searchedUsers = []
            searchedUsers = users.filter{($0.username?.lowercased().contains(searchText.lowercased()))!}
            usersTableView.reloadData()
            if searchedUsers.isEmpty {
                noSearchResultLabel.isHidden = false
                noSearchResultLabel.text = "No Result for '\(searchText)'"
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        searchBar.endEditing(true)
        usersTableView.reloadData()
    }
}
