//
//  ChatsController.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/2/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import UIKit

class ChatsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    let fbAccount = FirebaseAccount()
    var loggedInUser = User()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        setupLoggedInUserDetails()
    }
    
    func setupLoggedInUserDetails() {
        
        fbAccount.setupLoggedInUserDetails(forUser: loggedInUser) { (user) in
            self.loggedInUser = user
        }
        
    }
    
    @IBAction func segmentValueIsChanged(_ sender: Any) {
    }
    
    
    @IBAction func logoutBtnWasPressed(_ sender: Any) {
        if fbAccount.accountSignOut() {
           self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func composeBtnWasPressed(_ sender: Any) {
       // self.performSegue(withIdentifier: "NewMessageVC", sender: sender)
        
        let newMessageController = NewMessageController()
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
    
}

extension ChatsController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 50
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // Configure the cell...
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

}
