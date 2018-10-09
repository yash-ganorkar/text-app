//
//  ChatLogController.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/5/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import UIKit
import Firebase
class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var user : User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var textMessages = [TextMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "cellId")
        
        collectionView?.keyboardDismissMode = .interactive
        
        setupLoggedInUserDetails()
        setupKeyboardObservers()
    }

    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.userid else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messagesRef = Database.database().reference().child("messages").child(snapshot.key)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }
                
                let textMessage = TextMessage()
                
                textMessage.from = dictionary["from"] as? String
                if let text = dictionary["text"] as? String {
                    textMessage.text = text
                }
                
                if let imageUrl = dictionary["imageUrl"] as? String {
                    textMessage.imageUrl = imageUrl
                    textMessage.imageWidth = dictionary["imageWidth"] as? NSNumber
                    textMessage.imageHeight = dictionary["imageHeight"] as? NSNumber
                }
                textMessage.timestamp = dictionary["timestamp"] as? NSNumber
                textMessage.to = dictionary["to"] as? String
                
                
                
                 self.textMessages.append(textMessage)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        let indexPath = NSIndexPath(item: self.textMessages.count - 1, section: 0)
                        self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                    }
            }) { (error) in
                print(error)
            }
        }) { (error) in
            print(error)
        }
    }
    lazy var inputTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    var loggedInUser = User()
    
    let fbAccount = FirebaseAccount()
    
    
    lazy var inputContainerView : UIView? = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "uploadimage")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendBtn = UIButton(type: .system)
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendBtn)
        
        sendBtn.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendBtn.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendBtn.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendBtn.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        return containerView
    }()
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker : UIImage?
        var imageName = String()
        
        if let editedImage = info[.editedImage] {
            selectedImageFromPicker = editedImage as! UIImage
        }
            
        else if let originalImage = info[.originalImage] {
            selectedImageFromPicker = originalImage as! UIImage
        }
        
        if let imagePath = info[.imageURL] {
            imageName = (imagePath as! NSURL).lastPathComponent!
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            self.uploadToFirebaseStorageUsingImage(image: selectedImage, imageName: imageName)
            
        }
        
        self.dismiss(animated: true, completion: nil)

    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, imageName: String) {
        
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("Message failed", error)
                    return
                }
                
                ref.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print("Message failed", error)
                        return
                    }
                    if let imageUrl = url?.absoluteString {
                        print(imageUrl)
                        self.fbAccount.sendImage(withImageUrl: imageUrl, from: self.loggedInUser.userid!, to: (self.user?.userid!)!, image: image, handler: {
                            //
                        })
                    }
                })
            }
        }
        
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
   override var canBecomeFirstResponder: Bool { return true }
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    @objc func handleKeyboardDidShow(notification: Notification) {
        if textMessages.count > 0 {
            let indexPath = NSIndexPath(item: textMessages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    @objc func handleKeyboardWillHide(notification : Notification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        
        containerViewBottomAnchor?.constant = 0
        
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double

        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //to avoid memory leaks
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleKeyboardWillShow(notification : Notification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height :CGFloat = 80
        
        let message = textMessages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func setupLoggedInUserDetails() {
        
        fbAccount.setupLoggedInUserDetails(forUser: loggedInUser) { (user) in
            self.loggedInUser = user
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return textMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ChatMessageCell
       
        cell.chatLogController = self
        
        let message = textMessages[indexPath.row]
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCache(withURL: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.textView.isHidden = true
        }
        else {
            cell.messageImageView.isHidden = true
            cell.bubbleView.backgroundColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
            cell.textView.isHidden = false
        }
        
        if message.from == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blackColor
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }
        else {
            cell.bubbleView.backgroundColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            
            cell.textView.text = text
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
        
        
        return cell
    }
    
    var containerViewBottomAnchor : NSLayoutConstraint?
    
   @objc func handleSend() {
    
    fbAccount.sendMessage(messageText: inputTextField.text!, from: self.loggedInUser.userid!, to: (user?.userid!)!) {
            self.inputTextField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        textField.text = ""
        return true
    }
    
    var startingFrame : CGRect?
    var blackBackgroundView : UIView?
    var startImageView : UIImageView?
    
    func performZoomInForStartingImageView(staringImageView: UIImageView) {
        
        self.startImageView = staringImageView
        self.startImageView?.isHidden = true
        
        startingFrame = staringImageView.superview?.convert(staringImageView.frame, to: nil)
        
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        
        zoomingImageView.image = staringImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow =  UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView?.alpha = 0
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center

            }) { (completed) in
                // do nothing
            }
        }
    }
    
    @objc func handleZoomOut(tapGesture : UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView?.alpha = 1
            }) { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startImageView?.isHidden = false
            }
        }
    }
}
