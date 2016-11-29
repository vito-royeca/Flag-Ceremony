//
//  GlobeViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import WhirlyGlobe

class GlobeViewController: UIViewController {

    // MARK: Variables
    var globeView: WhirlyGlobeViewController?
    var countryLabels = [MaplyScreenLabel]()
    var capitalLabels = [MaplyScreenLabel]()
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initGlobe()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let lon = UserDefaults.standard.value(forKey: kLocationLongitude) as? Float,
            let lat = UserDefaults.standard.value(forKey: kLocationLatitude) as? Float,
            let height = UserDefaults.standard.value(forKey: kLocationHeight) as? Float {
            let position = MaplyCoordinateMake(lon, lat)
            globeView!.height = height
            globeView!.heading = 0
            globeView!.animate(toPosition: position, time: 1.0)
            globeView!.heading = DefaultLocationHeading
        }
        
        addFlags()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARL: Custom methods
    func initGlobe() {
        globeView = WhirlyGlobeViewController()
        globeView!.clearColor = UIColor.black
        globeView!.frameInterval = 2
        globeView!.delegate = self
        globeView!.heading = DefaultLocationHeading
        view.addSubview(globeView!.view)
        globeView!.view.frame = view.bounds
        addChildViewController(globeView!)
        
        
        // set up the data source
        if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres") {
            let layer = MaplyQuadImageTilesLayer(coordSystem: tileSource.coordSys, tileSource: tileSource)
            layer?.handleEdges = true
            layer?.coverPoles = true
            layer?.requireElev = false
            layer?.waitLoad = false
            layer?.drawPriority = 0
            layer?.singleLevelLoading = false
            globeView!.add(layer)
        }
        
        // set default position
        let lon = (DefaultLocationLongitude * Float.pi)/180
        let lat = (DefaultLocationLatitude * Float.pi)/180
        let position = MaplyCoordinateMake(lon, lat)
        globeView!.height = DefaultLocationHeight
        globeView!.heading = 0
        globeView!.setPosition(position)
        globeView!.heading = DefaultLocationHeading
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
                    self.globeView!.remove(self.countryLabels)
                    self.globeView!.remove(self.capitalLabels)
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
                    
                    self.globeView!.addScreenLabels(self.countryLabels, desc: [
                        kMaplyFont: UIFont.boldSystemFont(ofSize: 18.0),
                        kMaplyTextOutlineColor: UIColor.black,
                        kMaplyTextOutlineSize: 2.0,
                        kMaplyColor: UIColor.white
                        ])
                    
                    self.globeView!.addScreenLabels(self.capitalLabels, desc: [
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

extension GlobeViewController : WhirlyGlobeViewControllerDelegate {
    func globeViewController(_ viewC: WhirlyGlobeViewController!, didSelect selectedObj: NSObject!) {
        if let selectedObject = selectedObj as? MaplyScreenLabel {
            let country = selectedObject.userObject as? Country
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.performSegue(withIdentifier: "showDetailsAsPush", sender: country)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                self.performSegue(withIdentifier: "showDetailsAsModal", sender: country)
            }
        }
    }
    
    func globeViewController(_ viewC: WhirlyGlobeViewController!, didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>!, userMotion: Bool) {
        var pos = MaplyCoordinate(x: 0, y: 0)
        var height = Float(0)
        viewC.getPosition(&pos, height: &height)
        
        UserDefaults.standard.set(pos.x, forKey: kLocationLongitude)
        UserDefaults.standard.set(pos.y, forKey: kLocationLatitude)
        UserDefaults.standard.set(height, forKey: kLocationHeight)
        UserDefaults.standard.synchronize()
    }
    
}
