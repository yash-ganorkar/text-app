//
//  SettingsController.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/4/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {

    @IBOutlet weak var displaypicture: UIImageView!
    @IBOutlet weak var name: UITextField!
    
    var loggedInUser = User()
    let fbAccount = FirebaseAccount()
    let activityIndicator = CustomActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        displaypicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectDisplayPictureView)))
        
        displaypicture.isUserInteractionEnabled = true
        
        setupLoggedInUserDetails()
        
        
    }
    
    func setupLoggedInUserDetails() {
        
        fbAccount.setupLoggedInUserDetails(forUser: loggedInUser) { (user) in
            self.loggedInUser = user
            
            if let profileImageUrl = user.profileImage {
                self.displaypicture.loadImageUsingCache(withURL: profileImageUrl)
                self.name.text = self.loggedInUser.name
            }
        }
        
    }
    
   
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingsController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @objc func handleSelectDisplayPictureView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
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
            displaypicture.image = selectedImage
        }
        
        self.dismiss(animated: true, completion: nil)
        
        activityIndicator.showActivityIndicator(uiView: self.view)
        
        fbAccount.saveProfilePicture(image: displaypicture.image!, imageName: imageName) { (profileImageURL) in
            //do nothing
            self.loggedInUser.profileImage = profileImageURL
            self.fbAccount.updateUserAccount(withUID: self.loggedInUser.userid!, forUser: self.loggedInUser, handler: { (message) in
                DispatchQueue.main.async() {
                    self.activityIndicator.hideActivityIndicator(uiView: self.view)
                }
            })
        }
    }
}
