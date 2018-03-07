//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    @IBAction func logInPressed(_ sender: AnyObject) {
        SVProgressHUD.show()
        //Log in the user
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
                print(String(describing: error!))
                let alert = UIAlertController(title: "Login", message: String(describing: error!), preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(boo) in
                    self.emailTextfield.text = ""
                    self.passwordTextfield.text = ""
                })
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                print("User \(user!) has logged in successfully")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToChat", sender: nil)
            }
        }
    }
}
