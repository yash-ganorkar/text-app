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
    
    
    func accountSignIn(forUser user: UserLogin, handler : @escaping(Message) -> ()) {
        
        Auth.auth().signIn(withEmail: user.email, password: user.password)
        { (user, error) in
            if error == nil {
                
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
    
    func accountSignUp(forUser user: UserLogin, handler : @escaping(Message) -> ()) {
        Auth.auth().createUser(withEmail: user.email, password: user.password) { (user, error) in
            if error == nil {
                
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
}
