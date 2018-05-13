//
//  ContactViewController.swift
//  iFall
//
//  Created by Sathvik Koneru on 4/9/18.
//  Copyright © 2018 Sathvik Koneru. All rights reserved.

import Foundation
import UIKit
import Contacts
import ContactsUI
import ChameleonFramework

//global list of emergency contacts
var pickedUsers: [CNContact] = []

class ContactViewController: UIViewController, CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = RandomFlatColor()
        self.setStatusBarStyle(UIStatusBarStyleContrast)
        tableView.dataSource = self
    }
    
    //presents ContactPickerViewController when "+" button is pressed
    @IBAction func showContacts(_ sender: Any) {
        let picker = CNContactPickerViewController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    //adding chosen users to pickedUser array
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        contacts.forEach{ (contact) in
            pickedUsers.append(contact)
        }
        print(pickedUsers)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancelled out out of Contact Picker View Controller")
    }
    
    //returns section numbers
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickedUsers.count
    }
    
    //return string value in particular row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
    cell.textLabel?.text = "\(pickedUsers[indexPath.row].givenName) \(pickedUsers[indexPath.row].familyName)"
        return cell
    }
    
    //method for deleting cells
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            pickedUsers.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //this method reloads the data so that each time new contacts, they will
    //show up in the Table View
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

