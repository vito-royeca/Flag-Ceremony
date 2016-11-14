import UIKit
import DATAStack
import Networking
import Sync

let kMeinNetzkinoSessionId    = "sid"
let kMeinNetzkinoEmail        = "email"
let kMeinNetzkinoUsername     = "username"
let kMeinNetzkinoIsDeleted    = "isDeleted"
let kMeinNetzkinoUserNumber   = "userNumber"
let kMeinNetzkinoId           = "id"

typealias APIResult = (_ result: [[String : Any]], _ error: NSError?) -> Void

class API: NSObject {
    lazy internal var dataStack: DATAStack = DATAStack(modelName: "Flag Ceremony")

    func fetchCountries(completion: ((NSError?) -> Void)?) {
        let baseURL = CountriesAPIURL
        let path = "/info/all.json"
        let method:HTTPMethod = .Get
        let headers:[String: String]? = nil
        let paramType:Networking.ParameterType = .json
        let params = getParams() as AnyObject
        let completionHandler = { (result: [[String : Any]], error: NSError?) -> Void in
            if let error = error {
                completion?(error)
            } else {
                if let data = result.first {
                    if let countries = data["Results"] as? [String: [String: Any]] {
                        var newData = [[String : Any]]()
                        
                        for (_,value) in countries {
                            var country = [String : Any]()
                            for (key2,value2) in value {
                                country[key2] = value2
                            }
                            newData.append(country)
                        }
                        
                        self.dataStack.performInNewBackgroundContext { backgroundContext in
                            NotificationCenter.default.addObserver(self, selector: #selector(API.changeNotification(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: backgroundContext)
                            Sync.changes(newData, inEntityNamed: "Country", predicate: nil, parent: nil, inContext: backgroundContext, dataStack: self.dataStack, completion: { error in
                                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
                                completion?(error)
                            })
                        }
                    }
                }
            }
        }
        
        NetworkingManager.sharedInstance.doOperation(baseURL, path: path, method: method, headers: headers, paramType: paramType, params: params, completionHandler: completionHandler)
    }
    
    // MARK: Custom methods
    fileprivate func getParams() -> String {
        return "?x=100"
    }
    
    func changeNotification(_ notification: Notification) {
        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] {
            print("updatedObjects: \((updatedObjects as AnyObject).count)")
        }
        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] {
            print("deletedObjects: \((deletedObjects as AnyObject).count)")
        }
        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] {
            print("insertedObjects: \((insertedObjects as AnyObject).count)")
        }
    }

    // MARK: - Shared Instance
    static let sharedInstance = API()
}
