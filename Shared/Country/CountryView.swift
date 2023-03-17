//
//  CountryView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/16/23.
//

import SwiftUI
import SwiftUIX
import LinkPresentation

struct CountryView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingShareSheet = false
    @StateObject var viewModel: CountryViewModel
    
    init(id: String) {
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
                viewModel.fetchData()
            }
    }
    
    var mainView: some View {
        ScrollView {
            VStack {
                flagView()
                    .padding()
                actionsView
                titlesView
                if let url = viewModel.country?.getAudioURL() {
                    MediaPlayerView(url: url, autoPlay: true)
                        .padding()
                }
                lyricsView
            }
                .navigationBarTitle(Text(viewModel.country?.name ?? ""))
                .toolbar {
                    CountryToolbar(presentationMode: presentationMode,
                                   isShowingShareSheet: $isShowingShareSheet)
                }
                .sheet(isPresented: $isShowingShareSheet, content: {
                    activityView
                })
        }
    }
    
    func flagView() -> some View {
        AsyncImage(
            url: viewModel.country?.getFlagURL(),
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .border(.black)
            },
            placeholder: {
                ProgressView()
            }
        )
    }

    var titlesView: some View {
        let title = viewModel.anthem?.title
        let nativeTitle = viewModel.anthem?.nativeTitle

        return VStack {
            Text(nativeTitle ?? "")
                .font(Font.title)
            
            if title != nativeTitle {
                Text(title ?? "")
                    .font(Font.title2)
            }
        }
    }

    var actionsView: some View {
        HStack {
            Button(action: {
                
            }) {
                Image(systemName: "star")
                    .imageScale(.large)
                    .padding()
            }
            Spacer()
            Button(action: {
                
            }) {
                Image(systemName: "info.circle")
                    .imageScale(.large)
                    .padding()
            }
        }
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
        CountryView(id: "PH")
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
//                    .renderingMode(.original)
            }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: {
                $presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
//                    .renderingMode(.original)
            }
        }
    }
}

// MARK: - UIActivityItemSource

class CountryViewItemSource: NSObject, UIActivityItemSource {
    let country: FCCountry
    
    init(country: FCCountry) {
        self.country = country
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return country.displayName
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        guard let url = country.getFlagURL(),
           let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return country.displayName
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        guard let url = country.getFlagURL(),
           let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        
        return image
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        
        guard let url = country.getFlagURL(),
           let image = UIImage(contentsOfFile: url.path) else {
            return metadata
        }
        
        metadata.iconProvider = NSItemProvider(object: image)
        metadata.title = country.displayName
        return metadata
    }
}
