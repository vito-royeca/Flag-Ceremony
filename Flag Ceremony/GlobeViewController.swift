//
//  GlobeViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsFromGlobeAsPush" ||
            segue.identifier == "showDetailsFromGlobeAsModal" {
            
            if let nav = segue.destination as? UINavigationController {
                if let detailsVC = nav.childViewControllers.first {
                    detailsVC.navigationItem.title = sender as? String
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARL: Custom methods
    func initGlobe() {
//        if let globeView = globeView {
//            globeView.view.removeFromSuperview()
//        }
        
        globeView = WhirlyGlobeViewController()
        globeView!.clearColor = UIColor.black
        view.addSubview(globeView!.view)
        globeView!.view.frame = view.bounds
        addChildViewController(globeView!)
        globeView!.delegate = self
        
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
        
        // start up over Madrid, center of the old-world
        globeView!.height = 0.8
        globeView!.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
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
            
            self.globeView!.addScreenMarkers(flags, desc: nil)
        }
    }
}

extension GlobeViewController : WhirlyGlobeViewControllerDelegate {
    func globeViewController(_ viewC: WhirlyGlobeViewController!, didSelect selectedObj: NSObject!) {
        if let selectedObject = selectedObj as? MaplyScreenMarker {
            let title = selectedObject.userObject as? String
            
//            viewC.clearAnnotations()
//            let a = MaplyAnnotation()
//            a.title = title
//            viewC.addAnnotation(a, forPoint: selectedObject.loc, offset: CGPointZero)
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.performSegue(withIdentifier: "showDetailsGlobeMapAsPush", sender: title)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                self.performSegue(withIdentifier: "showDetailsFromGlobeAsModal", sender: title)
            }
        }
    }
}
