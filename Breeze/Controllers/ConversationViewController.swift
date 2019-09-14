//
//  ConversationViewController.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/4/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import UIKit
import Firebase


protocol ImageZoomDelegate: class {
    func performImageZoom(imageView: UIImageView)
}

protocol ConversationSearchDelegate: class {
    func scrollToMessage(message: Message)
} 

class ConversationViewController: UIViewController {
    
    var friend: User
    var messages = [Message]()
    let currentUser = Auth.auth().currentUser?.uid
    
    var conversationTableView: UITableView!
    var convoReuseIdentifier = "convoReuseIdentifier"
    
    var bottomView: UIView!
    var messageTextField: UITextField!
    var sendButton: UIButton!
    var imageButton: UIButton!
    var picPicker: UIImagePickerController!
    
    var searchButton: UIButton!
    let navBarItemSize: CGFloat = 30
    
    let ref = Database.database().reference()
    
    //FOR ZOOMING IMAGE
    var backgroundView: UIScrollView!
    var zoomImageView: UIImageView!
    var imageDownloadButton: UIButton!
    var exitButton: UIButton!
    var popupLabel: UILabel!
    var initialFrame: CGRect!

    init (friend: User) {
        self.friend = friend
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = friend.username
        
        view.backgroundColor = .white
        
        navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.tintColor = .white
        
        searchButton = UIButton(type: .custom)
        searchButton.setImage(UIImage(named:"search"), for: .normal)
        searchButton.addTarget(self, action: #selector(searchPressed), for: .touchUpInside)
        let searchBarItem = UIBarButtonItem(customView: searchButton)
        self.navigationItem.rightBarButtonItem = searchBarItem
        
        conversationTableView = UITableView()
        conversationTableView.separatorStyle = .none
        conversationTableView.dataSource = self
        conversationTableView.delegate = self
        conversationTableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: convoReuseIdentifier)
        conversationTableView.alwaysBounceVertical = true
        view.addSubview(conversationTableView)
        
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        
        messageTextField = UITextField()
        messageTextField.placeholder = "send message..."
        messageTextField.backgroundColor = .veryLightGray
        messageTextField.textColor = .black
        messageTextField.setLeftPadding(10)
        messageTextField.setRightPadding(10)
        messageTextField.layer.cornerRadius = 10
        messageTextField.delegate = self
        bottomView.addSubview(messageTextField)
        
        sendButton = UIButton()
        sendButton.setImage(UIImage(named: "send"), for: .normal)
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        bottomView.addSubview(sendButton)
        
        imageButton = UIButton()
        imageButton.setImage(UIImage(named: "image"), for: .normal)
        imageButton.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        bottomView.addSubview(imageButton)
        
        picPicker = UIImagePickerController()
        picPicker.delegate = self
        picPicker.allowsEditing = true
        
        setupConstraints(keyboardHeight: 0)
        getMessages()
        setupKeyboard()
        hideKeyboardWhenTapped() 
    }
    
    func setupConstraints(keyboardHeight: CGFloat) {
        
        searchButton.snp.makeConstraints { make in
            make.height.equalTo(navBarItemSize)
            make.width.equalTo(navBarItemSize)
        }
        
        conversationTableView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        bottomView.snp.remakeConstraints { make in
            make.height.equalTo(50)
            make.left.right.equalTo(view)
            if keyboardHeight == 0 {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(keyboardHeight)
            } else {
                make.bottom.equalTo(view.snp.bottom).offset(keyboardHeight)
            }
        }
        
        messageTextField.snp.makeConstraints { make in
            make.top.equalTo(bottomView.snp.top).offset(5)
            make.height.equalTo(40)
            make.left.equalTo(imageButton.snp.right).offset(10)
            make.right.equalTo(sendButton.snp.left).offset(-10)
        }
        
        sendButton.snp.makeConstraints { make in
            make.centerY.equalTo(bottomView)
            make.height.width.equalTo(35)
            make.right.equalTo(view).offset(-10)
        }
        
        imageButton.snp.makeConstraints { make in
            make.centerY.equalTo(bottomView)
            make.height.width.equalTo(35)
            make.left.equalTo(view).offset(10)
        }
    }
    
    func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func hideKeyboardWhenTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func showKeyboard(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            setupConstraints(keyboardHeight: -keyboardFrame.height)
        }
        
