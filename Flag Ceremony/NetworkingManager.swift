//
//  NetworkingManager.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 01/11/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import Networking

enum HTTPMethod: String {
    case Post  = "Post",
    Get  = "Get",
    Head = "Head"
}

typealias NetworkingResult = (_ result: [[String : Any]], _ error: NSError?) -> Void

class NetworkingManager: NSObject {
    var networkers = [String: Any]()
    
    func doOperation(_ baseUrl: String, path: String, method: HTTPMethod, headers: [String: String]?, paramType: Networking.ParameterType, params: AnyObject?, completionHandler: @escaping NetworkingResult) -> Void {
        var networker:Networking?
        
        if let n = networkers[baseUrl] as? Networking {
            networker = n
        } else {
            let newN = Networking(baseURL: baseUrl, configurationType: .default)
            networkers[baseUrl] = newN
            networker = newN
        }
        
        if let networker = networker {
            if let headers = headers {
                networker.headerFields = headers
            }
            
            switch (method) {
            case .Post:
                networker.POST(path, parameterType: paramType, parameters: params, completion: {(JSON, headers, error) in
                    if let error = error {
                        print("An error happened: \(error)")
                        completionHandler([[String : Any]](), error)
                    } else {
                        if let data = JSON as? [String : Any] {
                            completionHandler([data], nil)
                        } else if let data = JSON as? [[String : Any]] {
                            completionHandler(data, nil)
                        } else {
                            completionHandler([[String : Any]](), error)
                        }
                    }
                })
            case .Get:
                networker.GET(path, parameters: params, completion: { (JSON, headers, error) in
                    if let error = error {
                        print("An error happened: \(error)")
                        completionHandler([[String : Any]](), error)
                    } else {
                        if let data = JSON as? [String : Any] {
                            completionHandler([data], nil)
                        } else if let data = JSON as? [[String : Any]] {
                            completionHandler(data, nil)
                        } else {
                            completionHandler([[String : Any]](), error)
                        }
                    }
                })
            case .Head:
                ()
            }
        }
    }
    
    func downloadImage(url: URL, completionHandler: @escaping (_ image: UIImage?, _ error: NSError?) -> Void) {
        var baseString = ""
        let path = url.path
        var networker:Networking?
        
        if let scheme = url.scheme {
            baseString = "\(scheme)://"
        }
        if let host = url.host {
            baseString.append(host)
        }
        
        if let n = networkers[baseString] as? Networking {
            networker = n
        } else {
            let newN = Networking(baseURL: baseString, configurationType: .default)
            networkers[baseString] = newN
            networker = newN
        }
        
        // skip from iCloud backups!
        // TODO: also move the movies to Documents directory and exclude from iCloud backup
        do {
            var destinationURL = try networker!.destinationURL(for: path)
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try destinationURL.setResourceValues(resourceValues)
        } catch _{
        }
        
        networker!.downloadImage(path) { networkingImage, networkingError in
            // TO DO:
            // Image from network
            networker!.downloadImage(path) { networkingImage2, networkingError2 in
                // Image from cache
                if let networkinError2 = networkingError2 {
                    completionHandler(nil, networkinError2)
                } else {
                    completionHandler(networkingImage2, nil)
                }
            }
        }
    }
    
    func downloadFile(url: URL, completionHandler: @escaping (Data?, NSError?) -> Void) {
        var baseString = ""
        let path = url.path
        var networker:Networking?
        
        if let scheme = url.scheme {
            baseString = "\(scheme)://"
        }
        if let host = url.host {
            baseString.append(host)
        }
        
        if let n = networkers[baseString] as? Networking {
            networker = n
        } else {
            let newN = Networking(baseURL: baseString, configurationType: .default)
            networkers[baseString] = newN
            networker = newN
        }
        
        networker!.downloadData(for: path, completion: completionHandler)
    }
    
    func fileExistsAt(url : URL, completion: @escaping (Bool) -> Void) {
        let checkSession = Foundation.URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 1.0 // Adjust to your needs
        
        let task = checkSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let httpResp: HTTPURLResponse = response as? HTTPURLResponse {
                completion(httpResp.statusCode == 200)
            }
        })
        
        task.resume()
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = NetworkingManager()
}
