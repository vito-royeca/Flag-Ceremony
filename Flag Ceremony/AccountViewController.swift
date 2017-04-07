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

    // MARK: Variables
    var activity:Activity?
    var countries:[Country]?
    var selectedSegmentIndex = 0
    
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
                activity = nil
            } catch let error {
                print("\(error)")
            }
            updateDataDisplay()
        } else {
            performSegue(withIdentifier: "showLoginAsModal", sender: nil)
        }
    }
    
    @IBAction func dataChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        updateDataDisplay()
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "DataTableViewCell", bundle: nil), forCellReuseIdentifier: "DataCell")
        
        FirebaseManager.sharedInstance.fetchAllCountries(completion: { (countries: [Country]) in
            self.countries = countries
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateDataDisplay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseManager.sharedInstance.demonitorUserData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let tableView = tableView {
            tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCountry" {
            
            var countryVC:CountryViewController?
            
            if let nav = segue.destination as? UINavigationController {
                if let vc = nav.childViewControllers.first as? CountryViewController {
                    countryVC = vc
                }
            } else if let vc = segue.destination as? CountryViewController {
                countryVC = vc
            }
            
            if let countryVC = countryVC {
                countryVC.country = sender as? Country
            }
        }
    }

    // Mark: Custom methods
    func updateDataDisplay() {
        if let _ = FIRAuth.auth()?.currentUser {
            loginButton.image = UIImage(named: "logout")
            FirebaseManager.sharedInstance.monitorUserData(completion: { (activity: Activity?) in
                self.activity = activity
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        } else {
            loginButton.image = UIImage(named: "login")
            tableView.reloadData()
        }
    }
    
    func configure(cell: DataTableViewCell, at indexPath: IndexPath) {
        cell.rankLabel.isHidden = true
        cell.statIcon2.isHidden = true
        cell.statLabel2.isHidden = true
        
        switch selectedSegmentIndex {
        case 0:
            if let views = activity!.views,
                let countries = countries {
                let keys = Array(views.keys)
                let key = keys[indexPath.row]
                var country:Country?
                
                for c in countries {
                    if c.key == key {
                        country = c
                        break
                    }
                }
                
                if let country = country {
                    if let url = country.getFlagURLForSize(size: .normal) {
                        if let image = UIImage(contentsOfFile: url.path) {
                            cell.imageIcon.image = ImageUtil.imageWithBorder(fromImage: image)
                        }
                    }
                    cell.nameLabel.text = country.name
                    cell.statIcon.image = UIImage(named: "view-filled")
                    cell.statLabel.text = String(describing: views[key]!)
                }
            }
        case 1:
            if let plays = activity!.plays,
                let countries = countries {
                let keys = Array(plays.keys)
                let key = keys[indexPath.row]
                var country:Country?
                
                for c in countries {
                    if c.key == key {
                        country = c
                        break
                    }
                }
                
                if let country = country {
                    if let url = country.getFlagURLForSize(size: .normal) {
                        if let image = UIImage(contentsOfFile: url.path) {
                            cell.imageIcon.image = ImageUtil.imageWithBorder(fromImage: image)
                        }
                    }
                    cell.nameLabel.text = country.name
                    cell.statIcon.image = UIImage(named: "play-filled")
                    cell.statLabel.text = String(describing: plays[key]!)
                }
            }
        default:
            ()
        }
    }
}

extension AccountViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch section {
        case 0,1:
            rows = 1
        case 2:
            if let activity = activity {
                switch selectedSegmentIndex {
                case 0:
                    rows = activity.views?.count ?? 0
                case 1:
                    rows = activity.plays?.count ?? 0
                default:
                    ()
                }
            }
        default:
            ()
        }
        
        return rows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.section {
        case 0:
            if let dataCell = tableView.dequeueReusableCell(withIdentifier: "DataCell") as? DataTableViewCell {
                dataCell.imageIcon.image = UIImage(named: "user")
                dataCell.rankLabel.isHidden = false
                dataCell.statIcon2.isHidden = false
                dataCell.statLabel2.isHidden = false
                
                if let user = FIRAuth.auth()?.currentUser,
                    let activity = activity {
                    if let photoURL = user.photoURL {
                        NetworkingManager.sharedInstance.downloadImage(url: photoURL, completionHandler: { (origURL: URL?, image: UIImage?, error: NSError?) in
                            if let image = image {
                                dataCell.imageIcon.image = image
                            }
                        })
                    }
                    dataCell.nameLabel.text = user.displayName ?? user.email
                    dataCell.statIcon.image = UIImage(named: "view-filled")
                    if let viewCount = activity.viewCount {
                        dataCell.statLabel.text = String(describing: viewCount)
                    }
                    dataCell.statIcon2.image = UIImage(named: "play-filled")
                    if let playCount = activity.playCount {
                        dataCell.statLabel2.text = String(describing: playCount)
                    }
                } else {
                    dataCell.rankLabel.isHidden = true
                    dataCell.statIcon2.isHidden = true
                    dataCell.statLabel2.isHidden = true
                    dataCell.nameLabel.text = nil
                    dataCell.statIcon.image = nil
                    dataCell.statLabel.text = nil
                    dataCell.statIcon2.image = nil
                    dataCell.statLabel2.text = nil
                }
                cell = dataCell
            }
        case 1:
            if let c = tableView.dequeueReusableCell(withIdentifier: "SegmentedCell") {
                cell = c
            }
        case 2:
            if let dataCell = tableView.dequeueReusableCell(withIdentifier: "DataCell") as? DataTableViewCell {
                configure(cell: dataCell, at: indexPath)
                cell = dataCell
            }
        default:
            ()
        }
        
        cell!.selectionStyle = .none
        return cell!
    }
}

extension AccountViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(0)
        
        switch indexPath.section {
        case 0,2:
            height = 88
        case 1:
            height = UITableViewAutomaticDimension
        default:
            ()
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedSegmentIndex {
        case 0:
            if let views = activity!.views,
                let countries = countries {
                let keys = Array(views.keys)
                let key = keys[indexPath.row]
                var country:Country?
                
                for c in countries {
                    if c.key == key {
                        country = c
                        break
                    }
                }
                
                if let country = country {
                    self.performSegue(withIdentifier: "showCountry", sender: country)
                }
            }
        case 1:
            if let plays = activity!.plays,
                let countries = countries {
                let keys = Array(plays.keys)
                let key = keys[indexPath.row]
                var country:Country?
                
                for c in countries {
                    if c.key == key {
                        country = c
                        break
                    }
                }
                
                if let country = country {
                    self.performSegue(withIdentifier: "showCountry", sender: country)
                }
            }
        default:
            ()
        }
    }
}
