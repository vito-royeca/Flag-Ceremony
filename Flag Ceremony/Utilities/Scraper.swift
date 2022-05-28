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
import PromiseKit
import Sync

class Scraper : NSObject {
    let ref = Database.database().reference()
    
    // MARK: Firebase
    func insertCountries() {
        if let url = URL(string: "\(CountriesURL)/api/en/countries/info/all.json?x=100") {
            var rq = URLRequest(url: url)
            rq.httpMethod = "GET"
            rq.addValue("application/json",
                        forHTTPHeaderField: "Content-Type")
            rq.addValue("application/json",
                        forHTTPHeaderField: "Accept")
            
            firstly {
                URLSession.shared.dataTask(.promise, with: rq)
                }.compactMap {
                    try JSONSerialization.jsonObject(with: $0.data,
                                                     options: .allowFragments)
                }.done { foo in
                    //…
                }.catch { error in
                    //…
            }
        }
//        let baseURL = CountriesURL
//        let path = "/api/en/countries/info/all.json"
//        let method:HTTPMethod = .get
//        let headers:[String: String]? = nil
//        let paramType:Networking.ParameterType = .json
//        let params = "?x=100" as AnyObject
//        let completionHandler = { (result: [[String : Any]], error: NSError?) -> Void in
//            if let error = error {
//                print("error: \(error)")
//            } else {
//                if let data = result.first {
//                    if let countries = data["Results"] as? [String: [String: Any]] {
//                        for (key,value) in countries {
//                            let country = self.ref.child("countries").child(key)
//                            for (key2,value2) in value {
//                                country.child(key2).setValue(value2)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        NetworkingManager.sharedInstance.doOperation(baseURL, path: path, method: method, headers: headers, paramType: paramType, params: params, completionHandler: completionHandler)
    }
    
