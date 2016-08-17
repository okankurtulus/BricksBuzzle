//
//  GameViewController.swift
//  Click Brick
//
//  Created by Okan Kurtulus on 05/08/16.
//  Copyright (c) 2016 Okan Kurtulus. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    @IBOutlet var skView : SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initGameScene()
        (skView.scene as! GameScene).fillBricks()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func initGameScene() {
        
        //if let scene = GameScene(fileNamed:"GameScene") {
        
        if let scene : GameScene = GameScene(size: skView.frame.size) {
            // Configure the view.
            //let skView = self.view as! SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            //skView.showsPhysics = true // Creates memory leak, so be carefull while open!
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFit
            
            scene.backgroundColor = UIColor.blackColor()

            //scene.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0, 0), toPoint: CGPointMake(skView.frame.size.width, 0))
            
            
            skView.presentScene(scene)
        }
    }
    
    @IBAction func help() {
        let gameScene = skView.scene as! GameScene
        gameScene.helpUser()        
    }
    
}
