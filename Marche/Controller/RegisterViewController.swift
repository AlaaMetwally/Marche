//
//  RegisterViewController.swift
//  Marche
//
//  Created by Geek on 5/5/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit

class RegisterViewController: UIViewController{
    
    @IBOutlet weak var Register: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func registerButton(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        self.present(controller, animated: true, completion: nil)
    }
}
