//
//  AudioPlayerTableViewCell.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import AVFoundation

let kPlayFinished = "kPlayFinished"
let kAudioURL     = "kAudioURL"

class AudioPlayerTableViewCell: UITableViewCell {

    // MARK: Variables
    fileprivate var _url: URL?
    var url : URL? {
        get {
            return _url
        }
        set (newValue) {
            if newValue != _url {
                _url = newValue
                initPlayer()
            }
        }
    }
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
        if player!.isPlaying {
            pause()
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
        progressTap = UITapGestureRecognizer(target: self, action: #selector(AudioPlayerTableViewCell.progressTapAction(_:)))
        progressTap!.delegate = self
        progressTap!.numberOfTouchesRequired = 1
        progressTap!.cancelsTouchesInView = false
        progressSlider.addGestureRecognizer(progressTap!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Custom methods
    func pause() {
        if let player = player {
            player.pause()
        }
        playButton.setImage(UIImage(named: "play"), for: .normal)
    }
    
    func play() {
        if let player = player {
            setupTracker()
            player.play()
        }
        playButton.setImage(UIImage(named: "pause"), for: .normal)
    }
    
    func stop() {
        resetUI()
        
        if let player = player {
            if player.isPlaying {
                player.stop()
            }
            player.currentTime = 0.0
        }
        
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
        }
    }
    
    func resetUI() {
        DispatchQueue.main.async {
            self.progressSlider.value = 0.0
            self.startLabel.text = self.stringFromTimeInterval(0.0)
            self.endLabel.text = self.stringFromTimeInterval(self.player!.duration)
            self.playButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    func stringFromTimeInterval(_ interval:TimeInterval) -> String {
        let ti = NSInteger(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    func setupTracker() {
        if let tracker = tracker {
            tracker.invalidate()
        }
        
        tracker = CADisplayLink(target: self, selector: #selector(AudioPlayerTableViewCell.trackAudio))
        tracker!.frameInterval = 1
        tracker!.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    func trackAudio() {
        let currentTime = player!.currentTime
        let duration = player!.duration
        let normalizedTime = Float(currentTime / duration)
        let startText = stringFromTimeInterval(currentTime)
        let endText = stringFromTimeInterval(duration-currentTime)
        
        DispatchQueue.main.async {
            self.progressSlider.value = normalizedTime
            self.startLabel.text = startText
            self.endLabel.text = "-\(endText)"
        }
    }
    
    func progressTapAction(_ sender: UITapGestureRecognizer) {
        let pointTapped: CGPoint = sender.location(in: self)
        let positionOfSlider: CGPoint = progressSlider.frame.origin
        let widthOfSlider: CGFloat = progressSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(progressSlider.maximumValue) / widthOfSlider)
        
        progressSlider.setValue(Float(newValue), animated: true)
        update()
    }
    
    func toggleUI(_ hidden: Bool) {
        playButton.isHidden = hidden
        startLabel.isHidden = hidden
        progressSlider.isHidden = hidden
        endLabel.isHidden = hidden
        noAudioLabel.isHidden = !hidden
    }
    
    // MARK: Private methods
    private func initPlayer() {
        
        if let url = url {
            do {
                let data = try Data(contentsOf: url)
                player = try AVAudioPlayer(data: data)
//                let fileTpes = [AVFileType3GPP,
//                                AVFileType3GPP2,
//                                AVFileTypeAIFC,
//                                AVFileTypeAIFF,
//                                AVFileTypeAMR,
//                                AVFileTypeAC3,
//                                AVFileTypeMPEGLayer3,
//                                AVFileTypeSunAU,
//                                AVFileTypeCoreAudioFormat,
//                                AVFileTypeAppleM4V,
//                                AVFileTypeMPEG4,
//                                AVFileTypeAppleM4A,
//                                AVFileTypeQuickTimeMovie,
//                                AVFileTypeWAVE]
//                for fileType in fileTpes {
//                    player = try AVAudioPlayer(data: data, fileTypeHint: AVFileTypeCoreAudioFormat)
//                    if player != nil {
//                        break
//                    }
//                }
                
                player!.delegate = self
                player!.prepareToPlay()
                resetUI()
                toggleUI(false)
            } catch let error {
                print("error in audioPlayer: \(error)")
            }
        } else {
            stop()
            toggleUI(true)
        }
    }
}

// MARK: AVAudioPlayerDelegate
extension AudioPlayerTableViewCell : AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
        
        let userInfo = [kAudioURL: url]
        NotificationCenter.default.post(name: Notification.Name(rawValue: kPlayFinished), object: nil, userInfo: userInfo)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("error in audioPlayer: \(error)")
    }
}
