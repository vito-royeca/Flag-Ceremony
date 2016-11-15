//
//  AudioPlayerTableViewCell.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import AVFoundation

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
    var currentTime:TimeInterval = 0.0
    var duration:TimeInterval = 0.0
    
    // MARK: Outlets
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    // MARK: Actions
    
    @IBAction func playPauseAction(_ sender: UIButton) {
        if player!.isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    
    @IBAction func progressAction(_ sender: UISlider) {
        
    }
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Custom methods
    func pause() {
        player!.pause()
        playButton.setImage(UIImage(named: "play"), for: .normal)
    }
    
    func play() {
        setupTracker()
        
        player!.play()
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
    
    func resetUI() {
        DispatchQueue.main.async {
            self.progressSlider.value = 0.0
            self.startLabel.text = self.stringFromTimeInterval(0.0)
            self.endLabel.text = self.stringFromTimeInterval(self.duration)
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
        tracker = CADisplayLink(target: self, selector: #selector(AudioPlayerTableViewCell.trackAudio))
        tracker!.frameInterval = 1
        tracker!.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    func trackAudio() {
        currentTime = player!.currentTime
        duration = player!.duration
        
        let normalizedTime = Float(currentTime / duration)
        let startText = stringFromTimeInterval(currentTime)
        let endText = stringFromTimeInterval(duration-currentTime)
        
        DispatchQueue.main.async {
            self.progressSlider.value = normalizedTime
            self.startLabel.text = startText
            self.endLabel.text = endText
        }
    }
    
    // MARK: Private methods
    private func initPlayer() {
        do {
            if let url = url {
                try player = AVAudioPlayer(contentsOf: url)
                player!.delegate = self
                currentTime = player!.currentTime
                duration = player!.duration
                resetUI()
                errorLabel.isHidden = true
            } else {
                stop()
                playButton.isHidden = true
                startLabel.isHidden = true
                progressSlider.isHidden = true
                endLabel.isHidden = true
            }
        } catch {
            print("\(error)")
        }
    }
}

// MARK: AVAudioPlayerDelegate
extension AudioPlayerTableViewCell : AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
}
