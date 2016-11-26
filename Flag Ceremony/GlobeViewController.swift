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
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initGlobe()
        addFlags()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let heading = UserDefaults.standard.value(forKey: kLocationHeading) as? Float {
            globeView!.heading = heading
        } else {
            globeView!.heading = DefaultLocationHeading
        }
        
        if let lon = UserDefaults.standard.value(forKey: kLocationLongitude) as? Float,
            let lat = UserDefaults.standard.value(forKey: kLocationLatitude) as? Float,
            let height = UserDefaults.standard.value(forKey: kLocationHeight) as? Float {
            globeView!.height = height
            globeView!.animate(toPosition: MaplyCoordinateMake(lon, lat), time: 1.0)
        } else {
            globeView!.height = DefaultLocationHeight
            globeView!.animate(toPosition: MaplyCoordinateMake(DefaultLocationLongitude, DefaultLocationLatitude), time: 1.0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsFromGlobeAsPush" ||
            segue.identifier == "showDetailsFromGlobeAsModal" {
            
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
//        globeView!.tilt = Float((3.14/2)-23.0)
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
    }
    
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
                
                self.globeView!.addScreenLabels(countries, desc: [
                    kMaplyFont: UIFont.boldSystemFont(ofSize: 18.0),
                    kMaplyTextOutlineColor: UIColor.black,
                    kMaplyTextOutlineSize: 2.0,
                    kMaplyColor: UIColor.white
                    ])
                
                self.globeView!.addScreenLabels(capitals, desc: [
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

extension GlobeViewController : WhirlyGlobeViewControllerDelegate {
    func globeViewController(_ viewC: WhirlyGlobeViewController!, didSelect selectedObj: NSObject!) {
        if let selectedObject = selectedObj as? MaplyScreenLabel {
            let country = selectedObject.userObject as? Country
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.performSegue(withIdentifier: "showDetailsFromGlobeAsPush", sender: country)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                self.performSegue(withIdentifier: "showDetailsFromGlobeAsModal", sender: country)
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
        UserDefaults.standard.set(viewC.heading, forKey: kLocationHeading)
        UserDefaults.standard.synchronize()
    }
    
}
