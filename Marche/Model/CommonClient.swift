//
//  CommonClient.swift
//  Marche
//
//  Created by Geek on 5/8/19.
//  Copyright © 2019 Geek. All rights reserved.
//


import Foundation

class CommonClient{
    // Single Session
    var session: URLSession { return URLSession.shared }
    static let sharedInstance = CommonClient()
    
    
    //    To Encode The Parameters
    func encodeParameters(params: [String: AnyObject]) -> String {
        let components = NSURLComponents()
        components.queryItems = params.map { (URLQueryItem(name: $0, value: String($1 as! String)) as URLQueryItem) }
        
        return components.percentEncodedQuery ?? ""
    }
    
    
    /*
     * Prepare NSMutableURLRequest object to call API
     */
    func prepareRequest(url: String,headers: [String: String], method: String, params: [String: AnyObject] = [String: AnyObject](), body: AnyObject? = nil) -> NSMutableURLRequest {
        let url = url + "?" + self.encodeParameters(params: params)
        let request = NSMutableURLRequest(url: URL(string: url)! as URL)
        request.httpMethod = method
        
        for (header, value) in headers {
            request.addValue(value, forHTTPHeaderField: header)
        }
        
        if body != nil {
            do {
                request.httpBody = try! JSONSerialization.data(withJSONObject: body!, options: [])
            }
        }
        
        return request
    }
    
    /*
     * Send request using session task and try parse result as JSON object
     */
    func processResuest(request: NSMutableURLRequest,forUdacity:String = "n" ,handler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) {
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            // Was there an error?
            guard error == nil else {
                print("Error in response")
                handler(nil, "Connection error")
                return
            }
            
            // Did we get a successful 2XX response?
            guard let status = (response as? HTTPURLResponse)?.statusCode, status != 403 else {
                print("Wrong response status code (403)")
                handler( nil, "Username or password is incorrect")
                return
            }
            
            // Did we get a successful 2XX response?
            guard status >= 200 && status <= 299 else {
                print("Wrong response status code \(status)")
                handler ( nil, "Connection error")
                return
            }
            
            // Was there any data returned?
            guard var data = self.processResponseData(data: data! as NSData) as Data? else {
                print("Wrong response data")
                handler(nil, "Connection error")
                return
            }
            
            if forUdacity=="y"{
                let range = Range(5..<data.count)
                data = data.subdata(in: range) /* subset response data! */
                
            }
            
            let json:[String:AnyObject]!
            do {
                json = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String:AnyObject]
                
                //                print("yes write ",json)
            } catch {
                print("JSON converting error ",data )
                handler(nil, "Connection error")
                return
            }
            
            handler(json! as AnyObject,nil)
        }
        
        task.resume()
    }
    
    
    /*
     * Process response data for next parsing
     */
    func processResponseData(data: NSData?) -> NSData? {
        return data!
    }
    
    func getCategories(){
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

