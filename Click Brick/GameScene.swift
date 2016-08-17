//
//  GameScene.swift
//  Click Brick
//
//  Created by Okan Kurtulus on 05/08/16.
//  Copyright (c) 2016 Okan Kurtulus. All rights reserved.
//

import SpriteKit

struct EntityCategory {
    static let BrickNode : UInt32 = 1 << 0
}

class GameScene: SKScene {
    
    let applauseAction = SKAction.playSoundFileNamed("applause.mp3", waitForCompletion: false)
    let successAction = SKAction.playSoundFileNamed("success.mp3", waitForCompletion: false)
    let fitAction = SKAction.playSoundFileNamed("fit.mp3", waitForCompletion: false)
    let failAction = SKAction.playSoundFileNamed("fail.mp3", waitForCompletion: true)
    
    var counterNode : CounterNode? = nil;
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        physicsWorld.contactDelegate = self
        
        let counterNodeHeight : CGFloat = 35
        counterNode = CounterNode()        
        counterNode?.position = CGPointMake( counterNodeHeight, self.size.height - counterNodeHeight)
        counterNode?.zPosition = 50
        self.addChild(counterNode!)
    }
    
    func fillBricks() {
        self.counterNode?.reset()
        let size = self.size
        let columnCount = 10
        
        let width : CGFloat = size.width / CGFloat(columnCount)
        let height = width
        let rowCount = Int( size.height / height)
        
        
        //let texture = SKTexture(imageNamed: "square_mask")
        let brickSize = CGSizeMake(width, height)
        
        
        let level = GameStatsModel.sharedInstance.gameLevel
        
        for j in 0..<rowCount {
            for i in 0..<columnCount {
                
                let brick = BrickNode(rectOfSize: brickSize, cornerRadius: brickSize.width / 5 )
                brick.fillColor = ColorModel().randomColor(level + 1)
                
                brick.initPhysicsBody()
                
                brick.antialiased = false
                brick.lineWidth = 3
                brick.strokeColor = self.backgroundColor
                
                
                let locationX = CGFloat(i) * width + (width / 2)
                let locationY = CGFloat(j) * height + (height / 2)
                let shiftY = size.height + (CGFloat(i+j) * height)
                brick.position = CGPointMake(locationX, locationY + shiftY)
                
                brick.physicsBody?.categoryBitMask = EntityCategory.BrickNode
                brick.physicsBody?.contactTestBitMask = EntityCategory.BrickNode
                
                self.addChild(brick)
                self.counterNode?.addPoints(1)
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let brickCandidate = self.nodesAtPoint(location).filter({(node : SKNode) in return node is BrickNode }).first as? BrickNode
            if let brick = brickCandidate as BrickNode! {
                var bricksToRemove = Set<BrickNode>()
                bricksToRemove = brick.checkToExplode(&bricksToRemove)
                if (bricksToRemove.count > 1) {
                    for brick in bricksToRemove {
                        brick.removeFromParent()
                        self.counterNode?.addPoints(-1)
                    }
                    self.runAction(successAction)
                }
            }
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //self.checkIfCompleted()
    }
    
    func helpUser(){
        print("Inserting bricks...")
        removeRemainingNodes()
        self.fillBricks()
    }
    
    func checkIfCompleted() {
        var remainingBrickCount = 0
        var isBrickExistsToExplode = false
        if(self.children.count > 0) {
            for node in self.children {
                if let brickNode = node as? BrickNode {
                    if(brickNode.hasSameNeighbour()) {
                        isBrickExistsToExplode = true
                    } else {
                        remainingBrickCount += 1
                    }
                }
            }
            let isCompleted = !isBrickExistsToExplode
            
            
            if(isCompleted && remainingBrickCount == 0) {
                print("Finished with success")
                GameStatsModel.sharedInstance.nexLevel()
                runAction(applauseAction)
                clearScene()
            } else if(isCompleted) {
                print("No more movements. It remained: \(remainingBrickCount) blocks!")
                runAction(failAction)
                clearScene()
            }
        }
    }
    
    func clearScene() {
        let waitAction = SKAction.waitForDuration(0.5)
        let hideAction = SKAction.fadeAlphaTo(0, duration: 1)
        let showAction = SKAction.fadeAlphaTo(1, duration: 0.5)
        let clearAction = SKAction.runBlock({
            [unowned self] in
            self.removeRemainingNodes()
            })
        
        let fillBricksAction = SKAction.runBlock({
            [unowned self] in
            self.fillBricks()
        })
        
        
        self.runAction(SKAction.sequence([waitAction, hideAction, clearAction, showAction, fillBricksAction]))
    }
    
    func removeRemainingNodes() {
        self.children.forEach({ (node : SKNode) in if (node is BrickNode) { node.removeFromParent()} })
        self.counterNode?.reset()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}

extension GameScene : SKPhysicsContactDelegate {
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == EntityCategory.BrickNode && contact.bodyB.categoryBitMask == EntityCategory.BrickNode) {
            runAction(fitAction)
        }
    }
    
}

