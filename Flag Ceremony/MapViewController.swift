//
//  MapViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 15/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailsFromMapAsPush" ||
            segue.identifier == "showDetailsFromMapAsModal" {
            
            if let nav = segue.destinationViewController as? UINavigationController {
                if let detailsVC = nav.childViewControllers.first {
                    detailsVC.navigationItem.title = sender as? String
                }
            }
        }
    }

    // MARL: Custom methods
    func initMap() {
//        if let mapView = mapView {
//            mapView.view.removeFromSuperview()
//        }
        
        mapView = MaplyViewController()
        mapView!.clearColor = UIColor.whiteColor()
        view.addSubview(mapView!.view)
        mapView!.view.frame = view.bounds
        addChildViewController(mapView!)
        mapView!.delegate = self
        
        // set up the data source
        if let tileSource = MaplyMBTileSource(MBTiles: "geography-class_medres") {
            let layer = MaplyQuadImageTilesLayer(coordSystem: tileSource.coordSys, tileSource: tileSource)
            layer.handleEdges = false
            layer.coverPoles = false
            layer.requireElev = false
            layer.waitLoad = false
            layer.drawPriority = 0
            layer.singleLevelLoading = false
            mapView!.addLayer(layer)
        }
        
        // start up over Madrid, center of the old-world
        mapView!.height = 0.8
        mapView!.animateToPosition(MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
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
            
            self.mapView!.addScreenMarkers(flags, desc: nil)
        }
    }

}

extension MapViewController : MaplyViewControllerDelegate {
    func maplyViewController(viewC: MaplyViewController!, didSelect selectedObj: NSObject!) {
        if let selectedObject = selectedObj as? MaplyScreenMarker {
            let title = selectedObject.userObject as? String
            
//            viewC.clearAnnotations()
//            let a = MaplyAnnotation()
//            a.title = title
//            a.subTitle = subtitle
//            viewC.addAnnotation(a, forPoint: selectedObject.loc, offset: CGPointZero)
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                self.performSegueWithIdentifier("showDetailsFromMapAsPush", sender: title)
            } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                self.performSegueWithIdentifier("showDetailsFromMapAsModal", sender: title)
            }
        }
    }
}
