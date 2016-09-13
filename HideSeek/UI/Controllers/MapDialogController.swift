//
//  MapDialogController.swift
//  HideSeek
//
//  Created by apple on 8/12/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class MapDialogController: UIViewController, MAMapViewDelegate {
    var mapView: MAMapView!
    var markerDictionary = NSMutableDictionary()
    var goalDictionary = NSMutableDictionary()
    var setEndGoalDelegate: SetEndGoalDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView(mapWidth: CGFloat, mapHeight: CGFloat) {
        if mapView == nil {
            mapView = MAMapView(frame: CGRectMake(2, 2, mapWidth - 4, mapHeight - 4))
        } else {
            mapView.removeFromSuperview()
        }
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MAUserTrackingMode.Follow, animated: false)
        mapView.showsScale = true
        mapView.pausesLocationUpdatesAutomatically = false
        mapView.allowsBackgroundLocationUpdates = true
        mapView.showsCompass = false
        mapView.customizeUserLocationAccuracyCircleRepresentation = true
        mapView.delegate = self
        self.view.addSubview(mapView)
    }

    func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
        var keys = markerDictionary.allKeysForObject(view.annotation)
        if(keys.count > 0) {
            GoalCache.instance.selectedGoal?.isSelected = false
            let goal = goalDictionary.objectForKey(keys[0]) as! Goal
            goal.isSelected = true
            GoalCache.instance.selectedGoal = goal
            setEndGoalDelegate?.setEndGoal()
        }
    }
    
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        var annotationView : MAAnnotationView!
        if annotation.isKindOfClass(MAUserLocation) {
            let userLocationStyleReuseIdentifier = "userLocationStyleReuseIndetifier"
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(userLocationStyleReuseIdentifier)
            if annotationView == nil {
                annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: userLocationStyleReuseIdentifier)
                annotationView.image = UIImage(named: "location")
            }
            annotationView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        } else if annotation.isKindOfClass(MAPointAnnotation) {
            let reuseIndetifier = "annotationReuseIndetifier"
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIndetifier)
            if annotationView == nil {
                annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: reuseIndetifier)
            }
            
            var keys = markerDictionary.allKeysForObject(annotation)
            if(keys.count > 0) {
                let goal = goalDictionary.objectForKey(keys[0]) as! Goal
                
                if UserCache.instance.ifLogin() && goal.createBy == UserCache.instance.user.pkId
                    && goal.type == Goal.GoalTypeEnum.bomb {
                    if goal.isSelected {
                        annotationView.image = UIImage(named: "big_bomb_selected_marker")
                        annotationView.frame = CGRect(x: 0, y: 0, width: 25, height: 50)
                    } else {
                        annotationView.image = UIImage(named: "big_bomb_marker")
                        annotationView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
                    }
                } else {
                    if goal.isSelected {
                        annotationView.image = UIImage(named: "big_box_selected_marker")
                        annotationView.frame = CGRect(x: 0, y: 0, width: 25, height: 50)
                    } else {
                        annotationView.image = UIImage(named: "big_box_marker")
                        annotationView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
                    }
                }
            }
        } else {
            annotationView = MAAnnotationView()
        }
        
        annotationView.contentMode = UIViewContentMode.ScaleAspectFit
        return annotationView
    }
    
    func mapView(mapView: MAMapView!, rendererForOverlay overlay: MAOverlay!) -> MAOverlayRenderer! {
        let overlayCircle = overlay as! MACircle
        if overlayCircle == mapView.userLocationAccuracyCircle {
            let accuracyCircleRenderer = MACircleRenderer.init(circle: overlayCircle)
            accuracyCircleRenderer.lineWidth = 1
            accuracyCircleRenderer.strokeColor = UIColor.lightGrayColor()
            accuracyCircleRenderer.fillColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.3)
            return accuracyCircleRenderer
        }
        
        return nil
    }
}
