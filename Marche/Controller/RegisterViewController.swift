//
//  RegisterViewController.swift
//  Marche
//
//  Created by Geek on 5/5/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RegisterViewController: UIViewController, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var Register: UIButton!
    let dataController = DataController.shared
    var fetchedResultsController:NSFetchedResultsController<Category>!
    let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sortDescriptor = NSSortDescriptor(key: "titleEn", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "category-album")
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
       
        if( fetchedResultsController.fetchedObjects?.count == 0){
            getCountries()
        }
    }

    @IBAction func registerButton(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        self.present(controller, animated: true, completion: nil)
    }
    
    func getCountries(){
        var components = URLComponents()
        let fetchCategory = Category(context: DataController.shared.viewContext)
        
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
            for res in results{
                fetchCategory.titleEn = res["TitleEN"] as! String
                fetchCategory.titleAr = res["TitleAR"] as! String
                fetchCategory.productCount = res["ProductCount"] as! String
                fetchCategory.haveModel = res["HaveModel"] as! String
                fetchCategory.photo = res["Photo"] as! String
                
                if let subCat = res["SubCategories"] as? [[String:AnyObject]]{
                    for sub in subCat{
                        let fetchSubCategory = Category(context: DataController.shared.viewContext)
                        fetchSubCategory.titleEn = sub["TitleEN"] as! String
                        fetchSubCategory.titleAr = sub["TitleAR"] as! String
                        fetchSubCategory.productCount = sub["ProductCount"] as! String
                        fetchSubCategory.haveModel = sub["HaveModel"] as! String
                        fetchSubCategory.photo = sub["Photo"] as! String
                        fetchCategory.categories?.adding(fetchSubCategory)
                    }
                }
                try? self.dataController.viewContext.save()
            }
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
