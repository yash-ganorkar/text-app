//
//  RegisterController.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/2/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import UIKit

class RegisterController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var name: UITextField!
    var userLogin : User?
    
     let activityIndicator = CustomActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerBtnWasPressed(_ sender: Any) {
        let email = self.email.text
        let password = self.password.text
        let confirmPassword = self.confirmPassword.text
        let name = self.name.text
        
        
        activityIndicator.showActivityIndicator(uiView: self.view)

        if !(password!.elementsEqual(confirmPassword!)) {
            let alertController = UIAlertController(title: "Alert", message: "Please enter correct password!!", preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: "OK", style: .default) { (_) in
                self.password.text = ""
                self.confirmPassword.text = ""
                
                self.activityIndicator.hideActivityIndicator(uiView: self.view)

            }
            
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
        } else if email == "" || password == "" || confirmPassword == "" || name == "" {
            let alertController = UIAlertController(title: "Alert", message: "One or more fields are empty!!", preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: "OK", style: .default) { (_) in
                self.password.text = ""
                self.confirmPassword.text = ""
                
                self.activityIndicator.hideActivityIndicator(uiView: self.view)
            }
            
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            
            let accountLogin = FirebaseAccount()
            userLogin = User()
            
            userLogin?.email = email!
            userLogin?.password = password!
            userLogin?.name = name!
            userLogin?.profileImage = defaultProfileImage
            
            accountLogin.accountSignUp(forUser: userLogin!) { (response) in
                if response.details.contains("Error") {
                    //show alert
                }
                else {
                    
                    self.userLogin?.userid = response.details
                    
                    accountLogin.createUserAccount(forUser: self.userLogin!, handler: { (response) in
                      
                        if response.details == "Successfull"{
                            let alertController = UIAlertController(title: "Alert", message: "User registered successfully", preferredStyle: .alert)
                            
                            let okButton = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                
                                self.dismiss(animated: true, completion: nil)
                            })
                            
                            alertController.addAction(okButton)
                            
                            self.activityIndicator.hideActivityIndicator(uiView: self.view)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                    })
                }
            }
        }
    }
    
    
//    // MARK: - Navigation
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "HomeVC" {
//            _ = segue.destination as? HomeController
//        }
//    }
    
    
}


