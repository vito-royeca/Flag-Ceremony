//
//  GeographicViewController.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 4/6/23.
//

import UIKit

enum GeographicViewControllerType {
    case map, globe
}

class GeographicViewController: UIViewController {
    let defaultDescription:[String : Any] = [kMaplyFont: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                                             kMaplyTextOutlineColor: UIColor.black,
                                             kMaplyTextOutlineSize: 2.0,
                                             kMaplyTextColor: UIColor.white]
    let highlightedDescription:[String : Any] = [kMaplyFont: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                                                 kMaplyTextOutlineColor: UIColor.red,
                                                 kMaplyTextOutlineSize: 2.0,
                                                 kMaplyTextColor: UIColor.white]
    let capitalDescription:[String: Any] = [kMaplyFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .light),
                                            kMaplyTextColor: UIColor.black]

    var mbTilesFetcher: MaplyMBTileFetcher?
    
    var globe: WhirlyGlobeViewController?
    var map: MaplyViewController?
    var imageLoader : MaplyQuadImageLoader?
    var countries = [FCCountry]()
    var highlightedCountry: FCCountry?
    var countryObjects: MaplyComponentObject?
    var capitalObjects: MaplyComponentObject?
    var highlightedObject: MaplyComponentObject?
    var type: GeographicViewControllerType = .map

    convenience init(mbTilesFetcher: MaplyMBTileFetcher?, type: GeographicViewControllerType) {
        self.init()
        self.mbTilesFetcher = mbTilesFetcher
        self.type = type
        
        switch type {
        case .map:
            map = MaplyViewController(mapType: .typeFlat)
        case .globe:
            globe = WhirlyGlobeViewController()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        configure()
    }
    
    private func configure() {
        guard let mbTilesFetcher = mbTilesFetcher else {
            return
        }
        
        // Sampling parameters define how we break down the globe
        let sampleParams = MaplySamplingParams()
        sampleParams.coordSys = mbTilesFetcher.coordSys()
        sampleParams.coverPoles = true
        sampleParams.edgeMatching = true
        sampleParams.minZoom = mbTilesFetcher.minZoom()
        sampleParams.maxZoom = mbTilesFetcher.maxZoom()
        sampleParams.singleLevel = true

        switch type {
        case .map:
            self.view.addSubview(map!.view)
            map!.view.frame = self.view.bounds
            addChild(map!)

            map!.clearColor = UIColor.white
            map!.frameInterval = 2
            map!.height = MapViewModel.defaultMapViewHeight
            
            imageLoader = MaplyQuadImageLoader(params: sampleParams,
                tileInfo: mbTilesFetcher.tileInfo(),
                viewC: map!)

        case .globe:
            self.view.addSubview(globe!.view)
            globe!.view.frame = self.view.bounds
            addChild(globe!)
            
            globe!.clearColor = UIColor.black
            globe!.frameInterval = 2
            globe!.height = MapViewModel.defaultGlobeViewHeight

            imageLoader = MaplyQuadImageLoader(params: sampleParams,
                                               tileInfo: mbTilesFetcher.tileInfo(),
                                               viewC: globe!)
        }

        imageLoader!.setTileFetcher(mbTilesFetcher)
        imageLoader!.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault
    }
    
    func relocate(to position: MaplyCoordinate) {
        var cPosition = MaplyCoordinate(x: 0, y: 0)
        var cHeight = Float(0)
        
        switch type {
        case .map:
            guard let map = map else {
                return
            }
            
            map.getPosition(&cPosition, height: &cHeight)
            if cPosition.x != position.x ||
               cPosition.y != position.y {
                map.animate(toPosition: position, time: 1.0)
            }
        
        case .globe:
            guard let globe = globe else {
                return
            }
            
            globe.getPosition(&cPosition, height: &cHeight)
            if cPosition.x != position.x ||
               cPosition.y != position.y {
                globe.animate(toPosition: position,
                              height: cHeight,
                              heading: globe.heading,
                              time: 1.0)
            }
        }
    }
    
    func add(countries: [FCCountry], highlighted: FCCountry?) {
        guard self.countries != countries else {
            return
        }

        var countryLabels = [MaplyScreenLabel]()
        var capitalLabels = [MaplyScreenLabel]()

        // remove existing objects
        switch type {
        case .map:
            guard let map = map else {
                return
            }
            
            if let countryObjects = countryObjects {
                map.remove(countryObjects)
            }
            if let capitalObjects = capitalObjects {
                map.remove(capitalObjects)
            }
            if let highlightedObject = highlightedObject {
                map.remove(highlightedObject)
            }

        case .globe:
            guard let globe = globe else {
                return
            }
            
            if let countryObjects = countryObjects {
                globe.remove(countryObjects)
            }
            if let capitalObjects = capitalObjects {
                globe.remove(capitalObjects)
            }
            if let highlightedObject = highlightedObject {
                globe.remove(highlightedObject)
            }
        }
        self.countries.removeAll()

        // add highlighted object
        highlightedCountry = highlighted
        if let highlighted = highlighted {
            var label = label(for: highlighted)
            
            switch type {
            case .map:
                guard let map = map else {
                    return
                }
                
                highlightedObject = map.addScreenLabels([label], desc: highlightedDescription)

            case .globe:
                guard let globe = globe else {
                    return
                }
                
                highlightedObject = globe.addScreenLabels([label], desc: highlightedDescription)
            }
            
            if let capital = highlighted.capital {
                label = MaplyScreenLabel()
                let radians = highlighted.getCapitalGeoRadians()
                
                label.text = "\u{272A} \(capital[FCCountry.Keys.CapitalName]!)"
                label.loc = MaplyCoordinate(x: Float(radians[0]),
                                            y: Float(radians[1]))
                label.selectable = false
                capitalLabels.append(label)
            }
        }

        // add countries and capitals
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
        switch type {
        case .map:
            guard let map = map else {
                return
            }
            
            countryObjects = map.addScreenLabels(countryLabels, desc: defaultDescription)
            capitalObjects = map.addScreenLabels(capitalLabels, desc: capitalDescription)

        case .globe:
            guard let globe = globe else {
                return
            }
            
            countryObjects = globe.addScreenLabels(countryLabels, desc: defaultDescription)
            capitalObjects = globe.addScreenLabels(capitalLabels, desc: capitalDescription)
        }
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
