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

    func makeUIViewController(context: Context) -> GlobeVC {
        let globeVC = GlobeVC()
        globeVC.globe?.delegate = context.coordinator
        
        return globeVC
    }

    func updateUIViewController(_ uiViewController: GlobeVC, context: Context) {

    }
    
    func makeCoordinator() -> GlobeView.Coordinator {
        return Coordinator(self)
    }
}


struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        GlobeView()
    }
}

extension GlobeView {
    class Coordinator: NSObject, WhirlyGlobeViewControllerDelegate {
        var parent: GlobeView

        init(_ parent: GlobeView) {
            self.parent = parent
        }

        
    }
}

class GlobeVC: UIViewController {
    var globe: WhirlyGlobeViewController?
    var mbTilesFetcher : MaplyMBTileFetcher?
    var imageLoader : MaplyQuadImageLoader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        globe = WhirlyGlobeViewController()
        self.view.addSubview(globe!.view)
        globe!.view.frame = self.view.bounds
        addChild(globe!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initGlobe()
    }

    func initGlobe() {
        // Set up an MBTiles file and read the header
        mbTilesFetcher = MaplyMBTileFetcher(mbTiles: "geography-class_medres")

        // Sampling parameters define how we break down the globe
        let sampleParams = MaplySamplingParams()
        sampleParams.coordSys = mbTilesFetcher!.coordSys()
        sampleParams.coverPoles = true
        sampleParams.edgeMatching = true
        sampleParams.minZoom = mbTilesFetcher!.minZoom()
        sampleParams.maxZoom = mbTilesFetcher!.maxZoom()
        sampleParams.singleLevel = true

        if let globe = globe {
            imageLoader = MaplyQuadImageLoader(params: sampleParams,
                tileInfo: mbTilesFetcher!.tileInfo(),
                viewC: globe)
            imageLoader!.setTileFetcher(mbTilesFetcher!)
            imageLoader!.baseDrawPriority = kMaplyImageLayerDrawPriorityDefault

            globe.clearColor = UIColor.black
            globe.frameInterval = 2
            globe.height = 1.0
            globe.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704, 40.5023),
            time: 1.0)
        }
    }
}
