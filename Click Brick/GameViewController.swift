//
//  GameViewController.swift
//  Click Brick
//
//  Created by Okan Kurtulus on 05/08/16.
//  Copyright (c) 2016 Okan Kurtulus. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

//MARK - ByPass Print for Prod
func print(items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        var idx = items.startIndex
        let endIdx = items.endIndex
        
        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        }
            while idx < endIdx
    #endif
}

class GameViewController: UIViewController {

    @IBOutlet var skView : SKView!
    
    @IBOutlet var scoreLabel : UILabel?
    @IBOutlet var levelLabel : UILabel?
    
    @IBOutlet var previousLevelButton : UIButton?
    @IBOutlet var nextLevelButton : UIButton?
    @IBOutlet var shareButton : UIButton?
    
    @IBOutlet var bannerView: GADBannerView!
    var isBannerBottomInited : Bool = false
    var interstitial: GADInterstitial!
    
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.scoreLabel?.text = ""
        self.levelLabel?.text = ""
        self.previousLevelButton?.hidden = true
        self.nextLevelButton?.hidden = true
        self.shareButton?.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initGameScene()
        refreshLevel()
        
        #if DEBUG
        #else
            self.initBanner()
            if(interstitial == nil || !interstitial.isReady) {
                self.initInterstitial()
            }
        #endif
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
        if let scene : GameScene = GameScene(size: skView.frame.size) {
            #if DEBUG
                //skView.showsFPS = true
                //skView.showsPhysics = true // Creates memory leak, so be carefull while open!
            #endif
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            scene.scaleMode = .AspectFit
            scene.hudDelegate = self
            
            //scene.backgroundColor = UIColor.blackColor()
            skView.presentScene(scene)
        }
    }
    
    @IBAction func share(sender : UIButton) {
        print("share app")
        let currentLevel = GameStatsModel.sharedInstance.gameLevel
        let urlText = iRate.sharedInstance().ratingsURL.absoluteString
        let shareText = "This app is amazing and I'm already level \(currentLevel)! Download and try it!\n\(urlText)"
        BDGShare.sharedBDGShare().shareUsingActivityController(shareText, urlStr: urlText)
    }
    
    var resetButtonPressedTime = 0
    @IBAction func help(sender : UIButton) {
        resetButtonPressedTime += 1
        rotate(sender)
        
        if(resetButtonPressedTime % 15 == 0 && interstitial.isReady) {
            interstitial.presentFromRootViewController(self)
        } else {
            let gameScene = skView.scene as! GameScene
            gameScene.resetScene()
        }
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
        shareButton?.hidden = !(nextLevelButton!.hidden) || level < 2
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


//MARK: - Google Ads
extension GameViewController {
    
    func initBanner()  {
        #if DEBUG
            let bannerId = GoogleServiceModel.sharedInstance.read(GoogleServiceKey.AD_UNIT_ID_FOR_BANNER_TEST)
        #else
            let bannerId = GoogleServiceModel.sharedInstance.read(GoogleServiceKey.AD_UNIT_ID_FOR_BANNER)
        #endif
        
        bannerView.adUnitID = bannerId
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.loadRequest(GADRequest())
    }
    
    func initInterstitial() {
        #if DEBUG
            let interstitialId = GoogleServiceModel.sharedInstance.read(GoogleServiceKey.AD_UNIT_ID_FOR_INTERSTITIAL_TEST)
        #else
            let interstitialId = GoogleServiceModel.sharedInstance.read(GoogleServiceKey.AD_UNIT_ID_FOR_INTERSTITIAL)
        #endif
        interstitial = GADInterstitial(adUnitID: interstitialId)
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.loadRequest(request)
    }
}

//MARK: - Banner Ad delegate
extension GameViewController : GADBannerViewDelegate {
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        isBannerBottomInited = true
    }
}

//MARK: - Interstitial Ad delegate
extension GameViewController : GADInterstitialDelegate {
    func interstitialWillPresentScreen(ad: GADInterstitial!) {
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        initInterstitial()
    }
    
    func interstitialDidFailToPresentScreen(ad: GADInterstitial!) {
    }
    
}