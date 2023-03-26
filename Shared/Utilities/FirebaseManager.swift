//
//  FirebaseManager.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 23/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

enum FirebaseError : Error {
    case notLoggedIn
}

class FirebaseManager : NSObject {
    var queries = [String: DatabaseQuery]()
    var online = false
    let connectionRef = Database.database().reference(withPath: ".info/connected")
    
    func fetchUser(completion: @escaping (FCUser?) -> Void) {
        if let user = Auth.auth().currentUser {
            let ref = Database.database().reference().child("users").child(user.uid)

            ref.observe(.value, with: { snapshot in
                completion(FCUser(snapshot: snapshot))
            })
        }
    }

    func updateUser(photoURL: URL?, photoDirty: Bool, displayName: String?, completion: @escaping (Result<Void,Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(FirebaseError.notLoggedIn))
            return
        }

        updatePhoto(photoURL: photoURL, photoDirty: photoDirty) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let url):
                let ref = Database.database().reference().child("users").child(user.uid)
                
                ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                    var post = currentData.value as? [String : Any] ?? [String : Any]()
                    var providerData = [String]()
                    for pd in user.providerData {
                        providerData.append(pd.providerID)
                    }
                    
                    if photoDirty {
                        if let url = url {
                            post[FCUser.Keys.PhotoURL] = url.absoluteString
                        } else {
                            post[FCUser.Keys.PhotoURL] = nil
                        }
                    }
                    post[FCUser.Keys.DisplayName] = displayName ?? ""
                    post[FCUser.Keys.ProviderData] = providerData
                    
                    // Set value and report transaction success
                    currentData.value = post
                    return TransactionResult.success(withValue: currentData)
                    
                }) { (error, committed, snapshot) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    func updatePhoto(photoURL: URL?, photoDirty: Bool, completion: @escaping (Result<URL?,Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(FirebaseError.notLoggedIn))
            return
        }

        if photoDirty {
            let ref = Storage.storage().reference().child("avatars/\(user.uid).png")
            
            if let photoURL = photoURL,
               let image = UIImage(contentsOfFile: photoURL.path),
               let resizedImage = image.resize(to: CGSize(width: 256, height: 256)),
               let data = resizedImage.pngData() {
                
                let meta = StorageMetadata()
                meta.contentType = "image/png"
                
                
                ref.putData(data, metadata: meta) { (metadata, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        ref.downloadURL(completion: { (url, error) in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(url))
                            }
                        })
                    }
                }
            } else {
                ref.delete() { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(nil))
                    }
                }
            }
        } else {
            completion(.success(nil))
        }
    }

    func incrementCountryViews(_ key: String, completion: @escaping (Result<FCCountry?,Error>) -> Void) {
        let ref = Database.database().reference().child("countries").child(key)
        
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : Any] {
                
                var views = post[FCCountry.Keys.Views] as? Int ?? 0
                views += 1
                post[FCCountry.Keys.Views] = views
                
                // Set value and report transaction success
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    completion(.success(FCCountry(snapshot: snapshot)))
                } else {
                    completion(.success(nil))
                }
            }
        }
        
        if let user = Auth.auth().currentUser {
            let ref2 = Database.database().reference().child("activities").child(user.uid)
            
            ref2.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                var post = currentData.value as? [String : Any] ?? [String : Any]()
                    
                var viewCount = post[FCActivity.Keys.ViewCount] as? Int ?? 0
                viewCount += 1
                post[FCActivity.Keys.ViewCount] = viewCount
             
                var views = post[FCActivity.Keys.Views] as? [String : Any] ?? [String : Any]()
                var keyCount = views[key] as? Int ?? 0
                keyCount += 1
                views[key] = keyCount
                post[FCActivity.Keys.Views] = views
                
                // Set value and report transaction success
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func incrementCountryPlays(_ key: String, completion: @escaping (Result<FCCountry?,Error>) -> Void) {
        let ref = Database.database().reference().child("countries").child(key)
        
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : Any] {
                
                var plays = post[FCCountry.Keys.Plays] as? Int ?? 0
                plays += 1
                post[FCCountry.Keys.Plays] = plays
                print("\(key): \(plays)")
                
                // Set value and report transaction success
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    completion(.success(FCCountry(snapshot: snapshot)))
                } else {
                    completion(.success(nil))
                }
            }
        }
        
        if let user = Auth.auth().currentUser {
            let ref2 = Database.database().reference().child("activities").child(user.uid)
            
            ref2.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                var post = currentData.value as? [String : Any] ?? [String : Any]()
                    
                var playCount = post[FCActivity.Keys.PlayCount] as? Int ?? 0
                playCount += 1
                post[FCActivity.Keys.PlayCount] = playCount
                
                var plays = post[FCActivity.Keys.Plays] as? [String : Any] ?? [String : Any]()
                var keyCount = plays[key] as? Int ?? 0
                keyCount += 1
                plays[key] = keyCount
                post[FCActivity.Keys.Plays] = plays
                
                // Set value and report transaction success
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func toggleFavorite(_ key: String, completion: @escaping (Result<Void,Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(FirebaseError.notLoggedIn))
            return
        }
        
        
        let ref = Database.database().reference().child("activities").child(user.uid)
        
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            var post = currentData.value as? [String : Any] ?? [String : Any]()
            var favorites = post[FCActivity.Keys.Favorites] as? [String] ?? [String]()

            if !favorites.contains(key) {
                favorites.append(key)
            } else {
                if let index = favorites.firstIndex(of: key) {
                    favorites.remove(at: index)
                }
            }

            post[FCActivity.Keys.Favorites] = favorites
            
            // Set value and report transaction success
            currentData.value = post
            return TransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
    }
    
    func findAnthem(_ key: String, completion: @escaping (FCAnthem?) -> Void) {
        // read the bundled json
        if let path = Bundle.main.path(forResource: "flag-ceremony-export", ofType: "json") {
            if FileManager.default.fileExists(atPath: path) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    if let json = try JSONSerialization.jsonObject(with: data,
                                                                   options: .allowFragments) as? [String: [String: [String: Any]]] {
                        
                        var a:FCAnthem?
                        
                        if let dict = json["anthems"] {
                            if let anthem = dict[key] {
                                a = FCAnthem(key: key,
                                             dict: anthem)
                            }
                        }
                        completion(a)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
        } else { // look it up in Firebase
            connectionRef.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                    let anthem = Database.database().reference().child("anthems").child(key)
                    anthem.observeSingleEvent(of: .value, with: { (snapshot) in
                        var a:FCAnthem?
                        
                        if let _ = snapshot.value as? [String: Any] {
                            a = FCAnthem(snapshot: snapshot)
                        }
                        completion(a)
                    })
                }
            })
        }
    }
    
    func fetchAllCountries(completion: @escaping ([FCCountry]) -> Void) {
        var countries = [FCCountry]()
        
        // read the bundled json instead
        if let path = Bundle.main.path(forResource: "flag-ceremony-export", ofType: "json") {
            if FileManager.default.fileExists(atPath: path) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    if let json = try JSONSerialization.jsonObject(with: data,
                                                                   options: .allowFragments) as? [String: [String: [String: Any]]] {
                        
                        if let dict = json["countries"] {
                            for (key,value) in dict {
                                let country = FCCountry(key: key,
                                                        dict: value)
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
            let connectedRef = Database.database().reference(withPath: ".info/connected")
            
            connectedRef.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                    let ref = Database.database().reference()
                    ref.child("countries").queryOrdered(byChild: "Name").observeSingleEvent(of: .value,
                                                                                            with: { (snapshot) in
                        for child in snapshot.children {
                            if let c = child as? DataSnapshot {
                                countries.append(FCCountry(snapshot: c))
                            }
                        }
                        completion(countries)
                    })
                }
            })
        }
    }
    
    func findCountries(keys: [String], completion: @escaping ([FCCountry]) -> Void) {
        var countries = [FCCountry]()
        
        // read the bundled json instead
        if let path = Bundle.main.path(forResource: "flag-ceremony-export", ofType: "json") {
            if FileManager.default.fileExists(atPath: path) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    if let json = try JSONSerialization.jsonObject(with: data,
                                                                   options: .allowFragments) as? [String: [String: [String: Any]]] {
                        
                        if let dict = json["countries"] {
                            for (key,value) in dict.filter({ keys.contains($0.key) }) {
                                let country = FCCountry(key: key,
                                                        dict: value)
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
            let connectedRef = Database.database().reference(withPath: ".info/connected")
            
            connectedRef.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                    let ref = Database.database().reference()
                    ref.child("countries").queryOrdered(byChild: "Name").observeSingleEvent(of: .value,
                                                                                            with: { (snapshot) in
                        for child in snapshot.children {
                            if let c = child as? DataSnapshot,
                               keys.contains(c.key) {
                                countries.append(FCCountry(snapshot: c))
                            }
                        }
                        completion(countries)
                    })
                }
            })
        }
    }
    func findCountry(_ key: String, completion: @escaping (FCCountry?) -> Void) {
        if let path = Bundle.main.path(forResource: "flag-ceremony-export", ofType: "json") {
            if FileManager.default.fileExists(atPath: path) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    if let json = try JSONSerialization.jsonObject(with: data,
                                                                   options: .allowFragments) as? [String: [String: [String: Any]]] {

                        var a:FCCountry?

                        if let dict = json["countries"] {
                            if let country = dict[key] {
                                a = FCCountry(key: key, dict: country)
                            }
                        }
                        completion(a)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } else {
            connectionRef.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                    let country = Database.database().reference().child("countries").child(key)
                    country.observeSingleEvent(of: .value, with: { (snapshot) in
                        var a:FCCountry?
                        
                        if let _ = snapshot.value as? [String: Any] {
                            a = FCCountry(snapshot: snapshot)
                        }
                        if let a = a {
                            completion(a)
                        }
                    })
                }
            })
        }
    }
    
    func monitorTopViewed(completion: @escaping ([FCCountry]) -> Void) {
        let ref = Database.database().reference().child("countries")
        let query = ref.queryOrdered(byChild: FCCountry.Keys.Views).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var countries = [FCCountry]()
            
            for child in snapshot.children {
                if let c = child as? DataSnapshot {
                    countries.append(FCCountry(snapshot: c))
                }
            }
            completion(countries.reversed())
        })
       
        queries["topViewed"] = query
    }
    
    func monitorTopViewers(completion: @escaping ([FCActivity]) -> Void) {
        let ref = Database.database().reference().child("activities")
        let query = ref.queryOrdered(byChild: FCActivity.Keys.ViewCount).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var activities = [FCActivity]()
            
            for child in snapshot.children {
                if let c = child as? DataSnapshot {
                    activities.append(FCActivity(snapshot: c))
                }
            }
            completion(activities.reversed())
        })
        
        queries["topViewers"] = query
    }
    
    func monitorTopPlayed(completion: @escaping ([FCCountry]) -> Void) {
        let ref = Database.database().reference().child("countries")
        let query = ref.queryOrdered(byChild: FCCountry.Keys.Plays).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var countries = [FCCountry]()
            
            for child in snapshot.children {
                if let c = child as? DataSnapshot {
                    countries.append(FCCountry(snapshot: c))
                }
            }
            completion(countries.reversed())
        })
        
        queries["topPlayed"] = query
    }
    
    func monitorTopPlayers(completion: @escaping ([FCActivity]) -> Void) {
        let ref = Database.database().reference().child("activities")
        let query = ref.queryOrdered(byChild: FCActivity.Keys.PlayCount).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var activities = [FCActivity]()
            
            for child in snapshot.children {
                if let c = child as? DataSnapshot {
                    activities.append(FCActivity(snapshot: c))
                }
            }
            completion(activities.reversed())
        })
        
        queries["topPlayers"] = query
    }
    
    func monitorUsers(completion: @escaping ([FCUser]) -> Void) {
        let ref = Database.database().reference().child("users")
        let query = ref.queryOrderedByKey()
        query.observe(.value, with: { snapshot in
            var users = [FCUser]()
            
            for child in snapshot.children {
                if let c = child as? DataSnapshot {
                    users.append(FCUser(snapshot: c))
                }
            }
            completion(users)
        })
    }
    
    func monitorUserActivity(completion: @escaping (FCActivity?) -> Void) {
        if let user = Auth.auth().currentUser {
            let ref = Database.database().reference().child("activities").child(user.uid)
            let query = ref.queryOrderedByKey()
            query.observe(.value, with: { snapshot in
                completion(FCActivity(snapshot: snapshot))
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
    
    func demonitorUserActivity() {
        if let query = queries["userData"] {
            query.removeAllObservers()
            queries["userData"] = nil
        }
    }

    func downloadAnthem(country: FCCountry, completion: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        if let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let anthemsDir = "\(cacheDir)/anthems"
            let localPath = "\(anthemsDir)/\(country.key!.lowercased()).mp3"
            let remotePath = "gs://flag-ceremony.appspot.com/anthems/\(country.key!.lowercased()).mp3"
//            let storage = Storage.storage()
//            let gsReference = storage.reference(forURL: remotePath)
            
            // create anthems dir if not existing
            if !FileManager.default.fileExists(atPath: anthemsDir) {
                try! FileManager.default.createDirectory(atPath: anthemsDir,
                                                         withIntermediateDirectories: true,
                                                         attributes: nil)
            }
            
//            gsReference.write(toFile: URL(fileURLWithPath: localPath),
//                              completion: { (url: URL?, error: Error?) in
//                if let error = error {
//                    completion(nil, error)
//                } else {
//                    completion(url, nil)
//                }
//            })
        }
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = FirebaseManager()
}
