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
    
    @IBOutlet var scoreLabel : UILabel?
    @IBOutlet var levelLabel : UILabel?
    
    @IBOutlet var previousLevelButton : UIButton?
    @IBOutlet var nextLevelButton : UIButton?
    
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scoreLabel?.text = ""
        self.levelLabel?.text = ""
        self.previousLevelButton?.hidden = true
        self.nextLevelButton?.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initGameScene()
        let gameScene = skView.scene as! GameScene
        refreshLevel()
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
            
            skView.showsFPS = true
            //skView.showsNodeCount = true
            //skView.showsPhysics = true // Creates memory leak, so be carefull while open!
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            scene.scaleMode = .AspectFit
            scene.hudDelegate = self
            
            scene.backgroundColor = UIColor.blackColor()
            skView.presentScene(scene)
        }
    }
    
    @IBAction func help(sender : UIButton) {
        rotate(sender)
        let gameScene = skView.scene as! GameScene
        gameScene.resetScene()
    }
    
    @IBAction func nextLevel(sender : UIButton) {
        GameStatsModel.sharedInstance.gameOffset = min(0, GameStatsModel.sharedInstance.gameOffset + 1)
        refreshLevel()
        blink(sender)
    }
    
    @IBAction func previousLevel(sender : UIButton) {
        GameStatsModel.sharedInstance.gameOffset = max( (-1 * GameStatsModel.sharedInstance.gameLevel + 1) , (GameStatsModel.sharedInstance.gameOffset - 1))
        refreshLevel()
        blink(sender)
    }
    
    func setNavigationButtonVisibilities() {
        let offset = GameStatsModel.sharedInstance.gameOffset
        let level = GameStatsModel.sharedInstance.gameLevel
        nextLevelButton?.hidden = offset == 0
        previousLevelButton?.hidden = level + offset == 1
        
    }
    
    func refreshLevel() {
        let offset = GameStatsModel.sharedInstance.gameOffset
        let level = GameStatsModel.sharedInstance.gameLevel
        
        setNavigationButtonVisibilities()
        
        let gameScene = skView.scene as! GameScene
        let userDefinedlevel = level + offset
        
        if (userDefinedlevel != gameScene.level) {
            setLevelLabelText(userDefinedlevel)
            gameScene.resetScene()
        } else {
            print("Nothing to do...")
        }
    }
    
    func setLevelLabelText(level : Int) {
        levelLabel?.text = "Level \(level)"
    }
}

//MARK: - GameSceneHUDDelegate
extension GameViewController : GameSceneHUDDelegate {
    func resetCounter(level : Int) {
        print("Reset Counter")
        setNavigationButtonVisibilities()
        addPoints(-score)
        setLevelLabelText(level)
    }
    
    func addPoints(score : Int) {
        let toBlink = (score < 0 && score > -1 * self.score)
        self.score += score
        scoreLabel!.text = "\(self.score)"
        if(toBlink) { blink(scoreLabel!) }
    }
    
    func nextLevel() {
        GameStatsModel.sharedInstance.nexLevel()
    }
}


//MARK: - View Animations
extension GameViewController {
    func rotate(view : UIView) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = CGFloat(M_PI * 2)
        rotateAnimation.duration = 0.4
        rotateAnimation.removedOnCompletion = true
        view.layer.addAnimation(rotateAnimation, forKey: nil)
    }
    
    func blink(view : UIView) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.3
        animation.duration = 0.1
        animation.removedOnCompletion = true
        view.layer.addAnimation(animation, forKey: nil)
        animation.toValue = 1
        animation.duration = 0.1
        view.layer.addAnimation(animation, forKey: nil)
    }
    
    func hide(view : UIView) {
        view.alpha = 1
        UIView.animateWithDuration(0.2, animations: {
            view.alpha = 0
            }, completion: {(completed : Bool) in
                view.hidden = true
                view.alpha = 1
        })
    }
    
    func show(view : UIView) {
        view.alpha = 0
        UIView.animateWithDuration(0.2, animations: {
            view.alpha = 1
            }, completion: {(completed : Bool) in
                view.hidden = false
        })
    }
}
