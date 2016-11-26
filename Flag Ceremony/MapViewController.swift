//
//  MapViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import WhirlyGlobe

class MapViewController: UIViewController {
    // MARK: Variables
    var mapView: MaplyViewController?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initMap()
        addFlags()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let lon = UserDefaults.standard.value(forKey: kLocationLongitude) as? Float,
            let lat = UserDefaults.standard.value(forKey: kLocationLatitude) as? Float,
            let height = UserDefaults.standard.value(forKey: kLocationHeight) as? Float {
            mapView!.height = height
            mapView!.animate(toPosition: MaplyCoordinateMake(lon, lat), time: 1.0)
        } else {
            mapView!.height = DefaultLocationHeight
            mapView!.animate(toPosition: MaplyCoordinateMake(DefaultLocationLongitude, DefaultLocationLatitude), time: 1.0)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsFromMapAsPush" ||
            segue.identifier == "showDetailsFromMapAsModal" {
            
            var countryVC:CountryViewController?
            
            if let nav = segue.destination as? UINavigationController {
                if let vc = nav.childViewControllers.first as? CountryViewController {
                    countryVC = vc
                }
            }else  if let vc = segue.destination as? CountryViewController {
                countryVC = vc
            }
            
            if let countryVC = countryVC {
                countryVC.country = sender as? Country
            }
        }
    }

    // MARL: Custom methods
    func initMap() {
        mapView = MaplyViewController()
        mapView!.clearColor = UIColor.white
        mapView!.delegate = self
        view.addSubview(mapView!.view)
        mapView!.view.frame = view.bounds
        addChildViewController(mapView!)
        
        // set up the data source
        if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres") {
            if let layer = MaplyQuadImageTilesLayer(coordSystem: tileSource.coordSys, tileSource: tileSource) {
                layer.handleEdges = false
                layer.coverPoles = false
                layer.requireElev = false
                layer.waitLoad = false
                layer.drawPriority = 0
                layer.singleLevelLoading = false
                mapView!.add(layer)
            }
        }
    }
    
//    func addFlags() {
//        let ref = FIRDatabase.database().reference()
//        
//        MBProgressHUD.showAdded(to: view, animated: true)
//        ref.child("countries").observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
//                let countries = snapshot.value as? [String: [String: Any]] ?? [:]
//                var flags = [MaplyScreenMarker]()
//                
//                for (key,value) in countries {
//                    let country = Country.init(key: key, dict: value)
//                    
//                    // add flags only if there is an audio
//                    if let url = country.getFlagURLForSize(size: .Mini)/*,
//                        let _ = country.getAudioURL()*/ {
//                        let image = UIImage(contentsOfFile: url.path)
//                        let marker = MaplyScreenMarker()
//                        let radians = country.getGeoRadians()
//                        
//                        marker.image = image
//                        marker.loc = MaplyCoordinate(x: radians[0], y: radians[1])
//                        marker.size = image!.size
//                        marker.userObject = country
//                        flags.append(marker)
//                    } else {
//                        print("flag not found: \(country.name!)")
//                    }
//                }
//                
//                self.mapView!.addScreenMarkers(flags, desc: nil)
//            }
//            
//            DispatchQueue.main.async {
//                MBProgressHUD.hide(for: self.view, animated: true)
//            }
//            
//        }) { (error) in
//            print(error.localizedDescription)
//            MBProgressHUD.hide(for: self.view, animated: true)
//        }
//    }
    
    func addFlags() {
        let ref = FIRDatabase.database().reference()
        
        MBProgressHUD.showAdded(to: view, animated: true)
        ref.child("countries").observeSingleEvent(of: .value, with: { (snapshot) in
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                let dict = snapshot.value as? [String: [String: Any]] ?? [:]
                var countries = [MaplyScreenLabel]()
                var capitals = [MaplyScreenLabel]()
                //  Unicode: U+272A, UTF-8: E2 9C AA / \u{1830
                
                for (key,value) in dict {
                    let country = Country.init(key: key, dict: value)
                    
                    // add flags only if there is an audio
                    if let _ = country.getAudioURL() {
                            var label = MaplyScreenLabel()
                            var radians = country.getGeoRadians()
                        
                            label.text = "\(country.emojiFlag())\(country.name!)"
                            label.loc = MaplyCoordinate(x: radians[0], y: radians[1])
                            label.selectable = true
                            label.userObject = country
                            countries.append(label)
                        
                        if let capital = country.capital {
                            label = MaplyScreenLabel()
                            radians = country.getCapitalGeoRadians()
                            
                            label.text = "\u{272A} \(capital[Country.Keys.CapitalName]!)"
                            label.loc = MaplyCoordinate(x: radians[0], y: radians[1])
                            label.selectable = false
                            capitals.append(label)
                        }
                        
                    } else {
                        print("anthem not found: \(country.name!)")
                    }
                }
                
                self.mapView!.addScreenLabels(countries, desc: [
                    kMaplyFont: UIFont.boldSystemFont(ofSize: 18.0),
                    kMaplyTextOutlineColor: UIColor.black,
                    kMaplyTextOutlineSize: 2.0,
                    kMaplyColor: UIColor.white
                ])
                
                self.mapView!.addScreenLabels(capitals, desc: [
                    kMaplyFont: UIFont.systemFont(ofSize: 14),
                    kMaplyColor: UIColor.black
                    ])
            }
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
        }) { (error) in
            print(error.localizedDescription)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}

extension MapViewController : MaplyViewControllerDelegate {
    func maplyViewController(_ viewC: MaplyViewController!, didSelect selectedObj: NSObject!) {
        if let selectedObject = selectedObj as? MaplyScreenLabel {
            let country = selectedObject.userObject as? Country
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.performSegue(withIdentifier: "showDetailsFromMapAsPush", sender: country)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                self.performSegue(withIdentifier: "showDetailsFromMapAsModal", sender: country)
            }
        }
    }
    
    func maplyViewController(_ viewC: MaplyViewController!, didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>!, userMotion: Bool) {
        var pos = MaplyCoordinate(x: 0, y: 0)
        var height = Float(0)
        viewC.getPosition(&pos, height: &height)
        
        UserDefaults.standard.set(pos.x, forKey: kLocationLongitude)
        UserDefaults.standard.set(pos.y, forKey: kLocationLatitude)
        UserDefaults.standard.set(height, forKey: kLocationHeight)
        UserDefaults.standard.synchronize()
    }
    
    
}