        if let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) {
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
        if self.messages.count > 0 {
            scrollTo(row: self.messages.count-1)
        }
    }
    
    @objc func hideKeyboard(notification: Notification) {
        setupConstraints(keyboardHeight: 0)
        if let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) {
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func dismissKeyboard() {
        setupConstraints(keyboardHeight: 0)
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupKeyboard()
    }

    func getMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let friendId = friend.uid else {return}
        let friendMessagesRef = ref.child("user-messages").child(uid).child(friendId)
        friendMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = self.ref.child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let messageDict = snapshot.value as? [String:Any] {
                    let message = Message(dictionary: messageDict)
                    self.messages.append(message)
                    self.scrollTo(row: self.messages.count-1)
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func scrollTo(row: Int) {
        DispatchQueue.main.async {
            self.conversationTableView.reloadData()
            let indexPath = NSIndexPath(row: row, section: 0)
            self.conversationTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func send() {
        if let message = messageTextField.text, message != "" {
            let additionalData = [
                "message": message,
                ] 
            sendMessageWithValue(additionalData: additionalData)
            messageTextField.text = ""
        }
    }
    
    private func sendMessageWithValue(additionalData: [String: Any]) {
        let childRef = ref.child("messages").childByAutoId()
        let recipientID = friend.uid!
        let senderID = Auth.auth().currentUser!.uid
        let time = String(NSDate().timeIntervalSince1970)
        var data = [
            "senderID": senderID,
            "recipientID": recipientID,
            "time": time
            ] as [String : Any]
        additionalData.forEach { (arg) in
            let (key, value) = arg
            data[key] = value
        }
        childRef.setValue(data) { (error, reference) in
            if error != nil {
                print (error!)
                return
            }
            if let messageID = childRef.key {
                let senderRef = self.ref.child("user-messages").child(senderID).child(recipientID).child(messageID)
                let recipientRef = self.ref.child("user-messages").child(recipientID).child(senderID).child(messageID)
                senderRef.setValue(" ")
                recipientRef.setValue(" ")
            }
        }
    }
    
    @objc func pickImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            picPicker.sourceType = .photoLibrary
            present(picPicker, animated: true, completion: nil)
        } else {
            print ("unable to access photo library")
        }
    }
    
    @objc func searchPressed() {
        let searchVC = SearchInConversationViewController(messages: messages)
        searchVC.delegate = self
        self.navigationController?.pushViewController(searchVC, animated: true)
    }

}

extension ConversationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.messages[indexPath.row]
        if message.imageUrl != nil, let imageHeight = message.imageHeight, let imageWidth = message.imageWidth {
            if imageWidth > imageHeight {
                return CGFloat(imageHeight/imageWidth*200+10)
            } else {
                return CGFloat(210)
            }
        } else {
            if message.senderID == currentUser {
                return (message.message?.labelHeight(fontSize: 17, labelWidth: 280))! + 30
            } else {
                return (message.message?.labelHeight(fontSize: 17, labelWidth: 240))! + 30
            }
        }
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = conversationTableView.dequeueReusableCell(withIdentifier: convoReuseIdentifier, for: indexPath) as! ConversationTableViewCell
        let message = messages[indexPath.row]
        cell.configure(for: message, for: friend)
        cell.selectionStyle = .none
        cell.imageDelegate = self
        return cell
    }
}

extension ConversationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        send() 
        return true
    }
    
}

extension ConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print ("selected image")
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            uploadImageToFirebase(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImageToFirebase(image: UIImage) {
        let imageID = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message_images").child(imageID)
        let metadata = StorageMetadata()
        metadata.contentType = "message/jpeg"
        if let picData = image.jpegData(compressionQuality: 0.2) {
            storageRef.putData(picData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print (error!)
                } else {
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print (error!)
                        } else {
                            if let imageUrl = url?.absoluteString {
                                self.sendImageMessage(image: image, imageUrl: imageUrl)
                            }
                        }
                    })
                }
            }
        }
    }
    
    private func sendImageMessage(image: UIImage, imageUrl: String) {
        let additionalData = [
            "imageUrl": imageUrl,
            "imageWidth": image.size.width,
            "imageHeight": image.size.height,
            ] as [String : Any]
        sendMessageWithValue(additionalData: additionalData)
    }
    
}

