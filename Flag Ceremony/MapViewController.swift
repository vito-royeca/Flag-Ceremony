//
//  MapViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
//import Firebase
import MBProgressHUD
import WhirlyGlobe

class MapViewController: UIViewController {
    // MARK: Variables
    var mapView: MaplyViewController?
    var countryLabels = [MaplyScreenLabel]()
    var capitalLabels = [MaplyScreenLabel]()
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let lon = UserDefaults.standard.value(forKey: kLocationLongitude) as? Float,
            let lat = UserDefaults.standard.value(forKey: kLocationLatitude) as? Float,
            let height = UserDefaults.standard.value(forKey: kLocationHeight) as? Float {
            let position = MaplyCoordinateMake(lon, lat)
            mapView!.height = height
            mapView!.animate(toPosition: position, time: 1.0)
        }

        addFlags()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsAsPush" ||
            segue.identifier == "showDetailsAsModal" {
            
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
        
        // set default position
        let lon = (DefaultLocationLongitude * Float.pi)/180
        let lat = (DefaultLocationLatitude * Float.pi)/180
        let position = MaplyCoordinateMake(lon, lat)
        mapView!.height = DefaultLocationHeight
        mapView!.animate(toPosition: position, time: 1.0)
    }
    
    func addFlags() {
        if countryLabels.count > 0 &&
            capitalLabels.count > 0 {
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        FirebaseManager.sharedInstance.fetchAllCountries(completion: { (countries: [Country], error: NSError?) in
            if let _ = error {
                MBProgressHUD.hide(for: self.view, animated: true)
            
            } else {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    self.mapView!.remove(self.countryLabels)
                    self.mapView!.remove(self.capitalLabels)
                    self.countryLabels.removeAll()
                    self.capitalLabels.removeAll()

                    for country in countries {
                        // add flags only if there is an anthem and flag files
                        if let _ = country.getAudioURL(),
                            let _ = country.getFlagURLForSize(size: .mini) {
                            var label = MaplyScreenLabel()
                            var radians = country.getGeoRadians()
                            
                            label.text = "\(country.emojiFlag())\(country.name!)"
                            label.loc = MaplyCoordinate(x: radians[0], y: radians[1])
                            label.selectable = true
                            label.userObject = country
                            label.layoutImportance = 1
                            self.countryLabels.append(label)
                            
                            if let capital = country.capital {
                                label = MaplyScreenLabel()
                                radians = country.getCapitalGeoRadians()
                                
                                label.text = "\u{272A} \(capital[Country.Keys.CapitalName]!)"
                                label.loc = MaplyCoordinate(x: radians[0], y: radians[1])
                                label.selectable = false
                                self.capitalLabels.append(label)
                            }
                            
                        } else {
                            print("anthem not found: \(country.name!)")
                        }
                    }
                    
                    self.mapView!.addScreenLabels(self.countryLabels, desc: [
                        kMaplyFont: UIFont.boldSystemFont(ofSize: 18.0),
                        kMaplyTextOutlineColor: UIColor.black,
                        kMaplyTextOutlineSize: 2.0,
                        kMaplyColor: UIColor.white
                        ])
                    
                    self.mapView!.addScreenLabels(self.capitalLabels, desc: [
                        kMaplyFont: UIFont.systemFont(ofSize: 14),
                        kMaplyTextColor: UIColor.white
                        ])
                    
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                }
            }
        })
    }
}

extension MapViewController : MaplyViewControllerDelegate {
    func maplyViewController(_ viewC: MaplyViewController!, didSelect selectedObj: NSObject!) {
        if let selectedObject = selectedObj as? MaplyScreenLabel {
            let country = selectedObject.userObject as? Country
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.performSegue(withIdentifier: "showDetailsAsPush", sender: country)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                self.performSegue(withIdentifier: "showDetailsAsModal", sender: country)
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
