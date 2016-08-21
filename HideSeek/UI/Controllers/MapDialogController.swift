//
//  MapDialogController.swift
//  HideSeek
//
//  Created by apple on 8/12/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class MapDialogController: UIViewController {
    var mapView: MAMapView!
    var mapViewDelegate: MAMapViewDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView(mapWidth: CGFloat, mapHeight: CGFloat) {
        if mapView == nil {
            mapView = MAMapView(frame: CGRectMake(0, 0, mapWidth, mapHeight))
        } else {
            mapView.removeFromSuperview()
        }
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MAUserTrackingMode.Follow, animated: false)
        mapView.showsScale = true
        mapView.delegate = mapViewDelegate
        mapView.pausesLocationUpdatesAutomatically = false
        mapView.allowsBackgroundLocationUpdates = true
        mapView.showsCompass = false
        mapView.customizeUserLocationAccuracyCircleRepresentation = true
        self.view.addSubview(mapView)
    }

}
