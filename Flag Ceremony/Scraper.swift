//
//  Scraper.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 23/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import Foundation
import Firebase
import hpple
import Networking

class Scraper : NSObject {
    let ref = FIRDatabase.database().reference()
    
    func insertCountries() {
        let baseURL = CountriesURL
        let path = "/api/en/countries/info/all.json"
        let method:HTTPMethod = .Get
        let headers:[String: String]? = nil
        let paramType:Networking.ParameterType = .json
        let params = "?x=100" as AnyObject
        let completionHandler = { (result: [[String : Any]], error: NSError?) -> Void in
            if let error = error {
                print("error: \(error)")
            } else {
                if let data = result.first {
                    if let countries = data["Results"] as? [String: [String: Any]] {
                        for (key,value) in countries {
                            let country = self.ref.child("countries").child(key)
                            for (key2,value2) in value {
                                country.child(key2).setValue(value2)
                            }
                        }
                    }
                }
            }
        }
        
        NetworkingManager.sharedInstance.doOperation(baseURL, path: path, method: method, headers: headers, paramType: paramType, params: params, completionHandler: completionHandler)
    }
    
    func insertAnthems() {
        if let path = Bundle.main.path(forResource: "flag-ceremony-export", ofType: "json", inDirectory: "data") {
            if FileManager.default.fileExists(atPath: path) {
                
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    if let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        for (key,value) in dictionary {
                            
                            if key == "anthems" {
                                if let value2 = value as? [String: Any] {
                                    for (key3,value3) in value2 {
                                        let anthem = self.ref.child("anthems").child(key3)
                                        anthem.child(key3).setValue(value3)
                                    }
                                }
                            }
                        }
                    }
                }
                catch let error {
                    print("\(error)")
                }
            }
        }
    }

    func updateCountry(key: String, value: Any) {
        let countryRef = ref.child("countries").child(key)
        
        countryRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if let _ = currentData.value as? [String : Any] {
                // Set value and report transaction success
                currentData.value = value
                
                return FIRTransactionResult.success(withValue: currentData)
            }
            return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func downloadAnthemFiles() {
        ref.child("countries").observeSingleEvent(of: .value, with: { (snapshot) in
            let countries = snapshot.value as? [String: [String: Any]] ?? [:]
            
            for (key,value) in countries {
                let country = Country.init(key: key, dict: value)
                
                if let url = URL(string: "\(HymnsURL)/\(key.lowercased()).mp3") {
                    let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let localPath = "\(docsPath)/\(key.lowercased()).mp3"
                    
                    if country.getAudioURL() == nil {
                        let existsHandler = { (fileExistsAtServer: Bool) -> Void in
                            if fileExistsAtServer {
                                print ("downloading... \(country.name!)")
                                let completionHandler = { (data: Data?, error: NSError?) -> Void in
                                    if let error = error {
                                        print("error: \(error)")
                                    } else {
                                        do {
                                            try data!.write(to: URL(fileURLWithPath: localPath))
                                            print("saved: \(localPath)")
                                            self.updateCountry(key: key, value: NSNumber(value: true))
                                        } catch {
                                            
                                        }
                                    }
                                }
                                
                                NetworkingManager.sharedInstance.downloadFile(url: url, completionHandler: completionHandler)
                            } else {
                                self.updateCountry(key: key, value: NSNumber(value: false))
                            }
                        }
                        NetworkingManager.sharedInstance.fileExistsAt(url: url, completion: existsHandler);
                    
                    } else {
                        self.updateCountry(key: key, value: true)
                    }
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getLyrics() {
        if let path = Bundle.main.path(forResource: "anthems", ofType: "dict", inDirectory: "data") {
            if FileManager.default.fileExists(atPath: path) {
                if let dictionary = NSDictionary(contentsOfFile: path) {
                    let newDict = NSMutableDictionary()
                    
                    for (key,value) in dictionary {
                        let cc = key as! String
                        
                        if let value2 = value as? [String: Any] {
                            var anthemDict = [String: Any]()
                            
                            print("lyrics... \(key)")
                            // copy
                            for (key3,value3) in value2 {
                                anthemDict[key3] = value3
                            }
                            
                            // add lyrics and info
                            if anthemDict[Anthem.Keys.Lyrics] == nil ||
                                anthemDict[Anthem.Keys.Info] == nil {
                                if let url = URL(string: "\(HymnsURL)/\(cc.lowercased()).htm") {
                                    if let doc = readUrl(url: url) {
                                        anthemDict[Anthem.Keys.Lyrics] = parseAnthemLyrics(doc: doc)
                                        anthemDict[Anthem.Keys.Info] = parseAnthemInfo(doc: doc)
                                    }
                                }
                            }
                            
                            newDict.setObject(anthemDict, forKey: key as! NSCopying)
                        }
                    }
                    
                    // write to disk
                    do {
                        let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let localPath = "\(docsPath)/anthems.dict"
                        let localUrl = URL(fileURLWithPath: localPath)
                        if FileManager.default.fileExists(atPath: localPath) {
                            try FileManager.default.removeItem(at: localUrl)
                        }
                        newDict.write(to: localUrl, atomically: true)
                    } catch let error {
                        print("error: \(error)")
                    }
                }
            }
        }
    }
    
    func getFlagInfo() {
        if let path = Bundle.main.path(forResource: "flag-ceremony-export", ofType: "json", inDirectory: "data") {
            if FileManager.default.fileExists(atPath: path) {
                
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    if let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        
                        var newDict = [String: Any]()
                        for (key,value) in dictionary {
                            if let value2 = value as? [String: Any] {
                                var dict = [String: Any]()
                                
                                // copy
                                for (key3,value3) in value2 {
                                    dict[key3] = value3
                                    
                                    if key == "anthems" {
                                        var anthemDict = [String: Any]()
                                        for (key4,value4) in value3 as! [String: Any] {
                                            anthemDict[key4] = value4
                                        }
                                        
                                        // add lyrics
                                        if anthemDict[Anthem.Keys.Lyrics] == nil {
                                            print("getting lyrics for \(key3)...")
                                            if let url = URL(string: "\(HymnsURL)/\(key3.lowercased()).htm") {
                                                if let doc = readUrl(url: url) {
                                                    anthemDict[Anthem.Keys.Lyrics] = parseAnthemLyrics(doc: doc)
                                                }
                                            }
                                        }
                                        
                                        // add info
                                        if anthemDict[Anthem.Keys.Info] == nil {
                                            print("getting info for \(key3)...")
                                            if let url = URL(string: "\(HymnsURL)/\(key3.lowercased()).htm") {
                                                if let doc = readUrl(url: url) {
                                                    anthemDict[Anthem.Keys.Info] = parseAnthemInfo(doc: doc)
                                                }
                                            }
                                        }
                                        
                                        // add flagInfo
                                        var willGetFlagInfo = false
                                        if let flagInfo = anthemDict[Anthem.Keys.FlagInfo] as? String {
                                            if flagInfo.characters.count == 0 {
                                                willGetFlagInfo = true
                                            }
                                        } else {
                                            willGetFlagInfo = true
                                        }
                                        
                                        if willGetFlagInfo {
                                            let countriesDict = dictionary["countries"] as! [String : Any]
                                            if let country = countriesDict[key3] as? [String : Any] {
                                                var name = country[Country.Keys.Name] as! String
                                                name = name.lowercased()
                                                
                                                // transform the name
                                                var lastPaths = [String]()
                                                if name.contains(" ") {
                                                    name = name.replacingOccurrences(of: " ", with: "-")
                                                }
                                                
                                                if name == "korea-north" {
                                                    lastPaths.append("north-korea")
                                                } else if name == "korea-south" {
                                                    lastPaths.append("south-korea")
                                                } else if name == "timor-leste" {
                                                    lastPaths.append("east-timor")
                                                } else if name == "congo-democratic-republic" {
                                                    lastPaths.append("the-democratic-republic-of-the-congo")
                                                } else if name == "congo-republic" {
                                                    lastPaths.append("the-republic-of-the-congo")
                                                } else if name == "holy-see" {
                                                    lastPaths.append("the-vatican-city")
                                                } else if name == "china" {
                                                    lastPaths.append("the-people-s-republic-of-china")
                                                } else if name == "ivory-coast" {
                                                    lastPaths.append("cote-d-ivoire")
                                                } else {
                                                    lastPaths.append(name)
                                                    lastPaths.append("the-\(name)")
                                                }
                                                
                                                // add flag info
                                                for lp in lastPaths {
                                                    if let url = URL(string: "\(FlagpediaURL)/\(lp)") {
                                                        if let doc = self.readUrl(url: url) {
                                                            print("getting flag info... \(key3)")
                                                            anthemDict[Anthem.Keys.FlagInfo] = self.parseFlagInfo(doc: doc)
                                                        } else {
                                                            print("invalid url: \(url)")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        dict[key3] = anthemDict
                                    }
                                }
                                
                                newDict[key] = dict
                            }
                        }
                        
                        // write to disk
                        do {
                            let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            let localPath = "\(docsPath)/flag-ceremony-export.json"
                            if FileManager.default.fileExists(atPath: localPath) {
                                try FileManager.default.removeItem(atPath: localPath)
                            }
                            
                            
                            
                            // creating JSON out of the above array
                            let jsonData = try JSONSerialization.data(withJSONObject: newDict, options: .prettyPrinted)
                            try jsonData.write(to: URL(fileURLWithPath: localPath))
                        } catch let error {
                            print("error: \(error)")
                        }
                    }
                } catch let error {
                    print("\(error)")
                }
            }
        }
    }
    
    func countryNameFrom(countries: [String: Any]) -> String {
        return ""
    }
    
    func readUrl(url: URL) -> TFHpple? {
        do {
            let data = try Data(contentsOf: url)
            return TFHpple(htmlData: data)
            
        } catch let error {
            print("error: \(error)")
        }
        
        return nil
    }
    
    func parseAnthemLyrics(doc: TFHpple) -> [[String: Any]] {
        var array = [[String: Any]]()
        
        
        var keys = [String]()
        var values = [String]()
        
        if let elements = doc.search(withXPathQuery: "//div[@class='collapseomatic ']") as? [TFHppleElement] {
            for element in elements {
                keys.append(parseElement(element: element))
            }
        }
        
        if let elements = doc.search(withXPathQuery: "//div[@class='collapseomatic_content ']") as? [TFHppleElement] {
            for element in elements {
                values.append(parseElement(element: element))
            }
        }
        
        if keys.count > 0 {
            for i in 0...keys.count-1 {
                var lyrics = [String: Any]()
                lyrics[Anthem.Keys.LyricsName] = keys[i]
                lyrics[Anthem.Keys.LyricsText] = values[i]
                array.append(lyrics)
            }
        }
        
        return array
    }
    
    func parseAnthemInfo(doc: TFHpple) -> String? {
        var info:String?
        
        if let elements = doc.search(withXPathQuery: "//div[@class='entry fix']") as? [TFHppleElement] {
            info = ""
            
            for element in elements {
                info! += parseElement(element: element)
            }
            
            info = info!.trimmingCharacters(in: .whitespacesAndNewlines)
            info = info!.replacingOccurrences(of: "\n", with: "\n\n")
        }
        
        return info
    }

    func parseFlagInfo(doc: TFHpple) -> String? {
        var info:String?
        
        if let elements = doc.search(withXPathQuery: "//div[@id='flag-content']") as? [TFHppleElement] {
            info = ""
            
            for element in elements {
                info! += parseElement(element: element)
            }
            
            info = info!.trimmingCharacters(in: .whitespacesAndNewlines)
            info = info!.replacingOccurrences(of: "\n", with: "\n\n")
        }
        
        info = info?.replacingOccurrences(of: "(adsbygoogle = window.adsbygoogle || []).push({});\n\n\n\n\t", with: "")
        return info
    }
    
    func parseElement(element: TFHppleElement) -> String {
        var text = ""
        
        if let content = element.content {
            text += content
        }
        
        if element.hasChildren() {
            for child in element.children {
                let c = child as! TFHppleElement
                text += parseElement(element: c)
            }
        }
        
        return text
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = Scraper()
}
