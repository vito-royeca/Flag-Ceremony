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
    
//    var countries = [FCCountry]()
//    var capitalLabels = [MaplyScreenLabel]()

    public init() {}

    func makeUIViewController(context: Context) -> MaplyVC {
        let mapVC = MaplyVC(mapType: .typeFlat, mbTilesFetcher: geodata.mbTilesFetcher)
        mapVC.map?.delegate = context.coordinator
        
        return mapVC
    }

    func updateUIViewController(_ uiViewController: MaplyVC, context: Context) {
        guard let map = uiViewController.map else {
            return
        }
        
        var position = MaplyCoordinate(x: 0, y: 0)
        var height = Float(0)
        
        map.getPosition(&position, height: &height)
        
        if position.x != geodata.location.x ||
           position.y != geodata.location.y ||
           height != geodata.height {
            map.animate(toPosition: geodata.location,
                        height: geodata.height,
                        time: 1.0)
        }
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        return Coordinator(self)
    }
    
//    func addFlags() {
//        if countryLabels.count > 0 &&
//            capitalLabels.count > 0 {
//            return
//        }
//
//        MBProgressHUD.showAdded(to: view, animated: true)
//
//        FirebaseManager.sharedInstance.fetchAllCountries(completion: { (countries: [FCCountry]) in
//            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
//                self.map.remove(self.countryLabels)
//                self.map.remove(self.capitalLabels)
//                self.countries.removeAll()
//                self.countryLabels.removeAll()
//                self.capitalLabels.removeAll()
//
//                for country in countries {
//                    // add flags only if there is a flag files
//                    if  let _ = country.getFlagURLForSize(size: .mini) {
//                        var label = MaplyScreenLabel()
//                        var radians = country.getGeoRadians()
//
//                        label.text = "\(country.emojiFlag())\(country.name!)"
//                        label.loc = MaplyCoordinate(x: radians[0],
//                                                    y: radians[1])
//                        label.selectable = true
//                        label.userObject = country
//                        label.layoutImportance = 1
//                        self.countryLabels.append(label)
//
//                        if let capital = country.capital {
//                            label = MaplyScreenLabel()
//                            radians = country.getCapitalGeoRadians()
//
//                            label.text = "\u{272A} \(capital[FCCountry.Keys.CapitalName]!)"
//                            label.loc = MaplyCoordinate(x: radians[0],
//                                                        y: radians[1])
//                            label.selectable = false
//                            self.capitalLabels.append(label)
//                        }
//
//                        self.countries.append(country)
//
//                    } else {
////                        print("anthem not found: \(country.name!)")
//                    }
//                }
//
//                self.mapView!.addScreenLabels(self.countryLabels,
//                                              desc: [kMaplyFont: UIFont.boldSystemFont(ofSize: 18.0),
//                                                     kMaplyTextOutlineColor: UIColor.black,
//                                                     kMaplyTextOutlineSize: 2.0,
//                                                     kMaplyColor: UIColor.white])
//
//                self.mapView!.addScreenLabels(self.capitalLabels,
//                                              desc: [kMaplyFont: UIFont.systemFont(ofSize: 14),
//                                                     kMaplyTextColor: UIColor.white])
//
//                DispatchQueue.main.async {
//                    MBProgressHUD.hide(for: self.view,
//                                       animated: true)
//                }
//            }
//        })
//    }
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

        func maplyViewController(_ viewC: MaplyViewController, didSelect selectedObj: NSObject, atLoc coord: MaplyCoordinate, onScreen screenPt: CGPoint) {
            
        }
        
        func maplyViewController(_ viewC: MaplyViewController, allSelect selectedObjs: [Any], atLoc coord: MaplyCoordinate, onScreen screenPt: CGPoint) {
            
        }

        func maplyViewController(_ viewC: MaplyViewController, didTapAt coord: MaplyCoordinate) {
            
        }

        func maplyViewControllerDidStartMoving(_ viewC: MaplyViewController, userMotion: Bool) {
            
        }


        func maplyViewController(_ viewC: MaplyViewController, didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>, userMotion: Bool) {
            var position = MaplyCoordinate(x: 0, y: 0)
            var height = Float(0)

            viewC.getPosition(&position, height: &height)
            parent.geodata.location = position
            parent.geodata.height = height
        }

        func maplyViewController(_ viewC: MaplyViewController, didMove corners: UnsafeMutablePointer<MaplyCoordinate>) {
            
        }

        func maplyViewController(_ viewC: MaplyViewController, didTap annotation: MaplyAnnotation) {
            
        }
    }
}

// MARK: - MapVC

class MaplyVC: UIViewController {
    var map: MaplyViewController?
    var imageLoader : MaplyQuadImageLoader?
    var mapType: MaplyMapType?
    var mbTilesFetcher: MaplyMBTileFetcher?

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
    
    func setView(point: Int) {
        
    }
}
