//
//  MediaPlayer.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/16/23.
//

import SwiftUI
import AVKit

public class MediaPlayer: NSObject, ObservableObject {
 /// A Boolean representing whether this sound is currently playing.
    @Published public var isPlaying = false

/// These are used in our view
    @Published public var progress: CGFloat = 0.0
    @Published public var duration: Double = 0.0
    @Published public var formattedDuration: String = "00:00"
    @Published public var formattedProgress: String = "00:00"

  /// The internal audio player being managed by this object.
    private var audioPlayer: AVAudioPlayer?

    /// How loud to play this sound relative to other sounds in your app,
    /// specified in the range 0 (no volume) to 1 (maximum volume).
    public var volume: Double {
        didSet {
            audioPlayer?.volume = Float(volume)
        }
    }

    public var url: URL?
    public var repeatSound: Bool
    
    public init(url: URL?, volume: Double = 1.0, repeatSound: Bool = false) {
        self.url = url
        self.volume = volume
        self.repeatSound = repeatSound

        super.init()
        prepare()
   }
    
    func prepare() {
        guard let url = url,
            let player = try? AVAudioPlayer(contentsOf: url) else {
            print("Failed to load url.")
            return
        }

        self.audioPlayer = player
        self.audioPlayer?.prepareToPlay()

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [ .pad ]

        formattedDuration = formatter.string(from: TimeInterval(self.audioPlayer?.duration ?? 0.0))!
        duration = self.audioPlayer?.duration ?? 0.0

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = self.audioPlayer {
                if !player.isPlaying {
                    self.isPlaying = false
                }
                self.progress = CGFloat(player.currentTime / player.duration)
                self.formattedProgress = formatter.string(from: TimeInterval(player.currentTime))!
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

    public func forward() {
        if let player = self.audioPlayer {
            let increase = player.currentTime + 15
            if increase < self.duration {
                player.currentTime = increase
            } else {
                // give the user the chance to hear the end if he wishes
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
        if repeatSound  {
            play()
        } else {
            isPlaying = false
        }
    }
}


