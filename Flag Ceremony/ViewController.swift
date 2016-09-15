//
//  ViewController.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 14/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import WhirlyGlobe

class ViewController: UIViewController {

    // MARK: Variables
    var globeView: WhirlyGlobeViewController?
    var mapView: MaplyViewController?

    
    // MARK: Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var displayView: UIView!
    
    // MARK: Actions
    @IBAction func segmentedAction(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            showMap()
        case 1:
            showGlobe()
        default:
            ()
        }
        
        addCountries()
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        showMap()
        addCountries()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK Custom methods
    func showGlobe() {
        if let mapView = mapView {
            mapView.view.removeFromSuperview()
        }
        
        if globeView == nil {
            globeView = WhirlyGlobeViewController()
            globeView!.clearColor = UIColor.blackColor()
        }
        displayView.addSubview(globeView!.view)
        globeView!.view.frame = displayView.bounds
        
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
    
    func showMap() {
        if let globeView = globeView {
            globeView.view.removeFromSuperview()
        }
        
        if mapView == nil {
            mapView = MaplyViewController()
            mapView!.clearColor = UIColor.whiteColor()
        }
        displayView.addSubview(mapView!.view)
        mapView!.view.frame = displayView.bounds
        
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
    
    func addCountries() {
        // handle this in another thread
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(queue) {
            let bundle = NSBundle.mainBundle()
            let allOutlines = bundle.pathsForResourcesOfType("geojson", inDirectory: "country_json_50m")
            let vectorDict = [
                kMaplyColor: UIColor.whiteColor(),
                kMaplySelectable: true,
                kMaplyVecWidth: 4.0]
            
            var flags = [MaplyScreenMarker]()
            
            for outline in allOutlines {
                if let jsonData = NSData(contentsOfFile: outline),
                    wgVecObj = MaplyVectorObject(fromGeoJSON: jsonData) {
                    // the admin tag from the country outline geojson has the country name ­ save
                    if let attrs = wgVecObj.attributes,
                        vecName = attrs.objectForKey("ADMIN") as? NSObject {
                        wgVecObj.userObject = vecName
                    
                    
                        
                        if vecName.description.characters.count > 0 {
                            // add outline and label
//                            let label = MaplyScreenLabel()
//                            label.text = vecName.description
//                            label.loc = wgVecObj.center()
//                            label.selectable = true
//                            let desc = [
//                                kMaplyFont: UIFont.boldSystemFontOfSize(14.0),
//                                kMaplyTextOutlineColor: UIColor.blackColor(),
//                                kMaplyTextOutlineSize: 2.0,
//                                kMaplyColor: UIColor.whiteColor()]
//                            
//                            switch self.segmentedControl.selectedSegmentIndex {
//                            case 0:
//                                // If you ever intend to remove these, keep track of the MaplyComponentObjects.
//                                self.mapView!.addVectors([wgVecObj], desc: vectorDict)
//                                self.mapView!.addScreenLabels([label], desc: desc)
//                            case 1:
//                                // If you ever intend to remove these, keep track of the MaplyComponentObjects.
//                                self.globeView!.addVectors([wgVecObj], desc: vectorDict)
//                                self.globeView!.addScreenLabels([label], desc: desc)
//                            default:
//                                ()
//                            }
                            
                            var cc:String?
                            
                            if let isoA2 = attrs["ISO_A2"] as? String {
                                cc = isoA2.lowercaseString
                                
                            }
                            if cc == "-99" {
                                if let postal = attrs["POSTAL"] as? String {
                                    cc = postal.lowercaseString
                                }
                            }
                            print("\(cc!)")
                            
                            
                            if let cc = cc {
                                if let flag = UIImage(contentsOfFile: bundle.pathForResource(cc, ofType: "png", inDirectory: "data/flags/mini") ?? "") {
                                    
                                    let marker = MaplyScreenMarker()
                                    marker.image = flag
                                    marker.loc = wgVecObj.center()
                                    marker.size = flag.size
                                    
                                    flags.append(marker)
                                } else {
                                    print("not found: \(cc)")
                                }
                            }
                        }
                    }
                }
            }
            
            switch self.segmentedControl.selectedSegmentIndex {
            case 0:
                self.mapView!.addScreenMarkers(flags, desc: nil)
            case 1:
                self.globeView!.addScreenMarkers(flags, desc: nil)
            default:
                ()
            }
        }
    }
}

