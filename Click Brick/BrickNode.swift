//
//  BrickNode.swift
//  Click Brick
//
//  Created by Okan Kurtulus on 05/08/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import SpriteKit

class BrickNode: SKShapeNode {
    static let NAME = "BrickNode"
    
    /*
    init(texture: SKTexture?, color: UIColor, size: CGSize) {
        self.size = size
        self.color = color
        
        let cornerRadius : CGFloat = 30
        let padding : CGFloat = 5
        let rect = CGRectMake(0, 0, size.width - padding, size.height - padding)
        super.init(rect: rect, cornerRadius: cornerRadius)
        
        self.name = BrickNode.NAME
        
        //let block = SKSpriteNode(texture: nil, color: color, size: size)
        //block.position = CGPointMake(0, 0)
        //self.addChild(block)
        
        //let node = SKSpriteNode(texture: texture, color: UIColor.clearColor(), size: size)
        //node.position = CGPointMake(0, 0)
        //self.addChild(node)
        
        
        
        self.lineWidth = 0
        self.fillColor = color
        self.antialiased = true
        
     
        
    }*/
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPhysicsBody()  {
        let size = self.frame.size
        let phsicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(size.width * 0.6 , size.height))
        
        phsicsBody.mass = 2
        phsicsBody.allowsRotation = false
        phsicsBody.restitution = 0.1
        
        phsicsBody.friction = 0
        
        phsicsBody.dynamic = true
        phsicsBody.usesPreciseCollisionDetection = false
        self.physicsBody = phsicsBody
    }
    
    func checkToExplode(inout nodesToExplode : Set<BrickNode>) -> Set<BrickNode> {
        nodesToExplode.insert(self)
        
        let leftBrick = isSame(self.leftBrick())
        let rightBrick = isSame(self.rightBrick())
        let aboveBrick = isSame(self.aboveBrick())
        let belowBrick = isSame(self.belowBrick())
        
        if (leftBrick != nil && !nodesToExplode.contains(leftBrick!)) {
           nodesToExplode = nodesToExplode.union(leftBrick!.checkToExplode(&nodesToExplode))
        }
        
        if (rightBrick != nil && !nodesToExplode.contains(rightBrick!)) {
            nodesToExplode = nodesToExplode.union(rightBrick!.checkToExplode(&nodesToExplode))
        }
        
        if (aboveBrick != nil && !nodesToExplode.contains(aboveBrick!)) {
            nodesToExplode = nodesToExplode.union(aboveBrick!.checkToExplode(&nodesToExplode))
        }
        
        if (belowBrick != nil && !nodesToExplode.contains(belowBrick!)) {
            nodesToExplode = nodesToExplode.union(belowBrick!.checkToExplode(&nodesToExplode))
        }
        
        return nodesToExplode;
    }
    
    func hasSameNeighbour() -> Bool {
        return isSame(self.leftBrick()) != nil
        || isSame(self.rightBrick()) != nil
        || isSame(self.aboveBrick()) != nil
        || isSame(self.belowBrick()) != nil
    }
    
    func isSame(brick : BrickNode?) -> BrickNode? {
        return (brick != nil && brick!.fillColor == self.fillColor) ? brick : nil;
    }
    
    //MARK - Navigation
    
    func leftBrick() -> BrickNode? {
        return brickAtLocation(-1, yShift: 0)
    }
    
    func rightBrick() -> BrickNode? {
        return brickAtLocation(1, yShift: 0)
    }
    
    func aboveBrick() -> BrickNode? {
        return brickAtLocation(0, yShift: 1)
    }
    
    func belowBrick() -> BrickNode? {
        return brickAtLocation(0, yShift: -1)
    }
    
    func brickAtLocation(xShift : Int, yShift : Int) -> BrickNode? {
        var brick : BrickNode?;
        if let parent : SKNode = self.parent {
            let locationX = self.position.x + CGFloat(xShift) * self.frame.size.width
            let locationY = self.position.y + CGFloat(yShift) * self.frame.size.height
            
            let brickPosition = CGPointMake(locationX, locationY)
            if(parent.frame.contains(brickPosition)) {
                brick = parent.nodesAtPoint(brickPosition).filter({(node : SKNode) in return node is BrickNode }).first as? BrickNode
            }
        }
        return brick
    }
    
}