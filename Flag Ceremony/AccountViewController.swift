//
//  AccountViewController.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 06/04/2017.
//  Copyright © 2017 Jovit Royeca. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import SDWebImage

class AccountViewController: CommonViewController {

    // MARK: Variables
    var activity:FCActivity?
    var countries:[FCCountry]?
    var selectedSegmentIndex = 0
    
    // MARK: Outlets
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        showMenu()
    }
    
    @IBAction func loginAction(_ sender: UIBarButtonItem) {
        if let _ = Auth.auth().currentUser {
            do {
                try Auth.auth().signOut()
                activity = nil
            } catch let error {
                print("\(error)")
            }
            updateDataDisplay()
        } else {
            showParentalGate {
                self.performSegue(withIdentifier: "showLoginAsModal",
                                  sender: nil)
            }
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
        tableView.register(UINib(nibName: "DataTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "DataCell")
        
        FirebaseManager.sharedInstance.fetchAllCountries(completion: { (countries: [FCCountry]) in
            self.countries = countries
            self.updateDataDisplay()
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
                if let vc = nav.children.first as? CountryViewController {
                    countryVC = vc
                }
            } else if let vc = segue.destination as? CountryViewController {
                countryVC = vc
            }
            
            if let countryVC = countryVC {
                countryVC.country = sender as? FCCountry
            }
        }
    }

    // Mark: Custom methods
    func updateDataDisplay() {
        if let _ = Auth.auth().currentUser {
            loginButton.image = UIImage(named: "logout")
//            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            FirebaseManager.sharedInstance.monitorUserData(completion: { (activity: FCActivity?) in
                self.activity = activity
                DispatchQueue.main.async {
//                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.tableView.reloadData()
                }
            })
        } else {
            loginButton.image = UIImage(named: "login")
            tableView.reloadData()
        }
    }
    
    func configure(cell: DataTableViewCell, at indexPath: IndexPath) {
        var country:FCCountry?
        var stat = 0
        
        cell.rankLabel.text = " "
        cell.statIcon2.image = nil
        cell.statLabel2.text = " "
        
        switch selectedSegmentIndex {
        case 0:
            if let views = activity!.views,
                let countries = countries {
                let keys = Array(views.keys).sorted()
                let key = keys[indexPath.row]
                
                for c in countries {
                    if c.key == key {
                        country = c
                        stat = views[key]!
                        break
                    }
                }
                cell.statIcon.image = UIImage(named: "view-filled")
            }
        case 1:
            if let plays = activity!.plays,
                let countries = countries {
                let keys = Array(plays.keys).sorted()
                let key = keys[indexPath.row]
                
                for c in countries {
                    if c.key == key {
                        country = c
                        stat = plays[key]!
                        break
                    }
                }
                cell.statIcon.image = UIImage(named: "play-filled")
            }
        default:
            ()
        }
        
        if let country = country {
            if let url = country.getFlagURLForSize(size: .normal) {
                if let image = UIImage(contentsOfFile: url.path) {
                    cell.imageIcon.image = ImageUtil.imageWithBorder(fromImage: image)
                }
            }
            cell.nameLabel.text = country.name
            cell.statLabel.text = String(describing: stat)
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
                let placeholderImage = UIImage(named: "user")
                
                dataCell.imageIcon.image = placeholderImage
                dataCell.rankLabel.text = " "
                dataCell.nameLabel.text = "Not logged in"
                dataCell.statIcon.image = nil
                dataCell.statLabel.text = nil
                dataCell.statIcon2.image = nil
                dataCell.statLabel2.text = nil
                
                if let user = Auth.auth().currentUser,
                    let activity = activity {
                    
                    if let url = user.photoURL {
                        dataCell.imageIcon.sd_setImage(with: url,
                                                       placeholderImage: placeholderImage,
                                                       options: SDWebImageOptions.lowPriority,
                                                       completed: nil)
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
            height = DataTableViewCellHeight
        case 1:
            height = UITableView.automaticDimension
        default:
            ()
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var country:FCCountry?
        
        switch indexPath.section {
        case 0:
            () // TODO: handle account selection
        case 2:
            switch selectedSegmentIndex {
            case 0:
                if let views = activity!.views,
                    let countries = countries {
                    let keys = Array(views.keys).sorted()
                    let key = keys[indexPath.row]
                    
                    for c in countries {
                        if c.key == key {
                            country = c
                            break
                        }
                    }
                }
            case 1:
                if let plays = activity!.plays,
                    let countries = countries {
                    let keys = Array(plays.keys).sorted()
                    let key = keys[indexPath.row]
                    
                    for c in countries {
                        if c.key == key {
                            country = c
                            break
                        }
                    }
                }
            default:
                ()
            }
        default:
            ()
        }
        
        if let country = country {
            self.performSegue(withIdentifier: "showCountry", sender: country)
        }
    }
}
