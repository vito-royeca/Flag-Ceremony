//
//  FirebaseManager.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 23/11/2016.
//

import Combine
import Firebase
import FirebaseAuthCombineSwift
import FirebaseStorage
import FirebaseStorageCombineSwift

enum FirebaseManagerError : Error {
    case notLoggedIn
    case noDataFound
}

class FirebaseManager : NSObject {
    // MARK: Constants

    let kQueryTopViewed = "topViewed"
    let kQueryTopPlayed = "topPlayed"
    let kQueryTopViewers = "topViewers"
    let kQueryTopPlayers = "topPlayers"
    let kQueryUsers = "users"
    let kQueryUserData = "userData"
            
    // MARK: - Shared Instance
    
    static let sharedInstance = FirebaseManager()
    
    // MARK: - Variables
    
    private var queries = [String: DatabaseQuery]()
    private var online = false
    private let databaseReference = Database.database().reference()//(withPath: ".info/connected")
    private let storageReference = Storage.storage().reference()
    private var cancelables = Set<AnyCancellable>()
    
    // MARK: - User methods

    
    @available(*, renamed: "fetchUser()")
    func fetchUser(completion: @escaping (Result<FCUser?,Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(FirebaseManagerError.notLoggedIn))
            return
        }

        let child = databaseReference.child("users").child(user.uid)

