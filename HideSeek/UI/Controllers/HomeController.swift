//
//  HomeController.swift
//  HideSeek
//
//  Created by apple on 6/22/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import MobileCoreServices
import AFNetworking

class HomeController: UIImagePickerController, MAMapViewDelegate, SetBombDelegate, GuideDelegate {
    let HtmlType = "text/html"
    let REFRESH_MAP_INTERVAL: Double = 5
    var manager: AFHTTPRequestOperationManager!
    var setBombManager: CustomRequestManager!
    var success: AFHTTPRequestOperation!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var endGoal: Goal?
    var endPoint: MAMapPoint!
    var startPoint: MAMapPoint!
    var distance: Double = 0
    var overlayView: CameraOverlayView!
    var markerDictionary = NSMutableDictionary()
    var goalDictionary = NSMutableDictionary()
    var time: NSTimer!
    var locationFlag = false
    var orientation: Int!
    
    override func viewDidLoad() {
        openCamera()
        
        super.viewDidLoad()
        
        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        setBombManager = CustomRequestManager()
        setBombManager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)
        
        time = NSTimer.scheduledTimerWithTimeInterval(REFRESH_MAP_INTERVAL, target: self, selector: #selector(HomeController.refreshMap), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        time.fire()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        time.invalidate()
    }
    
    func initOverlayView() {
        overlayView.guideBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        overlayView.guideBtn.layer.cornerRadius = 5
        overlayView.guideBtn.layer.masksToBounds = true
        overlayView.setBombDelegate = self
        overlayView.guideDelegate = self
    }
    
    func openCamera() {
        if CameraUtil.isAvailable() {
            let mediaTypeArr:NSArray = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)!
            
            if mediaTypeArr.containsObject(kUTTypeMovie) && mediaTypeArr.containsObject(kUTTypeImage) {
                self.sourceType = UIImagePickerControllerSourceType.Camera
                self.showsCameraControls = false
                self.allowsEditing = false
                
                overlayView = NSBundle.mainBundle().loadNibNamed("CameraOverlay", owner: nil, options: nil).first as? CameraOverlayView
                if overlayView != nil {
                    let frame = UIScreen.mainScreen().bounds
                    overlayView?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                    overlayView?.addMapView(self)
                }
                
                self.cameraOverlayView = overlayView
                initOverlayView()
                
            }
        } else {
            
        }
    }
    
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        if updatingLocation {
            latitude = userLocation.coordinate.latitude
            longitude = userLocation.coordinate.longitude
            print("latitude : %f,longitude: %f", latitude, longitude);
            
            if(!locationFlag) {
                refreshMap();
//                overlayView.mapView.centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
                locationFlag = true;
            }
            
            refreshDistance()
        }
    }
    
    func refreshDistance() {
        if startPoint != nil && endPoint != nil {
            distance = MAMetersBetweenMapPoints(startPoint, endPoint)
            overlayView.distanceLabel.text = NSString(format: NSLocalizedString("M", comment: "%.0f m"), distance) as String
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
                annotationView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                annotationView.contentMode = UIViewContentMode.ScaleAspectFit
            }
        } else if annotation.isKindOfClass(MAPointAnnotation) {
            let reuseIndetifier = "annotationReuseIndetifier"
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIndetifier)
            if annotationView == nil {
                annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: reuseIndetifier)
            }
            
            var keys = markerDictionary.allKeysForObject(annotation)
            if(keys.count > 0) {
                let goal = goalDictionary.objectForKey(keys[0]) as! Goal
                
                if goal.isSelected {
                    annotationView.image = UIImage(named: "box_selected_marker")
                } else {
                    annotationView.image = UIImage(named: "box_marker")
                }
            }
        } else {
            annotationView = MAAnnotationView()
        }
        
        annotationView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
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
    
    func refreshMap() {
        if latitude == nil || longitude == nil {
            return
        }
        
        let paramDict = NSMutableDictionary()
        paramDict["latitude"] = "\(latitude)"
        paramDict["longitude"] = "\(longitude)"
        
        startPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(latitude, longitude));
        let updateTime = GoalCache.instance.updateTime
        if updateTime != nil && updateTime != "null" {
            paramDict["update_time"] = updateTime
        }
        
        let user = UserCache.instance.user
        if user != nil {
            paramDict["account_role"] = String(user.role.rawValue)
        }
        
        manager.POST(UrlParam.REFRESH_MAP_URL,
                    parameters: paramDict,
                    success: { (operation, responseObject) in
                        let response = responseObject as! NSDictionary
                        print("JSON: " + responseObject.description!)
                        GoalCache.instance.setGoals(response["result"] as! NSDictionary, latitude: self.latitude, longitude: self.longitude)
                        
                        if GoalCache.instance.updateList.count > 0 {
                            self.setEndGoal()
                        }

                        self.setGoalsOnMap(GoalCache.instance.updateList)
            },
                    failure: { (operation, error) in
                        print("Error: " + error.localizedDescription)
        })

    }
    
    func setGoalsOnMap(goals: NSMutableArray) {
        if GoalCache.instance.ifNeedClearMap{
            for marker in markerDictionary.allValues {
                let annotation = marker as! MAAnnotation
                overlayView.mapView.removeAnnotation(annotation)
            }
        }
        
        for goal in goals {
            let goalInfo = goal as! Goal
            
            if markerDictionary.allKeys.contains({ element in
                return ((element as? Int64) == goalInfo.pkId)
            }) {
                
                let annotation = markerDictionary.objectForKey(NSNumber(longLong: goalInfo.pkId)) as! MAPointAnnotation
                if goal.valid != nil && goal.valid {
                    overlayView.mapView.removeAnnotation(annotation)
                    markerDictionary.removeObjectForKey(NSNumber(longLong: goalInfo.pkId))
                    goalDictionary.removeObjectForKey(NSNumber(longLong: goalInfo.pkId))
                }
            } else {
                if goalInfo.valid != nil && goalInfo.valid {
                    let annotation = MAPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(goalInfo.latitude, goalInfo.longitude)
                    markerDictionary.setObject(annotation, forKey: NSNumber(longLong: goalInfo.pkId))
                    goalDictionary.setObject(goalInfo, forKey: NSNumber(longLong: goalInfo.pkId))
                    overlayView.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func setEndGoal() {
        endGoal = GoalCache.instance.selectedGoal
        
        if endGoal != nil {
            endPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(endGoal!.latitude, endGoal!.longitude));
        }
        
        refreshDistance()
    }
    
    func setBomb() {
        orientation = 0
        if(latitude == nil || longitude == nil || orientation == nil) {
            return
        }
        
        let paramDict = NSMutableDictionary()
        paramDict["latitude"] = "\(latitude)"
        paramDict["longitude"] = "\(longitude)"
        paramDict["orientation"] = "\(orientation)"
        
        setBombManager.POST(UrlParam.SET_BOMB_URL, paramDict: paramDict, success: { (operation, responseObject) in
                let response = responseObject as! NSDictionary
                print("JSON: " + responseObject.description!)
            }) { (operation, error) in
                print("Error: " + error.localizedDescription)
        }
    }
    
    func guideMe() {
        if endGoal != nil {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier("Navigation") as! NavigationController
            viewController.startPoint = AMapNaviPoint.locationWithLatitude(CGFloat(latitude), longitude: CGFloat(longitude))
            viewController.endPoint = AMapNaviPoint.locationWithLatitude(CGFloat(endGoal!.latitude), longitude: CGFloat(endGoal!.longitude))
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
}
