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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCountries()
    }
    
    @IBOutlet weak var Register: UIButton!
    
    @IBAction func registerButton(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        self.present(controller, animated: true, completion: nil)
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
            var categories: [Category] = []
            for res in results!{
                categories.append(Category(dictionary: res))
            }
            Singleton.sharedInstance.Categories = categories
        }
    }
    
    func requestHandler(request: URLRequest,completionHandler handler:@escaping (_ result: [[String:Any]]?,_ error: String?) -> Void){
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
            let parsedResult: [[String:Any]]!
            do {
                parsedResult = try (JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String:Any]])
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            handler(parsedResult,nil)
        }
        task.resume()
    }
}
