//
//  MenuViewController.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 18/12/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import Appirater
import Firebase
import SafariServices
import StoreKit

let kLoginShown = "kLoginShown"

class MenuViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func loginAction(_ sender: UIBarButtonItem) {
        if let _ = FIRAuth.auth()?.currentUser {
            do {
                try FIRAuth.auth()?.signOut()
                loginButton.title = "Login"
            } catch let error {
                print("\(error)")
            }
        }
        tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kLoginShown), object: nil, userInfo: nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = FIRAuth.auth()?.currentUser {
            loginButton.title = "Logout"
        } else {
            loginButton.title = "Login"
        }
        tableView.reloadData()
    }
    
    // MARK: Custom methods
    func showShareActivity(sourceView: UIView) {
        let appIcon = UIImage(named: "AppIcon40x40")
        let objectsToShare = ["Flag Ceremony displays flags and plays national anthems from various countries around the world", appIcon!] as [Any]
        let excludedActivities = [UIActivityType.postToWeibo, UIActivityType.message, UIActivityType.mail, UIActivityType.print,UIActivityType.copyToPasteboard, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList, UIActivityType.postToFlickr, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo, UIActivityType.airDrop]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = excludedActivities
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            // user did not cancel
            if success {
                if let e = error {
                    print("error sharing: \(e)")
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        activityVC.popoverPresentationController?.sourceView = sourceView
        present(activityVC, animated: true, completion: nil)
    }
    
    func openStoreProduct(identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) { (loaded, error) -> Void in
            if let error = error {
                print("\(error)")
            }
        }
        present(storeViewController, animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource
extension MenuViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch section {
        case 0:
            rows = 1
        case 1:
            rows = 2
        case 2:
            rows = 4
        case 3:
            rows = 1
        default:
            ()
        }
        
        return rows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title:String?
        
        switch section {
        case 1:
            title = "Tools"
        case 2:
            title = "Apps"
        case 3:
            title = "Developer"
        default:
            ()
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.detailTextLabel!.text = nil
        cell.accessoryType = .none
        
        switch indexPath.section {
        case 0:
            if let user = FIRAuth.auth()?.currentUser {
                cell.textLabel!.text = user.displayName ?? user.email
                
                if let photoURL = user.photoURL {
                    cell.imageView!.image = UIImage(named: "user")
                    NetworkingManager.sharedInstance.downloadImage(url: photoURL, completionHandler: { (image: UIImage?, error: NSError?) in
                        if let image = image {
                            cell.imageView!.image = image
                        }
                    })
                } else {
                    cell.imageView!.image = UIImage(named: "user")
                }
            } else {
                cell.textLabel!.text = nil
                cell.imageView!.image = UIImage(named: "user")
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = "Rate This App"
                cell.imageView!.image = UIImage(named: "star")
            case 1:
                cell.textLabel!.text = "Share This App"
                cell.imageView!.image = UIImage(named: "share")
            default:
                ()
            }
        case 2:
            // Rounded Rect for cell image
            if let imageLayer = cell.imageView?.layer {
                imageLayer.cornerRadius = 9.0
                imageLayer.masksToBounds = true
            }
            
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = "Cine Ko!"
                cell.imageView!.image = UIImage(named: "cineKo")
            case 1:
                cell.textLabel!.text = "Decktracker"
                cell.imageView!.image = UIImage(named: "decktracker")
            case 2:
                cell.textLabel!.text = "Fun With TTS"
                cell.imageView!.image = UIImage(named: "funWithTTS")
            case 3:
                cell.textLabel!.text = "WTHRM8"
                cell.imageView!.image = UIImage(named: "wthrm8")
            default:
                ()
            }
        case 3:
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = DeveloperName
                cell.detailTextLabel!.text = DeveloperWebsite
                cell.imageView!.image = UIImage(named: "domain")
                cell.accessoryType = .disclosureIndicator
            default:
                ()
            }
        default:
            ()
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension MenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                Appirater.forceShowPrompt(true)
            case 1:
                let cell = self.tableView(tableView, cellForRowAt: indexPath)
                showShareActivity(sourceView: cell)
            default:
                ()
            }
        case 2:
            switch indexPath.row {
            case 0:
                openStoreProduct(identifier: CineKo_AppID)
            case 1:
                openStoreProduct(identifier: Decktracker_AppID)
            case 2:
                openStoreProduct(identifier: FunWithTTS_AppID)
            case 3:
                openStoreProduct(identifier: WTHRM8_AppID)
            default:
                ()
            }
        case 3:
            switch indexPath.row {
            case 0:
                if let url = URL(string: DeveloperWebsite) {
                    let svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                    svc.delegate = self
                    navigationController?.present(svc, animated: true, completion: nil)
                }
            default:
                ()
            }
        default:
            ()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(0)
        
        switch indexPath.section {
        case 0:
            height = 88
        default:
            height = UITableViewAutomaticDimension
        }
        
        return height
    }
}

// MARK: SKStoreProductViewControllerDelegate
extension MenuViewController : SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: SFSafariViewControllerDelegate
extension MenuViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
