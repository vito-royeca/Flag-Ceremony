//
//  MediaPlayer.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/16/23.
//

import SwiftUI
import AVKit
import Combine

public class MediaPlayer: NSObject, ObservableObject {
    let kMediaPlayerVolumeKey = "kMediaPlayerVolumeKey"
    let kMediaPlayerHasVolumeKey = "kMediaPlayerHasVolumeKey"
    let kDefaultMediaPlayerVolume = 0.5
    
    @Published public var isPlaying = false
    @Published public var progress: CGFloat = 0.0
    @Published public var duration: Double = 0.0
    @Published public var currentTime: Double = 0.0
    @Published public var formattedDuration: String = "0:00"
    @Published public var formattedProgress: String = "0:00"
    
    let updatePublisher = PassthroughSubject<Void, Never>()
    
    private var audioPlayer: AVAudioPlayer?

    public var volume: Double {
        didSet {
            audioPlayer?.volume = Float(volume)
            UserDefaults.standard.set(volume, forKey: kMediaPlayerVolumeKey)
            UserDefaults.standard.set(true, forKey: kMediaPlayerHasVolumeKey)
        }
    }

    public var url: URL?
    
    public init(url: URL?) {
        self.url = url
        self.volume = UserDefaults.standard.bool(forKey: kMediaPlayerHasVolumeKey) ?
            UserDefaults.standard.double(forKey: kMediaPlayerVolumeKey) : kDefaultMediaPlayerVolume

        super.init()
        prepare()
   }
    
    func prepare() {
        guard let url = url,
            let player = try? AVAudioPlayer(contentsOf: url) else {
            print("Failed to load url.")
            return
        }

        audioPlayer = player
        volume = UserDefaults.standard.bool(forKey: kMediaPlayerHasVolumeKey) ?
            UserDefaults.standard.double(forKey: kMediaPlayerVolumeKey) : kDefaultMediaPlayerVolume
        audioPlayer?.prepareToPlay()

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [ .pad ]

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = self.audioPlayer {
                if !player.isPlaying {
                    self.isPlaying = false
                }
                self.progress = CGFloat(player.currentTime / player.duration)
                self.formattedProgress = formatter.string(from: TimeInterval(player.currentTime))!
                
                self.duration = player.duration - player.currentTime
                self.formattedDuration = "-\(formatter.string(from: TimeInterval(self.duration))!)"
                
                self.currentTime = player.currentTime
                self.updatePublisher.send()
            }
        }
        audioPlayer?.delegate = self
    }

    deinit {
        audioPlayer?.stop()
    }
    
    func playOrPause() {
        if isPlaying {
            stop()
        } else {
            play()
        }
    }
    
    public func play() {
        isPlaying = true
        audioPlayer?.play()
    }

    public func stop() {
        isPlaying = false
        audioPlayer?.stop()
    }

    public func volumeUp() {
        var newVolume = volume + 0.1
        
        if newVolume >= 1 {
            newVolume = 1
        }
        if volume != newVolume {
            volume = newVolume
        }
    }
    
    public func volumeDown() {
        var newVolume = volume - 0.1
        
        if newVolume <= 0 {
            newVolume = 0
        }
        if volume != newVolume {
            volume = newVolume
        }
    }

    public func forward() {
        if let player = self.audioPlayer {
            let increase = player.currentTime + 15

            if increase < self.duration {
                player.currentTime = increase
            } else {
                player.currentTime = duration
            }
        }
    }

    public func rewind() {
        if let player = self.audioPlayer {
            let decrease = player.currentTime - 15.0

            if decrease < 0.0 {
                player.currentTime = 0
            } else {
                player.currentTime -= 15
            }
        }
    }
}

extension MediaPlayer: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if repeatSound  {
//            play()
//        } else {
            isPlaying = false
//        }
    }
}


