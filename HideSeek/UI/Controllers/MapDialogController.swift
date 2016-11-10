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
    var ifMapLoaded: Bool = false
    var pointAnnotation: MAPointAnnotation!
    var circleAnnotation: MAPointAnnotation!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView(_ mapWidth: CGFloat, mapHeight: CGFloat) {
        if mapView == nil {
            mapView = MAMapView(frame: CGRect(x: 2, y: 2, width: mapWidth - 4, height: mapHeight - 4))
        } else {
            mapView.removeFromSuperview()
        }
        
        mapView.showsScale = true
        mapView.showsCompass = false
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        ifMapLoaded = true
    }

    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        var keys = markerDictionary.allKeys(for: view.annotation)
        if(keys.count > 0) {
            GoalCache.instance.selectedGoal?.isSelected = false
            let goal = goalDictionary.object(forKey: keys[0]) as! Goal
            goal.isSelected = true
            GoalCache.instance.selectedGoal = goal
            setEndGoalDelegate?.setEndGoal()
        }
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        var annotationView : MAAnnotationView!
        if annotation.isKind(of: MAPointAnnotation.self) {
            if pointAnnotation == annotation as! MAPointAnnotation {
                let pointReuseIndetifier = "pointReuseIndetifier"
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
                
                if annotationView == nil {
                    annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                    annotationView.image = UIImage(named: "location")
                    annotationView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                }
            } else if circleAnnotation == annotation as! MAPointAnnotation {
                let pointReuseIndetifier = "pointReuseIndetifier"
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
                
                if annotationView == nil {
                    annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                    annotationView.image = UIImage(named: "location_circle")
                    annotationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
                }
            } else {
                let reuseIndetifier = "annotationReuseIndetifier"
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndetifier)
                if annotationView == nil {
                    annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: reuseIndetifier)
                }
                
                var keys = markerDictionary.allKeys(for: annotation)
                if(keys.count > 0) {
                    let goal = goalDictionary.object(forKey: keys[0]) as! Goal
                    
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
            }
        } else {
            annotationView = MAAnnotationView()
        }
        
        annotationView.contentMode = UIViewContentMode.scaleAspectFit
        return annotationView
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        let overlayCircle = overlay as! MACircle
        if overlayCircle == mapView.userLocationAccuracyCircle {
            let accuracyCircleRenderer = MACircleRenderer.init(circle: overlayCircle)
            accuracyCircleRenderer?.lineWidth = 1
            accuracyCircleRenderer?.strokeColor = UIColor.lightGray
            accuracyCircleRenderer?.fillColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.3)
            return accuracyCircleRenderer
        }
        
        return nil
    }
}
