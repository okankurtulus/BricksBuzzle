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

protocol GameSceneHUDDelegate {
    func resetCounter(level : Int)
    func addPoints(score : Int)
    func nextLevel()
}

class GameScene: SKScene {
    
    var isCheckingToFixPositions = false
    var isClearing = false
    var level : Int = 0
    
    let sequenceKey = "Sequence_Key"
    let contactKey = "Contact_Key"
    
    let applauseAction = SKAction.playSoundFileNamed("applause.mp3", waitForCompletion: false)
    let successAction = SKAction.playSoundFileNamed("success.mp3", waitForCompletion: false)
    let fitAction = SKAction.playSoundFileNamed("fit.mp3", waitForCompletion: false)
    let failAction = SKAction.playSoundFileNamed("fail.mp3", waitForCompletion: true)
    
    var hudDelegate: GameSceneHUDDelegate? = nil
    
    var brickWidth : CGFloat = 0
    var rowCount : Int = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        physicsWorld.contactDelegate = self
    }
    
    func fillBricks() {
        self.scene?.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0, 0), toPoint: CGPointMake((self.scene?.size.width)!, 0))
        self.scene?.physicsBody?.dynamic = false
        
        self.level = GameStatsModel.sharedInstance.gameLevel + GameStatsModel.sharedInstance.gameOffset
        self.hudDelegate?.resetCounter(level)
        let size = self.size
        let columnCount = 10
        
        let width : CGFloat = size.width / CGFloat(columnCount)
        let height = width
        brickWidth = width
        rowCount = Int( size.height / height) - 1
        
        let brickSize = CGSizeMake(width, height)
        let texture = SKTexture(imageNamed: "square_mask")
        
        for i in 0..<columnCount {
            for j in 0..<rowCount {
                let color = ColorModel().randomColor(self.level + 1)
                let brick = BrickNode(color: color, size: brickSize)
                
                brick.initPhysicsBody()
                let maskNode = SKSpriteNode(texture: texture, color: UIColor.clearColor(), size: brickSize)
                brick.addChild(maskNode)
                
                brick.physicsBody?.categoryBitMask = EntityCategory.BrickNode
                brick.physicsBody?.contactTestBitMask = EntityCategory.BrickNode
                brick.physicsBody?.collisionBitMask = EntityCategory.BrickNode
                
                let locationX = CGFloat(i) * width + (width / 2)
                let locationY = CGFloat(j) * height + (height / 2)
                let shiftY = size.height + (CGFloat(i+j) * height)
                brick.position = CGPointMake(locationX, locationY + shiftY)
                
                self.addChild(brick)
                self.hudDelegate?.addPoints(1)
            }
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let brickCandidate = self.nodesAtPoint(location).filter({(node : SKNode) in return node is BrickNode }).first as? BrickNode
            if let brick = brickCandidate as BrickNode! {
                var bricksToRemove = Set<BrickNode>()
                bricksToRemove = brick.checkToExplode(&bricksToRemove)
                if (bricksToRemove.count > 1) {
                    for brick in bricksToRemove {
                        brick.removeFromParent()
                        self.hudDelegate?.addPoints(-1)
                    }
                    
                    self.removeActionForKey(sequenceKey)
                    let waitAction = SKAction.waitForDuration(1)
                    let checkForCompletedAction = SKAction.runBlock({
                        [unowned self] in
                        self.checkIfCompleted()
                    })
                    self.runAction(SKAction.sequence([successAction, waitAction, checkForCompletedAction]), withKey: sequenceKey)
                }
            }
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    func checkIfCompleted() {
        var remainingBrickCount = 0
        var isBrickExistsToExplode = false
        if(self.children.count >= 0) {
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
            
            
            if(!isCompleted) {
                //TODO : Consider to slide bricks to fill empty spaces
                /*
                let leftSlideNode = SKNode()
                leftSlideNode.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0, 0), toPoint: CGPointMake(0, (self.scene?.size.height)!))
                self.addChild(leftSlideNode)
                leftSlideNode.physicsBody?.applyImpulse(CGVectorMake(100000, 0))
                */                
            } else if(isCompleted && remainingBrickCount == 0) {
                print("Finished with success")
                self.hudDelegate?.nextLevel()
                runAction(applauseAction)
                clearScene()
            } else if(isCompleted) {
                print("No more movements. It remained: \(remainingBrickCount) blocks!")
                runAction(failAction)
                clearScene()
            }
        }
    }
    
    func resetScene() {
        self.scene?.physicsBody = nil
        
        let waitAction = SKAction.waitForDuration(1)
        let clearAction = SKAction.runBlock({
            [unowned self] in
            self.removeRemainingNodes()
            self.fillBricks()
            })
        runAction(SKAction.sequence([waitAction, clearAction]))
    }
    
    func clearScene() {
        if (!isClearing) {
            isClearing = true
            let waitAction = SKAction.waitForDuration(0.8)
            
            let letGoAction = SKAction.runBlock({
                self.scene?.physicsBody = nil
            })
            
            let clearAction = SKAction.runBlock({
                [unowned self] in
                self.removeRemainingNodes()
                })
            
            let fillBricksAction = SKAction.runBlock({
                [unowned self] in
                self.fillBricks()
                })
            
            let clearingFalseAction = SKAction.runBlock({
                [unowned self] in
                self.isClearing = false
            })
            
            self.runAction(SKAction.sequence([waitAction, letGoAction, waitAction, clearAction, fillBricksAction, clearingFalseAction]))
        }
    }
    
    func removeRemainingNodes() {
        self.children.forEach({
            (node : SKNode) in
            if (node is BrickNode) {
                if(!scene!.frame.contains(node.position)) {
                    node.removeFromParent()
                } else {
                    node.physicsBody?.collisionBitMask = 0
                    node.physicsBody?.contactTestBitMask = 0
                    node.physicsBody?.categoryBitMask = 0
                    node.runAction(SKAction.sequence([
                        SKAction.waitForDuration(1),
                        SKAction.runBlock({
                            [unowned self] in
                            self.removeFromParent()
                        })
                    ]))
                }
            }
        })
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}

extension GameScene : SKPhysicsContactDelegate {
    func didBeginContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == EntityCategory.BrickNode && contact.bodyB.categoryBitMask == EntityCategory.BrickNode
            && scene?.physicsBody != nil
            && !isCheckingToFixPositions) {
            runAction(fitAction)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == EntityCategory.BrickNode && contact.bodyB.categoryBitMask == EntityCategory.BrickNode
            && scene?.physicsBody != nil) {
            self.removeActionForKey(contactKey)
            let waitAction = SKAction.waitForDuration(0.3)
            let checkForCompletedAction = SKAction.runBlock({
                [unowned self] in
                self.checkToFixLocations()
                })
            self.runAction(SKAction.sequence([waitAction, checkForCompletedAction]), withKey: contactKey)
        }
    }
    
    func checkToFixLocations()  {
        if(self.children.count > 0) {
            print("checking to Fix Locations")
            isCheckingToFixPositions = true
            let width = brickWidth
            let height = width
            let maxHeight = CGFloat(rowCount) * height + height / 2
            
            for x in (width/2).stride(to: self.size.width, by: width) {
                for y in (maxHeight).stride(to:  height/2 , by: -1*height) {
                    let point = CGPointMake(x, y)
                    if let brickCandidate = self.nodesAtPoint(point).filter({(node : SKNode) in return node is BrickNode }).first as? BrickNode {
                        if(brickCandidate.physicsBody!.dynamic) {
                            brickCandidate.position = point
                        }
                    }
                }
            }
            
            let waitAction = SKAction.waitForDuration(0.5)
            let blockAction = SKAction.runBlock({
                [unowned self] in
                self.isCheckingToFixPositions = false
                })
            self.runAction(SKAction.sequence([waitAction, blockAction]))
        }
        
    }
}
