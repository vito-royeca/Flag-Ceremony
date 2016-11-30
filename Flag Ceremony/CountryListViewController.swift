//
//  CountryListViewController.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 11/30/16.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import MBProgressHUD

let kCountrySelected = "kCountrySelected"

class CountryListViewController: UIViewController {

    // MARK: Variables
    var countries = [Country]()
    var filteredCountries:[Country]?
    var sectionedCountries = [String: [Country]]()
    var selectedRow = -1
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        createSections(array: countries)
    }
    
    // MARK: Custom methods
    func doSearch() {
        if let text = searchController.searchBar.text {
            let count = text.characters.count
            
            if count > 0 {
                filteredCountries = countries.filter({
                    if count == 1 {
                        return $0.name!.lowercased().hasPrefix(text.lowercased())
                    } else {
                        return $0.name!.lowercased().contains(text.lowercased())
                    }
                })
                createSections(array: filteredCountries!)
            } else {
                filteredCountries = nil
                createSections(array: countries)
            }
            
        } else {
            filteredCountries = nil
            createSections(array: countries)
        }
        
        tableView.reloadData()
    }
    
    func createSections(array: [Country]) {
        sectionedCountries.removeAll()
        
        for c in array {
            let name = c.name!
            let index = name.index(name.startIndex, offsetBy: 1)
            let prefix = name.substring(to: index)
            
            if let _ = sectionedCountries[prefix] {
                sectionedCountries[prefix]!.append(c)
            } else {
                var ncarray = [Country]()
                ncarray.append(c)
                sectionedCountries[prefix] = ncarray
            }
        }
    }
}

// MARK: UITableViewDataSource
extension CountryListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keys = sectionedCountries.keys.sorted()
        let key = keys[section]
        
        if let carray = sectionedCountries[key] {
            return carray.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionedCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if let c = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            let keys = sectionedCountries.keys.sorted()
            let key = keys[indexPath.section]
            
            if let carray = sectionedCountries[key] {
                let country = carray[indexPath.row]
                var capitalText = "Capital: "
                
                if let capital = country.capital {
                    if let name = capital[Country.Keys.CapitalName] {
                        capitalText += "\(name)"
                    }
                }
                c.textLabel?.text = "\(country.emojiFlag())\(country.name!)"
                c.detailTextLabel?.text = capitalText
                c.accessoryType = selectedRow == indexPath.row ? .checkmark : .none
            }
            cell = c
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keys = sectionedCountries.keys.sorted()
        return keys[section]
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionedCountries.keys.sorted()
    }
}

// MARK: UITableViewDelegate
extension CountryListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = sectionedCountries.keys.sorted()
        let key = keys[indexPath.section]
        
        if let carray = sectionedCountries[key] {
            let country = carray[indexPath.row]
            
            selectedRow = indexPath.row
            
            tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kCountrySelected), object: nil, userInfo: ["country": country])
            
            let radians = country.getGeoRadians()
            UserDefaults.standard.set(radians[0], forKey: kLocationLongitude)
            UserDefaults.standard.set(radians[1], forKey: kLocationLatitude)
            UserDefaults.standard.synchronize()
        }
    }
}

// MARK: UISearchResultsUpdating
extension CountryListViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        doSearch()
    }
}

// MARK: UISearchBarDelegate
extension CountryListViewController: UISearchBarDelegate {
    
}