extension ConversationViewController: ImageZoomDelegate {
    
    func performImageZoom(imageView: UIImageView) {
        
        dismissKeyboard()

        initialFrame = imageView.superview?.convert(imageView.frame, to: nil)
        
        zoomImageView = UIImageView(frame: initialFrame!)
        zoomImageView.image = imageView.image
        zoomImageView.isUserInteractionEnabled = true
        zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageZoomOutTap)))
        
        imageDownloadButton = UIButton()
        imageDownloadButton.setImage(UIImage(named: "download"), for: .normal)
        imageDownloadButton.addTarget(self, action: #selector(saveImageToCameraRoll), for: .touchUpInside)
        
        exitButton = UIButton()
        exitButton.setImage(UIImage(named: "circle-x"), for: .normal)
        exitButton.addTarget(self, action: #selector(xPressed), for: .touchUpInside)
    
        if let keyWindow = UIApplication.shared.keyWindow {
            
            backgroundView = UIScrollView(frame: keyWindow.frame)
            backgroundView.backgroundColor = .black
            backgroundView.delegate = self
            backgroundView.showsHorizontalScrollIndicator = false
            backgroundView.showsVerticalScrollIndicator = false
            backgroundView.bounces = false
            backgroundView.maximumZoomScale = 3.0
            backgroundView.minimumZoomScale = 1.0
            backgroundView.isScrollEnabled = true
            backgroundView.isUserInteractionEnabled = true
            backgroundView.alpha = 0
            keyWindow.addSubview(backgroundView)
            backgroundView.addSubview(zoomImageView)
            backgroundView.addSubview(imageDownloadButton)
            backgroundView.addSubview(exitButton)
            
            setButtonConstraints()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView.alpha = 1
                let width = keyWindow.frame.width
                let height = self.initialFrame.height / self.initialFrame.width * width
                self.zoomImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                self.zoomImageView.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    @objc func imageZoomOutTap(tap: UITapGestureRecognizer) {
        if let zoomOutImageView = tap.view as? UIImageView {
            imageZoomOut(zoomOutImageView: zoomOutImageView)
        }
    }
    
    @objc func xPressed() {
        imageZoomOut(zoomOutImageView: zoomImageView)
    }
    
    func imageZoomOut(zoomOutImageView: UIImageView) {
        zoomOutImageView.layer.cornerRadius = 20
        zoomOutImageView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            zoomOutImageView.frame = self.initialFrame
            self.backgroundView.alpha = 0
        }) { (completed: Bool) in
            self.backgroundView.removeFromSuperview()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomImageView
    }
    
    func setButtonConstraints() {
        imageDownloadButton.snp.makeConstraints { make in
            make.height.width.equalTo(45)
            make.bottom.equalTo(view.snp.bottom).offset(-80)
            make.left.equalTo(view).offset(30)
        }
        
        exitButton.snp.makeConstraints { make in
            make.height.width.equalTo(25)
            make.top.equalTo(view.snp.top).offset(10)
            make.right.equalTo(view).offset(-30)
        }
    }
    
    @objc func saveImageToCameraRoll() {
        guard let image = zoomImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            showPopup(text: "Save Failed")
        } else {
            showPopup(text: "Image Saved")
        }
    }
    
    func showPopup(text: String) {
        popupLabel = UILabel(frame: CGRect(x: view.frame.width/2-100, y: view.frame.height/2, width: 200, height: 100))
        popupLabel.textColor = .white
        popupLabel.backgroundColor = .black
        popupLabel.alpha = 0.8
        popupLabel.text = text
        popupLabel.textAlignment = .center
        popupLabel.font = .systemFont(ofSize: 20, weight: .bold)
        popupLabel.layer.masksToBounds = true
        popupLabel.layer.cornerRadius = 6
        backgroundView.addSubview(popupLabel)
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.dismissPopup), userInfo: nil, repeats: false)
    }
    
    @objc func dismissPopup(){
        if popupLabel != nil {
            popupLabel.removeFromSuperview()
        }
    }
}

extension ConversationViewController: ConversationSearchDelegate {
    func scrollToMessage(message: Message) {
        if let index = messages.firstIndex(where: {$0.message == message.message}) {
            let indexPath = IndexPath(row: index, section: 0)
            conversationTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
}


