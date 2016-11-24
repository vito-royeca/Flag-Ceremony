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
    var anthem:Anthem?
    
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
        
        FirebaseManager.sharedInstance.findAnthem(country!.key, completion: { (anthem) in
            self.anthem = anthem
            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPlayFinished), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CountryViewController.playListener(_:)), name: NSNotification.Name(rawValue: kPlayFinished), object: nil)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AudioPlayerTableViewCell {
            cell.url = country!.getAudioURL()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AudioPlayerTableViewCell {
            cell.pause()
            cell.play()
            
            FirebaseManager.sharedInstance.incrementCountryViews(country!.key)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPlayFinished), object:nil)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AudioPlayerTableViewCell {
            cell.url = nil
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
    
    // MARK: Custom methods
    func playListener(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let url = userInfo[kAudioURL] as? URL,
                let country = country {
                if url == country.getAudioURL() {
                    FirebaseManager.sharedInstance.incrementCountryPlays(country.key)
                }
            }
        }
    }
    
}

// MARK: UITableViewDataSource
extension CountryViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell")
            let flagSize:FlagSize = UIDevice.current.userInterfaceIdiom == .phone ? .Normal : .Big
            
            if let url = country!.getFlagURLForSize(size: flagSize) {
                if let image = UIImage(contentsOfFile: url.path),
                    let imageView = cell?.viewWithTag(1) as? UIImageView {
                    imageView.image = imageWithBorder(fromImage: image)
                }
            }
        case 1:
            if let audioPlayerCell = tableView.dequeueReusableCell(withIdentifier: "AudioPlayerCell") as? AudioPlayerTableViewCell {
                audioPlayerCell.url = country!.getAudioURL()
                cell = audioPlayerCell
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell")
            cell?.textLabel?.text = ""
            cell?.detailTextLabel?.text = ""
            
            if let anthem = anthem {
                cell?.textLabel?.text = anthem.nativeTitle
                
                // show subtitle if nativeTitle is not equal to title
                if anthem.nativeTitle != anthem.title {
                    cell?.detailTextLabel?.text = anthem.title
                }
            }
            
        default:
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        return cell!
    }
    
    func imageWithBorder(fromImage source: UIImage) -> UIImage? {
        let size = source.size
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        source.draw(in: rect, blendMode: .normal, alpha: 1.0)
    
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            context.stroke(rect)
            let newImg =  UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImg
        }
        return nil
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
