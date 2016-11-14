//
//  MapViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import DATAStack
import DATASource
import WhirlyGlobe

class MapViewController: UIViewController {
    // MARK: Variables
    var mapView: MaplyViewController?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initMap()

//        addFlags()
        API.sharedInstance.fetchCountries(completion: {(error: NSError?) in
            if let error = error {
                print("error: \(error)")
            }
            self.addFlagsFromDB()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsFromMapAsPush" ||
            segue.identifier == "showDetailsFromMapAsModal" {
            
            if let nav = segue.destination as? UINavigationController {
                if let detailsVC = nav.childViewControllers.first {
                    detailsVC.navigationItem.title = sender as? String
                }
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
        
        // start up over Madrid, center of the old-world
        mapView!.height = 0.8
        mapView!.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
    }
    
    func addFlags() {
        // handle this in another thread
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
        queue.async {
            let bundle = Bundle.main
            let allOutlines = bundle.paths(forResourcesOfType: "geojson", inDirectory: "country_json_50m")
            var flags = [MaplyScreenMarker]()
            
            for outline in allOutlines {
                if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: outline)),
                    let wgVecObj = MaplyVectorObject(fromGeoJSON: jsonData) {
                    // the admin tag from the country outline geojson has the country name ­ save
                    if let attrs = wgVecObj.attributes,
                        let vecName = attrs.object(forKey: "ADMIN") as? NSObject {
                        wgVecObj.userObject = vecName
                        
                        if vecName.description.characters.count > 0 {
                            var cc:String?
                            
                            if let isoA2 = attrs["ISO_A2"] as? String {
                                cc = isoA2.lowercased()
                                
                            }
                            
                            if let cc = cc {
                                if let flag = UIImage(contentsOfFile: bundle.path(forResource: cc, ofType: "png", inDirectory: "data/flags/mini") ?? "") {
                                    
                                    let marker = MaplyScreenMarker()
                                    marker.image = flag
                                    marker.loc = wgVecObj.center()
                                    marker.size = flag.size
                                    marker.userObject = attrs["NAME"]
                                    
                                    flags.append(marker)
                                } else {
                                    print("not found: \(cc)")
                                }
                            }
                        }
                    }
                }
            }
            
            self.mapView!.addScreenMarkers(flags, desc: nil)
        }
    }
    
    func addFlagsFromDB() {
        // handle this in another thread
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
        queue.async {
            let bundle = Bundle.main
            let dir = "data/flags/mini"
            let imageType = "png"
            var flags = [MaplyScreenMarker]()
            
            var countries:[Country]?
            let newRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Country")
            newRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            do {
                try countries = API.sharedInstance.dataStack.mainContext.fetch(newRequest) as? [Country]
                
                for country in countries! {
                    if let countryCodes = country.getCountryCodes(),
                        let geoPt = country.getGeoPt() {
                        var flagFound = false
                        
                        for (_,value) in countryCodes {
                            if let value = value as? String {
                                if let path = bundle.path(forResource: value.lowercased(), ofType: imageType, inDirectory: dir) {
                                    
                                    let image = UIImage(contentsOfFile: path)
                                    let marker = MaplyScreenMarker()
                                    marker.image = image
//                                    Radians = Degrees * PI / 180
//                                    Degrees = Radians * 180 / PI
                                    marker.loc = MaplyCoordinate(x: (geoPt[1] * Float.pi)/180, y: (geoPt[0] * Float.pi)/180)
                                    marker.size = image!.size
                                    marker.userObject = country.name
                                    flags.append(marker)
                                    flagFound = true
                                    break
                                }
                            }
                        }
                        
                        if !flagFound {
                            print("flag not found: \(country.name!)")
                        }
                    }

                }
            } catch {
                print("error: \(error)")
            }
            
            self.mapView!.addScreenMarkers(flags, desc: nil)
        }
    }
}

extension MapViewController : MaplyViewControllerDelegate {
    func maplyViewController(_ viewC: MaplyViewController!, didSelect selectedObj: NSObject!) {
        if let selectedObject = selectedObj as? MaplyScreenMarker {
            let title = selectedObject.userObject as? String
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.performSegue(withIdentifier: "showDetailsFromMapAsPush", sender: title)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                self.performSegue(withIdentifier: "showDetailsFromMapAsModal", sender: title)
            }
        }
    }
}
