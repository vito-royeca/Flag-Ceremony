//
//  CountryView.swift
//  Flag Ceremony Watch App
//
//  Created by Vito Royeca on 4/27/23.
//

import SwiftUI

struct CountryView: View {
    @Environment(\.colorScheme) var colorScheme

    @StateObject var viewModel: CountryViewModel
    @State var currentTime: Double = 0
    @State var durationTime: Double = 0
    @State var isFinished: Bool = false
    var isAutoPlay: Bool

    init(id: String, isAutoPlay: Bool) {
        self.isAutoPlay = isAutoPlay
        _viewModel = StateObject(wrappedValue: CountryViewModel(id: id))
    }

    var body: some View {
        Group {
            if viewModel.isBusy {
                ProgressView()
            } else if viewModel.isFailed {
                Text("An error has occured")
            } else {
                mainView
            }
        }
            .task {
                do {
                    try await viewModel.fetchData()
                    #if !targetEnvironment(simulator)
                    viewModel.incrementViews()
                    #endif
                } catch let error {
                    
                }
            }
    }
    
    var mainView: some View {
        VStack {
            flagView
                .padding()
            Text(viewModel.country?.name ?? "")
            if let url = viewModel.country?.getAudioURL() {
                MediaPlayerView(url: url,
                                autoPlay: isAutoPlay,
                                showVolume: false,
                                currentTime: $currentTime,
                                durationTime: $durationTime,
                                isFinished: $isFinished)
            }
        }
    }
    
    var flagView: some View {
        AsyncImage(
            url: viewModel.country?.getFlagURL(),
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .border(colorScheme == .dark ? .clear : .black)
            },
            placeholder: {
                Text(viewModel.country?.emojiFlag ?? "")
                    .font(.largeTitle)
            }
        )
    }
}

struct CountryView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            CountryView(id: "PH", isAutoPlay: false)
                .environmentObject(AccountViewModel())
                .previewDevice("Apple Watch Series 5 - 44mm")

            CountryView(id: "PH", isAutoPlay: false)
                .environmentObject(AccountViewModel())
                .previewDevice("Apple Watch Series 5 - 40mm")
        }
    }
}
