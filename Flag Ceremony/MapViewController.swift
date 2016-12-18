//
//  MapViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import MBProgressHUD
import MMDrawerController
import WhirlyGlobe

class MapViewController: UIViewController {
    // MARK: Variables
    var mapView: MaplyViewController?
    var countries = [Country]()
    var countryLabels = [MaplyScreenLabel]()
    var capitalLabels = [MaplyScreenLabel]()
    private var hasShownCountryForScreenshot = false
    
    // MARK: Actions
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        if let navigationVC = mm_drawerController.leftDrawerViewController as? UINavigationController {
            var menuView:MenuViewController?
            
            for drawer in navigationVC.viewControllers {
                if drawer is MenuViewController {
                    menuView = drawer as? MenuViewController
                }
            }
            if menuView == nil {
                menuView = MenuViewController()
                navigationVC.addChildViewController(menuView!)
            }
            
            navigationVC.popToViewController(menuView!, animated: true)
        }
        mm_drawerController.toggle(.left, animated:true, completion:nil)
    }
    
    @IBAction func searchAction(_ sender: UIBarButtonItem) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.performSegue(withIdentifier: "showCountriesAsPush", sender: nil)
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            self.performSegue(withIdentifier: "showCountriesAsPopup", sender: nil)
        }
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initMap()
        addFlags()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showCountry(nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCountrySelected), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.showCountry(_:)), name: NSNotification.Name(rawValue: kCountrySelected), object: nil)
    }

    func showCountryForScreenshot() {
        FirebaseManager.sharedInstance.findCountry(DefaultCountry, completion: { (country) in
            if self.hasShownCountryForScreenshot {
                return
            }
            self.hasShownCountryForScreenshot = true
            UserDefaults.standard.set(country!.getGeoRadians()[0], forKey: kLocationLongitude)
            UserDefaults.standard.set(country!.getGeoRadians()[1], forKey: kLocationLatitude)
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.performSegue(withIdentifier: "showDetailsAsPush", sender: country)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                self.performSegue(withIdentifier: "showDetailsAsModal", sender: country)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCountrySelected), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsAsPush" ||
            segue.identifier == "showDetailsAsModal" {
            
            var countryVC:CountryViewController?
            
            if let nav = segue.destination as? UINavigationController {
                if let vc = nav.childViewControllers.first as? CountryViewController {
                    countryVC = vc
                }
            } else  if let vc = segue.destination as? CountryViewController {
                countryVC = vc
            }
            
            if let countryVC = countryVC {
                countryVC.country = sender as? Country
            }
        } else if segue.identifier == "showCountriesAsPush" ||
            segue.identifier == "showCountriesAsPopup" {
            
            var countryListVC:CountryListViewController?
            
            if let nav = segue.destination as? UINavigationController {
                if let vc = nav.childViewControllers.first as? CountryListViewController {
                    countryListVC = vc
                }
            } else  if let vc = segue.destination as? CountryListViewController {
                countryListVC = vc
            }
            
            if let countryListVC = countryListVC {
                countryListVC.countries = countries
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
        if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres"),
            let layer = MaplyQuadImageTilesLayer(coordSystem: tileSource.coordSys, tileSource: tileSource) {
            layer.handleEdges = false
            layer.coverPoles = false
            layer.requireElev = false
            layer.waitLoad = false
            layer.drawPriority = 0
            layer.singleLevelLoading = false
            mapView!.add(layer)
        }
    }
    
    func addFlags() {
        if countryLabels.count > 0 &&
            capitalLabels.count > 0 {
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        FirebaseManager.sharedInstance.fetchAllCountries(completion: { (countries: [Country]) in
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                self.mapView!.remove(self.countryLabels)
                self.mapView!.remove(self.capitalLabels)
                self.countries.removeAll()
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
                        
                        self.countries.append(country)
                        
                    } else {
//                        print("anthem not found: \(country.name!)")
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
//                    #if SHOW_COUNTRY_4_SCREENSHOT
//                        self.showCountryForScreenshot()
//                    #endif
                }
            }
        })
    }
    
    func showCountry(_ notification: Notification?) {
        var newPosition:MaplyCoordinate?
        var newHeight = Float(0)
        var willGotoNewPosition = false
        
        if let lon = UserDefaults.standard.value(forKey: kLocationLongitude) as? Float,
            let lat = UserDefaults.standard.value(forKey: kLocationLatitude) as? Float,
            let height = UserDefaults.standard.value(forKey: kLocationHeight) as? Float {
            
            if let mapView = mapView {
                var cPosition = MaplyCoordinate(x: 0, y: 0)
                var cHeight = Float(0)
                
                mapView.getPosition(&cPosition, height: &cHeight)
                
                // do not reposition if in the same position
                if lon != cPosition.x ||
                    lat != cPosition.y ||
                    height != cHeight {
                    
                    newPosition = MaplyCoordinateMake(lon, lat)
                    newHeight = height
                    willGotoNewPosition = true
                }
            }
        } else {
            // set default position
            let lon = (DefaultLocationLongitude * Float.pi)/180
            let lat = (DefaultLocationLatitude * Float.pi)/180
            newPosition = MaplyCoordinateMake(lon, lat)
            newHeight = DefaultLocationHeight
            willGotoNewPosition = true
        }
        
        if willGotoNewPosition {
            mapView!.height = newHeight
            mapView!.animate(toPosition: newPosition!, time: 1.0)
        }
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
        var position = MaplyCoordinate(x: 0, y: 0)
        var height = Float(0)
        viewC.getPosition(&position, height: &height)
        
        UserDefaults.standard.set(position.x, forKey: kLocationLongitude)
        UserDefaults.standard.set(position.y, forKey: kLocationLatitude)
        UserDefaults.standard.set(height, forKey: kLocationHeight)
        UserDefaults.standard.synchronize()
    }
    
    
}
