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
    var anthemsDict:NSDictionary?
    
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
        if anthemsDict == nil {
            if let path = Bundle.main.path(forResource: "anthems", ofType: "json", inDirectory: "data") {
                if FileManager.default.fileExists(atPath: path) {
                    anthemsDict = NSDictionary(contentsOfFile: path)
                }
            }
        }
        
        if let anthemsDict = anthemsDict {
            var a:Anthem?
            
            if let anthem = anthemsDict[key] as? [String: Any] {
                a = Anthem(key: key, dict: anthem)
            }
            
            completion(a)
        }
//        let anthem = FIRDatabase.database().reference().child("anthems").child(key)
//        anthem.observeSingleEvent(of: .value, with: { (snapshot) in
//            var a:Anthem?
//            
//            if let _ = snapshot.value as? [String: Any] {
//                 a = Anthem(snapshot: snapshot)
//            }
//            completion(a)
//        })
    }
    
    func fetchTopViewed(completion: @escaping ([Country]) -> Void) {
        let ref = FIRDatabase.database().reference().child("countries").queryOrdered(byChild: "views").queryLimited(toFirst: 10)
        
        ref.observe(.value, with: { snapshot in
            var countries = [Country]()
            
            for child in snapshot.children {
                if let c = child as? FIRDataSnapshot {
                    countries.append(Country(snapshot: c))
                }
            }
            completion(countries)
        })
    }
    
    func fetchTopPlayed(completion: @escaping ([Country]) -> Void) {
        let ref = FIRDatabase.database().reference().child("countries").queryStarting(atValue: 1, childKey: "plays").queryOrderedByValue().queryLimited(toLast: 10)
        
        ref.observe(.value, with: { snapshot in
            var countries = [Country]()
            
            for child in snapshot.children {
                if let c = child as? FIRDataSnapshot {
                    countries.append(Country(snapshot: c))
                }
            }
            completion(countries)
        })
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = FirebaseManager()
}
