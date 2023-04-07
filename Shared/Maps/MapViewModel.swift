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
    
    var mbTilesFetcher = MaplyMBTileFetcher(mbTiles: "geography-class_medres")
    private let locationManager = CLLocationManager()
    
    @Published var countries = [FCCountry]()
    @Published var location = defaultLocation
    @Published var highleightedCountry: FCCountry?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
    }
    
    func fetchAllCountries() {
        if countries.isEmpty {
            FirebaseManager.sharedInstance.fetchAllCountries(completion: { [weak self] (countries: [FCCountry]) in
                self?.countries = countries.filter({ $0.getFlagURL() != nil })
            })
        }
    }
    
    func requestLocation() {
        locationManager.startUpdatingLocation()
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
