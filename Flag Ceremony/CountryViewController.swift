//
//  CountryViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import Firebase

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPlayFinished), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CountryViewController.playListener(_:)), name: NSNotification.Name(rawValue: kPlayFinished), object: nil)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AudioPlayerTableViewCell {
            cell.url = country!.getAudioURL()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AudioPlayerTableViewCell {
            cell.pause()
            cell.play()
            
            incrementCountryViews()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPlayFinished), object:nil)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AudioPlayerTableViewCell {
            cell.url = nil
        }
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        tableView.reloadData()
//    }
    
    // MARK: Custom methods
    func playListener(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let url = userInfo[kAudioURL] as? URL,
                let country = country {
                
                if url == country.getAudioURL() {
                    incrementCountryPlays()
                }
            }
        }
    }
    
    func incrementCountryViews() {
        let ref = FIRDatabase.database().reference().child("countries").child(country!.key)
        
        ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : Any] {
                
                var views = post[Country.Keys.Views] as? Int ?? 0
                views += 1
                post[Country.Keys.Views] = views
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func incrementCountryPlays() {
        let ref = FIRDatabase.database().reference().child("countries").child(country!.key)
        
        ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : Any] {
                
                var plays = post[Country.Keys.Plays] as? Int ?? 0
                plays += 1
                post[Country.Keys.Plays] = plays
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

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
                height = tableView.frame.size.height / 2
            default:
                height = tableView.frame.size.height / 3
            }
        default:
            height =  UITableViewAutomaticDimension
        }
        
        return height
    }
}
