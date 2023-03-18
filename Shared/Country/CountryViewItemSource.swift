//
//  CountryViewItemSource.swift
//  Flag Ceremony (iOS)
//
//  Created by Vito Royeca on 3/17/23.
//

import UIKit
import LinkPresentation

class CountryViewItemSource: NSObject, UIActivityItemSource {
    let country: FCCountry
    
    init(country: FCCountry) {
        self.country = country
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return country.displayName
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        guard let url = country.getFlagURL(),
           let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return country.displayName
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        guard let url = country.getFlagURL(),
           let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        
        return image
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        
        guard let url = country.getFlagURL(),
           let image = UIImage(contentsOfFile: url.path) else {
            return metadata
        }
        
        metadata.iconProvider = NSItemProvider(object: image)
        metadata.title = country.displayName
        return metadata
    }
}
