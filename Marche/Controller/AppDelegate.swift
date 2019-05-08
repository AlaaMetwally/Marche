//
//  AppDelegate.swift
//  Marche
//
//  Created by Geek on 5/5/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController.shared

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.hexString
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent
        getCountries()
        dataController.load()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Marche")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
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

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
