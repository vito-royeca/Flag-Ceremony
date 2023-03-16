//
//  MenuViewController.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 18/12/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import Appirater
import SafariServices
import StoreKit

let kLoginShown = "kLoginShown"

let kAppsInfo = [["id": CineKo_AppID,
                  "name": "Cine Ko!",
                  "image": "cineKo"],
                 ["id": WTHRM8_AppID,
                  "name": "WTHRM8",
                  "image": "wthrm8"]]

class MenuViewController: CommonViewController {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Custom methods
    func showShareActivity(sourceView: UIView) {
        let appIcon = UIImage(named: "AppIcon40x40")
        let objectsToShare = ["Flag Ceremony is an iOS app that displays flags and plays national anthems from various countries around the world.",
                              appIcon!] as [Any]
        let excludedActivities = [UIActivity.ActivityType.postToWeibo,
                                  UIActivity.ActivityType.print,
                                  UIActivity.ActivityType.copyToPasteboard,
                                  UIActivity.ActivityType.assignToContact,
                                  UIActivity.ActivityType.saveToCameraRoll,
                                  UIActivity.ActivityType.addToReadingList,
                                  UIActivity.ActivityType.postToFlickr,
                                  UIActivity.ActivityType.postToVimeo,
                                  UIActivity.ActivityType.postToTencentWeibo,
                                  UIActivity.ActivityType.airDrop]
        let activityVC = UIActivityViewController(activityItems: objectsToShare,
                                                  applicationActivities: nil)
        
        activityVC.excludedActivityTypes = excludedActivities
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            // user did not cancel
            if success {
                if let e = error {
                    print("error sharing: \(e)")
                }
                
                self.dismiss(animated: true,
                             completion: nil)
            }
        }
        activityVC.popoverPresentationController?.sourceView = sourceView
        present(activityVC,
                animated: true,
                completion: nil)
    }
    
    func openStoreProduct(identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters)
                                        { (loaded, error) -> Void in
            if let error = error {
                print("\(error)")
            }
        }
        present(storeViewController,
                animated: true,
                completion: nil)
    }
}

// MARK: UITableViewDataSource
extension MenuViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch section {
        case 0:
            rows = 2
        case 1:
            rows = kAppsInfo.count
        case 2:
            rows = 1
        default:
            ()
        }
        
        return rows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title:String?
        
        switch section {
        case 0:
            title = "Tools"
        case 1:
            title = "Apps"
        case 2:
            title = "Developer"
        default:
            ()
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        cell.detailTextLabel!.text = nil
        cell.accessoryType = .none
        
        switch indexPath.section {
        case 0:
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
        case 1:
            // Rounded Rect for cell image
            if let imageLayer = cell.imageView?.layer {
                imageLayer.cornerRadius = 9.0
                imageLayer.masksToBounds = true
            }
            
            cell.textLabel!.text = kAppsInfo[indexPath.row]["name"]
            cell.imageView!.image = UIImage(named: kAppsInfo[indexPath.row]["image"]!)
            
        case 2:
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
        case 0:
            switch indexPath.row {
            case 0:
                showParentalGate {
                    Appirater.forceShowPrompt(true)
                }
            case 1:
                showParentalGate {
                    let cell = self.tableView(tableView,
                                              cellForRowAt: indexPath)
                    self.showShareActivity(sourceView: cell)
                }
            default:
                ()
            }
        case 1:
            showParentalGate {
                self.openStoreProduct(identifier: kAppsInfo[indexPath.row]["id"]!)
            }
            
        case 2:
            switch indexPath.row {
            case 0:
                showParentalGate {
                    if let url = URL(string: DeveloperWebsite),
                        let navigationController = self.navigationController {
                        let svc = SFSafariViewController(url: url,
                                                         entersReaderIfAvailable: true)
                        svc.delegate = self
                        navigationController.present(svc,
                                                     animated: true,
                                                     completion: nil)
                    }

                }
            default:
                ()
            }
        default:
            ()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: SKStoreProductViewControllerDelegate
extension MenuViewController : SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true,
                               completion: nil)
    }
}

// MARK: SFSafariViewControllerDelegate
extension MenuViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true,
                           completion: nil)
    }
}
