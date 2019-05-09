//
//  RegisterViewController.swift
//  Marche
//
//  Created by Geek on 5/5/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var Login: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var password = PasswordTextFieldDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        passwordTextField.delegate = password
        getCountries()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func getCountries(){
        var components = URLComponents()
        components.scheme = "http"
        components.host = "souq.hardtask.co"
        components.path = "/app/app.asmx/GetCategories"
        components.queryItems = [URLQueryItem]()
        
        var parameters = ["categoryId" : 0 ,"countryId" : 1]
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        let url = components.url!
        let request = URLRequest(url: url)
        self.requestHandler(request: request){ (results,error) in
            guard let results = results else{
                return
            }
            var categories: [Category] = []
            
            for res in results {
                categories.append(Category(dictionary: res))
            }
            Singleton.sharedInstance.categories = categories
        }
    }
    
    func requestHandler(request: URLRequest,completionHandler handler:@escaping (_ result: [[String:AnyObject]]?,_ error: String?) -> Void){
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            func displayError(_ error: String) {
                print(error)
                handler(nil,error)
            }
            
            /* GUARD: Was there an error? */
            guard error == nil else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: [[String:AnyObject]]!
            do {
                parsedResult = try (JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String:AnyObject]])
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            handler(parsedResult,nil)
        }
        task.resume()
    }
}
