//
//  FirebaseAccount.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/2/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class FirebaseAccount {
    
    var message = Message()
    
    var textMessages = [TextMessage]()
    var messageDictionary = [String : TextMessage]()
    
    func accountSignIn(forUser user: User, handler : @escaping(Message) -> ()) {
        
        Auth.auth().signIn(withEmail: user.email!, password: user.password!)
        { (user, error) in
            if error == nil {
                print(user?.user.displayName)
                self.message.details = "Successfull"
                handler(self.message)
            }
            else {
                guard let errorDescription = error?.localizedDescription else {
                    return
                }
                
                self.message.details = errorDescription
                handler(self.message)
            }
        }
    }
    
    func accountSignUp(forUser user: User, handler : @escaping(Message) -> ()) {
        Auth.auth().createUser(withEmail: user.email!, password: user.password!) { (user, error) in
            if error == nil {
                guard let uid = user?.user.uid else {
                    return
                }
                self.message.details = uid
                handler(self.message)
            }
            else {
                guard let errorDescription = error?.localizedDescription else {
                    return
                }
                
                self.message.details = "Error : \(errorDescription)"
                handler(self.message)
            }
            
        }
    }
    
    func createUserAccount(forUser user: User, handler: @escaping(Message) -> ())
    {
        let dbref = Database.database().reference(fromURL: dburl)
        
        let usersReference = dbref.child("users").child(user.userid!)
        let values = ["name": user.name!, "email": user.email!, "profilePicURL" : user.profileImage!]
        usersReference.updateChildValues(values) { (err, ref) in
            
            if err != nil {
                self.message.details = (err?.localizedDescription)!
                handler(self.message)
            }
            
            self.message.details = "Successfull"
            handler(self.message)
        }
        
    }
    
    func saveProfilePicture(image: UIImage, imageName: String, handler: @escaping(String) -> ()) {
        let storageRef = Storage.storage().reference().child("profileImages").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.1) {
            
            //        if let uploadData = image.pngData() {
            storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
                storageRef.downloadURL(completion: { (url, err) in
                    if err != nil {
                        print(err as Any)
                        handler("Error")
                    }
                    handler((url?.absoluteString)!)
                })
            }
        }
    }
    
    func updateUserAccount(withUID uid: String, forUser user: User, handler: @escaping(String) -> ()) {
        let dbref = Database.database().reference()
        
        let usersReference = dbref.child("users")
        
        let userDict = ["name" : user.name,
                        "email" : user.email,
                        "profilePicURL" : user.profileImage
        ]
        
        usersReference.child(uid).setValue(userDict)
        handler("Successful")
    }
    
    func accountSignOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        }catch let logoutError {
            print(logoutError)
            return false
        }
    }
    
    func fetchUserDetails(handler : @escaping(User?) -> ()) {
        if checkUserLoginStatus() {
            let loggedInUser = User()
            
            if let user = Auth.auth().currentUser {
                loggedInUser.email = user.email!
                loggedInUser.name = user.displayName!
            }
            
            handler(loggedInUser)
        }
    }
    
    func checkUserLoginStatus() -> Bool {
        if Auth.auth().currentUser?.uid == nil {
            print("User logged out!!")
            return false
        }
        print("User logged in!!")
        return true
    }
    
    func setupLoggedInUserDetails(forUser user: User, handler : @escaping (User) -> ()) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        let dbref = Database.database().reference().child("users")
        
        dbref.child(uid).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                user.email = dictionary["email"] as! String
                user.name = dictionary["name"] as! String
                user.profileImage = dictionary["profilePicURL"] as! String
                user.userid = uid
            }
            handler(user)
        }) { (error) in
            print(error)
        }
    }
    
    func fetchAllUsers(handler : @escaping ([User]) -> ()) {
        var users = [User]()
        guard let loggedInUser = Auth.auth().currentUser else {
            return
        }
        Database.database().reference().child("users").observe(DataEventType.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImage = dictionary["profilePicURL"] as? String
                user.userid = snapshot.key
                if loggedInUser.email != user.email {
                    users.append(user)
                }
            }
            handler(users)
        }, withCancel: { (error) in
            print(error)
        })
    }
    
    func sendMessage(messageText text: String, from: String, to: String, handler : @escaping () -> ()) {
        let dbref = Database.database().reference().child("messages")
        let childRef = dbref.childByAutoId()
        let timeStamp = NSDate().timeIntervalSince1970
        let values = ["text": text, "from": from, "to": to, "timestamp": timeStamp] as [String : Any]
        // childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(from).child(to)
            let messageId = childRef.key!
            let val = [messageId : 1] as [String : Any]
            userMessagesRef.updateChildValues(val) { (error, ref) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                let receipientRef = Database.database().reference().child("user-messages").child(to).child(from)
                
                receipientRef.updateChildValues(val, withCompletionBlock: { (error
                    , ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    handler()
                })
                
            }
        }
    }
    
    func sendImage(withImageUrl imageUrl: String, from: String, to: String, image: UIImage, handler : @escaping () -> ()) {
        let dbref = Database.database().reference().child("messages")
        let childRef = dbref.childByAutoId()
        let timeStamp = NSDate().timeIntervalSince1970
        let values = ["imageUrl": imageUrl, "from": from, "to": to, "timestamp": timeStamp, "imageWidth" : image.size.width, "imageHeight" : image.size.height] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(from).child(to)
            let messageId = childRef.key!
            let val = [messageId : 1] as [String : Any]
            userMessagesRef.updateChildValues(val) { (error, ref) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                let receipientRef = Database.database().reference().child("user-messages").child(to).child(from)
                
                receipientRef.updateChildValues(val, withCompletionBlock: { (error
                    , ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    handler()
                })
                
            }
        }
    }
    
    func fetchAllMessages(withUID uid : String,handler : @escaping ([TextMessage]) -> ()) {
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(DataEventType.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                
                let messageRef = Database.database().reference().child("messages").child(messageId)
                
                messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String : AnyObject] {
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
                        
                        print(textMessage)
                        
                        if let chatPartnerId = textMessage.chatPartnerId() {
                            self.messageDictionary[chatPartnerId] = textMessage
                            
                            self.textMessages = Array(self.messageDictionary.values)
                            self.textMessages.sort(by: { (message1, message2) -> Bool in
                                return message1.timestamp!.intValue > message2.timestamp!.intValue
                            })
                        }
                        handler(self.textMessages)
                    }
                })
                
            }, withCancel: { (error) in
                //
            })
        }, withCancel: {( error ) in
            print(error)
            
        })
    }
    
    func fetchUserNameAndProfilePicURL(withID id: String, handler : @escaping (String, String) -> ()) {
        
        let dbref = Database.database().reference().child("users").child(id)
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                handler((dictionary["name"] as? String)!, (dictionary["profilePicURL"] as? String)!)
            }
        }, withCancel: nil)
    }
    
    func fetchUser(withID id: String, handler : @escaping (User) -> ()) {
        
        let user = User()
        
        let dbref = Database.database().reference().child("users").child(id)
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImage = dictionary["profilePicURL"] as? String
                user.userid = snapshot.key
                
                handler(user)
            }
        }, withCancel: nil)
    }
    
    func deleteChats(message: TextMessage, handler : @escaping(Bool) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if let chatPartnerId = message.chatPartnerId() {
            let dbref = Database.database().reference().child("user-messages").child(uid).child(chatPartnerId)
            
            dbref.removeValue { (error, ref) in
                if error != nil {
                    print("Failed to delete message", error)
                    handler(false)
                }
                self.messageDictionary.removeValue(forKey: chatPartnerId)
                handler(true)
            }

        }
        
    }
    
}
