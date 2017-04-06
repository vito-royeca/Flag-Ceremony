//
//  AccountViewController.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 06/04/2017.
//  Copyright © 2017 Jovit Royeca. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: CommonViewController {

    // MARK: Outlets
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        showMenu()
    }
    
    @IBAction func loginAction(_ sender: UIBarButtonItem) {
        if let _ = FIRAuth.auth()?.currentUser {
            do {
                try FIRAuth.auth()?.signOut()
            } catch let error {
                print("\(error)")
            }
            updateDataDisplay()
        } else {
            performSegue(withIdentifier: "showLoginAsModal", sender: nil)
        }
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDataDisplay()
    }
    
    // Mark: Custom methods
    func updateDataDisplay() {
        if let _ = FIRAuth.auth()?.currentUser {
            loginButton.image = UIImage(named: "logout")
        } else {
            loginButton.image = UIImage(named: "login")
        }
        tableView.reloadData()
    }
}

extension AccountViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if let c = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            if let user = FIRAuth.auth()?.currentUser {
                c.textLabel!.text = user.displayName ?? user.email
                c.detailTextLabel?.text = nil
                
                if let photoURL = user.photoURL {
                    c.imageView!.image = UIImage(named: "user")
                    NetworkingManager.sharedInstance.downloadImage(url: photoURL, completionHandler: { (origURL: URL?, image: UIImage?, error: NSError?) in
                        if let image = image {
                            c.imageView!.image = image
                        }
                    })
                } else {
                    c.imageView!.image = UIImage(named: "user")
                }
            } else {
                c.textLabel!.text = nil
                c.detailTextLabel?.text = nil
                c.imageView!.image = UIImage(named: "user")
            }

            cell = c
        }
        
        return cell!
    }
}

extension AccountViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(0)
        
        switch indexPath.row {
        case 0:
            height = 88
        default:
            height = UITableViewAutomaticDimension
        }
        
        return height
    }
}
