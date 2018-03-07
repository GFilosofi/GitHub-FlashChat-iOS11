//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // Declare instance variables here
    lazy var dataList: [String] = {
        var tmpArray = [String]()
        for i in 0..<100 {
            tmpArray.append("message \(i)")
        }
        return tmpArray
    }()
    
    lazy var messageArray: [Message] = [Message]()

    // We've pre-linked the IBOutlets
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var messageTableView: UITableView! {
        willSet { //property observer. We use it to allocate the required cache for the TV
            newValue.delegate = self //this is the same of Ctrl+drag in the storyboard
            newValue.dataSource = self
            newValue.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
            //the following settings allow the cell height to adjust automatically to fit the message size
            newValue.rowHeight = UITableViewAutomaticDimension
            newValue.estimatedRowHeight = 120.0
            newValue.separatorStyle = .none
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextfield.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        retrieveMessages()
    }

    //MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        //select the avatar image and the bkg color depending if the message is mine or not
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            cell.avatarImageView.image = UIImage(named: "me")
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.avatarImageView.image = UIImage(named: "steve")
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatLime()
        }
        return cell
    }
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }

    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        //Disable the TextField and the button to prevent unvoluntary repetitions
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        //Send the message to Firebase and save it in our database
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": (Auth.auth().currentUser?.email)!, "MessageBody": messageTextfield.text!]
        messagesDB.childByAutoId().setValue(messageDictionary) {(error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfully!")
                //Re-enable the TextField and the button
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //Create the retrieveMessages method here:
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(DataEventType.childAdded) { (snapshot) in
            let messageDictionary = snapshot.value as! [String:String]
            guard let sender = messageDictionary["Sender"] else {return}
            guard let text = messageDictionary["MessageBody"] else {return}
            //print(sender + " sent: " + text)
            let message = Message()
            message.sender = sender
            message.messageBody = text
            self.messageArray.append(message)
            self.messageTableView.reloadData()
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        //Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
