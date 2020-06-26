//
//  AudioPlayerTableViewCell.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import AVFoundation

let kAudioPlayerStatus         = "kAudioPlayerStatus"
let kAudioPlayerStatusPlay     = "kAudioPlayerStatusPlay"
let kAudioPlayerStatusPause    = "kAudioPlayerStatusPause"
let kAudioPlayerStatusFinished = "kAudioPlayerStatusFinished"
let kAudioURL                  = "kAudioURL"

class AudioPlayerTableViewCell: UITableViewCell {

    // MARK: Variables
    var url : URL?
    var player:AVAudioPlayer?
    var tracker:CADisplayLink?
    var progressTap: UITapGestureRecognizer?
    
    // MARK: Outlets
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var noAudioLabel: UILabel!
    
    // MARK: Actions
    @IBAction func playPauseAction(_ sender: UIButton) {
        if let player = player {
            if player.isPlaying {
                pause()
            } else {
                play()
            }
        } else {
            play()
        }
    }
    
    @IBAction func progressAction(_ sender: UISlider) {
        update()
    }
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        progressTap = UITapGestureRecognizer(target: self,
                                             action: #selector(AudioPlayerTableViewCell.progressTapAction(_:)))
        progressTap!.delegate = self
        progressTap!.numberOfTouchesRequired = 1
        progressTap!.cancelsTouchesInView = false
        progressSlider.addGestureRecognizer(progressTap!)
        
        // remove the thumb image in the slider
        let rect = CGRect(x: 0,
                          y: 0,
                          width: 1,
                          height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1,
                                                      height: 1),
                                               false,
                                               0)
        UIColor.clear.setFill()
        UIRectFill(rect)
        if let blankImg = UIGraphicsGetImageFromCurrentImageContext() {
            progressSlider.setThumbImage(blankImg,
                                         for: .normal)
        }
        UIGraphicsEndImageContext()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Custom methods
    func updatePlayButton() {
        if let image = playButton.imageView!.image {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            playButton.setImage(tintedImage,
                                for: .normal)
            playButton.imageView!.tintColor = kBlueColor
        }
    }
    
    func pause() {
        playButton.setImage(UIImage(named: "play"), for: .normal)
        updatePlayButton()
        
        let userInfo = [kAudioPlayerStatus: kAudioPlayerStatusPause]
        NotificationCenter.default.post(name: Notification.Name(rawValue: kAudioPlayerStatus),
                                        object: nil,
                                        userInfo: userInfo)
        
        if let player = player {
            player.pause()
        }
    }
    
    func play() {
        // reinit the player in case we stop()
        if player == nil {
            if let url = url {
                initPlayer(withURL: url)
            } else {
                return
            }
        }
        
        playButton.setImage(UIImage(named: "pause"), for: .normal)
        updatePlayButton()
        
        let userInfo = [kAudioPlayerStatus: kAudioPlayerStatusPlay]
        NotificationCenter.default.post(name: Notification.Name(rawValue: kAudioPlayerStatus),
                                        object: nil,
                                        userInfo: userInfo)
        
        if let player = player {
            setupTracker()
            player.play()
        }
    }
    
    func stop() {
        if let player = player {
            if player.isPlaying {
                player.stop()
            }
            player.currentTime = 0.0
        }
        player = nil
        
        if let tracker = tracker {
            tracker.invalidate()
        }
    }
    
    func update() {
        if let player = player {
            pause()
            let position = progressSlider.value
            let duration = player.duration
            let currentTime = TimeInterval(position) * duration
            player.currentTime = currentTime
            play()
            
            let userInfo = [kAudioPlayerStatus: kAudioPlayerStatusPlay]
            NotificationCenter.default.post(name: Notification.Name(rawValue: kAudioPlayerStatus),
                                            object: nil,
                                            userInfo: userInfo)
        }
    }
    
    func resetUI() {
        progressSlider.value = 0.0
        startLabel.text = self.stringFromTimeInterval(0.0)
        endLabel.text = self.stringFromTimeInterval(self.player!.duration)
        playButton.setImage(UIImage(named: "play"),
                            for: .normal)
        updatePlayButton()
    }
    
    func stringFromTimeInterval(_ interval:TimeInterval) -> String {
        let ti = NSInteger(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        
        return String(format: "%0.2d:%0.2d", minutes,seconds)
    }
    
    func setupTracker() {
        if let tracker = tracker {
            tracker.invalidate()
        }
        
        tracker = CADisplayLink(target: self,
                                selector: #selector(AudioPlayerTableViewCell.trackAudio))
        //tracker!.frameInterval = 1
        tracker!.preferredFramesPerSecond = 1
        tracker!.add(to: RunLoop.current,
                     forMode: RunLoop.Mode.common)
    }
    
    @objc  func trackAudio() {
        let currentTime = player!.currentTime
        let duration = player!.duration
        let normalizedTime = Float(currentTime / duration)
        let startText = stringFromTimeInterval(currentTime)
        let endText = stringFromTimeInterval(duration-currentTime)
        
//        DispatchQueue.main.async {
        UIView.animate(withDuration: 1, animations: {
            self.progressSlider.value = normalizedTime
            self.startLabel.text = startText
            self.endLabel.text = "-\(endText)"
        })
    }
    
    @objc func progressTapAction(_ sender: UITapGestureRecognizer) {
        let pointTapped: CGPoint = sender.location(in: self)
        let positionOfSlider: CGPoint = progressSlider.frame.origin
        let widthOfSlider: CGFloat = progressSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(progressSlider.maximumValue) / widthOfSlider)
        
        progressSlider.setValue(Float(newValue),
                                animated: true)
        update()
    }
    
    func toggleUI(_ hidden: Bool, message: String?) {
        playButton.isHidden = hidden
        startLabel.isHidden = hidden
        progressSlider.isHidden = hidden
        endLabel.isHidden = hidden
        noAudioLabel.isHidden = !hidden
        noAudioLabel.text = message
    }
    
    // MARK: Private methods
    func initPlayer(withURL url: URL) {
        self.url = url
        
        if player == nil {
            let data = try! Data(contentsOf: url)
            player = try! AVAudioPlayer(data: data)
            player!.delegate = self
            player!.prepareToPlay()
            
            resetUI()
            toggleUI(false, message: nil)
        }
    }
}

// MARK: AVAudioPlayerDelegate
extension AudioPlayerTableViewCell : AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        resetUI()
        stop()
        
        let userInfo = [kAudioPlayerStatus: kAudioPlayerStatusFinished,
                        kAudioURL: url!] as [String : Any]
        NotificationCenter.default.post(name: Notification.Name(rawValue: kAudioPlayerStatus),
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("error in audioPlayer: \(error!)")
    }
}
