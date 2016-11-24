//
//  FeaturedViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 16/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import Firebase
import Networking

class FeaturedViewController: UIViewController {

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: UITableViewDataSource
extension FeaturedViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Top viewed"
        case 1:
            return "Top Played"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.section {
        case 0:
            if let sliderCell = tableView.dequeueReusableCell(withIdentifier: "TopViewedCell") as? SliderTableViewCell {
                sliderCell.countries = topViewedCountries
                sliderCell.collectionView.reloadData()
                sliderCell.countType = .Views
                cell = sliderCell
            }
        case 1:
            if let sliderCell = tableView.dequeueReusableCell(withIdentifier: "TopPlayedCell") as? SliderTableViewCell {
                sliderCell.countries = topPlayedCountries
                sliderCell.collectionView.reloadData()
                sliderCell.countType = .Plays
                cell = sliderCell
            }
        default:
            ()
        }
        
        return cell!
    }
}

// MARK: UITableViewDelegate
extension FeaturedViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 3
    }
}
