//
//  NewMessageController.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/3/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import UIKit


class NewMessageController: UITableViewController {

    let fbAccount = FirebaseAccount()
    var users = [User]()
    
    var chatsController : ChatsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.navigationItem.title = "New Message"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        fetchUsers()
    }
    
    func fetchUsers() {
        
        fbAccount.fetchAllUsers() { (registeredUsers) in
            self.users = registeredUsers
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ChatCell
        
       
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.timeLabel.text = ""

        if let profileImageUrl = user.profileImage {
            cell.profileImageView.loadImageUsingCache(withURL: profileImageUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.chatsController?.showChatController(user: user)
        }
    }
}
