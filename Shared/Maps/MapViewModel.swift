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
    var mbTilesFetcher = MaplyMBTileFetcher(mbTiles: "geography-class_medres")
    private let locationManager = CLLocationManager()
    
    @Published var location = defaultLocation
    @Published var height = Float(0.8)
    @Published var countries = [FCCountry]()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestAlwaysAuthorization()
//        locationManager.startUpdatingLocation()
    }
    
    func fetchAllCountries() {
        if countries.isEmpty {
            FirebaseManager.sharedInstance.fetchAllCountries(completion: { [weak self] (countries: [FCCountry]) in
                self?.countries = countries.filter({ $0.getFlagURL() != nil })
            })
        }
    }
    
    func requestLocation() {
//        if location.distance(from: MapViewModel.defaultLocation) {
//            locationManager.requestAlwaysAuthorization()
//            locationManager.requestWhenInUseAuthorization()
//
//            if CLLocationManager.locationServicesEnabled() {
//                locationManager.delegate = self
//                locationManager.desiredAccuracy = kCLLocationAccuracyReduced
//                locationManager.startUpdatingLocation()
//            }
//        }

        locationManager.startUpdatingLocation()
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        location = MaplyCoordinateMakeWithDegrees(Float(locValue.longitude), Float(locValue.latitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
