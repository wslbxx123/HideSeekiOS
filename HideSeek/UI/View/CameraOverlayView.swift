//
//  CameraOverlayView.swift
//  HideSeek
//
//  Created by apple on 6/22/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class CameraOverlayView: UIView {
    var mapView:MAMapView!
    
    @IBOutlet weak var bombNumBtn: UIButton!
    @IBOutlet weak var guideBtn: UIButton!
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var setBombBtn: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var goalImageView: UIImageView!
    
    var setBombDelegate: SetBombDelegate!
    var guideDelegate: GuideDelegate!
    var getGoalDelegate: GetGoalDelegate!
    var imageArray: Array<CGImage> = Array<CGImage>()
    var ifGoalPaused: Bool = false
    var ifGoalShowing: Bool = false
    var animation: CAKeyframeAnimation!
    
    private var _endGoal: Goal! = nil
    var endGoal: Goal! {
        get {
            return _endGoal
        }
        set {
            _endGoal = newValue
            ifGoalPaused = false
            imageArray.removeAll()
            
            let imageNameArray = AnimationImageFactory.get(newValue)
            
            for imageName in imageNameArray {
                let filePath = NSBundle.mainBundle().pathForResource(imageName as? String, ofType: ".png")
                imageArray.append((UIImage(contentsOfFile: filePath!)?.CGImage)!)
            }
            
            animation = CAKeyframeAnimation(keyPath: "contents")
            animation.delegate = self
            animation.values = imageArray
            animation.duration = 3
            if(newValue.type == Goal.GoalTypeEnum.bomb) {
                animation.repeatCount = 1
            } else {
                animation.repeatCount = MAXFLOAT
            }
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if endGoal!.type == Goal.GoalTypeEnum.bomb {
            getGoalDelegate?.getGoal()
        }
    }
    
    @IBAction func setBombClicked(sender: AnyObject) {
        setBombDelegate?.setBomb()
    }
    
    @IBAction func guideBtnClicked(sender: AnyObject) {
        guideDelegate?.guideMe()
    }
    
    @IBAction func bombNumClicked(sender: AnyObject) {
        setBombDelegate?.setBomb()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addMapView(mapViewDelegate: MAMapViewDelegate) {
        mapView = MAMapView(frame: CGRectMake(0, 0, CGRectGetWidth(mapUIView.bounds), CGRectGetHeight(mapUIView.bounds)))
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MAUserTrackingMode.Follow, animated: false)
        mapView.showsScale = true
        mapView.delegate = mapViewDelegate
        mapView.pausesLocationUpdatesAutomatically = false
        mapView.allowsBackgroundLocationUpdates = true
        mapView.showsCompass = false
        mapView.customizeUserLocationAccuracyCircleRepresentation = true
        mapUIView.addSubview(mapView)
    }
    
    func showGoal() {
        if(!ifGoalPaused && goalImageView.layer.animationForKey("goal") == nil) {
            print("goalImageView show!!!!!!!!'")
            goalImageView.layer.addAnimation(animation, forKey: "goal")
            
            if endGoal.type == Goal.GoalTypeEnum.bomb {
                ifGoalPaused = true
            }
        }
    }
    
    func hideGoal() {
        goalImageView.layer.removeAllAnimations()
    }
}
