//
//  MapViewModel.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/15/23.
//

import Foundation
import CoreLocation

class MapViewModel: NSObject, ObservableObject {
    static let defaultMapViewHeight = Float(0.8)
    static let defaultGlobeViewHeight = Float(1.0)
    static let defaultCountryID = "PH"

    @Published var countries = [FCCountry]()
    @Published var selectedCountry: FCCountry? = nil
    @Published var highlightedCountry: FCCountry? = nil
    @Published var longitude = Float(0)
    @Published var latitude = Float(0)
    @Published var isBusy = false
    @Published var error: Error?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()

        #if targetEnvironment(simulator)
        longitude = Float((DefaultLocationLongitude * Float.pi)/180)
        latitude = Float((DefaultLocationLatitude * Float.pi)/180)
        #else
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
                self.error = error
            }
        }
    }
    
    func requestLocation() {
        #if !targetEnvironment(simulator)
        locationManager.startUpdatingLocation()
        #endif
    }
    
    func searchResults(searchText: String) -> [String: [FCCountry]] {
        var results = [String: [FCCountry]]()
        let countries = searchText.isEmpty ? countries :
            self.countries.filter { country in
                let text = searchText.lowercased()
                let name = (country.name ?? "").lowercased()
                let capital = (country.capital?[FCCountry.Keys.CapitalName] as? String ?? "").lowercased()
                
                if text.count == 1 {
                    return name.starts(with: text) || capital.starts(with: text)
                } else {
                    return name.contains(text) || capital.contains(text)
                }
            }
        
        for country in countries {
            if let name = country.name,
               !name.isEmpty {
                let key = String(name.prefix(1))
                
                var array = results[key] ?? [FCCountry]()
                array.append(country)
                results[key] = array
            }
        }

        return results
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }

        // Convert to radians
        longitude = Float((locValue.longitude * Double.pi)/180)
        latitude = Float((locValue.latitude * Double.pi)/180)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
}
