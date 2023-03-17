//
//  MediaPlayerView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/16/23.
//

import SwiftUI
import AVKit

struct MediaPlayerView: View {
    @StateObject private var sound: MediaPlayer
    
    var url: URL?
    var autoPlay: Bool
    
    init(url: URL?, autoPlay: Bool) {
        self.url = url
        self.autoPlay = autoPlay
        
        _sound = StateObject(wrappedValue: MediaPlayer(url: url))
    }

    var body: some View {
        VStack {
            VStack {
                GeometryReader { gr in
                    Capsule()
                        .stroke(Color.systemBlue, lineWidth: 2)
                        .background(
                            Capsule()
                                .foregroundColor(Color.blue)
                                .frame(width: gr.size.width * sound.progress,
                                          height: 8), alignment: .leading)
                }
                    .frame( height: 8)
                
                HStack {
                    Text(sound.formattedProgress)
                        .font(Font.callout.monospacedDigit())
                    Spacer()
                    Text(sound.formattedDuration)
                        .font(Font.callout.monospacedDigit())
                }
                
                Button(action: {
                    sound.playOrPause()
                }) {
                    Image(systemName: sound.isPlaying ? "pause.circle" : "play.circle")
                        .font(Font.largeTitle)
                        .imageScale(.large)
                }
                
                HStack {
                    Button(action: {
                        sound.volumeDown()
                    }) {
                        Image(systemName: sound.volume <= 0 ? "speaker.slash" : "speaker.wave.1")
                            .imageScale(.medium)
                    }
                        .disabled(sound.volume <= 0)
                    
                    GeometryReader { gr in
                        Capsule()
                            .stroke(Color.systemBlue, lineWidth: 2)
                            .background(
                                Capsule()
                                    .foregroundColor(Color.blue)
                                    .frame(width: gr.size.width * sound.volume,
                                           height: 8), alignment: .leading)
                    }
                        .frame( height: 8)
                    
                    Button(action: {
                        sound.volumeUp()
                    }) {
                        Image(systemName: "speaker.wave.3")
                            .imageScale(.medium)
                    }
                        .disabled(sound.volume >= 1)
                }
            }
        }
            .onAppear {
                if autoPlay {
                    sound.playOrPause()
                }
            }
            .onDisappear {
                sound.stop()
            }
    }
}

struct MediaPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        if let path = Bundle.main.path(forResource: "ph", ofType: "mp3"),
           FileManager.default.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            
            MediaPlayerView(url: url, autoPlay: false)
        } else {
            EmptyView()
        }
    }
}
