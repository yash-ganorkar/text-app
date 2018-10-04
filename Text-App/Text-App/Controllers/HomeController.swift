//
//  HomeController.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/2/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var userlogin = UserLogin()
    let activityIndicator = CustomActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterVC" {
            _ = segue.destination as? RegisterController
        }
        else if segue.identifier == "ChatsVC" {
            _ = segue.destination as? ChatsController
        }
    }

    @IBAction func loginBtnWasPressed(_ sender: Any) {
        
        let email = self.email.text
        let password = self.password.text
        
        activityIndicator.showActivityIndicator(uiView: self.view)
        
        if email == "" || password == "" {
            let alertController = UIAlertController(title: "Alert", message: "Username and/or Password field is empty!!", preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okButton)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            userlogin.email = email!
            userlogin.password = password!
            
            let accountLogin = FirebaseAccount()
            
            accountLogin.accountSignIn(forUser: userlogin) { (message) in
                
                if message.details != "Successfull" {
                    let alertController = UIAlertController(title: "Alert", message: "Username and/or Password not registered.!!", preferredStyle: .alert)
                    
                    let okButton = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                        // do nothing
                    })
                    
                    alertController.addAction(okButton)
                }
                else {
                    let alertController = UIAlertController(title: "Alert", message: "User logged in!!", preferredStyle: .alert)
                    
                    let okButton = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                        self.performSegue(withIdentifier: "ChatsVC", sender: sender)
                    })
                    
                    alertController.addAction(okButton)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                self.activityIndicator.hideActivityIndicator(uiView: self.view)
            }
        }
    }
    
    
    @IBAction func registerBtnWasPressed(_ sender: Any) {
        performSegue(withIdentifier: "RegisterVC", sender: sender)
    }
    
}

