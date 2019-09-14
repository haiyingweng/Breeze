//
//  SearchInConversationViewController.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/15/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase

class SearchInConversationViewController: UIViewController {
    
    var messagesTableView: UITableView!
    let messageReuseIdentifier = "messageCellReuse"
    
    var searchBar: UISearchBar!
    var noSearchResultLabel: UILabel!
    
    var messages = [Message]()
    var searchedMessages = [Message]()
    
    weak var delegate: ConversationSearchDelegate?
    
    init (messages: [Message]) {
        self.messages = messages
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        messagesTableView = UITableView()
        messagesTableView.separatorStyle = .none
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        messagesTableView.register(SearchInConversationTableViewCell.self, forCellReuseIdentifier: messageReuseIdentifier)
        view.addSubview(messagesTableView)
        
        searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = " Search in Conversation..."
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
    }
    
    func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
            make.height.equalTo(35)
        }
        
        messagesTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(5)
            make.left.right.bottom.equalTo(view)
        }
        
        noSearchResultLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.height.equalTo(30)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
}

extension SearchInConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messagesTableView.dequeueReusableCell(withIdentifier: messageReuseIdentifier, for: indexPath) as! SearchInConversationTableViewCell
        let message = searchedMessages[indexPath.row]
        if let searchText = searchBar.text {
             cell.configure(for: message, for: searchText)
        }
        cell.selectionStyle = .none
        return cell
    }
    
}

extension SearchInConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = searchedMessages[indexPath.row]
        delegate?.scrollToMessage(message: message)
        self.navigationController?.popViewController(animated: true)
    }
}

extension SearchInConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "", let searchText = searchBar.text {
            searchedMessages = []
            searchedMessages = messages.filter({
                guard let message = $0.message else {return false}
                return message.lowercased().contains(searchText.lowercased())
            })
            messagesTableView.reloadData()
            searchBar.endEditing(true)
            if searchedMessages.isEmpty {
                noSearchResultLabel.isHidden = false
                noSearchResultLabel.text = "No Result for '\(searchText)'"
            } else {
                noSearchResultLabel.isHidden = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
}
