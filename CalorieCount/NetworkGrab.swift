//
//  NetworkGrab.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation

class NetworkGrab{
    let baseUrl: NSURL?
    let appID: String
    let appKey: String
    
    init(){
        appID = "8b36dac9"
        appKey = "c79b530ed299ec9f53d64be135311b09"
        baseUrl = NSURL(string: "https://api.nutritionix.com/v1_1/search/")
    }
    
    func performSearch(url: NSURL){
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        let request = NSURLRequest(URL: url )
        let dataTask = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            let dict = self.parseJson(data!)
            print(dict!)
        })
        dataTask.resume()
    }
    
    func urlWithSearchText(text: String) -> NSURL{
        let spaceEscapeText = text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: "\(spaceEscapeText)?results=0%3A1&cal_min=0&cal_max=50000&appId=\(appID)&appKey=\(appKey)", relativeToURL: baseUrl)
        return url!
    }
    
    func parseJson(data:NSData) -> [String: AnyObject]?{
        do{
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        }catch{
            print("JSON ERROR: \(error)")
            return nil
        }
    }
    
}
