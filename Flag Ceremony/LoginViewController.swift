//
//  LoginViewController.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 18/12/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import MBProgressHUD

class LoginViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        switch sender.tag {
        case 3: // Login
            var email:String?
            var password:String?
            
            if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) {
                if let textField = cell.contentView.viewWithTag(100) as? UITextField {
                    email = textField.text
                }
            }
            if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) {
                if let textField = cell.contentView.viewWithTag(100) as? UITextField {
                    password = textField.text
                }
            }
            
            if let email = email,
                let password = password {
                
                // TO DO: add validation here...
                
                MBProgressHUD.showAdded(to: self.view, animated: true)
                FIRAuth.auth()!.signIn(withEmail: email, password: password,  completion: {(user: FIRUser?, error: Error?) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    if let error = error {
                        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
            
        case 6: // Sign Up
            let alertController = UIAlertController(title: "Sign Up", message: nil, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Submit", style: .default) { (_) in
                MBProgressHUD.showAdded(to: self.view, animated: true)
                
                if let fields = alertController.textFields {
                    let email = fields[0].text
                    let password1 = fields[1].text
                    let password2 = fields[2].text
                    
                    // TO DO: add validation here...
                    
                    
                    FIRAuth.auth()!.createUser(withEmail: email!, password: password1!) { user, error in
                        if let error = error {
                            MBProgressHUD.hide(for: self.view, animated: true)
                            
                            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            FIRAuth.auth()!.signIn(withEmail: email!, password: password1!, completion: {(user: FIRUser?, error: Error?) in
                                MBProgressHUD.hide(for: self.view, animated: true)
                                
                                if let error = error {
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                    
                                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alertController, animated: true, completion: nil)
                                } else {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                        }
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alertController.addTextField { (textField) in
                textField.placeholder = "Email"
            }
            alertController.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
            alertController.addTextField { (textField) in
                textField.placeholder = "Confirm Password"
                textField.isSecureTextEntry = true
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        case 12: // Retrieve Password
            ()
        default:
            ()
        }
    }
    
    @IBAction func facebookAction(_ sender: UIButton) {
        let login = FBSDKLoginManager()
        
        login.logIn(withReadPermissions: ["public_profile"], from: self, handler: {(result: FBSDKLoginManagerLoginResult?, error: Error?) in
            if let error = error {
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                if let current = FBSDKAccessToken.current() {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: current.tokenString)
                    FIRAuth.auth()!.signIn(with: credential, completion: {(user: FIRUser?, error: Error?) in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        if let error = error {
                            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
        })
    }
    
    @IBAction func twitterAction(_ sender: UIButton) {
        
    }
    
    @IBAction func googlePlusAction(_ sender: UIButton) {
        
    }
    
    @IBAction func githubAction(_ sender: UIButton) {
        
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSource
extension LoginViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "LogoCell", for: indexPath)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath)
            if let textField = cell!.contentView.viewWithTag(100) as? UITextField {
                textField.placeholder = "Email"
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath)
            if let textField = cell!.contentView.viewWithTag(100) as? UITextField {
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath)
            if let button = cell!.contentView.viewWithTag(100) as? UIButton {
                button.setTitle("Login", for: .normal)
                button.tag = indexPath.row
                
                let imageLayer = button.layer
                imageLayer.cornerRadius = button.frame.size.height/4
                imageLayer.masksToBounds = true
            }
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "ClearCell", for: indexPath)
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            if let label = cell!.contentView.viewWithTag(100) as? UILabel {
                label.text = "No Account?"
            }
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath)
            if let button = cell!.contentView.viewWithTag(100) as? UIButton {
                button.setTitle("Sign Up", for: .normal)
                button.tag = indexPath.row
                
                let imageLayer = button.layer
                imageLayer.cornerRadius = button.frame.size.height/4
                imageLayer.masksToBounds = true
            }
        case 7:
            cell = tableView.dequeueReusableCell(withIdentifier: "ClearCell", for: indexPath)
        case 8:
            cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            if let label = cell!.contentView.viewWithTag(100) as? UILabel {
                label.text = "Or Login With Your Other Accounts"
            }
        case 9:
            cell = tableView.dequeueReusableCell(withIdentifier: "AccountsCell", for: indexPath)
            for subview in cell!.contentView.subviews {
                if let button = subview as? UIButton {
                    if let image = button.imageView?.image {
                        let tintedImage = image.withRenderingMode(.alwaysTemplate)
                        button.imageView?.image = tintedImage
                        button.imageView?.tintColor = view.backgroundColor
                    }
                    
                    let imageLayer = button.layer
                    imageLayer.cornerRadius = button.frame.size.height/4
                    imageLayer.masksToBounds = true
                }
            }
        case 10:
            cell = tableView.dequeueReusableCell(withIdentifier: "ClearCell", for: indexPath)
        case 11:
            cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            if let label = cell!.contentView.viewWithTag(100) as? UILabel {
                label.text = "Forgot Password?"
            }
        case 12:
            cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath)
            if let button = cell!.contentView.viewWithTag(100) as? UIButton {
                button.setTitle("Retrive Password", for: .normal)
                button.tag = indexPath.row
                
                let imageLayer = button.layer
                imageLayer.cornerRadius = button.frame.size.height/4
                imageLayer.masksToBounds = true
            }
        default:
            ()
        }
        
        return cell!
    }
}

// MARK: UITableViewDelegate
extension LoginViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(0)
        
        switch indexPath.row {
        case 0, 9:
            height = 88
        case 4, 7, 10:
            height = 10
        default:
            height = UITableViewAutomaticDimension
        }
        
        return height
    }
}
