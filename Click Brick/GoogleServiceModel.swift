//
//  GoogleServiceModel.swift
//  BabyPuzzle
//
//  Created by Okan Kurtulus on 29/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import Foundation

enum GoogleServiceKey : String {
    case AD_UNIT_ID_FOR_BANNER_TEST = "AD_UNIT_ID_FOR_BANNER_TEST"
    case AD_UNIT_ID_FOR_INTERSTITIAL_TEST = "AD_UNIT_ID_FOR_INTERSTITIAL_TEST"
    case AD_UNIT_ID_FOR_BANNER = "AD_UNIT_ID_FOR_BANNER"
    case AD_UNIT_ID_FOR_INTERSTITIAL = "AD_UNIT_ID_FOR_INTERSTITIAL"
}

class GoogleServiceModel: BaseModel {
    
    static let sharedInstance = GoogleServiceModel()
    var serviceDict: NSDictionary?
    
    private override init() {
        super.init()
        if let path = NSBundle.mainBundle().pathForResource("GoogleService-Info", ofType: "plist") {
            serviceDict = NSDictionary(contentsOfFile: path)
        }
    }
    
    func printDict() {
        if let dict = serviceDict {
            // Use your dict here
            print("GooglePlist : \n \(dict)")
        }
    }
    
    func read(key : GoogleServiceKey) -> String {
        var value = ""
        value = serviceDict?.valueForKey(key.rawValue) as! String
        return value
    }
}