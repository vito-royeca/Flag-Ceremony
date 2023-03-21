//
//  MediaPlayerView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/16/23.
//

import SwiftUI
import AVKit

protocol MediaPlayerViewDelegate {
    func advance(progress: Double)
}

struct MediaPlayerView: View {
    @StateObject private var sound: MediaPlayer
    @Binding var currentTime: Double
    @Binding var durationTime: Double
    @Binding var isFinished: Bool

    var url: URL?
    var isAutoPlay: Bool
    
    init(url: URL?, autoPlay: Bool, currentTime: Binding<Double>, durationTime: Binding<Double>, isFinished: Binding<Bool>) {
        self.url = url

        self.isAutoPlay = autoPlay
        _sound = StateObject(wrappedValue: MediaPlayer(url: url))
        _currentTime = currentTime
        _durationTime = durationTime
        _isFinished = isFinished
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { gr in
                Capsule()
                    .stroke(Color.white, lineWidth: 2)
                    .background(
                        Capsule()
                            .foregroundColor(Color.white)
                            .frame(width: gr.size.width * sound.progress,
                                      height: 8), alignment: .leading)
            }
                .frame( height: 8)
            
            HStack {
                Text(sound.formattedProgress)
                    .font(Font.callout.monospacedDigit())
                    .foregroundColor(.white)
                Spacer()
                Text(sound.formattedRemaining)
                    .font(Font.callout.monospacedDigit())
                    .foregroundColor(.white)
            }
            
            Button(action: {
                sound.playOrPause()
            }) {
                Image(systemName: sound.isPlaying ? "pause.circle" : "play.circle")
                    .font(Font.largeTitle)
                    .imageScale(.large)
                    .foregroundColor(.white)
            }
            
            HStack {
                Button(action: {
                    sound.volumeDown()
                }) {
                    Image(systemName: sound.volume <= 0 ? "speaker.slash" : "speaker.wave.1")
                        .imageScale(.medium)
                }
                    .disabled(sound.volume <= 0)
                    .foregroundColor(.white)
                
                GeometryReader { gr in
                    Capsule()
                        .stroke(Color.white, lineWidth: 2)
                        .background(
                            Capsule()
                                .foregroundColor(Color.white)
                                .frame(width: gr.size.width * sound.volume,
                                       height: 8), alignment: .leading)
                }
                    .frame( height: 8)
                
                Button(action: {
                    sound.volumeUp()
                }) {
                    Image(systemName: "speaker.wave.3")
                        .imageScale(.medium)
                        .foregroundColor(.white)
                }
                    .disabled(sound.volume >= 1)
            }
        }
            .background(Color(uiColor: kBlueColor))
            .onAppear {
                if isAutoPlay {
                    sound.playOrPause()
                }
            }
            .onDisappear {
                sound.stop()
            }
            .onReceive(sound.updatePublisher) {
                currentTime = sound.currentTime
                durationTime = sound.durationTime
                isFinished = sound.isFinished
            }
    }
}

struct MediaPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        if let path = Bundle.main.path(forResource: "ph", ofType: "mp3"),
           FileManager.default.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            
            MediaPlayerView(url: url,
                            autoPlay: false,
                            currentTime: .constant(0),
                            durationTime: .constant(0),
                            isFinished: .constant(false))
        } else {
            EmptyView()
        }
    }
}
