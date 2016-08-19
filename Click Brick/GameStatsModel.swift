//
//  GameStatsModel.swift
//  BabyPuzzle
//
//  Created by Okan Kurtulus on 19/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import Foundation


class GameStatsModel: BaseModel {
    static let sharedInstance = GameStatsModel()
    
    private let gameLevelKey = "GameLevelKey"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var gameOffset = 0
    var gameLevel : Int
    
    override private init() {
        gameLevel = max(1, defaults.integerForKey(gameLevelKey))
        #if DEBUG
            gameLevel = (Int(arc4random_uniform(UInt32(1000))) % 4)
        #endif
    }
    
    func nexLevel() {
        gameLevel += 1
        defaults.setObject(gameLevel, forKey: gameLevelKey)
        defaults.synchronize()
    }
}