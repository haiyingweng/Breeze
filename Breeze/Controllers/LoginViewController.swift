//
//  ViewController.swift
//  Breeze
//
//  Created by HAIYING WENG on 7/30/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class LoginViewController: UIViewController {
    
    var loginLabel: UILabel!
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var loginButton: UIButton!
    var makeAccountButton: UIButton!
    
    var userID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserLoggedIn()
        
        view.backgroundColor = .baseBlue
        
        navigationController?.navigationBar.isHidden = true
        
        loginLabel = UILabel()
        loginLabel.textColor = .white
        loginLabel.text = "Log in"
        loginLabel.font = UIFont(name: "AvenirNext-Medium", size: 50)
        view.addSubview(loginLabel)
        
        emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.backgroundColor = .white
        emailTextField.textColor = .black
        emailTextField.setLeftPadding(10)
        emailTextField.setRightPadding(10)
        emailTextField.layer.cornerRadius = 10
        emailTextField.layer.borderColor = UIColor.darkerBlue.cgColor
        emailTextField.layer.borderWidth = 1
        emailTextField.drawText(in: CGRect(x: 0, y: 0, width: 10, height: 10))
        view.addSubview(emailTextField)
        
        passwordTextField = UITextField()
        passwordTextField.placeholder = "Password"
        passwordTextField.backgroundColor = .white
        passwordTextField.textColor = .black
        passwordTextField.setLeftPadding(10)
        passwordTextField.setRightPadding(10)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.layer.borderColor = UIColor.darkerBlue.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 10
        view.addSubview(passwordTextField)
        
        loginButton = UIButton()
        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.textAlignment = .center
        loginButton.layer.cornerRadius = 10
        loginButton.backgroundColor = .darkerBlue
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        view.addSubview(loginButton)
        
        makeAccountButton = UIButton()
        makeAccountButton.setTitle("Create New Account", for: .normal)
        makeAccountButton.setTitleColor(.white, for: .normal)
        makeAccountButton.titleLabel?.textAlignment = .center
        makeAccountButton.addTarget(self, action: #selector(makeAccount), for: .touchUpInside)
        view.addSubview(makeAccountButton)
        
        setupConstraints()
        hideKeyboardWhenTapped()
    }

    private func checkIfUserLoggedIn() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                let messagesVC = MessagesViewController()
                self.navigationController?.pushViewController(messagesVC, animated: true)
            } else {
                
            }
        }
    }
    
    func setupConstraints() {
        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
            make.left.equalTo(view).offset(25)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(100)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(loginLabel.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(55)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(55)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(50)
        }
        
        makeAccountButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(15)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(20)
        }
        
    }
    
    func hideKeyboardWhenTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboardOnTap() {
        self.view.endEditing(true)
    }
    
    func createAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func login() {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                
                if error == nil {
                    self.userID = Auth.auth().currentUser?.uid
                    let messagesVC = MessagesViewController()
                    self.navigationController?.pushViewController(messagesVC, animated: true)
                }

                else {
                    if let error = error {
                        self.createAlert(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @objc func makeAccount() {
        
        let registerVC = RegisterViewController()
        self.navigationController?.pushViewController(registerVC, animated: true)
        
    }

}

