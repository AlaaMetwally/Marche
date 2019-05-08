//
//  CommonExtension.swift
//  Marche
//
//  Created by Geek on 5/8/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showErrorAlert(message: String, dismissButtonTitle: String = "OK") {
        let controller = UIAlertController(title: "Something Wrong !!", message: message, preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: dismissButtonTitle, style: .default) { (action: UIAlertAction!) in
            controller.dismiss(animated: true, completion: nil)
        })
        
        self.present(controller, animated: true, completion: nil)
    }
}
