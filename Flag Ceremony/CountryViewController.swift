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
    var selectedDataSegment = 0
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    
    @IBAction func dataAction(_ sender: UISegmentedControl) {
        selectedDataSegment = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = country?.name
        navigationController?.navigationItem.title = country?.name
        
        tableView.register(UINib(nibName: "AudioPlayerTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioPlayerCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        FirebaseManager.sharedInstance.findAnthem(country!.key, completion: { (anthem) in
            self.anthem = anthem
            self.tableView.reloadData()
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
        tableView.reloadData()
        
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
        switch section {
        case 0:
            return 4
        default:
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 1
     
        if let anthem = anthem {
            switch selectedDataSegment {
            case 0:
            if let lyrics = anthem.lyrics {
                sections += lyrics.count
            }
            case 1:
                return 2
            case 2:
                sections += 3
            default:
                ()
            }
        }
        return sections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        default:
            if let anthem = anthem {
                switch selectedDataSegment {
                case 0:
                    if let lyrics = anthem.lyrics {
                        let lyricsDict = lyrics[section-1]
                        return lyricsDict[Anthem.Keys.LyricsName] as! String?
                    }
                case 2:
                    switch section + 3 {
                    case 4:
                        return "Date Adopted"
                    case 5:
                        return "Composer"
                    case 6:
                        return "Lyricist"
                    default:
                        return nil
                    }
                default:
                    return nil
                }
            }
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.section {
        case 0:
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
            case 3:
                cell = tableView.dequeueReusableCell(withIdentifier: "SegmentedCell")
            default:
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "DynamicCell")
            
            if let anthem = anthem,
                let label = cell?.viewWithTag(1) as? UILabel {

                switch selectedDataSegment {
                case 0:
                    if let lyrics = anthem.lyrics {
                        let lyricsDict = lyrics[indexPath.section-1]
                        label.text = lyricsDict[Anthem.Keys.LyricsText] as! String?
                    }
                case 1:
                    label.text = anthem.info
                case 2:
                    switch indexPath.section + 3 {
                    case 4:
                        if let dateAdopted = anthem.dateAdopted {
                            label.text = dateAdopted.joined(separator: ", ")
                        } else {
                            label.text = ""
                        }
                    case 5:
                        if let musicWriter = anthem.musicWriter {
                            label.text = musicWriter.joined(separator: ", ")
                        } else {
                            label.text = ""
                        }
                    case 6:
                        if let lyricsWriter = anthem.lyricsWriter {
                            label.text = lyricsWriter.joined(separator: ", ")
                        } else {
                            label.text = ""
                        }
                    default:
                        ()
                    }
                default:
                    ()
                }
            }
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
        
        switch indexPath.section {
        case 0:
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
        default:
            height =  UITableViewAutomaticDimension
        }
        
        return height
    }
}
