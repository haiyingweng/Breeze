//
//  EditProfileViewController.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/4/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {
    
    var profilePicView: UIImageView!
    var usernameLabel: UILabel!
    var emailLabel: UILabel!
    var usernameTextField: UITextField!
    var userEmailLabel: UILabel!
    var profilePicButton: UIButton!
    var logoutButton: UIButton!
    var cancelButton: UIButton!
    var doneButton: UIButton!
    
    var picPicker: UIImagePickerController!
    
    var originalProfilePicData: Data?
    var originalUsername: String!
    
    var currentUser: User!
    let currentUserUid = Auth.auth().currentUser?.uid
    
    let profilePicSize: CGFloat = 130

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Your Profile"
        
        view.backgroundColor = .white
        
        navigationItem.largeTitleDisplayMode = .never
        
        cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.darkGray, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        let cancelBarItem = UIBarButtonItem(customView: cancelButton)
        self.navigationItem.leftBarButtonItem = cancelBarItem
        
        doneButton = UIButton(type: .custom)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.darkerBlue, for: .normal)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        doneButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
        let doneBarItem = UIBarButtonItem(customView: doneButton)
        self.navigationItem.rightBarButtonItem = doneBarItem
        
        profilePicView = UIImageView()
        profilePicView.contentMode = .scaleAspectFill
        profilePicView.clipsToBounds = true
        profilePicView.backgroundColor = .white
        profilePicView.layer.masksToBounds = true
        profilePicView.layer.cornerRadius = profilePicSize/2
        view.addSubview(profilePicView)
        
        usernameLabel = UILabel()
        usernameLabel.text = "Username"
        usernameLabel.textColor = .darkGray
        usernameLabel.textAlignment = .left
        usernameLabel.font = .systemFont(ofSize: 18, weight: .regular)
        view.addSubview(usernameLabel)
        
        usernameTextField = UITextField()
        usernameTextField.textColor = .darkerBlue
        usernameTextField.clearButtonMode = .whileEditing
        usernameTextField.font = .systemFont(ofSize: 20, weight: .bold)
        usernameTextField.underline()
        view.addSubview(usernameTextField)
        
        emailLabel = UILabel()
        emailLabel.text = "Email"
        emailLabel.textColor = .darkGray
        emailLabel.textAlignment = .left
        emailLabel.font = .systemFont(ofSize: 18, weight: .regular)
        view.addSubview(emailLabel)
        
        userEmailLabel = UILabel()
        userEmailLabel.textColor = .darkerBlue
        userEmailLabel.textAlignment = .left
        userEmailLabel.font = .systemFont(ofSize: 18, weight: .regular)
        view.addSubview(userEmailLabel)
        
        logoutButton = UIButton()
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.titleLabel?.textAlignment = .center
        logoutButton.layer.cornerRadius = 15
        logoutButton.backgroundColor = .darkerBlue
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        profilePicButton = UIButton()
        profilePicButton.setTitle("Change Picture", for: .normal)
        profilePicButton.setTitleColor(.baseBlue, for: .normal)
        profilePicButton.titleLabel?.textAlignment = .center
        profilePicButton.addTarget(self, action: #selector(choosePic), for: .touchUpInside)
        view.addSubview(profilePicButton)
        
        picPicker = UIImagePickerController()
        picPicker.delegate = self
        picPicker.allowsEditing = true
        
        setupConstraints()
        getCurrentUserProfile()
        hideKeyboardWhenTapped()
    }
    
    func setupConstraints() {
        profilePicView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.height.width.equalTo(profilePicSize)
        }
        
        profilePicButton.snp.makeConstraints { make in
            make.top.equalTo(profilePicView.snp.bottom).offset(5)
            make.centerX.equalTo(view.center)
            make.width.equalTo(200)
            make.height.equalTo(20)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(profilePicButton.snp.bottom).offset(40)
            make.left.equalTo(view).offset(40)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(profilePicButton.snp.bottom).offset(40)
            make.left.equalTo(usernameLabel.snp.right).offset(10)
            make.height.equalTo(30)
            make.right.equalTo(view).offset(-40)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(15)
            make.left.equalTo(view).offset(40)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        userEmailLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel)
            make.left.equalTo(usernameTextField)
            make.height.equalTo(30)
            make.right.equalTo(view).offset(-40)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
    }
    
    func hideKeyboardWhenTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboardOnTap() {
        self.view.endEditing(true)
    }
    
    func getCurrentUserProfile() {
        guard let uid = currentUserUid else {return}
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let currentUserDict = snapshot.value as? [String: Any]{
                self.currentUser = User(dictionary: currentUserDict)
                if let url = self.currentUser.profilePic {
                    self.profilePicView.getImagesFromUrl(url: url)
                    if let image = self.profilePicView.image {
                        self.originalProfilePicData = image.pngData()
                    }
                }
                self.originalUsername = self.currentUser.username
                self.usernameTextField.text = self.currentUser.username
                self.userEmailLabel.text = self.currentUser.email
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
    
    @objc func cancelPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func donePressed() {
        guard let uid = currentUserUid else {return}
        if usernameTextField.text != originalUsername && usernameTextField.text != "" {
            let usernameRef = Database.database().reference().child("users").child(uid).child("username")
            usernameRef.setValue(usernameTextField.text)
        } else {
            print ("username unchanged")
        }
        
        let imageData = profilePicView.image?.pngData()
        if imageData != originalProfilePicData, let image = profilePicView.image, let imageUrl = currentUser.profilePic {
            uploadImageToFirebase(image: image)
            deleteImageFromStorage(imageUrl: imageUrl)
        } else {
            print ("profile pic unchanged")
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    private func uploadImageToFirebase(image: UIImage) {
        guard let uid = currentUserUid else {return}
        let imageID = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child(imageID)
        let metadata = StorageMetadata()
        metadata.contentType = "picture/jpeg"
        if let picData = image.jpegData(compressionQuality: 0.1) {
            storageRef.putData(picData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print (error!)
                } else {
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print (error!)
                        } else {
                            if let imageUrl = url?.absoluteString {
                                let profilePicRef = Database.database().reference().child("users").child(uid).child("profilePic")
                                profilePicRef.setValue(imageUrl)
                            }
                        }
                    })
                }
            }
        }
    }
    
    private func deleteImageFromStorage(imageUrl: String) {
        let imageStorageRef = Storage.storage().reference().child(imageUrl)
        imageStorageRef.delete { (error) in
            if error != nil {
                print (error!)
            } else {
                print ("image deleted")
            }
        }
    }
    
    @objc func logout() {
        
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action:UIAlertAction) in
            
            do {
                try Auth.auth().signOut()
            } catch let error {
                print (error)
            }
            
            let loginVC = LoginViewController()
            self.navigationController?.pushViewController(loginVC, animated: true)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)

    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profilePicView.image = photo
        }
        dismiss(animated: true, completion: nil)
    }
}
