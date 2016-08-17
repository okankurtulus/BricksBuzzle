//
//  ColorModel.swift
//  Click Brick
//
//  Created by Okan Kurtulus on 11/08/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import Foundation
import UIKit

class ColorModel: BaseModel {
    
    
    let colors = [UIColor.redColor(),
                  UIColor.yellowColor(),
                  UIColor.greenColor(),
                  UIColor.blueColor(),
                  UIColor.orangeColor(),
                  UIColor.magentaColor(),
                  UIColor.cyanColor(),
                  UIColor.brownColor(),
                  ]
    
    func randomColor(mod : Int =  Int(INT_MAX) ) -> UIColor {
        let random = Int(arc4random_uniform(UInt32(colors.count)))        
        return colors[random % mod]
    }    
    
}