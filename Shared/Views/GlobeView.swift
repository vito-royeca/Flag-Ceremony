//
//  GlobeView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI
import WhirlyGlobe

struct GlobeView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = GlobeVC
    @EnvironmentObject var geodata: Geodata

    func makeUIViewController(context: Context) -> GlobeVC {
        let globeVC = GlobeVC(mbTilesFetcher: geodata.mbTilesFetcher)
        globeVC.globe?.delegate = context.coordinator
        
        return globeVC
    }

    func updateUIViewController(_ uiViewController: GlobeVC, context: Context) {
        uiViewController.relocate(to: geodata.location, height: geodata.height)
        uiViewController.add(countries: geodata.countries)
    }
    
    func makeCoordinator() -> GlobeView.Coordinator {
        return Coordinator(self)
    }
}


struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        GlobeView().environmentObject(Geodata())
    }
}

extension GlobeView {
    class Coordinator: NSObject, WhirlyGlobeViewControllerDelegate {
        var parent: GlobeView

        init(_ parent: GlobeView) {
            self.parent = parent
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didSelect selectedObj: NSObject) {

        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>, userMotion: Bool) {
            var position = MaplyCoordinate(x: 0, y: 0)
            var height = Float(0)

            viewC.getPosition(&position, height: &height)
            parent.geodata.location = position
            parent.geodata.height = height - 0.2
        }
    }
}

// MARK: - GlobeVC

class GlobeVC: UIViewController {
    var mbTilesFetcher: MaplyMBTileFetcher?
    
    var globe: WhirlyGlobeViewController?
    var imageLoader : MaplyQuadImageLoader?
    var countries = [FCCountry]()
    var countryObjects: MaplyComponentObject?
    var capitalObjects: MaplyComponentObject?

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
        globe!.height = 1.0
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
    
    func add(countries: [FCCountry]) {
        guard let globe = globe,
           countries.count != self.countries.count else {
            return
        }

        self.countries.removeAll()
        if let countryObjects = countryObjects {
            globe.remove(countryObjects)
        }
        if let capitalObjects = capitalObjects {
            globe.remove(capitalObjects)
        }
        
        var countryLabels = [MaplyScreenLabel]()
        var capitalLabels = [MaplyScreenLabel]()
        
        for country in countries {
            var label = MaplyScreenLabel()
            var radians = country.getGeoRadians()
            
            label.text = country.displayName
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
        }
                        
        countryObjects = globe.addScreenLabels(countryLabels,
                                               desc: [kMaplyFont: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                                                      kMaplyTextOutlineColor: UIColor.black,
                                                      kMaplyTextOutlineSize: 2.0,
                                                      kMaplyColor: UIColor.white])
        
        capitalObjects = globe.addScreenLabels(capitalLabels,
                                               desc: [kMaplyFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .light),
                                                      kMaplyTextColor: UIColor.black])
    }
}
