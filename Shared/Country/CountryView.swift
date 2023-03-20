//
//  CountryView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/16/23.
//

import SwiftUI
import SwiftUIX
import Introspect

struct CountryView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @State private var isShowingShareSheet = false
    @State var currentTime: Double = 0
    @State var durationTime: Double = 0
    @State var isFinished: Bool = false
    @StateObject var viewModel: CountryViewModel
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
            .onAppear {
                viewModel.fetchData {
                    viewModel.incrementViews()
                }
            }
    }
    
    var mainView: some View {
        GeometryReader { reader in
            ZStack(alignment: .bottomTrailing) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            flagView
                            actionsView
                            Spacer()
                            titlesView
                            Spacer()
                            lyricsView
                            Spacer(minLength: 200)
                        }.padding()
                    }
                    .introspectScrollView(customize: { scrollView in
                        guard currentTime > 0 && durationTime > 0 else {
                            return
                        }
                        
                        let contentSize = scrollView.contentSize
                        let visibleSize = scrollView.visibleSize
                        let diff = contentSize.height - visibleSize.height
                        let index = currentTime / durationTime
                        let y = diff * index
                        
                        if y <= diff {
                            let scrollPoint = CGPoint(x: 0, y: y)
                            scrollView.setContentOffset(scrollPoint, animated: true)
                        }

                        if isFinished {
                            let scrollPoint = CGPoint(x: 0, y: -(reader.safeAreaInsets.top))
                            
                            scrollView.setContentOffset(scrollPoint, animated: true)
                            viewModel.incrementPlays()
                        }
                    })
                }
                
                VStack {
                    if let url = viewModel.country?.getAudioURL() {
                        MediaPlayerView(url: url,
                                        autoPlay: isAutoPlay,
                                        currentTime: $currentTime,
                                        durationTime: $durationTime,
                                        isFinished: $isFinished)
                            .padding()
                            .background(Color.systemGroupedBackground .edgesIgnoringSafeArea(.bottom))
                    }
                }
            }
        }
        
            .navigationBarTitle(Text(viewModel.country?.displayName ?? ""))
            .toolbar {
                CountryToolbar(presentationMode: presentationMode,
                               isShowingShareSheet: $isShowingShareSheet)
            }
            .sheet(isPresented: $isShowingShareSheet, content: {
                activityView
            })
    }
    
    var flagView: some View {
        AsyncImage(
            url: viewModel.country?.getFlagURL(),
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .border(.black)
            },
            placeholder: {
                EmptyView()
            }
        )
    }

    var actionsView: some View {
        HStack {
            Text("\(viewModel.country?.views ?? 0)")
            Image(systemName: "eye.fill")
                .imageScale(.small)
            Text("\(viewModel.country?.plays ?? 0)")
            Image(systemName: "play.fill")
                .imageScale(.small)
            
            Spacer()
            Button(action: {
                guard let key = viewModel.country?.key else {
                    return
                }
                
                accountViewModel.toggleFavorite(key: key)
            }) {
                if let country = viewModel.country {
                    Image(systemName: accountViewModel.favoriteCountries.contains(country) ? "star.fill" : "star")
                        .imageScale(.large)
                        .padding()
                } else {
                    EmptyView()
                }
            }
                .disabled(accountViewModel.account == nil)
            
            Button(action: {
                
            }) {
                Image(systemName: "info.circle")
                    .imageScale(.large)
                    .padding()
            }
        }
    }

    var titlesView: some View {
        let title = viewModel.anthem?.title
        let nativeTitle = viewModel.anthem?.nativeTitle
        let lyricsWriter = (viewModel.anthem?.lyricsWriter ?? []).joined(separator: ",")
        let musicWriter = (viewModel.anthem?.musicWriter ?? []).joined(separator: ",")
        
        return VStack(alignment: .leading) {
            Text(nativeTitle ?? "")
                .font(Font.title2)
            
            if title != nativeTitle {
                Spacer()
                Text(title ?? "")
                    .font(Font.title3)
            }
            
            if !lyricsWriter.isEmpty {
                Spacer()
                Text("Lyrics: \(lyricsWriter)")
                    .font(.footnote)
            }
                
            if !lyricsWriter.isEmpty {
                Spacer()
                Text("Music: \(musicWriter)")
                    .font(.footnote)
            }
        }
            .frame(
                  minWidth: 0,
                  maxWidth: .infinity,
                  minHeight: 0,
                  maxHeight: .infinity,
                  alignment: .topLeading
                )
    }

    var lyricsView: some View {
        let lyrics = viewModel.anthem?.lyrics ?? []

        return VStack {
            ForEach(lyrics, id: \.self) { lyric in
                let keys = lyric.map{$0.key}.sorted(by: <)

                ForEach(keys, id: \.self) { key in
                    if let value = lyric[key] {
                        Text(value)
                    }
                }
            }
        }
            .frame(
                  minWidth: 0,
                  maxWidth: .infinity,
                  minHeight: 0,
                  maxHeight: .infinity,
                  alignment: .top
                )
    }
        
    var activityView: some View {
        var itemSources = [UIActivityItemSource]()
        
        if let country = viewModel.country {
            itemSources.append(CountryViewItemSource(country: country))
        }

        return AppActivityView(activityItems: itemSources)
            .excludeActivityTypes([])
            .onCancel { }
            .onComplete { result in
                return
            }
    }
}

struct CountryView_Previews: PreviewProvider {
    static var previews: some View {
        CountryView(id: "PH", isAutoPlay: false)
    }
}

// MARK: - CountryToolbar

struct CountryToolbar: ToolbarContent {
    @Binding var presentationMode: PresentationMode
    @Binding var isShowingShareSheet: Bool
    
    init(presentationMode: Binding<PresentationMode>, isShowingShareSheet: Binding<Bool>) {
        _presentationMode = presentationMode
        _isShowingShareSheet = isShowingShareSheet
    }
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button(action: {
                isShowingShareSheet.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: {
                $presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
            }
        }
    }
}

