//
//  ChartsViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 16/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import Firebase
import Networking

class ChartsViewController: UIViewController {

    // MARK: Variables
    var topViewedCountries:[Country]?
    var topPlayedCountries:[Country]?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "SliderTableViewCell", bundle: nil), forCellReuseIdentifier: "TopViewedCell")
        tableView.register(UINib(nibName: "SliderTableViewCell", bundle: nil), forCellReuseIdentifier: "TopPlayedCell")
        
        FirebaseManager.sharedInstance.fetchTopViewed(completion: { (countries) in
            self.topViewedCountries = countries
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        })
        
        FirebaseManager.sharedInstance.fetchTopPlayed(completion: { (countries) in
            self.topPlayedCountries = countries
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            }
        })
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
        return tableView.frame.size.height / 3
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

