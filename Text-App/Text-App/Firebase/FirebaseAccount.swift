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
                    print(url?.absoluteString)
                    handler((url?.absoluteString)!)
                })
            }
        }
    }
    
    func updateUserAccount(withUID uid: String, forUser user: User, handler: @escaping(String) -> ()) {
        let dbref = Database.database().reference(fromURL: dburl)
        
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
        
    Database.database().reference().child("users").child(uid).observe(DataEventType.value, with:
            { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    user.email = dictionary["email"] as! String
                    user.name = dictionary["name"] as! String
                    user.profileImage = dictionary["profilePicURL"] as! String
                    user.userid = uid
                }
                handler(user)
            }, withCancel: nil)
    }
    
    func fetchAllUsers(handler : @escaping ([User]) -> ()) {
        var users = [User]()
        Database.database().reference().child("users").observe(DataEventType.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImage = dictionary["profilePicURL"] as? String
                
//                if loggedInUser != user {
//                  users.append(user)
//                }
                
                users.append(user)
            }
            
            handler(users)
        }, withCancel: nil)
    }
    
}
