//
//  MapView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI
import Firebase
import MBProgressHUD
import WhirlyGlobe

struct MapView: UIViewRepresentable {
    var map = MaplyViewController()
//    var countries = [FCCountry]()
//    var capitalLabels = [MaplyScreenLabel]()

    func makeUIView(context: Context) -> UIView {
        initMap()
//        addFlags()
        return map.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    func initMap() {
        map.clearColor = UIColor.white
//        map.delegate = self
        
        // set up the data source
        if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres"),
            let layer = MaplyQuadImageTilesLayer(coordSystem: tileSource.coordSys,
                                                 tileSource: tileSource) {
            layer.handleEdges = false
            layer.coverPoles = false
            layer.requireElev = false
            layer.waitLoad = false
            layer.drawPriority = 0
            layer.singleLevelLoading = false
            map.add(layer)
        }
    }
        
//    func addFlags() {
//        if countryLabels.count > 0 &&
//            capitalLabels.count > 0 {
//            return
//        }
//
////        MBProgressHUD.showAdded(to: view, animated: true)
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
