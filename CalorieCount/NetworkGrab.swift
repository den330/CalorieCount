//
//  NetworkGrab.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation

class NetworkGrab{
    private let baseUrl: NSURL?
    private let appID: String
    private let appKey: String
    private(set) var state: State = .NotSearchedYet
    
    
    enum State{
        case NotSearchedYet
        case Searching
        case SearchSuccess([Food])
        case NotFound
        
        func get() -> [Food]?{
            switch self{
                case SearchSuccess(let lst):
                    return lst
                default: return nil
            }
        }
    }
    
    init(){
        appID = "8b36dac9"
        appKey = "c79b530ed299ec9f53d64be135311b09"
        baseUrl = NSURL(string: "https://api.nutritionix.com/v1_1/search/")
    }
    
    func performSearch(url: NSURL, completion: (Void) -> Void){
        state = .Searching
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        let request = NSURLRequest(URL: url )
        let dataTask = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            var success: Bool = false
            
            
            if let error = error where error.code == -999{
                return
            }
            
            if let httpResponse = response  as? NSHTTPURLResponse where httpResponse.statusCode == 200{
                let dict = self.parseJson(data!)
                print(dict)
                success = true
                var searchResults = [Food]()
                for index in 0..<5{
                    let foodItem = Food()
                    let hitsLst = dict!["hits"]! as! NSArray
                    if hitsLst.count == 0{
                        success = false
                        break
                    }
                    let fields = dict!["hits"]![index]!["fields"]!!
                    let calories = fields["nf_calories"]!! as! Double
                    let name = fields["item_name"]!! as! String
                    let brandName = fields["brand_name"]!! as! String
                    let serve_unit = fields["nf_serving_size_unit"]!! as! String
                    let serve_qty = fields["nf_serving_size_qty"]!! as! Double
                    let food_id = fields["item_id"]!! as! String
                    foodItem.caloriesCount = calories
                    foodItem.foodContent = name
                    foodItem.brandContent = brandName
                    foodItem.quantity = String(serve_qty) + " " + serve_unit
                    foodItem.id = food_id
                    searchResults.append(foodItem)
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
        dataTask.resume()
    }
    
    func urlWithSearchText(text: String) -> NSURL{
        let spaceEscapeText = text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: "\(spaceEscapeText)?results=0%3A5&fields=nf_calories%2Citem_name%2Cbrand_name%2Cnf_serving_size_unit%2Cnf_serving_size_qty%2Citem_id&cal_min=0&cal_max=50000&appId=\(appID)&appKey=\(appKey)", relativeToURL: baseUrl)
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
