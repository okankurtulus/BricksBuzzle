//
//  CounterNode.swift
//  Click Brick
//
//  Created by Okan Kurtulus on 16/08/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//


import SpriteKit

class CounterNode: SKNode {
    var points : Int;
    var labelNode : SKLabelNode;
    var levelLabelNode : SKLabelNode;
    
    override init() {
        points = 0
        labelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        levelLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        super.init()
        
        labelNode.color = UIColor.whiteColor()
        labelNode.fontSize = 25
        labelNode.position = CGPointMake(0, 0)
        addPoints(0)
        self.addChild(labelNode)
        
        levelLabelNode.color = UIColor.whiteColor()
        levelLabelNode.fontSize = 25
        levelLabelNode.position = CGPointMake(200, 0)
        self.addChild(levelLabelNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addPoints(score : Int)  {
        points += score
        labelNode.text = "\(points)"
        labelNode.runAction(SKAction.sequence([
            SKAction.scaleTo(1.5, duration: 0.2),
            SKAction.scaleTo(1, duration: 0.1)
            ]))
        levelLabelNode.text = "Level \(GameStatsModel.sharedInstance.gameLevel)"
    }
    
    func reset() {
        addPoints(-1 * points)
    }
}