//
//  UserLogin.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/2/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import Foundation

class User : NSObject {
    
    //MARK: Properties
    
    var email : String?
    var password : String?
    var name : String?
    var userid : String?
    var profileImage : String?
    
    //MARK: Initialization
    override init() {
        self.email = ""
        self.password = ""
        self.name = ""
        self.userid = ""
        self.profileImage = ""
    }
    
}
