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
    
    func backgroundTapAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let rootView = view.window
            let location = sender.location(in: nil)
            let point = view.convert(location, from: rootView)
            if !view.point(inside: point, with: nil) {
                dismiss(animated: true, completion: {
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // add background tap gesture on iPads
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            if let rootView = view.window,
                let backgroundTap = backgroundTap {
                rootView.addGestureRecognizer(backgroundTap)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        // remove background tap gesture on iPads
        if (UIDevice.current.userInterfaceIdiom == .pad) {
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
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

