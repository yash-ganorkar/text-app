//
//  TextMessage.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/5/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import UIKit
import Firebase
class TextMessage: NSObject {
    var from : String?
    var text: String?
    var timestamp : NSNumber?
    var to : String?
    
    func chatPartnerId() -> String? {
        
        return from == Auth.auth().currentUser?.uid ? to : from
    }
}
