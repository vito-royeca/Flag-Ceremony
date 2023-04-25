//
//  MapViewModel.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/15/23.
//

import Foundation
import CoreLocation
import WhirlyGlobe

class MapViewModel: NSObject, ObservableObject {
    static let defaultLocation = MaplyCoordinateMakeWithDegrees(DefaultLocationLongitude, DefaultLocationLatitude)
    static let defaultMapViewHeight = Float(0.8)
    static let defaultGlobeViewHeight = Float(1.0)
    static let defaultCountryID = "PH"

    var mbTilesFetcher = MaplyMBTileFetcher(mbTiles: "geography-class_medres")
    private let locationManager = CLLocationManager()
    
    @Published var countries = [FCCountry]()
    @Published var location = defaultLocation
    @Published var highlightedCountry: FCCountry?

    override init() {
        super.init()
        #if !targetEnvironment(simulator)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        #endif
    }

    @MainActor
    func fetchAllCountries() {
        Task {
            do {
                if countries.isEmpty {
                    countries = try await FirebaseManager.sharedInstance.fetchAllCountries().filter({ $0.getFlagURL() != nil })
                }
            } catch let error {
                
            }
        }
    }
    
    func requestLocation() {
        #if targetEnvironment(simulator)
        location = MapViewModel.defaultLocation
        #else
        locationManager.startUpdatingLocation()
        #endif
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        
        location = MaplyCoordinateMakeWithDegrees(Float(locValue.longitude), Float(locValue.latitude))
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
