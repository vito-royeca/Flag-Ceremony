//
//  CountryViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit

class CountryViewController: DismissableViewController {

    // MARK: Variables
    var country:Country?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = country?.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
