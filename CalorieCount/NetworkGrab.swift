//
//  NetworkGrab.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import SystemConfiguration



class NetworkGrab{
    private let baseUrl: NSURL?
    private let appID1: String
    private let appKey1: String
    private let appKey2: String
    private let appID2: String
    private var idInUse: String?
    private var keyInUse: String?
    private(set) var state: State = .NotSearchedYet
    private var dataTask: NSURLSessionDataTask? = nil
    private let numOfResults: String
    private let fields: String


    
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func getInUse(){
        if idInUse == nil{
            idInUse = appID1
            keyInUse = appKey1
        }else if idInUse! == appID1{
            idInUse = appID2
            keyInUse = appKey2
        }else{
            idInUse = appID1
            keyInUse = appKey1
        }
    }
    
    
    enum State{
        case NotSearchedYet
        case Searching
        case SearchSuccess([Food])
        case NotFound
        case NoConnection
        
        
        func get() -> [Food]?{
            switch self{
                case SearchSuccess(let lst):
                    return lst
                default: return nil
            }
        }
    }
    
    init(){
        appID1 = "8b36dac9"
        appKey1 = "c79b530ed299ec9f53d64be135311b09"
        appID2 = "0a714183"
        appKey2 = "67d0f5774ec4e02095a3cc1b36a5ccc8"
        baseUrl = NSURL(string: "https://api.nutritionix.com/v1_1/search/")
        numOfResults = "0%3A50"
        state = .NotSearchedYet
        fields = "\"fields\":[\"nf_calories\",\"item_name\",\"brand_name\",\"nf_serving_size_unit\",\"nf_serving_size_qty\",\"item_id\"]"
    }
    
    func performSearch(mainText: String, filterText: String, completion: (Void) -> Void){
        if !connectedToNetwork(){
            state = .NoConnection
            return
        }
        state = .Searching
        dataTask?.cancel()
        getInUse()
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        let request = NSMutableURLRequest(URL: baseUrl!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "Post"
        var postString: String
        if filterText == ""{
            postString = "{\"appId\":\"\(idInUse!)\", \"appKey\":\"\(keyInUse!)\",\"query\":\"\(mainText)\",\(fields),\"offset\":0,\"limit\":50}"
        }else{
            postString = "{\"appId\":\"\(idInUse!)\", \"appKey\":\"\(keyInUse!)\",\"queries\":{\"item_name\":\"\(mainText)\", \"brand_name\":\"\(filterText)\"},\(fields),\"offset\":0,\"limit\":50}"
        }
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        dataTask = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            var success: Bool = false
            if let error = error where error.code == -999{
                return
            }
            
            if let httpResponse = response  as? NSHTTPURLResponse where httpResponse.statusCode == 200{
                let dict = self.parseJson(data!)
                success = true
                var searchResults = [Food]()
                let hitsLst = dict!["hits"]! as! NSArray
                let totalNum = min(hitsLst.count, 50)
                if totalNum == 0 {
                    success = false
                }else{
                    for index in 0..<totalNum{
                        let foodItem = Food()
                        let fields = dict!["hits"]![index]!["fields"]!!
                        let calories = fields["nf_calories"]!! as! Double
                        let name = fields["item_name"]!! as! String
                        let brandName = fields["brand_name"]!! as! String
                        let serve_unit = fields["nf_serving_size_unit"]!! as? String
                        let serve_qty = fields["nf_serving_size_qty"]!! as? Double
                        let food_id = fields["item_id"]!! as! String
                        foodItem.caloriesCount = calories
                        foodItem.foodContent = name
                        foodItem.brandContent = brandName
                        if let unit = serve_unit, qty = serve_qty{
                            foodItem.quantity = qty
                            foodItem.unit = unit
                        }else{
                            foodItem.quantity = nil
                            foodItem.unit = nil
                        }
                        foodItem.id = food_id
                        searchResults.append(foodItem)
                        }
                }
                if success{
                    self.state = .SearchSuccess(searchResults)
                }else{
                    self.state = .NotFound
                }
            }
            dispatch_async(dispatch_get_main_queue()){
                completion()
            }
        })
        
        dataTask!.resume()
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
