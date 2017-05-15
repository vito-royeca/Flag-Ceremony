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
    
    func updateUser(email: String?, photoURL: URL?, displayName: String?) {
        if let user = FIRAuth.auth()?.currentUser {
            let ref = FIRDatabase.database().reference().child("users").child(user.uid)
            
            ref.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                var post = currentData.value as? [String : Any] ?? [String : Any]()
                var providerData = [String]()
                for pd in user.providerData {
                    providerData.append(pd.providerID)
                }
                
                post[User.Keys.Email] = email ?? ""
                post[User.Keys.PhotoURL] = photoURL?.absoluteString ?? ""
                post[User.Keys.DisplayName] = displayName ?? ""
                post[User.Keys.ProviderData] = providerData
                
                // Set value and report transaction success
                currentData.value = post
                return FIRTransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
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
        
        if let user = FIRAuth.auth()?.currentUser {
            let ref2 = FIRDatabase.database().reference().child("activities").child(user.uid)
            
            ref2.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                var post = currentData.value as? [String : Any] ?? [String : Any]()
                    
                var viewCount = post[Activity.Keys.ViewCount] as? Int ?? 0
                viewCount += 1
                post[Activity.Keys.ViewCount] = viewCount
             
                var views = post[Activity.Keys.Views] as? [String : Any] ?? [String : Any]()
                var keyCount = views[key] as? Int ?? 0
                keyCount += 1
                views[key] = keyCount
                post[Activity.Keys.Views] = views
                
                // Set value and report transaction success
                currentData.value = post
                return FIRTransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
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
        
        if let user = FIRAuth.auth()?.currentUser {
            let ref2 = FIRDatabase.database().reference().child("activities").child(user.uid)
            
            ref2.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                var post = currentData.value as? [String : Any] ?? [String : Any]()
                    
                var playCount = post[Activity.Keys.PlayCount] as? Int ?? 0
                playCount += 1
                post[Activity.Keys.PlayCount] = playCount
                
                var plays = post[Activity.Keys.Plays] as? [String : Any] ?? [String : Any]()
                var keyCount = plays[key] as? Int ?? 0
                keyCount += 1
                plays[key] = keyCount
                post[Activity.Keys.Plays] = plays
                
                // Set value and report transaction success
                currentData.value = post
                return FIRTransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func findAnthem(_ key: String, completion: @escaping (Anthem?) -> Void) {
        // read the bundled json
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
            
        } else { // look it up in Firebase
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
                }
            })
        }
    }
    
    func fetchAllCountries(completion: @escaping ([Country]) -> Void) {
        var countries = [Country]()
        
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
                        completion(countries)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
        } else {
            let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
            
            connectedRef.observe(.value, with: { snapshot in
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
                }
            })
        }
    }
    
    func findCountry(_ key: String, completion: @escaping (Country?) -> Void) {
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
        
        } else {
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
                }
            })
        }
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
    
    func monitorTopViewers(completion: @escaping ([Activity]) -> Void) {
        let ref = FIRDatabase.database().reference().child("activities")
        let query = ref.queryOrdered(byChild: Activity.Keys.ViewCount).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var activities = [Activity]()
            
            for child in snapshot.children {
                if let c = child as? FIRDataSnapshot {
                    activities.append(Activity(snapshot: c))
                }
            }
            completion(activities.reversed())
        })
        
        queries["topViewers"] = query
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
    
    func monitorTopPlayers(completion: @escaping ([Activity]) -> Void) {
        let ref = FIRDatabase.database().reference().child("activities")
        let query = ref.queryOrdered(byChild: Activity.Keys.PlayCount).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var activities = [Activity]()
            
            for child in snapshot.children {
                if let c = child as? FIRDataSnapshot {
                    activities.append(Activity(snapshot: c))
                }
            }
            completion(activities.reversed())
        })
        
        queries["topPlayers"] = query
    }
    
    func monitorUsers(completion: @escaping ([User]) -> Void) {
        let ref = FIRDatabase.database().reference().child("users")
        let query = ref.queryOrderedByKey()
        query.observe(.value, with: { snapshot in
            var users = [User]()
            
            for child in snapshot.children {
                if let c = child as? FIRDataSnapshot {
                    users.append(User(snapshot: c))
                }
            }
            completion(users)
        })
    }
    
    func monitorUserData(completion: @escaping (Activity?) -> Void) {
        if let user = FIRAuth.auth()?.currentUser {
            let ref = FIRDatabase.database().reference().child("activities").child(user.uid)
            let query = ref.queryOrderedByKey()
            query.observe(.value, with: { snapshot in
                let activity = Activity(snapshot: snapshot)
                completion(activity)
            })
            
            queries["userData"] = query
        }
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
        
        if let query = queries["topViewers"] {
            query.removeAllObservers()
            queries["topViewers"] = nil
        }
        
        if let query = queries["topPlayers"] {
            query.removeAllObservers()
            queries["topPlayers"] = nil
        }
        
        if let query = queries["users"] {
            query.removeAllObservers()
            queries["users"] = nil
        }
    }
    
    func demonitorUserData() {
        if let query = queries["userData"] {
            query.removeAllObservers()
            queries["userData"] = nil
        }
    }

    func downloadAnthem(country: Country, completion: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        if let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let anthemsDir = "\(cacheDir)/anthems"
            let localPath = "\(anthemsDir)/\(country.key!.lowercased()).mp3"
            let remotePath = "gs://flag-ceremony.appspot.com/anthems/\(country.key!.lowercased()).mp3"
            let storage = FIRStorage.storage()
            let gsReference = storage.reference(forURL: remotePath)
            
            // create anthems dir if not existing
            if !FileManager.default.fileExists(atPath: anthemsDir) {
                try! FileManager.default.createDirectory(atPath: anthemsDir, withIntermediateDirectories: true, attributes: nil)
            }
            
            gsReference.write(toFile: URL(fileURLWithPath: localPath), completion: { (url: URL?, error: Error?) in
                if let error = error {
                    completion(nil, error)
                } else {
                    completion(url, nil)
                }
            })
        }
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = FirebaseManager()
}
