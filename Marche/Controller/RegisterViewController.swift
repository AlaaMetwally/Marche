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
    
    @IBOutlet weak var Login: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var password = PasswordTextFieldDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        passwordTextField.delegate = password
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        activityIndicator.isHidden = true
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if (self.emailTextField.text?.isEmpty)! || (self.passwordTextField.text?.isEmpty)! {
            showErrorAlert(message: "please fill all required fields")
            return
        }
        // Try to login with Udacity API
        UdacityClient.shared.postSession(email: emailTextField.text!, password: passwordTextField.text!) { (result,error: String?) in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    self.showErrorAlert(message: error!)
                    return
                }
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                Singleton.sharedInstance.userEmail = self.emailTextField.text!
                CommonClient.sharedInstance.getCategories()
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

extension RegisterViewController{
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if emailTextField.isEditing || passwordTextField.isEditing{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}
extension RegisterViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        unsubscribeFromKeyboardNotifications()
        return true
    }
}
