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
    
//    var countries = [FCCountry]()
//    var capitalLabels = [MaplyScreenLabel]()

    func makeUIViewController(context: Context) -> MaplyVC {
        let mapVC = MaplyVC(mapType: .typeFlat)
        mapVC.map?.delegate = context.coordinator
        
        return mapVC
    }

    func updateUIViewController(_ uiViewController: MaplyVC, context: Context) {

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
        MapView()
    }
}

extension MapView {
    class Coordinator: NSObject, MaplyViewControllerDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        
    }
}

class MaplyVC: UIViewController {
    var map: MaplyViewController?
    var mbTilesFetcher : MaplyMBTileFetcher?
    var imageLoader : MaplyQuadImageLoader?
    var mapType: MaplyMapType?
    
    convenience init(mapType: MaplyMapType) {
        self.init()
        self.mapType = mapType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let mapType = mapType {
            map = MaplyViewController(mapType: mapType)
            self.view.addSubview(map!.view)
            map!.view.frame = self.view.bounds
            addChild(map!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initMap()
    }

    func initMap() {
        // Set up an MBTiles file and read the header
        mbTilesFetcher = MaplyMBTileFetcher(mbTiles: "geography-class_medres")

        // Sampling parameters define how we break down the globe
        let sampleParams = MaplySamplingParams()
        sampleParams.coordSys = mbTilesFetcher!.coordSys()
        sampleParams.coverPoles = true
        sampleParams.edgeMatching = true
        sampleParams.minZoom = mbTilesFetcher!.minZoom()
        sampleParams.maxZoom = mbTilesFetcher!.maxZoom()
        sampleParams.singleLevel = true

        if let map = map {
            imageLoader = MaplyQuadImageLoader(params: sampleParams,
                tileInfo: mbTilesFetcher!.tileInfo(),
                viewC: map)
            imageLoader!.setTileFetcher(mbTilesFetcher!)
            imageLoader!.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault
            
            map.clearColor = UIColor.white
            map.frameInterval = 2
            map.height = 0.8
            map.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704, 40.5023),
            time: 1.0)
        }
    }
}
