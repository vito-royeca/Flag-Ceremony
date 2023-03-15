//
//  GlobeView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI
import WhirlyGlobe

struct GlobeView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = GlobeVC
    @EnvironmentObject var geodata: Geodata

    func makeUIViewController(context: Context) -> GlobeVC {
        let globeVC = GlobeVC(mbTilesFetcher: geodata.mbTilesFetcher)
        globeVC.globe?.delegate = context.coordinator
        
        return globeVC
    }

    func updateUIViewController(_ uiViewController: GlobeVC, context: Context) {
        guard let globe = uiViewController.globe else {
            return
        }
        
        var position = MaplyCoordinate(x: 0, y: 0)
        var height = Float(0)
        
        globe.getPosition(&position, height: &height)
        
        if position.x != geodata.location.x ||
           position.y != geodata.location.y ||
            height != geodata.height - 0.2 {
            globe.animate(toPosition: geodata.location,
                          height: geodata.height + 0.2,
                          heading: globe.heading,
                          time: 1.0)
        }
    }
    
    func makeCoordinator() -> GlobeView.Coordinator {
        return Coordinator(self)
    }
}


struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        GlobeView().environmentObject(Geodata())
    }
}

extension GlobeView {
    class Coordinator: NSObject, WhirlyGlobeViewControllerDelegate {
        var parent: GlobeView

        init(_ parent: GlobeView) {
            self.parent = parent
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didSelect selectedObj: NSObject) {
            
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didSelect selectedObj: NSObject, atLoc coord: MaplyCoordinate, onScreen screenPt: CGPoint) {
            
        }
        
        func globeViewController(_ viewC: WhirlyGlobeViewController, allSelect selectedObjs: [Any], atLoc coord: MaplyCoordinate, onScreen screenPt: CGPoint) {
            
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didTapAt coord: MaplyCoordinate) {
            
        }

        func globeViewControllerDidStartMoving(_ viewC: WhirlyGlobeViewController, userMotion: Bool) {
            
        }


        func globeViewController(_ viewC: WhirlyGlobeViewController, didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>, userMotion: Bool) {
            var position = MaplyCoordinate(x: 0, y: 0)
            var height = Float(0)

            viewC.getPosition(&position, height: &height)
            parent.geodata.location = position
            parent.geodata.height = height + 0.2
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didMove corners: UnsafeMutablePointer<MaplyCoordinate>) {
            
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didTap annotation: MaplyAnnotation) {
            
        }
    }
}

// MARK: - GlobeVC

class GlobeVC: UIViewController {
    var globe: WhirlyGlobeViewController?
    var imageLoader : MaplyQuadImageLoader?
    var mbTilesFetcher: MaplyMBTileFetcher?

    convenience init(mbTilesFetcher: MaplyMBTileFetcher?) {
        self.init()
        self.mbTilesFetcher = mbTilesFetcher
        globe = WhirlyGlobeViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        configureGlobe()
    }
    
    func configureGlobe() {
        guard let mbTilesFetcher = mbTilesFetcher else {
            return
        }
        
        self.view.addSubview(globe!.view)
        globe!.view.frame = self.view.bounds
        addChild(globe!)
        
        // Sampling parameters define how we break down the globe
        let sampleParams = MaplySamplingParams()
        sampleParams.coordSys = mbTilesFetcher.coordSys()
        sampleParams.coverPoles = true
        sampleParams.edgeMatching = true
        sampleParams.minZoom = mbTilesFetcher.minZoom()
        sampleParams.maxZoom = mbTilesFetcher.maxZoom()
        sampleParams.singleLevel = true

        imageLoader = MaplyQuadImageLoader(params: sampleParams,
            tileInfo: mbTilesFetcher.tileInfo(),
            viewC: globe!)
        imageLoader!.setTileFetcher(mbTilesFetcher)
        imageLoader!.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault

        globe!.clearColor = UIColor.black
        globe!.frameInterval = 2
        globe!.height = 1.0
    }
}