    func insertAnthems() {
        if let path = Bundle.main.path(forResource: "flag-ceremony-export", ofType: "json", inDirectory: "data") {
            if FileManager.default.fileExists(atPath: path) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    if let dictionary = try JSONSerialization.jsonObject(with: data,
                                                                         options: .mutableContainers) as? [String: Any] {
                        for (key,value) in dictionary {
                            
                            if key == "anthems" {
                                if let value2 = value as? [String: Any] {
                                    for (key3,value3) in value2 {
                                        let anthem = self.ref.child("anthems").child(key3)
                                        anthem.setValue(value3)
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
        
        countryRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if let _ = currentData.value as? [String : Any] {
                // Set value and report transaction success
                currentData.value = value
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    // MARK: Scraper
    func getCountries() {
        if let url = URL(string: "\(CountriesURL)/api/en/countries/info/all.json") {
            var rq = URLRequest(url: url)
            rq.httpMethod = "GET"
            rq.addValue("application/json",
                        forHTTPHeaderField: "Content-Type")
            rq.addValue("application/json",
                        forHTTPHeaderField: "Accept")
            
            firstly {
                URLSession.shared.dataTask(.promise, with: rq)
                }.compactMap {
                    try JSONSerialization.jsonObject(with: $0.data,
                                                     options: .allowFragments) as? [String: Any]
                    
                }.done { json in
                    if let results = json["Results"] as? [String: Any] {
                        var countries = [[String: Any]]()
                        
                        for (k,v) in results {
                            if let d = v as? [String: Any] {
                                var country = [String: Any]()
                                
                                country["country_code"] = k
                                country["name"] = d["Name"]
                                country["country_info"] = d["CountryInfo"]
                                
                                if let capital = d["Capital"] as? [String: Any] {
                                    country["capital"] =  capital["Name"]
                                    if let geoPt = capital["GeoPt"] as? [Double] {
                                        country["capital_geo_x"] =  geoPt[0]
                                        country["capital_geo_y"] =  geoPt[1]
                                    }
                                }
                                
                                if let geoPt = d["GeoPt"] as? [Double] {
                                    country["geo_x"] =  geoPt[0]
                                    country["geo_y"] =  geoPt[1]
                                }
                                
                                countries.append(country)
                            }
                        }
                        
                        DatabaseManager.sharedInstance.dataStack.sync(countries,
                                                                      inEntityNamed: "DBCountry") { error in
                            if let error = error {
                                print("getCountries: \(error)")
                            }
                        }
                    }
                    
                }.catch { error in
                    print("getCountries: \(error)")
            }
        }
    }
    
    func getAnthems(ccFilter: String?) {
        let request: NSFetchRequest<DBCountry> = NSFetchRequest(entityName: "DBCountry")
        
        request.sortDescriptors = [NSSortDescriptor(key: "name",
                                                    ascending: true)]
        if let ccFilter = ccFilter {
            request.predicate = NSPredicate(format: "countryCode == %@",
                                            ccFilter)
        }
        
        for country in try! DatabaseManager.sharedInstance.dataStack.mainContext.fetch(request) {
            if let countryCode = country.countryCode {
                print("\(countryCode)...")
                
                if let anthem = findOrCreateObject("DBAnthem",
                                                   objectFinder: ["country.countryCode": countryCode as AnyObject]) as? DBAnthem {
                    anthem.country = country

                    // anthem info and lyrics
                    if let url = URL(string: "\(HymnsURL)/\(countryCode.lowercased()).htm") {
                        if let doc = readUrl(url: url) {
                            anthem.info = parseAnthemInfo(doc: doc)
                            
                            for dict in parseAnthemLyrics(doc: doc) {
                                if let lyrics = findOrCreateObject("DBLyrics",
                                                                   objectFinder: ["name": dict["name"] as AnyObject]) as? DBLyrics {
                                    lyrics.name = dict["name"] as? String
                                    lyrics.text = dict["text"] as? String
                                    lyrics.anthem = anthem
                                }
                            }
                            
                            anthem.titles = NSData(data: NSKeyedArchiver.archivedData(withRootObject: parseAnthemTitles(doc: doc)))
                            anthem.lyricsWriter = NSData(data: NSKeyedArchiver.archivedData(withRootObject: parseLyricsWriter(doc: doc)))
                            anthem.musicWriter = NSData(data: NSKeyedArchiver.archivedData(withRootObject: parseMusicWriter(doc: doc)))
                            anthem.dateAdopted = NSData(data: NSKeyedArchiver.archivedData(withRootObject: parseDateAdopted(doc: doc)))
                        }
                    }
                    
                    // background
                    if let url = URL(string: "\(CountriesURL)/geo/en/cc/\(countryCode.lowercased()).html") {
                        if let doc = readUrl(url: url) {
                            anthem.background = parseAnthemBackground(doc: doc)
                        }
                    }
                    
                    // flag info
                    if let name = country.name {
                        var tmpName = name.lowercased()
                        
                        // transform the name
                        var lastPaths = [String]()
                        if tmpName.contains(" ") {
                            tmpName = tmpName.replacingOccurrences(of: " ", with: "-")
                        }
                        
                        if tmpName == "korea-north" {
                            lastPaths.append("north-korea")
                        } else if tmpName == "korea-south" {
                            lastPaths.append("south-korea")
                        } else if tmpName == "timor-leste" {
                            lastPaths.append("east-timor")
                        } else if tmpName == "congo-democratic-republic" {
                            lastPaths.append("the-democratic-republic-of-the-congo")
                        } else if tmpName == "congo-republic" {
                            lastPaths.append("the-republic-of-the-congo")
                        } else if tmpName == "holy-see" {
                            lastPaths.append("the-vatican-city")
                        } else if tmpName == "china" {
                            lastPaths.append("the-people-s-republic-of-china")
                        } else if tmpName == "ivory-coast" {
                            lastPaths.append("cote-d-ivoire")
                        } else {
                            lastPaths.append(tmpName)
                            lastPaths.append("the-\(tmpName)")
                        }
                        
                        // add flag info
                        for lp in lastPaths {
                            if let url = URL(string: "\(FlagpediaURL)/\(lp)") {
                                if let doc = self.readUrl(url: url) {
                                    anthem.flagInfo = parseFlagInfo(doc: doc)
                                } else {
                                    print("invalid url: \(url)")
                                }
                            }
                        }
                    }
                }
                
                try! DatabaseManager.sharedInstance.dataStack.mainContext.save()
            }
        }
    }
    
    // MARK: Old code
    func getAnthemFiles() {
        ref.child("countries").observeSingleEvent(of: .value, with: { (snapshot) in
            let countries = snapshot.value as? [String: [String: Any]] ?? [:]
            
            for (key,value) in countries {
                let country = FCCountry.init(key: key,
                                             dict: value)
                
                if let url = URL(string: "\(HymnsURL)/\(key.lowercased()).mp3") {
                    let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let localPath = "\(docsPath)/\(key.lowercased()).mp3"
                    
//                    if country.getAudioURL() == nil {
//                        let existsHandler = { (fileExistsAtServer: Bool) -> Void in
//                            if fileExistsAtServer {
//                                print ("downloading... \(country.name!)")
//                                let completionHandler = { (data: Data?, error: NSError?) -> Void in
//                                    if let error = error {
//                                        print("error: \(error)")
//                                    } else {
//                                        do {
//                                            try data!.write(to: URL(fileURLWithPath: localPath))
//                                            print("saved: \(localPath)")
//                                            self.updateCountry(key: key, value: NSNumber(value: true))
//                                        } catch {
//                                            
//                                        }
//                                    }
//                                }
//                                
//                                NetworkingManager.sharedInstance.downloadFile(url: url, completionHandler: completionHandler)
//                            } else {
//                                self.updateCountry(key: key, value: NSNumber(value: false))
//                            }
//                        }
//                        NetworkingManager.sharedInstance.fileExistsAt(url: url, completion: existsHandler);
//                    
//                    } else {
//                        self.updateCountry(key: key, value: true)
//                    }
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: Parser
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
                lyrics[FCAnthem.Keys.LyricsName] = keys[i]
                lyrics[FCAnthem.Keys.LyricsText] = values[i]
                array.append(lyrics)
            }
        }
        
        return array
    }
    
    func parseAnthemInfo(doc: TFHpple) -> String? {
        var text:String?
        
        if let elements = doc.search(withXPathQuery: "//div[@class='entry fix']") as? [TFHppleElement] {
            text = ""
            
            for element in elements {
//                var specialThanks = false
//
//                if element.hasChildren() {
//                    for child in element.children {
//                        if let c = child as? TFHppleElement {
//                            if c.content.hasPrefix("Special thanks") {
//                                specialThanks = true
//                                break
//                            }
//                        }
//                    }
//                }
                
                text! += parseElement(element: element)
            }
            
            text = text!.trimmingCharacters(in: .whitespacesAndNewlines)
            text = text!.replacingOccurrences(of: "\n",
                                              with: "\n\n")
            text = text!.replacingOccurrences(of: "\t",
                                              with: "")
            text = text!.replacingOccurrences(of: "\n\n\n\n",
                                              with: "\n")
        }
        
        return text
    }

    func parseAnthemBackground(doc: TFHpple) -> String? {
        var text:String?
        
        if let elements = doc.search(withXPathQuery: "//div[@id='Background']") as? [TFHppleElement] {
            text = ""
            
            for element in elements {
                text! += parseElement(element: element)
            }
            
            text = text!.trimmingCharacters(in: .whitespacesAndNewlines)
            text = text!.replacingOccurrences(of: "\n",
                                              with: "\n\n")
            text = text!.replacingOccurrences(of: "\t",
                                              with: "")
            text = text!.replacingOccurrences(of: "\n\n\n\n",
                                              with: "\n")
            text = text!.replacingOccurrences(of: "Background : \n",
                                              with: "")
        }

        return text
    }
    
    func parseAnthemTitles(doc: TFHpple) -> [String] {
        var array = [String]()
        
        if let elements = doc.search(withXPathQuery: "//aside[@id='custom-field-5']") as? [TFHppleElement] {
            var text = ""
            
            for element in elements {
                text += parseElement(element: element)
            }
            text = text.replacingOccurrences(of: "\n Title \n\n",
                                             with: "")
            text = text.replacingOccurrences(of: "\r\n\r\n",
                                             with: "\r\n")
            text = text.replacingOccurrences(of: "\n\n",
                                             with: "")
            
            for t in text.components(separatedBy: "\r\n") {
                let title = t.replacingOccurrences(of: "“",
                                                   with: "").replacingOccurrences(of: "”",
                                                                                  with: "")
                array.append(title)
            }
        }
        
        return array
    }
    
    func parseLyricsWriter(doc: TFHpple) -> [String] {
        var array = [String]()
        
        if let elements = doc.search(withXPathQuery: "//aside[@id='custom-field-2']") as? [TFHppleElement] {
            var text = ""
            
            for element in elements {
                text += parseElement(element: element)
            }
            text = text.replacingOccurrences(of: "\n Lyricist \n\n",
                                             with: "")
            text = text.replacingOccurrences(of: "\r\n",
                                             with: ", ")
            text = text.replacingOccurrences(of: " and ",
                                             with: ", ")
            text = text.replacingOccurrences(of: "\n\n",
                                             with: "")
            
            for t in text.components(separatedBy: ", ") {
                array.append(t)
            }
        }
        
        return array
    }
    
    func parseMusicWriter(doc: TFHpple) -> [String] {
        var array = [String]()
        
        if let elements = doc.search(withXPathQuery: "//aside[@id='custom-field-10']") as? [TFHppleElement] {
            var text = ""
            
            for element in elements {
                text += parseElement(element: element)
            }
            text = text.replacingOccurrences(of: "\n Composers \n\n",
                                             with: "")
            text = text.replacingOccurrences(of: "\r\n",
                                             with: ", ")
            text = text.replacingOccurrences(of: " and ",
                                             with: ", ")
            text = text.replacingOccurrences(of: "\n\n",
                                             with: "")
            
            for t in text.components(separatedBy: ", ") {
                array.append(t)
            }
        }
        
        return array
    }

    func parseDateAdopted(doc: TFHpple) -> [String] {
        var array = [String]()
        
        // TODO: Fix this
//        for element in elements {
//            text += parseElement(element: element)
//        }
//        text = text.replacingOccurrences(of: "\n Date Adopted \n\n", with: "")
//        text = text.replacingOccurrences(of: "\r\n", with: ", ")
//        text = text.replacingOccurrences(of: " and ", with: ", ")
//        text = text.replacingOccurrences(of: "\n\n", with: "")
//
//        for t in text.components(separatedBy: ", ") {
//            array.append(t)
//        }
        
        return array
    }

    func parseFlagInfo(doc: TFHpple) -> String? {
        var info:String?
        
        if let elements = doc.search(withXPathQuery: "//div[@id='flag-content']") as? [TFHppleElement] {
            info = ""
            
            for element in elements {
                info! += parseElement(element: element)
            }
            
            info = info!.trimmingCharacters(in: .whitespacesAndNewlines)
            info = info!.replacingOccurrences(of: "\n",
                                              with: "\n\n")
        }
        
        info = info?.replacingOccurrences(of: "(adsbygoogle = window.adsbygoogle || []).push({});\n\n\n\n\t",
                                          with: "")
        return info
    }
    
    func parseElement(element: TFHppleElement) -> String {
        var text = ""
        
        if let content = element.content {
            text += content
        }
        
        if element.hasChildren() {
            for child in element.children {
                if let c = child as? TFHppleElement {
                    text += parseElement(element: c)
                }
            }
        }
        
        return text
    }
    
    // MARK: Core Data
    func findOrCreateObject(_ entityName: String, objectFinder: [String: AnyObject]?) -> NSManagedObject? {
        var object:NSManagedObject?
        var predicate:NSPredicate?
        var fetchRequest:NSFetchRequest<NSFetchRequestResult>?
        let dataStack = DatabaseManager.sharedInstance.dataStack
        
        if let objectFinder = objectFinder {
            for (key,value) in objectFinder {
                if predicate != nil {
                    predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!,
                                                                                    NSPredicate(format: "%K == %@", key, value as! NSObject)])
                } else {
                    predicate = NSPredicate(format: "%K == %@", key, value as! NSObject)
                }
            }
            
            fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest!.predicate = predicate
        }
        
        if let fetchRequest = fetchRequest {
            if let m = try! dataStack.mainContext.fetch(fetchRequest).first as? NSManagedObject {
                object = m
            } else {
                if let desc = NSEntityDescription.entity(forEntityName: entityName,
                                                         in: dataStack.mainContext) {
                    object = NSManagedObject(entity: desc,
                                             insertInto: dataStack.mainContext)
                    try! dataStack.mainContext.save()
                }
            }
        } else {
            if let desc = NSEntityDescription.entity(forEntityName: entityName,
                                                     in: dataStack.mainContext) {
                object = NSManagedObject(entity: desc,
                                         insertInto: dataStack.mainContext)
                try! dataStack.mainContext.save()
            }
        }
        
        return object
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = Scraper()
}
