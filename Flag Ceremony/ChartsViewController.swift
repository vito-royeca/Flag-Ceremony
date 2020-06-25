//
//  ChartsViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 16/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
//import FBSDKCoreKit
import MBProgressHUD
import SDWebImage

class ChartsViewController: CommonViewController {

    // MARK: Variables
    var topViewedCountries:[FCCountry]?
    var topPlayedCountries:[FCCountry]?
    var topViewers:[FCActivity]?
    var topPlayers:[FCActivity]?
    var users:[FCUser]?
    var selectedSegmentIndex = 0
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        if let navigationVC = mm_drawerController.leftDrawerViewController as? UINavigationController {
            var menuView:MenuViewController?
            
            for drawer in navigationVC.viewControllers {
                if drawer is MenuViewController {
                    menuView = drawer as? MenuViewController
                }
            }
            if menuView == nil {
                menuView = MenuViewController()
                navigationVC.addChild(menuView!)
            }
            
            navigationVC.popToViewController(menuView!, animated: true)
        }
        mm_drawerController.toggle(.left, animated:true, completion:nil)
    }
    
    @IBAction func dataChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        
        switch selectedSegmentIndex {
        case 0:
            showTopViewed()
        case 1:
            showTopPlayed()
        case 2:
            showTopViewers()
        case 3:
            showTopPlayers()
        default:
            showTopViewed()
        }
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "DataTableViewCell", bundle: nil), forCellReuseIdentifier: "DataCell")
        
        getUsers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch selectedSegmentIndex {
        case 0:
            showTopViewed()
        case 1:
            showTopPlayed()
        case 2:
            showTopViewers()
        case 3:
            showTopPlayers()
        default:
            showTopViewed()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseManager.sharedInstance.demonitorTopCharts()
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
    
    // MARK: Custom methods
    func showTopViewed() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        FirebaseManager.sharedInstance.monitorTopViewed(completion: { (countries) in
            self.topViewedCountries = countries
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.tableView.reloadData()
            }
        })
    }
    
    func showTopPlayed() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        FirebaseManager.sharedInstance.monitorTopPlayed(completion: { (countries) in
            self.topPlayedCountries = countries
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.tableView.reloadData()
            }
        })
    }
    
    func showTopViewers() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        FirebaseManager.sharedInstance.monitorTopViewers(completion: { (activities) in
            self.topViewers = activities
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.tableView.reloadData()
            }
        })
    }
    
    func showTopPlayers() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        FirebaseManager.sharedInstance.monitorTopPlayers(completion: { (activities) in
            self.topPlayers = activities
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.tableView.reloadData()
            }
        })
    }
    
    func getUsers() {
        FirebaseManager.sharedInstance.monitorUsers(completion: { (users) in
            self.users = users
        })
    }
    
    func configure(cell: DataTableViewCell, at indexPath: IndexPath) {
        let placeholderImage = UIImage(named: "user")
        
        cell.statIcon2.isHidden = true
        cell.statLabel2.isHidden = true
        
        switch selectedSegmentIndex {
        case 0:
            if let topViewedCountries = topViewedCountries {
                let country = topViewedCountries[indexPath.row]
                
                if let url = country.getFlagURLForSize(size: .normal) {
                    if let image = UIImage(contentsOfFile: url.path) {
                        cell.imageIcon.image = ImageUtil.imageWithBorder(fromImage: image)
                    }
                }
                cell.rankLabel.text = "#\(indexPath.row + 1)"
                cell.nameLabel.text = country.name
                cell.statIcon.image = UIImage(named: "view-filled")
                if let views = country.views {
                    cell.statLabel.text = "\(views)"
                }
            }
        case 1:
            if let topPlayedCountries = topPlayedCountries {
                let country = topPlayedCountries[indexPath.row]
                
                if let url = country.getFlagURLForSize(size: .normal) {
                    if let image = UIImage(contentsOfFile: url.path) {
                        cell.imageIcon.image = ImageUtil.imageWithBorder(fromImage: image)
                    }
                }
                cell.rankLabel.text = "#\(indexPath.row + 1)"
                cell.nameLabel.text = country.name
                cell.statIcon.image = UIImage(named: "play-filled")
                if let plays = country.plays {
                    cell.statLabel.text = "\(plays)"
                }
            }
        case 2:
            if let topViewers = topViewers {
                let activity = topViewers[indexPath.row]
                
                cell.rankLabel.text = "#\(indexPath.row + 1)"
                cell.imageIcon.image = placeholderImage
                if let users = users {
                    for u in users {
                        if u.key == activity.key {
                            cell.nameLabel.text = u.displayName
                            
                            if let photoURL = u.photoURL {
                                if let url = URL(string: photoURL) {
                                    cell.imageIcon.sd_setImage(with: url,
                                                               placeholderImage: placeholderImage,
                                                               options: SDWebImageOptions.lowPriority,
                                                               completed: nil)
                                }
                            }
                            break
                        }
                    }
                }
                cell.statIcon.image = UIImage(named: "view-filled")
                if let views = activity.viewCount {
                    cell.statLabel.text = "\(views)"
                }
            }
        case 3:
            if let topPlayers = topPlayers {
                let activity = topPlayers[indexPath.row]
                
                cell.rankLabel.text = "#\(indexPath.row + 1)"
                cell.imageIcon.image = placeholderImage
                if let users = users {
                    for u in users {
                        if u.key == activity.key {
                            cell.nameLabel.text = u.displayName
                            
                            if let photoURL = u.photoURL {
                                if let url = URL(string: photoURL) {
                                    cell.imageIcon.sd_setImage(with: url, placeholderImage: placeholderImage, options: SDWebImageOptions.lowPriority, completed: nil)
                                }
                            }
                            break
                        }
                    }
                }
                cell.statIcon.image = UIImage(named: "play-filled")
                if let plays = activity.playCount {
                    cell.statLabel.text = "\(plays)"
                }
            }
        default:
            ()
        }
    }
}

// MARK: UITableViewDataSource
extension ChartsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch section {
        case 0:
            rows = 1
        case 1:
            switch selectedSegmentIndex {
            case 0:
                rows = topViewedCountries?.count ?? 0
            case 1:
                rows = topPlayedCountries?.count ?? 0
            case 2:
                rows = topViewers?.count ?? 0
            case 3:
                rows = topPlayers?.count ?? 0
            default:
                ()
            }
        default:
            ()
        }
        
        return rows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.section {
        case 0:
            if let c = tableView.dequeueReusableCell(withIdentifier: "SegmentedCell") {
                cell = c
            }
        case 1:
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

// MARK: UITableViewDelegate
extension ChartsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(0)
        
        switch indexPath.section {
        case 0:
            height = UITableView.automaticDimension
        case 1:
            height = DataTableViewCellHeight
        default:
            ()
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedSegmentIndex {
        case 0:
            if let topViewedCountries = topViewedCountries {
                let country = topViewedCountries[indexPath.row]
                self.performSegue(withIdentifier: "showCountry", sender: country)
            }
        case 1:
            if let topPlayedCountries = topPlayedCountries {
                let country = topPlayedCountries[indexPath.row]
                self.performSegue(withIdentifier: "showCountry", sender: country)
            }
        default:
            ()
        }
    }
}
