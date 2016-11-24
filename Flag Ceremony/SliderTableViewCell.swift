//
//  SliderTableViewCell.swift
//  Flag Ceremony
//
//  Created by Jovit Royeca on 12/09/2016.
//  Copyright © 2016 Jovit Royeca. All rights reserved.
//

import UIKit
import CoreData
import GameplayKit
import Networking

@objc protocol SliderTableViewCellDelegate : NSObjectProtocol {
    func didSelectItem(_ item: Any)
}

enum CountType: String {
    case Views  = "Views",
    Plays  = "Plays"
}


class SliderTableViewCell: UITableViewCell {

    // MARK: Variables
    fileprivate var _countries: [Country]?
    var countries : [Country]? {
        get {
            return _countries
        }
        set (newValue) {
            _countries = newValue
            updateDisplay()
        }
    }
    var delegate:SliderTableViewCellDelegate?
    var slideshowTimer:Timer?
    var countType:CountType = .Views
    
    // MARK: Outlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Actions
    
    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let space = CGFloat(10.0)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        collectionView.register(UINib(nibName: "SliderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // MARK: Custom methods
    func updateDisplay() {
        collectionView.reloadData()
    }
    
    func startSlideShow() {
        slideshowTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(SliderTableViewCell.showSlide), userInfo: nil, repeats: true)
    }
    
    func stopSlideShow() {
        if slideshowTimer != nil {
            slideshowTimer!.invalidate()
        }
        slideshowTimer = nil
    }
    
    func showSlide() {
        if collectionView.indexPathsForVisibleItems.count > 0 {
            let indexPath = collectionView.indexPathsForVisibleItems.first
            let rows = collectionView(collectionView, numberOfItemsInSection: 0)
            var row = (indexPath! as NSIndexPath).row
            var newIndexPath:IndexPath?
            var bWillSlide = true
            
            if row == rows-1 {
                row = 0
                bWillSlide = false
                
            } else {
                row += 1
            }
            
            newIndexPath = IndexPath(row: row, section: 0)
            collectionView.scrollToItem(at: newIndexPath!, at: UICollectionViewScrollPosition.left, animated: bWillSlide)
            
        }
    }
    
    func imageWithBorder(fromImage source: UIImage) -> UIImage? {
        let size = source.size
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        source.draw(in: rect, blendMode: .normal, alpha: 1.0)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            context.stroke(rect)
            let newImg =  UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImg
        }
        return nil
    }
}

// MARK: UICollectionViewDataSource
extension SliderTableViewCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = (indexPath as NSIndexPath).row
        var cell:UICollectionViewCell?
        
        if let sliderCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SliderCollectionViewCell,
            let countries = countries {
            let country = countries[row]
            sliderCell.imageView.image = nil
            sliderCell.nameLabel.text = ""
            sliderCell.countIcon.image = nil
            sliderCell.countLabel.text = ""
            
            if let url = country.getFlagURLForSize(size: .Normal) {
                if let image = UIImage(contentsOfFile: url.path) {
                    sliderCell.imageView.image = imageWithBorder(fromImage: image)
                }
                sliderCell.nameLabel.text = country.name
            }
            
            switch countType {
            case .Views:
                sliderCell.countIcon.image = UIImage(named: "view-filled")
                if let views = country.views {
                    sliderCell.countLabel.text = "\(views)"
                } else {
                    sliderCell.countLabel.text = "0"
                }
            case .Plays:
                sliderCell.countIcon.image = UIImage(named: "play-filled")
                if let plays = country.plays {
                    sliderCell.countLabel.text = "\(plays)"
                } else {
                    sliderCell.countLabel.text = "0"
                }
            }
            cell = sliderCell
        }
        
        return cell!
    }
}

// MARK: UICollectionViewDelegate
extension SliderTableViewCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = (indexPath as NSIndexPath).row
        
        if let delegate = delegate,
            let countries = countries {
            let country = countries[row]
            delegate.didSelectItem(country)
        }
    }
}
