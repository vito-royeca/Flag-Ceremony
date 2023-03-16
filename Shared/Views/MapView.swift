//
//  MapView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI
import WhirlyGlobe

struct MapView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = MaplyVC
    @EnvironmentObject var geodata: Geodata
    
    func makeUIViewController(context: Context) -> MaplyVC {
        let mapVC = MaplyVC(mapType: .typeFlat, mbTilesFetcher: geodata.mbTilesFetcher)
        mapVC.map?.delegate = context.coordinator
        
        return mapVC
    }

    func updateUIViewController(_ uiViewController: MaplyVC, context: Context) {
        uiViewController.relocate(to: geodata.location, height: geodata.height)
        uiViewController.add(countries: geodata.countries)
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        return Coordinator(self)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView().environmentObject(Geodata())
    }
}

extension MapView {
    class Coordinator: NSObject, MaplyViewControllerDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func maplyViewController(_ viewC: MaplyViewController, didSelect selectedObj: NSObject) {
            
        }

        func maplyViewController(_ viewC: MaplyViewController, didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>, userMotion: Bool) {
            var position = MaplyCoordinate(x: 0, y: 0)
            var height = Float(0)

            viewC.getPosition(&position, height: &height)
            parent.geodata.location = position
            parent.geodata.height = height
        }
    }
}

// MARK: - MapVC

class MaplyVC: UIViewController {
    var mapType: MaplyMapType?
    var mbTilesFetcher: MaplyMBTileFetcher?
    
    var map: MaplyViewController?
    var imageLoader : MaplyQuadImageLoader?
    var countries = [FCCountry]()
    var countryObjects: MaplyComponentObject?
    var capitalObjects: MaplyComponentObject?

    convenience init(mapType: MaplyMapType, mbTilesFetcher: MaplyMBTileFetcher?) {
        self.init()
        self.mapType = mapType
        self.mbTilesFetcher = mbTilesFetcher
        map = MaplyViewController(mapType: mapType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureMap()
    }
    
    func configureMap() {
        guard let mbTilesFetcher = mbTilesFetcher else {
            return
        }
        
        self.view.addSubview(map!.view)
        map!.view.frame = self.view.bounds
        addChild(map!)
        
        // Sampling parameters define how we break down the map
        let sampleParams = MaplySamplingParams()
        sampleParams.coordSys = mbTilesFetcher.coordSys()
        sampleParams.coverPoles = false
        sampleParams.edgeMatching = true
        sampleParams.minZoom = mbTilesFetcher.minZoom()
        sampleParams.maxZoom = mbTilesFetcher.maxZoom()
        sampleParams.singleLevel = true

        imageLoader = MaplyQuadImageLoader(params: sampleParams,
            tileInfo: mbTilesFetcher.tileInfo(),
            viewC: map!)
        imageLoader!.setTileFetcher(mbTilesFetcher)
        imageLoader!.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault
        
        map!.clearColor = UIColor.white
        map!.frameInterval = 2
        map!.height = 0.8
    }
    
    func relocate(to position: MaplyCoordinate, height: Float) {
        guard let map = map else {
            return
        }
        
        var cPosition = MaplyCoordinate(x: 0, y: 0)
        var cHeight = Float(0)
        
        map.getPosition(&cPosition, height: &cHeight)
        
        if cPosition.x != position.x ||
           cPosition.y != position.y ||
           cHeight != height {
            map.animate(toPosition: position,
                        height: height,
                        time: 1.0)
        }
    }
    
    func add(countries: [FCCountry]) {
        guard let map = map,
           countries.count != self.countries.count else {
            return
        }

        self.countries.removeAll()
        if let countryObjects = countryObjects {
            map.remove(countryObjects)
        }
        if let capitalObjects = capitalObjects {
            map.remove(capitalObjects)
        }
        
        var countryLabels = [MaplyScreenLabel]()
        var capitalLabels = [MaplyScreenLabel]()
        
        for country in countries {
            // add flags only if there is a flag files
//            if  let _ = country.getFlagURLForSize(size: .mini) {
                var label = MaplyScreenLabel()
                var radians = country.getGeoRadians()
                
                label.text = "\(country.emojiFlag())\(country.name!)"
                label.loc = MaplyCoordinate(x: Float(radians[0]),
                                            y: Float(radians[1]))
                label.selectable = true
                label.userObject = country
                label.layoutImportance = 1
                countryLabels.append(label)
                
                if let capital = country.capital {
                    label = MaplyScreenLabel()
                    radians = country.getCapitalGeoRadians()
                    
                    label.text = "\u{272A} \(capital[FCCountry.Keys.CapitalName]!)"
                    label.loc = MaplyCoordinate(x: Float(radians[0]),
                                                y: Float(radians[1]))
                    label.selectable = false
                    capitalLabels.append(label)
                }
                self.countries.append(country)
//            }
        }
                        
        countryObjects = map.addScreenLabels(countryLabels,
                                             desc: [kMaplyFont: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                                                    kMaplyTextOutlineColor: UIColor.black,
                                                    kMaplyTextOutlineSize: 2.0,
                                                    kMaplyColor: UIColor.white])
        
        capitalObjects = map.addScreenLabels(capitalLabels,
                                             desc: [kMaplyFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .light),
                                                    kMaplyTextColor: UIColor.black])
    }
}
