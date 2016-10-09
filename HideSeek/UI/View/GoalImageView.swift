//
//  GoalImageView.swift
//  HideSeek
//
//  Created by apple on 8/15/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class GoalImageView: UIImageView {
    let FLING_COUNT = 5;
    let FLING_DURATION = 0.2;
    let kMaxTimeStep: Double = 1;
    var animatedImages: Array<UIImage> = Array<UIImage>()
    var currentFrameIndex: Int = 0
    var accumulator: Double = 0
    var duration: Double = 0.1
    var currentFrame: UIImage?
    var interval: Double = 0
    var getGoalDelegate: GetGoalDelegate!
    var swordLayer: CALayer!
    var isHittingMonster: Bool = false
    var flingIndex: Int = 0
    var flingAccumulator: Double = 0
    
    var _displayLink: CADisplayLink!
    var displayLink: CADisplayLink {
        if self.superview != nil {
            if _displayLink == nil {
                _displayLink = CADisplayLink(target: self, selector: #selector(GoalImageView.changeKeyFrame))
                _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: self.runLoopMode)
            }
        } else {
            _displayLink.invalidate()
            _displayLink = nil
        }
        
        return _displayLink
    }

    var _runLoopMode: String!
    var runLoopMode: String {
        get{
            return _runLoopMode == nil ? NSRunLoopCommonModes : _runLoopMode
        }
        set{
            if newValue != _runLoopMode {
                self.stopAnimating()
                let runLoop = NSRunLoop.mainRunLoop()
                self.displayLink.removeFromRunLoop(runLoop, forMode: _runLoopMode)
                self.displayLink.addToRunLoop(runLoop, forMode: newValue)
                _runLoopMode = newValue
                self.startAnimating()
            }
        }
    }
    
    var _endGoal: Goal!
    var endGoal: Goal! {
        get {
            return _endGoal
        }
        set {
            _endGoal = newValue
            currentFrameIndex = 0
            animatedImages.removeAll()
            
            let imageNameArray = AnimationImageFactory.get(newValue)
            
            for imageName in imageNameArray {
                let filePath = NSBundle.mainBundle().pathForResource(imageName as? String, ofType: ".png")
                animatedImages.append(UIImage(contentsOfFile: filePath!)!)
            }
            
            setDuration()
            stopAnimating()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func startAnimating() {
        if self.isAnimating() {
            return;
        }
        super.startAnimating()
        self.displayLink.paused = false
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        self.displayLink.paused = true
    }
    
    func setDuration() {
        switch(endGoal.type) {
        case .bomb:
            duration = 0.2
            break;
        case .mushroom:
            duration = 0.1
            break;
        case .monster:
            duration = 0.4
            break;
        default:
            duration = 0
            break;
        }
    }
    
    func changeKeyFrame() {
        if interval > 0 {
            interval -= 1
        }
        
        if self.animatedImages.count == 0 || self.currentFrameIndex > self.animatedImages.count || interval > 0{
            return
        }
        
        self.accumulator += fmin(displayLink.duration, kMaxTimeStep);
        while self.accumulator >= duration {
            self.accumulator -= duration;
            if self.currentFrameIndex >= self.animatedImages.count {
                self.currentFrameIndex = 0;
                setInterval()
                
                if(endGoal.type == Goal.GoalTypeEnum.bomb && UserCache.instance.ifLogin() &&
                    endGoal.createBy != UserCache.instance.user.pkId) {
                    getGoalDelegate?.getGoal()
                }
            }
            
            self.currentFrameIndex = min(self.currentFrameIndex, self.animatedImages.count - 1);
            self.currentFrame = animatedImages[currentFrameIndex]
            currentFrameIndex += 1
            self.layer.setNeedsDisplay()
        }
        
        self.flingAccumulator += fmin(displayLink.duration, kMaxTimeStep);
        while self.flingAccumulator >= FLING_DURATION {
            self.flingAccumulator -= FLING_DURATION;
            if isHittingMonster && flingIndex <= FLING_COUNT{
                self.hidden = !self.hidden
                
                if flingIndex == FLING_COUNT {
                    isHittingMonster = false
                }
                flingIndex += 1
            }
        }
    }
    
    override func displayLayer(layer: CALayer) {
        if self.animatedImages.count == 0 {
            return;
        }
        
        if self.currentFrame != nil {
            layer.contents = self.currentFrame?.CGImage
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
//        if self.window != nil {
//            self.startAnimating()
//        } else {
//            dispatch_async(dispatch_get_main_queue(), {
//                if self.window == nil {
//                    self.stopAnimating()
//                }
//            })
//        }
    }
    
    func setInterval() {
        switch(endGoal.type) {
        case .bomb:
            interval = 0
            break;
        case .mushroom:
            interval = 20
            break;
        case .monster:
            interval = 0
            break;
        default:
            interval = 0
            break;
        }
    }
    
    func hitMonster() {
        self.isHittingMonster = true
        self.flingIndex = 0
        self.flingAccumulator = 0
    }
}
