//
//  ChatsController.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/2/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import UIKit
import UserNotifications

class ChatsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    let fbAccount = FirebaseAccount()
    var loggedInUser = User()
    var messages = [TextMessage]()
    let activityIndicator = CustomActivityIndicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: "reuseIdentifier")
    
        activityIndicator.showActivityIndicator(uiView: self.view)
        setupLoggedInUserDetails()
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func observeMessages() {
        
        fbAccount.fetchAllMessages(withUID: loggedInUser.userid!) { (textMessages) in
            self.messages = textMessages
            
            self.attemptReloadOfTable()
        }
        self.activityIndicator.hideActivityIndicator(uiView: self.view)
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    var timer : Timer?
    
    func setupLoggedInUserDetails() {
        
        fbAccount.setupLoggedInUserDetails(forUser: loggedInUser) { (user) in
            self.loggedInUser = user
            self.observeMessages()
        }
        
    }
    
    @IBAction func logoutBtnWasPressed(_ sender: Any) {
        if fbAccount.accountSignOut() {
           self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func composeBtnWasPressed(_ sender: Any) {
       // self.performSegue(withIdentifier: "NewMessageVC", sender: sender)
        
        let newMessageController = NewMessageController()
        newMessageController.chatsController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        
        self.present(navController, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "NewMessageVC" {
            _ = segue.destination as? NewMessageController
        }
        
        if segue.identifier == "SettingsVC" {
            _ = segue.destination as? SettingsController
        }
    }
    
    
    @IBAction func settingsBtnWasPressed(_ sender: Any) {
        performSegue(withIdentifier: "SettingsVC", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       self.tableView.reloadData()
    }
    
}

extension ChatsController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        fbAccount.fetchUser(withID: chatPartnerId) { (response) in
            let user = User()
            
            user.name = response.name
            user.email = response.email
            user.profileImage = response.profileImage
            user.userid = chatPartnerId
            
            self.showChatController(user: user)
        }
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ChatCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        self.activityIndicator.hideActivityIndicator(uiView: self.view)
        return cell
    }
    
    func showChatController(user: User) {
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let message = self.messages[indexPath.row]
        
        fbAccount.deleteChats(message: message) { (response) in
            if response {
                self.observeMessages()
            }
        }
    }
}

