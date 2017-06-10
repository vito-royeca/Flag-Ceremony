//
//  CountryViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import MBProgressHUD

enum CountryViewRows: Int {
    case lyrics, anthem, flag, country
}

class CountryViewController: UIViewController {

    // MARK: Variables
    var country:FCCountry?
    var anthem:FCAnthem?
    var selectedSegmentIndex = 0
    var isPlaying = false
    
    // MARK: Outlets
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        var objectsToShare = [Any]()
        
        // country name
        objectsToShare.append(country!.name!)
        
        // anthem title
        if let anthem = anthem {
            var title = anthem.nativeTitle!
        
            // show subtitle if nativeTitle is not equal to title
            if anthem.nativeTitle != anthem.title {
                title += " \(anthem.title!)"
            }
            
            objectsToShare.append(title)
        }

        // flag image
        if let url = country!.getFlagURLForSize(size: .big) {
            objectsToShare.append(UIImage(contentsOfFile: url.path)!)
        }
        
        // audio file url
        let audioPath = "https://firebasestorage.googleapis.com/v0/b/flag-ceremony.appspot.com/o/anthems%2F\(country!.key!.lowercased()).mp3?alt=media"
        objectsToShare.append(URL(string: audioPath)!)
        
        // app name hashtag
        objectsToShare.append("#FlagCeremony")
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        let excludedActivities = [UIActivityType.print,UIActivityType.copyToPasteboard, UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.airDrop]
        
        activityVC.excludedActivityTypes = excludedActivities
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            // user did not cancel
            if success {
                if let e = error {
                    print("error sharing: \(e)")
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        activityVC.popoverPresentationController?.sourceView = self.view
        present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func playPauseAction(_ sender: UIButton) {
        isPlaying = !isPlaying
//        updatePlayButton()
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AudioPlayerTableViewCell {
            if isPlaying {
                cell.play()
            } else {
                cell.pause()
            }
        }
    }
    
    @IBAction func dataAction(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
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
            
            FirebaseManager.sharedInstance.incrementCountryViews(self.country!.key!)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kAudioPlayerStatus), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CountryViewController.playListener(_:)), name: NSNotification.Name(rawValue: kAudioPlayerStatus), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        tableView.reloadData()
        
        if let flagCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) ,
            let anthemCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AudioPlayerTableViewCell {
            
            // anthems are fetched from Firebase
            if let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
                let anthemsDir = "\(cacheDir)/anthems"
                let localPath = "\(anthemsDir)/\(country!.key!.lowercased()).mp3"
                
                if FileManager.default.fileExists(atPath: localPath) {
                    anthemCell.initPlayer(withURL: URL(fileURLWithPath: localPath))
                    anthemCell.play()
                    self.isPlaying = true

                } else {
                    MBProgressHUD.showAdded(to: flagCell, animated: true)
                    anthemCell.toggleUI(true, message: "Downloading...")
                    FirebaseManager.sharedInstance.downloadAnthem(country: country!, completion: {(url: URL?, error: Error?) in
                        MBProgressHUD.hide(for: flagCell, animated: true)
                        
                        if let _ = error {
                            self.updatePlayButton(false)
                            anthemCell.toggleUI(true, message: "Audio file not found.")
                        } else {
                            anthemCell.toggleUI(false, message: nil)
                            anthemCell.initPlayer(withURL: url!)
                            anthemCell.play()
                            self.isPlaying = true
                        }
                    })
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kAudioPlayerStatus), object:nil)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AudioPlayerTableViewCell {
            cell.stop()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
    
    // MARK: Custom methods
    func updatePlayButton(_ success: Bool) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            if let button = cell.viewWithTag(200) as? UIButton {
                let playImage = isPlaying ? UIImage(named: "circled pause") : UIImage(named: "circled play")
                let errorImage = UIImage(named: "error")
                
                let tintedImage = success ? playImage!.withRenderingMode(.alwaysTemplate) : errorImage!.withRenderingMode(.alwaysTemplate)
                button.setImage(tintedImage, for: .normal)
                button.imageView!.tintColor = kBlueColor
                button.isHidden = isPlaying
            }
        }
    }

    func playListener(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let status = userInfo[kAudioPlayerStatus] as? String {
                
                if status == kAudioPlayerStatusPlay {
                    isPlaying = true
                    updatePlayButton(true)
                } else if status == kAudioPlayerStatusPause {
                    isPlaying = false
                    updatePlayButton(true)
                } else if status == kAudioPlayerStatusFinished {
                    if let _ = userInfo[kAudioURL] as? URL,
                        let country = country {
                    
                        isPlaying = false
                        updatePlayButton(true)
                        FirebaseManager.sharedInstance.incrementCountryPlays(country.key!)
                    }
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
            switch selectedSegmentIndex {
            case CountryViewRows.lyrics.rawValue :
                if let lyrics = anthem.lyrics {
                    sections += lyrics.count
                }
            case CountryViewRows.anthem.rawValue:
                sections += 4
            case CountryViewRows.flag.rawValue:
                sections += 1
            case CountryViewRows.country.rawValue:
                sections += 2
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
                switch selectedSegmentIndex {
                case CountryViewRows.lyrics.rawValue:
                    if let lyrics = anthem.lyrics {
                        let lyricsDict = lyrics[section-1]
                        title = lyricsDict[FCAnthem.Keys.LyricsName] as! String?
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
                    switch section + 7 {
                    case 8:
                        title = "Capital"
                    case 9:
                        title = "Background"
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
                        let imageView = cell?.viewWithTag(100) as? UIImageView {
                        imageView.image = ImageUtil.imageWithBorder(fromImage: image)
                    }
                    if let button = cell?.viewWithTag(200) as? UIButton {
                        let image = isPlaying ? UIImage(named: "circled pause") : UIImage(named: "circled play")
                        let tintedImage = image!.withRenderingMode(.alwaysTemplate)
                        button.setImage(tintedImage, for: .normal)
                        button.imageView!.tintColor = kBlueColor
                    }
                }
            case 1:
                if let audioPlayerCell = tableView.dequeueReusableCell(withIdentifier: "AudioPlayerCell") as? AudioPlayerTableViewCell {
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
                
                switch selectedSegmentIndex {
                case CountryViewRows.lyrics.rawValue:
                    if let lyrics = anthem.lyrics {
                        let lyricsDict = lyrics[indexPath.section-1]
                        label.text = lyricsDict[FCAnthem.Keys.LyricsText] as! String?
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
                            label.text = capital[FCCountry.Keys.CapitalName] as! String?
                        }
                    case 2:
                        label.text = anthem.background
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
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return indexPath
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                    if let button = cell.viewWithTag(200) as? UIButton {
                        playPauseAction(button)
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
