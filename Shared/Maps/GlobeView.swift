//
//  GlobeView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI
import WhirlyGlobe

struct GlobeViewVC: View {
    @EnvironmentObject var viewModel: MapViewModel
    @State var selectedCountry: FCCountry? = nil
    @State var highlightedCountry: FCCountry? = nil
    @State var location = MapViewModel.defaultLocation
    @State var height = MapViewModel.defaultGlobeViewHeight
    @State private var isShowingSearch = false

    var body: some View {
        GlobeView(selectedCountry: $selectedCountry,
                  highlightedCountry: $highlightedCountry,
                  location: $location,
                  height: $height)
            .navigationTitle("Globe")
            .sheet(item: $selectedCountry) { selectedCountry in
                NavigationView {
                    CountryView(id: selectedCountry.id, isAutoPlay: true)
                }
            }
            .sheet(isPresented: $isShowingSearch, content: {
                NavigationView {
                    MapSearchView(height: height, highlightedCountry: $highlightedCountry)
                        .environmentObject(viewModel)
                }
            })
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingSearch.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .onAppear {
                location = viewModel.location
                height = viewModel.height
                highlightedCountry = viewModel.highleightedCountry
            }
            .onDisappear {
                viewModel.location = location
                viewModel.height = height
                viewModel.highleightedCountry = highlightedCountry
            }
    }
}

struct GlobeView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = GlobeVC

    @EnvironmentObject var viewModel: MapViewModel
    @Binding var selectedCountry: FCCountry?
    @Binding var highlightedCountry: FCCountry?
    @Binding var location: MaplyCoordinate
    @Binding var height: Float

    func makeUIViewController(context: Context) -> GlobeVC {
        let globeVC = GlobeVC(mbTilesFetcher: viewModel.mbTilesFetcher)
        globeVC.globe?.delegate = context.coordinator
        
        return globeVC
    }

    func updateUIViewController(_ uiViewController: GlobeVC, context: Context) {
        uiViewController.relocate(to: viewModel.location, height: viewModel.height)
        uiViewController.add(highlitedCountry: highlightedCountry)
        uiViewController.add(countries: viewModel.countries.filter({ $0.id != highlightedCountry?.id }))
    }
    
    func makeCoordinator() -> GlobeView.Coordinator {
        return Coordinator(self)
    }
}


struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        let country = FCCountry(key: "PH", dict: [:])
        GlobeView(selectedCountry: .constant(country),
                  highlightedCountry: .constant(nil),
                  location: .constant(MapViewModel.defaultLocation),
                  height: .constant(MapViewModel.defaultGlobeViewHeight))
           .environmentObject(MapViewModel())
    }
}

extension GlobeView {
    class Coordinator: NSObject, WhirlyGlobeViewControllerDelegate {
        var parent: GlobeView

        init(_ parent: GlobeView) {
            self.parent = parent
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didSelect selectedObj: NSObject) {
            if let selectedObject = selectedObj as? MaplyScreenLabel {
                let country = selectedObject.userObject as? FCCountry
                parent.selectedCountry = country
            }
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>, userMotion: Bool) {
            var position = MaplyCoordinate(x: 0, y: 0)
            var height = Float(0)

            viewC.getPosition(&position, height: &height)
            parent.location = position
            parent.height = height - 0.2
        }
    }
}

// MARK: - GlobeVC

class GlobeVC: UIViewController {
    var mbTilesFetcher: MaplyMBTileFetcher?
    
    var globe: WhirlyGlobeViewController?
    var imageLoader : MaplyQuadImageLoader?
    var countries = [FCCountry]()
    var highlightedCountry: FCCountry?
    var countryObjects: MaplyComponentObject?
    var capitalObjects: MaplyComponentObject?
    var highlightedObject: MaplyComponentObject?
    var countryLabels = [MaplyScreenLabel]()
    var capitalLabels = [MaplyScreenLabel]()

    convenience init(mbTilesFetcher: MaplyMBTileFetcher?) {
        self.init()
        self.mbTilesFetcher = mbTilesFetcher
        globe = WhirlyGlobeViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        configureGlobe()
    }
    
