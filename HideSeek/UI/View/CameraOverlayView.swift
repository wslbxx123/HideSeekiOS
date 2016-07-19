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
    
    @IBOutlet weak var guideBtn: UIButton!
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var setBombBtn: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var goalImageView: UIImageView!
    var setBombDelegate: SetBombDelegate!
    var guideDelegate: GuideDelegate!
    var imageArray: Array<UIImage> = Array<UIImage>()
    
    private var _endGoal: Goal! = nil
    var endGoal: Goal! {
        get {
            return _endGoal
        }
        set {
            _endGoal = newValue
            imageArray.removeAll()
            
            let imageNameArray = AnimationImageFactory.get(newValue)
            
            for imageName in imageNameArray {
                let filePath = NSBundle.mainBundle().pathForResource(imageName as? String, ofType: ".png")
                imageArray.append(UIImage(contentsOfFile: filePath!)!)
            }
            goalImageView.animationImages = imageArray
            goalImageView.contentMode = UIViewContentMode.ScaleAspectFit
            goalImageView.animationRepeatCount = LONG_MAX
            goalImageView.animationDuration = 0.2
            showGoal()
        }
    }
    
    @IBAction func setBombClicked(sender: AnyObject) {
        setBombDelegate?.setBomb()
    }
    
    @IBAction func guideBtnClicked(sender: AnyObject) {
        guideDelegate?.guideMe()
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
        goalImageView.startAnimating()
    }
    
    func hideGoal() {
        goalImageView.stopAnimating()
    }
}
