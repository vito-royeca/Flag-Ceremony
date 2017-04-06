//
//  CountryViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import SafariServices

enum CountryViewRows: Int {
    case lyrics, anthem, flag, country
}

class CountryViewController: UIViewController {

    // MARK: Variables
    var country:Country?
    var anthem:Anthem?
    var selectedDataSegment = 0
    
    // MARK: Outlets
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dataAction(_ sender: UISegmentedControl) {
        selectedDataSegment = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameLabel.text = "\(country!.emojiFlag()) \(country!.name!)"
        
        tableView.register(UINib(nibName: "AudioPlayerTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioPlayerCell")
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        FirebaseManager.sharedInstance.findAnthem(country!.key!, completion: { (anthem) in
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
            
            FirebaseManager.sharedInstance.incrementCountryViews(country!.key!)
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
                    FirebaseManager.sharedInstance.incrementCountryPlays(country.key!)
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
            case CountryViewRows.lyrics.rawValue :
                if let lyrics = anthem.lyrics {
                    sections += lyrics.count
                }
            case CountryViewRows.anthem.rawValue:
                sections += 4
            case CountryViewRows.flag.rawValue:
                sections += 1
            case CountryViewRows.country.rawValue:
                sections += 3
            default:
                ()
            }
        }
        return sections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title:String? = nil
        
        switch section {
        case 0:
            ()
        default:
            if let anthem = anthem {
                switch selectedDataSegment {
                case CountryViewRows.lyrics.rawValue:
                    if let lyrics = anthem.lyrics {
                        let lyricsDict = lyrics[section-1]
                        title = lyricsDict[Anthem.Keys.LyricsName] as! String?
                    }
                case CountryViewRows.anthem.rawValue:
                    switch section + 4 {
                    case 5:
                        title = "Date Adopted"
                    case 6:
                        title = "Composer"
                    case 7:
                        title = "Lyricist"
                    default:
                        ()
                    }
                case CountryViewRows.country.rawValue:
                    switch section + 8 {
                    case 9:
                        title = "Capital"
                    case 10:
                        title = "Background"
                    case 11:
                        title = "Further Info"
                    default:
                        ()
                    }
                default:
                    ()
                }
            }
        }
        
        return title
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell")
                let flagSize:FlagSize = UIDevice.current.userInterfaceIdiom == .phone ? .normal : .big
                
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
            cell!.accessoryType = .none
            
            if let country = country,
                let anthem = anthem,
                let label = cell?.viewWithTag(1) as? UILabel {

                label.text = ""
                
                switch selectedDataSegment {
                case CountryViewRows.lyrics.rawValue:
                    if let lyrics = anthem.lyrics {
                        let lyricsDict = lyrics[indexPath.section-1]
                        label.text = lyricsDict[Anthem.Keys.LyricsText] as! String?
                    }
                case CountryViewRows.anthem.rawValue:
                    switch indexPath.section {
                    case 1:
                        if let dateAdopted = anthem.dateAdopted {
                            label.text = dateAdopted.joined(separator: ", ")
                        }
                    case 2:
                        if let musicWriter = anthem.musicWriter {
                            label.text = musicWriter.joined(separator: ", ")
                        }
                    case 3:
                        if let lyricsWriter = anthem.lyricsWriter {
                            label.text = lyricsWriter.joined(separator: ", ")
                        }
                    case 4:
                        label.text = anthem.info
                    default:
                        ()
                    }
                case CountryViewRows.flag.rawValue:
                    label.text = anthem.flagInfo
                case CountryViewRows.country.rawValue:
                    switch indexPath.section {
                    case 1:
                        if let capital = country.capital {
                            label.text = capital[Country.Keys.CapitalName] as! String?
                        }
                    case 2:
                        label.text = anthem.background
                    case 3:
                        cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
                        cell!.accessoryType = .disclosureIndicator
                        cell!.textLabel?.text = country.countryInfo
                    default:
                        ()
                    }
                default:
                    ()
                }
            }
        }
        
        cell!.selectionStyle = .none
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
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch selectedDataSegment {
        case CountryViewRows.country.rawValue:
            switch indexPath.section {
            case 3:
                return indexPath
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedDataSegment {
        case CountryViewRows.country.rawValue:
            switch indexPath.section {
            case 3:
                if let country = country {
                    if let countryInfo = country.countryInfo {
                        if let url = URL(string: countryInfo) {
                            let svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                            svc.delegate = self
                            navigationController?.present(svc, animated: true, completion: nil)
                        }
                    }
                }
            default:
                ()
            }
        default:
            ()
        }
    }
}

// MARK: SFSafariViewControllerDelegate
extension CountryViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
