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
    var setBombDelegate: SetBombDelegate!
    var guideDelegate: GuideDelegate!
    
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
}
