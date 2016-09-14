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
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        showMap()
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
        
        //        theViewC!.view.frame = self.view.bounds
        //        addChildViewController(theViewC!)
    }
}