        child.observe(.value, with: { snapshot in
            if let _ = snapshot.value as? [String: Any] {
                completion(.success(FCUser(snapshot: snapshot)))
            } else {
                completion(.failure(FirebaseManagerError.noDataFound))
            }
        })
    }
    
    @available(*, renamed: "updateUser(photoURL:photoDirty:displayName:)")
    func updateUser(photoURL: URL?, photoDirty: Bool, displayName: String?, completion: @escaping (Result<Void,Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(FirebaseManagerError.notLoggedIn))
            return
        }

        updatePhoto(photoURL: photoURL, photoDirty: photoDirty) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let url):
                let child = self.databaseReference.child("users").child(user.uid)
                
                child.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
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
    
    @available(*, renamed: "updatePhoto(photoURL:photoDirty:)")
    func updatePhoto(photoURL: URL?, photoDirty: Bool, completion: @escaping (Result<URL?,Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(FirebaseManagerError.notLoggedIn))
            return
        }

        if photoDirty {
            let child = storageReference.child("avatars/\(user.uid).png")
            
            if let photoURL = photoURL {
               if FileManager.default.fileExists(atPath: photoURL.path),
                  let image = UIImage(contentsOfFile: photoURL.path),
                  let resizedImage = image.resize(to: CGSize(width: 256, height: 256)),
                  let data = resizedImage.pngData() {
                   
                   let meta = StorageMetadata()
                   meta.contentType = "image/png"
                   
                   child.putData(data, metadata: meta) { (metadata, error) in
                       if let error = error {
                           completion(.failure(error))
                       } else {
                           child.downloadURL(completion: { (url, error) in
                               if let error = error {
                                   completion(.failure(error))
                               } else {
                                   completion(.success(url))
                               }
                           })
                       }
                   }
               } else {
                   completion(.success(photoURL))
               }
            } else {
                child.delete() { error in
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
    
    @available(*, renamed: "toggleFavorite(_:)")
    func toggleFavorite(_ key: String, completion: @escaping (Result<Void,Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(FirebaseManagerError.notLoggedIn))
            return
        }
        
        let child = databaseReference.child("activities").child(user.uid)
        
        child.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
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
    

    // MARK: - Country methods

    @available(*, renamed: "incrementCountryViews(_:)")
    func incrementCountryViews(_ key: String, completion: @escaping (Result<FCCountry?,Error>) -> Void) {
        let child = databaseReference.child("countries").child(key)
        
        child.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
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
                    completion(.failure(FirebaseManagerError.noDataFound))
                }
            }
        }
        
        if let user = Auth.auth().currentUser {
            let child2 = databaseReference.child("activities").child(user.uid)
            
            child2.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
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
    
    
    @available(*, renamed: "incrementCountryPlays(_:)")
    func incrementCountryPlays(_ key: String, completion: @escaping (Result<FCCountry?,Error>) -> Void) {
        let child = databaseReference.child("countries").child(key)
        
        child.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
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
                    completion(.failure(FirebaseManagerError.noDataFound))
                }
            }
        }
        
        if let user = Auth.auth().currentUser {
            let child2 = databaseReference.child("activities").child(user.uid)
            
            child2.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
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
    
    func findAnthem(_ key: String, completion: @escaping (Result<FCAnthem?,Error>) -> Void) {
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
                        completion(.success(a))
                    } else {
                        completion(.failure(FirebaseManagerError.noDataFound))
                    }
                } catch let error {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(FirebaseManagerError.noDataFound))
            }
        } else { // look it up in Firebase
            databaseReference.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                    let anthem = self.databaseReference.child("anthems").child(key)
                    anthem.observeSingleEvent(of: .value, with: { (snapshot) in
                        var a:FCAnthem?
                        
                        if let _ = snapshot.value as? [String: Any] {
                            a = FCAnthem(snapshot: snapshot)
                        }
                        completion(.success(a))
                    })
                } else {
                    completion(.failure(FirebaseManagerError.noDataFound))
                }
            })
        }
    }
    
    @available(*, renamed: "downloadAnthem(country:)")
    func downloadAnthem(country: FCCountry, completion: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        guard let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            completion(nil, nil)
            return
        }

        let anthemsDir = "\(cacheDir)/anthems"
        let localPath = "\(anthemsDir)/\(country.key!.lowercased()).mp3"
        let remotePath = "gs://flag-ceremony.appspot.com/anthems/\(country.key!.lowercased()).mp3"
        let storage = Storage.storage()
        let gsReference = storage.reference(forURL: remotePath)
        
        // create anthems dir if not existing
        if !FileManager.default.fileExists(atPath: anthemsDir) {
            try! FileManager.default.createDirectory(atPath: anthemsDir,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
            
        gsReference.write(toFile: URL(fileURLWithPath: localPath)) { (url: URL?, error: Error?) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(url, nil)
            }
        }
    }
    
    @available(*, renamed: "fetchAllCountries()")
    func fetchAllCountries(completion: @escaping (Result<[FCCountry],Error>) -> Void) {
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
                        completion(.success(countries))
                    } else {
                        completion(.failure(FirebaseManagerError.noDataFound))
                    }
                } catch let error {
                    completion(.failure(error))
                }
            }

        } else {
            databaseReference.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                    let child = self.databaseReference.child("countries")
                    child.queryOrdered(byChild: "Name").observeSingleEvent(of: .value,
                                                                           with: { (snapshot) in
                        for child in snapshot.children {
                            if let c = child as? DataSnapshot {
                                countries.append(FCCountry(snapshot: c))
                            }
                        }
                        completion(.success(countries))
                    })
                } else {
                    completion(.failure(FirebaseManagerError.noDataFound))
                }
            })
        }
    }
    
    @available(*, renamed: "findCountries(keys:)")
    func findCountries(keys: [String], completion: @escaping (Result<[FCCountry],Error>) -> Void) {
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
                        completion(.success(countries))
                    }
                } catch let error {
                    completion(.failure(error))
                }
            }
            
        } else {
            databaseReference.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                    let child = self.databaseReference.child("countries")
                    child.queryOrdered(byChild: "Name").observeSingleEvent(of: .value,
                                                                           with: { (snapshot) in
                        for child in snapshot.children {
                            if let c = child as? DataSnapshot,
                               keys.contains(c.key) {
                                countries.append(FCCountry(snapshot: c))
                            }
                        }
                        completion(.success(countries))
                    })
                } else {
                    completion(.failure(FirebaseManagerError.noDataFound))
                }
            })
        }
    }
    
    
    @available(*, renamed: "findCountry(_:)")
    func findCountry(_ key: String, completion: @escaping (Result<FCCountry?,Error>) -> Void) {
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
                        completion(.success(a))
                    } else {
                        completion(.failure(FirebaseManagerError.noDataFound))
                    }
                } catch let error {
                    completion(.failure(error))
                }
            }
        } else {
            databaseReference.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                    let country = self.databaseReference.child("countries").child(key)
                    country.observeSingleEvent(of: .value, with: { (snapshot) in
                        var a:FCCountry?
                        
                        if let _ = snapshot.value as? [String: Any] {
                            a = FCCountry(snapshot: snapshot)
                        }
                        completion(.success(a))
                    })
                } else {
                    completion(.failure(FirebaseManagerError.noDataFound))
                }
            })
        }
    }
    
    // MARK: - Chart methods

    @available(*, renamed: "monitorTopViewed()")
    func monitorTopViewed(completion: @escaping ([FCCountry]) -> Void) {
        let child = databaseReference.child("countries")
        let query = child.queryOrdered(byChild: FCCountry.Keys.Views).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var countries = [FCCountry]()
            
            for child in snapshot.children {
                if let c = child as? DataSnapshot,
                   let _ = snapshot.value as? [String: Any] {
                    countries.append(FCCountry(snapshot: c))
                }
            }
            completion(countries.reversed())
        })
       
        queries[kQueryTopViewed] = query
    }
    
    @available(*, renamed: "monitorTopViewers()")
    func monitorTopViewers(completion: @escaping ([FCActivity]) -> Void) {
        let child = databaseReference.child("activities")
        let query = child.queryOrdered(byChild: FCActivity.Keys.ViewCount).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var activities = [FCActivity]()
            
            for child in snapshot.children {
                if let c = child as? DataSnapshot,
                   let _ = snapshot.value as? [String: Any] {
                    activities.append(FCActivity(snapshot: c))
                }
            }
            completion(activities.reversed())
        })
        
        queries[kQueryTopViewers] = query
    }
    
    @available(*, renamed: "monitorTopPlayed()")
    func monitorTopPlayed(completion: @escaping ([FCCountry]) -> Void) {
        let child = databaseReference.child("countries")
        let query = child.queryOrdered(byChild: FCCountry.Keys.Plays).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var countries = [FCCountry]()
            
            for child in snapshot.children {
                if let c = child as? DataSnapshot,
                   let _ = snapshot.value as? [String: Any] {
                    countries.append(FCCountry(snapshot: c))
                }
            }
            completion(countries.reversed())
        })
        
        queries[kQueryTopPlayed] = query
    }
    
    @available(*, renamed: "monitorTopPlayers()")
    func monitorTopPlayers(completion: @escaping ([FCActivity]) -> Void) {
        let child = databaseReference.child("activities")
        let query = child.queryOrdered(byChild: FCActivity.Keys.PlayCount).queryStarting(atValue: 1).queryLimited(toLast: 20)
        query.observe(.value, with: { snapshot in
            var activities = [FCActivity]()
            
            for child in snapshot.children {
                if let c = child as? DataSnapshot,
                   let _ = snapshot.value as? [String: Any] {
                    activities.append(FCActivity(snapshot: c))
                }
            }
            completion(activities.reversed())
        })
        
        queries[kQueryTopPlayers] = query
    }
    
    @available(*, renamed: "monitorUsers()")
    func monitorUsers(completion: @escaping ([FCUser]) -> Void) {
        let child = databaseReference.child("users")
        let query = child.queryOrderedByKey()
        query.observe(.value, with: { snapshot in
            var users = [FCUser]()
            
            for child in snapshot.children {
                if let c = child as? DataSnapshot,
                   let _ = snapshot.value as? [String: Any] {
                    users.append(FCUser(snapshot: c))
                }
            }
            completion(users)
        })
        
        queries[kQueryUsers] = query
    }
    
    @available(*, renamed: "monitorUserActivity()")
    func monitorUserActivity(completion: @escaping (Result<FCActivity?, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(FirebaseManagerError.notLoggedIn))
            return
        }

        let child = databaseReference.child("activities").child(user.uid)
        let query = child.queryOrderedByKey()
        query.observe(.value, with: { snapshot in
            if let _ = snapshot.value as? [String: Any] {
                completion(.success(FCActivity(snapshot: snapshot)))
            } else {
                completion(.failure(FirebaseManagerError.noDataFound))
            }
        })
        
        queries[kQueryUserData] = query
    }
    
    func demonitorTopCharts() {
        if let query = queries[kQueryTopViewed] {
            query.removeAllObservers()
            queries.removeValue(forKey: kQueryTopViewed)
        }
        
        if let query = queries[kQueryTopPlayed] {
            query.removeAllObservers()
            queries.removeValue(forKey: kQueryTopPlayed)
        }
        
        if let query = queries[kQueryTopViewers] {
            query.removeAllObservers()
            queries.removeValue(forKey: kQueryTopViewers)
        }
        
        if let query = queries[kQueryTopPlayers] {
            query.removeAllObservers()
            queries.removeValue(forKey: kQueryTopPlayers)
        }
        
        if let query = queries[kQueryUsers] {
            query.removeAllObservers()
            queries.removeValue(forKey: kQueryUsers)
        }
    }
    
    func demonitorUserActivity() {
        if let query = queries[kQueryUserData] {
            query.removeAllObservers()
            queries.removeValue(forKey: kQueryUserData)
        }
    }
}
