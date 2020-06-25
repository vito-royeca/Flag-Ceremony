//
//  CommonViewController.swift
//  Flag Ceremony
//
//  Created by Jovito Royeca on 06/04/2017.
//  Copyright © 2017 Jovit Royeca. All rights reserved.
//

import UIKit
import MMDrawerController

class CommonViewController: UIViewController {

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: Custom methods
    func showMenu() {
        if let navigationVC = mm_drawerController.leftDrawerViewController as? UINavigationController {
            var menuView:MenuViewController?
            
            for drawer in navigationVC.viewControllers {
                if drawer is MenuViewController {
                    menuView = drawer as? MenuViewController
                }
            }
            if menuView == nil {
                menuView = MenuViewController()
                navigationVC.addChild(menuView!)
            }
            
            navigationVC.popToViewController(menuView!, animated: true)
        }
        mm_drawerController.toggle(.left, animated:true, completion:nil)
    }

    func showCountryList() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            performSegue(withIdentifier: "showCountriesAsPush", sender: nil)
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            performSegue(withIdentifier: "showCountriesAsPopup", sender: nil)
        }
    }
    
    func showParentalGate(completion: @escaping () -> Void) {
        let random = NSNumber.randomNumber()
        let roman = random.toRomanNumeral()
        
        let alertController = UIAlertController(title: "Parental Gate", message: "Ask your parent or guardian to help you answer the question below.\n\nThe Roman Numeral \(roman) is equivalent to?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            var answer:String?
            
            if let textField = alertController.textFields!.first {
                answer = textField.text
            }
            
            if answer == random.stringValue {
                completion()
            } else {
                let ac2 = UIAlertController(title: "Parental Gate", message: "The answer is incorrect answer.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (_) in }
                ac2.addAction(action)
                self.present(ac2, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Answer"
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
