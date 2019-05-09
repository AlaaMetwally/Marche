//
//  PasswordTextFieldDelegate.swift
//  Marche
//
//  Created by Geek on 5/9/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit

class PasswordTextFieldDelegate : NSObject, UITextFieldDelegate{
    func textField(_ textField: UITextField,shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool{
        textField.isSecureTextEntry = true
        return true;
    }
}
