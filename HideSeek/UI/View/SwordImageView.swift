//
//  SwordImageView.swift
//  HideSeek
//
//  Created by apple on 8/16/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class SwordImageView: UIImageView {
    let duration: Double = 0.1
    let kMaxTimeStep: Double = 1;
    var animatedImages: Array<UIImage> = Array<UIImage>()
    var currentFrameIndex: Int = 0
    var accumulator: Double = 0
    var hitMonsterDelegate: HitMonsterDelegate!
    var currentFrame: UIImage?
    var isHittingMonster: Bool = false
    
    var _displayLink: CADisplayLink!
    var displayLink: CADisplayLink {
        if self.superview != nil {
            if _displayLink == nil {
                _displayLink = CADisplayLink(target: self, selector: #selector(SwordImageView.changeKeyFrame))
                _displayLink.add(to: RunLoop.main, forMode: RunLoopMode(rawValue: self.runLoopMode))
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
            return _runLoopMode == nil ? RunLoopMode.commonModes.rawValue : _runLoopMode
        }
        set{
            if newValue != _runLoopMode {
                self.stopAnimating()
                let runLoop = RunLoop.main
                self.displayLink.remove(from: runLoop, forMode: RunLoopMode(rawValue: _runLoopMode))
                self.displayLink.add(to: runLoop, forMode: RunLoopMode(rawValue: newValue))
                _runLoopMode = newValue
                self.startAnimating()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let imageNameArray = AnimationImageFactory.getSwordArray()
        for imageName in imageNameArray {
            let filePath = Bundle.main.path(forResource: imageName as? String, ofType: ".png")
            animatedImages.append(UIImage(contentsOfFile: filePath!)!)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func startAnimating() {
        if self.isAnimating {
            return;
        }
        super.startAnimating()
        self.displayLink.isPaused = false
    }
    
    func changeKeyFrame() {
        if self.animatedImages.count == 0 || self.currentFrameIndex > self.animatedImages.count || !isHittingMonster{
            return
        }
        
        self.accumulator += fmin(displayLink.duration, kMaxTimeStep);
        while self.accumulator >= duration {
            self.accumulator -= duration;
            if self.currentFrameIndex >= self.animatedImages.count {
                self.currentFrameIndex = 0;
                isHittingMonster = false
                currentFrame = nil
                hitMonsterDelegate?.hitMonster()
            } else {
                self.currentFrameIndex = min(self.currentFrameIndex, self.animatedImages.count - 1);
                self.currentFrame = animatedImages[currentFrameIndex]
            }
            
            currentFrameIndex += 1
            self.layer.setNeedsDisplay()
        }
    }
    
    override func display(_ layer: CALayer) {
        if self.animatedImages.count == 0 {
            return;
        }
        
        layer.contents = self.currentFrame?.cgImage
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window != nil {
            self.startAnimating()
        } else {
            DispatchQueue.main.async(execute: {
                if self.window == nil {
                    self.stopAnimating()
                }
            })
        }
    }
    
    func hitMonster() {
        accumulator = 0
        currentFrameIndex = 0
        isHittingMonster = true
    }
}
