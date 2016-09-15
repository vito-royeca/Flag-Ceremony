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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailsFromGlobeAsPush" ||
            segue.identifier == "showDetailsFromGlobeAsModal" {
            
            if let nav = segue.destinationViewController as? UINavigationController {
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
        globeView!.clearColor = UIColor.blackColor()
        view.addSubview(globeView!.view)
        globeView!.view.frame = view.bounds
        addChildViewController(globeView!)
        globeView!.delegate = self
        
        // set up the data source
        if let tileSource = MaplyMBTileSource(MBTiles: "geography-class_medres") {
            let layer = MaplyQuadImageTilesLayer(coordSystem: tileSource.coordSys, tileSource: tileSource)
            layer.handleEdges = true
            layer.coverPoles = true
            layer.requireElev = false
            layer.waitLoad = false
            layer.drawPriority = 0
            layer.singleLevelLoading = false
            globeView!.addLayer(layer)
        }
        
        // start up over Madrid, center of the old-world
        globeView!.height = 0.8
        globeView!.animateToPosition(MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
    }
    
    func addFlags() {
        // handle this in another thread
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(queue) {
            let bundle = NSBundle.mainBundle()
            let allOutlines = bundle.pathsForResourcesOfType("geojson", inDirectory: "country_json_50m")
            var flags = [MaplyScreenMarker]()
            
            for outline in allOutlines {
                if let jsonData = NSData(contentsOfFile: outline),
                    wgVecObj = MaplyVectorObject(fromGeoJSON: jsonData) {
                    // the admin tag from the country outline geojson has the country name ­ save
                    if let attrs = wgVecObj.attributes,
                        vecName = attrs.objectForKey("ADMIN") as? NSObject {
                        wgVecObj.userObject = vecName
                        
                        if vecName.description.characters.count > 0 {
                            var cc:String?
                            
                            if let isoA2 = attrs["ISO_A2"] as? String {
                                cc = isoA2.lowercaseString
                                
                            }
                            
                            if let cc = cc {
                                if let flag = UIImage(contentsOfFile: bundle.pathForResource(cc, ofType: "png", inDirectory: "data/flags/mini") ?? "") {
                                    
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
    func globeViewController(viewC: WhirlyGlobeViewController!, didSelect selectedObj: NSObject!) {
        if let selectedObject = selectedObj as? MaplyScreenMarker {
            let title = selectedObject.userObject as? String
            
//            viewC.clearAnnotations()
//            let a = MaplyAnnotation()
//            a.title = title
//            viewC.addAnnotation(a, forPoint: selectedObject.loc, offset: CGPointZero)
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                self.performSegueWithIdentifier("showDetailsGlobeMapAsPush", sender: title)
            } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                self.performSegueWithIdentifier("showDetailsFromGlobeAsModal", sender: title)
            }
        }
    }
}
