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
        navigationController?.navigationItem.title = country?.name
        
        tableView.register(UINib(nibName: "AudioPlayerTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioPlayerCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AudioPlayerTableViewCell {
            cell.url = nil
        }
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        tableView.reloadData()
//    }
}

// MARK: UITableViewDataSource
extension CountryViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.row {
        case 0:
            if let audioPlayerCell = tableView.dequeueReusableCell(withIdentifier: "AudioPlayerCell") as? AudioPlayerTableViewCell {
                
                if let url = country!.getFlagURLForSize(size: .Normal) {
                    audioPlayerCell.backgroundImage.image = UIImage(contentsOfFile: url.path)
                }
                audioPlayerCell.url = country!.getAudioURL()
                
                cell = audioPlayerCell
            }
        default:
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        return cell!
    }
}

// MARK: UITableViewDelegate
extension CountryViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(0.0)
        
        switch indexPath.row {
        case 0:
            switch UIApplication.shared.statusBarOrientation {
            case .portrait,
                 .portraitUpsideDown:
                height = tableView.frame.size.height / 3
            case .landscapeLeft,
                 .landscapeRight:
                height = tableView.frame.size.height
            default:
                height = tableView.frame.size.height / 3
            }
        default:
            height =  UITableViewAutomaticDimension
        }
        
        return height
    }
}
