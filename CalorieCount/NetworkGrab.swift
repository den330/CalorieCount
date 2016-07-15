//
//  NetworkGrab.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import SystemConfiguration
import Alamofire

class NetworkGrab{
    private let baseUrl = NSURL(string: "https://api.nutritionix.com/v1_1/search/")!
    private let appID1 = "8b36dac9"
    private let appKey1 = "c79b530ed299ec9f53d64be135311b09"
    private let appKey2 = "67d0f5774ec4e02095a3cc1b36a5ccc8"
    private let appID2 = "0a714183"
    private var idInUse: String?
    private var keyInUse: String?
    private(set) var state = State.NotSearchedYet
    private let fields = ["nf_calories","item_name","brand_name","nf_serving_size_unit","nf_serving_size_qty","item_id"]
    private var request: Alamofire.Request?
    private var success = true
    
    func performSearch(mainText: String, filterText: String, completion: Void->Void){
        request?.cancel()
        if !connectedToNetwork(){
            state = .NoConnection
            return
        }
        state = .Searching
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
            case .Failure(let error):
                if error.code == -999 {return}
                print(error)
                return
            }
            let searchResults = self.putInFood(dict)
            if self.success{
                    self.state = .SearchSuccess(searchResults!)
            }else{
                    self.state = .NotFound
                }
            dispatch_async(dispatch_get_main_queue()){
                completion()
            }
        }
    }
    
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
    
    func pickParameter(filterText: String, mainText: String) -> [String: AnyObject]{
        var parameter: [String: AnyObject]
        if filterText == ""{
            parameter = ["appId": idInUse!, "appKey": keyInUse!, "query": mainText, "offset": 0, "limit": 50]
        }else{
            parameter = ["appId": idInUse!, "appKey": keyInUse!, "queries": ["item_name":mainText, "brand_name": filterText], "offset": 0, "limit": 50]
        }
        parameter["fields"] = fields
        return parameter
    }
    
    func putInFood(dict: [String: AnyObject]) -> [Food]?{
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
                if let unit = serve_unit, qty = serve_qty{
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

