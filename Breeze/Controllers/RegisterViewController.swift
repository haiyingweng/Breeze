//
//  RegisterViewController.swift
//  Breeze
//
//  Created by HAIYING WENG on 7/31/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase


class RegisterViewController: UIViewController {
    
    var registerLabel: UILabel!
    var usernameTextField: UITextField!
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var registerButton: UIButton!
    var profilePicView: UIImageView!
    var profilePicButton: UIButton!
    var picPicker: UIImagePickerController!
    var loginButton:UIButton!
    
    var userID: String!
    
    let profilePicSize: CGFloat = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .baseBlue
        
        navigationController?.navigationBar.isHidden = true
        
        registerLabel = UILabel()
        registerLabel.textColor = .white
        registerLabel.text = "Register"
        registerLabel.font = UIFont(name: "AvenirNext-Medium", size: 50)
        view.addSubview(registerLabel)
        
        usernameTextField = UITextField()
        usernameTextField.placeholder = "Username"
        usernameTextField.backgroundColor = .white
        usernameTextField.textColor = .black
        usernameTextField.setLeftPadding(10)
        usernameTextField.setRightPadding(10)
        usernameTextField.layer.cornerRadius = 10
        usernameTextField.layer.borderColor = UIColor.darkerBlue.cgColor
        usernameTextField.layer.borderWidth = 1
        usernameTextField.drawText(in: CGRect(x: 0, y: 0, width: 10, height: 10))
        view.addSubview(usernameTextField)
        
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
        
        registerButton = UIButton()
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.textAlignment = .center
        registerButton.layer.cornerRadius = 10
        registerButton.backgroundColor = .darkerBlue
        registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        view.addSubview(registerButton)
        
        profilePicView = UIImageView()
        profilePicView.contentMode = .scaleAspectFill
        profilePicView.clipsToBounds = true
        profilePicView.backgroundColor = .white
        profilePicView.image = UIImage(named: "default")
        profilePicView.layer.masksToBounds = true
        profilePicView.layer.cornerRadius = profilePicSize/2
        view.addSubview(profilePicView)
        
        profilePicButton = UIButton()
        profilePicButton.setTitle("Choose Picture", for: .normal)
        profilePicButton.setTitleColor(.darkerBlue, for: .normal)
        profilePicButton.titleLabel?.textAlignment = .center
        profilePicButton.addTarget(self, action: #selector(choosePic), for: .touchUpInside)
        view.addSubview(profilePicButton)
        
        picPicker = UIImagePickerController()
        picPicker.delegate = self
        picPicker.allowsEditing = true
        
        loginButton = UIButton()
        loginButton = UIButton()
        loginButton.setTitle("Already have an account? Log in", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.textAlignment = .center
        loginButton.addTarget(self, action: #selector(backToLogin), for: .touchUpInside)
        view.addSubview(loginButton)
        
        setupConstraints()
        hideKeyboardWhenTapped()
    }
        
    func setupConstraints() {
        
        registerLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
            make.left.equalTo(view).offset(25)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(100)
        }
        
        profilePicView.snp.makeConstraints { make in
            make.top.equalTo(registerLabel.snp.bottom)
            make.centerX.equalTo(view.center)
            make.width.height.equalTo(profilePicSize)
        }
        
        profilePicButton.snp.makeConstraints { make in
            make.top.equalTo(profilePicView.snp.bottom).offset(5)
            make.centerX.equalTo(view.center)
            make.width.equalTo(200)
            make.height.equalTo(20)
        }
        
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(profilePicButton.snp.bottom).offset(15)
            make.centerX.equalTo(view.center)
            make.width.equalTo(view.frame.width-40)
            make.height.equalTo(55)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(20)
            make.centerX.equalTo(view.center)
            make.width.equalTo(view.frame.width-40)
            make.height.equalTo(55)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.centerX.equalTo(view.center)
            make.width.equalTo(view.frame.width-40)
            make.height.equalTo(55)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(15)
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
    
    func createAlert (message: String, alertTitle: String) {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func register() {
        
        if usernameTextField.text == "" {
            createAlert(message: "Username cannot be empty.", alertTitle: "Error")
        }
        
        if emailTextField.text == "" {
            createAlert(message: "Email cannot be empty.", alertTitle: "Error")
        }
        
        if passwordTextField.text == "" {
            createAlert(message: "Password cannot be empty.", alertTitle: "Error")
        }
        
        if let email = emailTextField.text, let password = passwordTextField.text, let username = usernameTextField.text, username != "" && email != "" && password != "" {
            
            Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
    
                if error != nil {
                    if let error = error {
                        self.createAlert(message: error.localizedDescription, alertTitle: "Error")
                    }
                } else {
                    if let result = authDataResult {
                        self.userID = result.user.uid
                    }
                    let picID = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child(picID)
                    if let profilePic = self.profilePicView.image, let picData = profilePic.jpegData(compressionQuality: 0.1) {
                        let metadata = StorageMetadata()
                        metadata.contentType = "picture/jpeg"
                        storageRef.putData(picData, metadata: metadata) { (metadata, error) in
                            if error != nil {
                                print (error!)
                            } else {
                                storageRef.downloadURL(completion: { (url, error) in
                                    if error != nil {
                                        print (error!)
                                    } else {
                                        if let url = url?.absoluteString {
                                            let userData = [
                                                "username": username,
                                                "email": email,
                                                "profilePic" : url
                                            ]
                                            let userRef = Database.database().reference().child("users").child(self.userID)
                                            userRef.setValue(userData)
                                        }
                                        self.login(email: email, password: password)
                                    }
                                })
                            }
                            
                        }
                        
                    }
                }
  
            }
        }
    }
    
    func login(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                self.userID = Auth.auth().currentUser?.uid
                let messagesVC = MessagesViewController()
                self.navigationController?.pushViewController(messagesVC, animated: true)
            }
            else {
                if let error = error {
                    self.createAlert(message: error.localizedDescription, alertTitle: "Error")
                }
            }
        }
    }
    
    @objc func choosePic() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            picPicker.sourceType = .photoLibrary
            present(picPicker, animated: true, completion: nil)
        } else {
            print ("unable to access photo library")
        }
    }
    
    @objc func backToLogin() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profilePicView.image = photo
        }
        dismiss(animated: true, completion: nil)
    }
}

