//
//  FirebaseManager.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 23/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager : NSObject {
    var queries = [String: FIRDatabaseQuery]()
    var online = false
    let connectionRef = FIRDatabase.database().reference(withPath: ".info/connected")
    
    func incrementCountryViews(_ key: String) {
        let ref = FIRDatabase.database().reference().child("countries").child(key)
        
        ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : Any] {
                
                var views = post[Country.Keys.Views] as? Int ?? 0
                views += 1
                post[Country.Keys.Views] = views
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func incrementCountryPlays(_ key: String) {
        let ref = FIRDatabase.database().reference().child("countries").child(key)
        
        ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : Any] {
                
                var plays = post[Country.Keys.Plays] as? Int ?? 0
                plays += 1
                post[Country.Keys.Plays] = plays
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func findAnthem(_ key: String, completion: @escaping (Anthem?) -> Void) {
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                let anthem = FIRDatabase.database().reference().child("anthems").child(key)
                anthem.observeSingleEvent(of: .value, with: { (snapshot) in
                    var a:Anthem?
                    
                    if let _ = snapshot.value as? [String: Any] {
                         a = Anthem(snapshot: snapshot)
                    }
                    completion(a)
                })
            } else {
                // read the bundled json instead
                if let path = Bundle.main.path(forResource: "flag-ceremony-export", ofType: "json", inDirectory: "data") {
                    if FileManager.default.fileExists(atPath: path) {
                        do {
                            let data = try Data(contentsOf: URL(fileURLWithPath: path))
                            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: [String: [String: Any]]] {
                                
                                var a:Anthem?
                                
                                if let dict = json["anthems"] {
                                    if let anthem = dict[key] {
                                        a = Anthem(key: key, dict: anthem)
                                    }
                                }
                                completion(a)
                            }
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        })
    }
    
    func fetchAllCountries(completion: @escaping ([Country]) -> Void) {
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            var countries = [Country]()
            
            if let connected = snapshot.value as? Bool, connected {
                let ref = FIRDatabase.database().reference()
                ref.child("countries").queryOrdered(byChild: "Name").observeSingleEvent(of: .value, with: { (snapshot) in
                    for child in snapshot.children {
                        if let c = child as? FIRDataSnapshot {
                            countries.append(Country(snapshot: c))
                        }
                    }
                    completion(countries)
                })
            } else {
                // read the bundled json instead
                if let path = Bundle.main.path(forResource: "flag-ceremony-export", ofType: "json", inDirectory: "data") {
                    if FileManager.default.fileExists(atPath: path) {
                        do {
                            let data = try Data(contentsOf: URL(fileURLWithPath: path))
                            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: [String: [String: Any]]] {
                                
                                
                                if let dict = json["countries"] {
                                    for (key,value) in dict {
                                        let country = Country(key: key, dict: value)
                                        countries.append(country)
                                    }
                                }
                                
                                countries.sort { $0.name! < $1.name! }
                            }
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
                
                completion(countries)
            }
        })
    }
    
    func findCountry(_ key: String, completion: @escaping (Country?) -> Void) {
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                let anthem = FIRDatabase.database().reference().child("countries").child(key)
                anthem.observeSingleEvent(of: .value, with: { (snapshot) in
                    var a:Country?
                    
                    if let _ = snapshot.value as? [String: Any] {
                        a = Country(snapshot: snapshot)
                    }
                    completion(a)
                })
            } else {
                // read the bundled json instead
                if let path = Bundle.main.path(forResource: "flag-ceremony-export", ofType: "json", inDirectory: "data") {
                    if FileManager.default.fileExists(atPath: path) {
                        do {
                            let data = try Data(contentsOf: URL(fileURLWithPath: path))
                            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: [String: [String: Any]]] {
                                
                                var a:Country?
                                
                                if let dict = json["countries"] {
                                    if let country = dict[key] {
                                        a = Country(key: key, dict: country)
                                    }
                                }
                                completion(a)
                            }
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        })
    }
    
    func monitorTopViewed(completion: @escaping ([Country]) -> Void) {
        let ref = FIRDatabase.database().reference().child("countries")
        let query = ref.queryOrdered(byChild: Country.Keys.Views).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var countries = [Country]()
            
            for child in snapshot.children {
                if let c = child as? FIRDataSnapshot {
                    countries.append(Country(snapshot: c))
                }
            }
            completion(countries.reversed())
        })
       
        queries["topViewed"] = query
    }
    
    func monitorTopPlayed(completion: @escaping ([Country]) -> Void) {
        let ref = FIRDatabase.database().reference().child("countries")
        let query = ref.queryOrdered(byChild: Country.Keys.Plays).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var countries = [Country]()
            
            for child in snapshot.children {
                if let c = child as? FIRDataSnapshot {
                    countries.append(Country(snapshot: c))
                }
            }
            completion(countries.reversed())
        })
        
        queries["topPlayed"] = query
    }
    
    func demonitorTopCharts() {
        if let query = queries["topViewed"] {
            query.removeAllObservers()
            queries["topViewed"] = nil
        }
        
        if let query = queries["topPlayed"] {
            query.removeAllObservers()
            queries["topPlayed"] = nil
        }
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = FirebaseManager()
}
