//
//  GameScene.swift
//  Click Brick
//
//  Created by Okan Kurtulus on 05/08/16.
//  Copyright (c) 2016 Okan Kurtulus. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Ground level, i am holding marbles...."
        myLabel.fontSize = 45
        
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:0)
        myLabel.position.y += 5*myLabel.frame.size.height
        
        myLabel.physicsBody = SKPhysicsBody(rectangleOfSize: myLabel.frame.size)
        myLabel.physicsBody?.affectedByGravity = false
        myLabel.physicsBody?.mass = 99999
        
        self.addChild(myLabel)
        
        self.physicsWorld.gravity = CGVectorMake(0, -10)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let spaceShip = SKSpriteNode(imageNamed:"marble")
            
            spaceShip.xScale = 0.5
            spaceShip.yScale = 0.5
            spaceShip.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            let reversedAction = SKAction.reversedAction(action)
            let sequence = SKAction.sequence([action, reversedAction(), reversedAction(), action])
            
            //spaceShip.runAction(SKAction.repeatActionForever(sequence))
            //sprite.runAction(SKAction.repeatActionForever(action))
            
            let phsicsBody = SKPhysicsBody(circleOfRadius: spaceShip.size.height/2)
            phsicsBody.dynamic = true
            phsicsBody.mass = 1
            
            
            
            spaceShip.physicsBody = phsicsBody
            
            self.addChild(spaceShip)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