    func configureGlobe() {
        guard let mbTilesFetcher = mbTilesFetcher else {
            return
        }
        
        self.view.addSubview(globe!.view)
        globe!.view.frame = self.view.bounds
        addChild(globe!)
        
        // Sampling parameters define how we break down the globe
        let sampleParams = MaplySamplingParams()
        sampleParams.coordSys = mbTilesFetcher.coordSys()
        sampleParams.coverPoles = true
        sampleParams.edgeMatching = true
        sampleParams.minZoom = mbTilesFetcher.minZoom()
        sampleParams.maxZoom = mbTilesFetcher.maxZoom()
        sampleParams.singleLevel = true

        imageLoader = MaplyQuadImageLoader(params: sampleParams,
            tileInfo: mbTilesFetcher.tileInfo(),
            viewC: globe!)
        imageLoader!.setTileFetcher(mbTilesFetcher)
        imageLoader!.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault

        globe!.clearColor = UIColor.black
        globe!.frameInterval = 2
        globe!.height = MapViewModel.defaultGlobeViewHeight
    }
    
    func relocate(to position: MaplyCoordinate, height: Float) {
        guard let globe = globe else {
            return
        }
        
        var cPosition = MaplyCoordinate(x: 0, y: 0)
        var cHeight = Float(0)
        
        globe.getPosition(&cPosition, height: &cHeight)
        
        if cPosition.x != position.x ||
           cPosition.y != position.y ||
           cHeight != height {
            globe.animate(toPosition: position,
                          height: height + 0.2,
                          heading: globe.heading,
                          time: 1.0)
        }
    }
    
    func add(highlitedCountry: FCCountry?) {
        guard let globe = globe,
           self.highlightedCountry?.id != highlitedCountry?.id else {
            return
        }

        self.highlightedCountry = highlitedCountry
        if let highlightedObject = highlightedObject {
            globe.remove(highlightedObject)
        }
        
        if let highlitedCountry = highlitedCountry {
            let label = label(for: highlitedCountry)
            
            highlightedObject = globe.addScreenLabels([label],
                                                      desc: [kMaplyFont: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                                                             kMaplyTextOutlineColor: UIColor.lightGray,
                                                             kMaplyTextOutlineSize: 2.0,
                                                             kMaplyTextColor: UIColor.red])
        }
    }

    func add(countries: [FCCountry]) {
        guard let globe = globe,
           self.countries != countries else {
            return
        }

        self.countries.removeAll()
        countryLabels.removeAll()
        capitalLabels.removeAll()

        if let countryObjects = countryObjects {
            globe.remove(countryObjects)
        }
        if let capitalObjects = capitalObjects {
            globe.remove(capitalObjects)
        }
        
        for country in countries {
            var label = label(for: country)
            countryLabels.append(label)
            
            if let capital = country.capital {
                label = MaplyScreenLabel()
                let radians = country.getCapitalGeoRadians()
                
                label.text = "\u{272A} \(capital[FCCountry.Keys.CapitalName]!)"
                label.loc = MaplyCoordinate(x: Float(radians[0]),
                                            y: Float(radians[1]))
                label.selectable = false
                capitalLabels.append(label)
            }
            self.countries.append(country)
        }
                        
        countryObjects = globe.addScreenLabels(countryLabels,
                                               desc: [kMaplyFont: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                                                      kMaplyTextOutlineColor: UIColor.black,
                                                      kMaplyTextOutlineSize: 2.0,
                                                      kMaplyTextColor: UIColor.white])
        
        capitalObjects = globe.addScreenLabels(capitalLabels,
                                               desc: [kMaplyFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .light),
                                                      kMaplyTextColor: UIColor.black])
    }

    func label(for country: FCCountry) -> MaplyScreenLabel {
        let label = MaplyScreenLabel()
        let radians = country.getGeoRadians()
        
        label.text = country.displayName
        label.loc = MaplyCoordinate(x: Float(radians[0]),
                                    y: Float(radians[1]))
        label.selectable = true
        label.userObject = country
        label.layoutImportance = 1
        
        return label
    }
}
