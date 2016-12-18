//
//  ChartsViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 16/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import Networking

class ChartsViewController: UIViewController {

    // MARK: Variables
    var topViewedCountries:[Country]?
    var topPlayedCountries:[Country]?
    
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
                navigationVC.addChildViewController(menuView!)
            }
            
            navigationVC.popToViewController(menuView!, animated: true)
        }
        mm_drawerController.toggle(.left, animated:true, completion:nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "SliderTableViewCell", bundle: nil), forCellReuseIdentifier: "TopViewedCell")
        tableView.register(UINib(nibName: "SliderTableViewCell", bundle: nil), forCellReuseIdentifier: "TopPlayedCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseManager.sharedInstance.monitorTopViewed(completion: { (countries) in
            self.topViewedCountries = countries
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        })
        
        FirebaseManager.sharedInstance.monitorTopPlayed(completion: { (countries) in
            self.topPlayedCountries = countries
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            }
        })
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
        if segue.identifier == "showDetailsAsPush" ||
            segue.identifier == "showDetailsAsModal" {
            
            var countryVC:CountryViewController?
            
            if let nav = segue.destination as? UINavigationController {
                if let vc = nav.childViewControllers.first as? CountryViewController {
                    countryVC = vc
                }
            }else  if let vc = segue.destination as? CountryViewController {
                countryVC = vc
            }
            
            if let countryVC = countryVC {
                countryVC.country = sender as? Country
            }
        }
    }
}

// MARK: UITableViewDataSource
extension ChartsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.section {
        case 0:
            if let sliderCell = tableView.dequeueReusableCell(withIdentifier: "TopViewedCell") as? SliderTableViewCell {
                sliderCell.countries = topViewedCountries
                sliderCell.delegate = self
                cell = sliderCell
                
            }
        case 1:
            if let sliderCell = tableView.dequeueReusableCell(withIdentifier: "TopPlayedCell") as? SliderTableViewCell {
                sliderCell.countries = topPlayedCountries
                sliderCell.delegate = self
                cell = sliderCell
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
        var divisor = CGFloat(0)
        
        switch UIApplication.shared.statusBarOrientation {
        case .portrait,
             .portraitUpsideDown:
            divisor = UIDevice.current.userInterfaceIdiom == .phone ? 3 : 6
        case .landscapeLeft,
             .landscapeRight:
            divisor = UIDevice.current.userInterfaceIdiom == .phone ? 2 : 5
        default:
            divisor = UIDevice.current.userInterfaceIdiom == .phone ? 3 : 6
        }
        
        return tableView.frame.size.height / divisor
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header:UIView?
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") {
            header = cell
            
            if let iconView = cell.viewWithTag(1) as? UIImageView,
                let label = cell.viewWithTag(2) as? UILabel {
                
                switch section {
                case 0:
                    iconView.image = UIImage(named: "view-filled")
                    label.text = "Top Viewed"
                case 1:
                    iconView.image = UIImage(named: "play-filled")
                    label.text = "Top Played"
                default:
                    ()
                }
            }
        }
        
        return header!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(24)
    }
}

extension ChartsViewController : SliderTableViewCellDelegate {
    func didSelectItem(_ item: Any) {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.performSegue(withIdentifier: "showDetailsAsPush", sender: item)
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            self.performSegue(withIdentifier: "showDetailsAsModal", sender: item)
        }
    }
}

