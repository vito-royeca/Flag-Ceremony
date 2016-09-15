//
//  DismissableViewController.swift
//  Cineko
//
//  Created by Jovit Royeca on 11/09/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

class DismissableViewController: UIViewController {

    // MARK: Outlets
    var backgroundTap: UITapGestureRecognizer?
    
    func backgroundTapAction(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            let rootView = view.window
            let location = sender.locationInView(nil)
            let point = view.convertPoint(location, fromView: rootView)
            if !view.pointInside(point, withEvent: nil) {
                dismissViewControllerAnimated(true, completion: {
                    if let backgroundTap = self.backgroundTap {
                        rootView!.removeGestureRecognizer(backgroundTap)
                    }
                })
            }
        }
    }
    
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backgroundTap = UITapGestureRecognizer(target: self, action: #selector(DismissableViewController.backgroundTapAction(_:)))
        backgroundTap!.delegate = self
        backgroundTap!.numberOfTouchesRequired = 1
        backgroundTap!.cancelsTouchesInView = false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // add background tap gesture on iPads
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            if let rootView = view.window,
                let backgroundTap = backgroundTap {
                rootView.addGestureRecognizer(backgroundTap)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    
        // remove background tap gesture on iPads
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            if let rootView = view.window,
                let backgroundTap = backgroundTap {
                rootView.removeGestureRecognizer(backgroundTap)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: UIGestureRecognizerDelegate
extension DismissableViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

