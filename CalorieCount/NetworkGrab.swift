//
//  NetworkGrab.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import SystemConfiguration
import  Alamofire

class NetworkGrab{
    fileprivate let baseUrl = URL(string: "https://api.nutritionix.com/v1_1/search/")!
    fileprivate let appID1 = "8b36dac9"
    fileprivate let appKey1 = "c79b530ed299ec9f53d64be135311b09"
    fileprivate let appKey2 = "67d0f5774ec4e02095a3cc1b36a5ccc8"
    fileprivate let appID2 = "0a714183"
    fileprivate var idInUse: String?
    fileprivate var keyInUse: String?
    fileprivate(set) var state = State.notSearchedYet
    fileprivate let fields = ["nf_calories","item_name","brand_name","nf_serving_size_unit","nf_serving_size_qty","item_id"]
    fileprivate var request: Alamofire.Request?
    fileprivate var success = true
    
    func performSearch(_ mainText: String, filterText: String, completion: @escaping (Void)->Void){
        request?.cancel()
        if !connectedToNetwork(){
            state = .noConnection
            return
        }
        state = .searching
        getInUse()
        let headers = ["Content-Type":"application/json"]
        let parameter = pickParameter(filterText, mainText: mainText)
        request = Alamofire.request(.POST, baseUrl, parameters: parameter, encoding: .JSON, headers: headers)
        request!.responseJSON{
            [unowned self] response in
            var dict: [String: AnyObject]
            switch response.result{
            case .Success(let value):
                dict = value as! [String : AnyObject]
                let searchResults = self.putInFood(dict)
                if self.success{
                    self.state = .SearchSuccess(searchResults!)
                }else{
                    self.state = .NotFound
                }
            case .Failure:
                self.state = .NotFound
            }
            dispatch_async(dispatch_get_main_queue()){
                completion()
            }
        }
    }
    
    func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
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
        case notSearchedYet
        case searching
        case searchSuccess([Food])
        case notFound
        case noConnection
        
        func get() -> [Food]?{
            switch self{
            case .searchSuccess(let lst):
                return lst
            default: return nil
            }
        }
    }
    
    func pickParameter(_ filterText: String, mainText: String) -> [String: AnyObject]{
        var parameter: [String: AnyObject]
        if filterText == ""{
            parameter = ["appId": idInUse! as AnyObject, "appKey": keyInUse! as AnyObject, "query": mainText as AnyObject, "offset": 0 as AnyObject, "limit": 50 as AnyObject]
        }else{
            parameter = ["appId": idInUse! as AnyObject, "appKey": keyInUse! as AnyObject, "queries": ["item_name":mainText, "brand_name": filterText], "offset": 0, "limit": 50]
        }
        parameter["fields"] = fields as AnyObject?
        return parameter
    }
    
    func putInFood(_ dict: [String: AnyObject]) -> [Food]?{
        success = true
        var searchResults = [Food]()
        let hitsLst = dict["hits"]! as! NSArray
        let totalNum = min(hitsLst.count, 50)
        if totalNum == 0 {
            success = false
            return nil
        }else{
            for index in 0..<totalNum{
                let foodItem = Food()
                let fields = dict["hits"]![index]!["fields"]!!
                let calories = fields["nf_calories"]!! as! Double
                let name = fields["item_name"]!! as! String
                let brandName = fields["brand_name"]!! as! String
                let serve_unit = fields["nf_serving_size_unit"]!! as? String
                let serve_qty = fields["nf_serving_size_qty"]!! as? Double
                let food_id = fields["item_id"]!! as! String
                foodItem.caloriesCount = calories
                foodItem.foodContent = name
                foodItem.brandContent = brandName
                if let unit = serve_unit, let qty = serve_qty{
                    foodItem.quantity = qty
                    foodItem.unit = unit
                }else{
                    foodItem.quantity = 0.0
                    foodItem.unit = "Unknown"
                }
                foodItem.id = food_id
                searchResults.append(foodItem)
            }
            return searchResults
        }
    }


}

