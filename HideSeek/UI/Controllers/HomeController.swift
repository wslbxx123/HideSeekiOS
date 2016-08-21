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
import CoreMotion.CMMotionManager

class HomeController: UIImagePickerController, MAMapViewDelegate, SetBombDelegate, GuideDelegate, GetGoalDelegate, GuideMonsterDelegate, TouchDownDelegate, CLLocationManagerDelegate, HitMonsterDelegate {
    let HtmlType = "text/html"
    let REFRESH_MAP_INTERVAL: Double = 5
    var manager: AFHTTPRequestOperationManager!
    var setBombManager: CustomRequestManager!
    var getGoalManager: CustomRequestManager!
    var success: AFHTTPRequestOperation!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var endGoal: Goal!
    var endPoint: MAMapPoint!
    var startPoint: MAMapPoint!
    var distance: Double = 0
    var overlayView: CameraOverlayView!
    var markerDictionary = NSMutableDictionary()
    var goalDictionary = NSMutableDictionary()
    var time: NSTimer!
    var locationFlag = false
    var orientation: Int = -1
    var mapDialogController: MapDialogController!
    var screenRect: CGRect!
    var mapHeight: CGFloat = 300
    var mapWidth: CGFloat!
    var grayView: UIView!
    var locManager: CLLocationManager!
    var guideView: MonsterGuideView!
    
    override func viewDidLoad() {
        openCamera()
        
        super.viewDidLoad()
        
        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        setBombManager = CustomRequestManager()
        setBombManager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)
        getGoalManager = CustomRequestManager()
        getGoalManager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)
        
        locManager = CLLocationManager()
        locManager.delegate = self
        if CLLocationManager.headingAvailable() {
            locManager.startUpdatingHeading()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        time = NSTimer.scheduledTimerWithTimeInterval(REFRESH_MAP_INTERVAL, target: self, selector: #selector(HomeController.refreshMap), userInfo: nil, repeats: true)
        if overlayView != nil {
            initMenuBtn()
            overlayView.addMapView(self)
            mapDialogController.initView(mapWidth, mapHeight: mapHeight)
        }
        
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBarHidden = true
    }    
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBarHidden = false
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        time.invalidate()
        time = nil
    }
    
    func initOverlayView() {
        overlayView.guideBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        overlayView.guideBtn.layer.cornerRadius = 5
        overlayView.guideBtn.layer.masksToBounds = true
        overlayView.setBombDelegate = self
        overlayView.guideDelegate = self
        overlayView.getGoalDelegate = self
        overlayView.guideMonsterDelegate = self
        overlayView.distanceView.touchDownDelegate = self
        overlayView.hitMonsterDelegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeController.touchDown))
        overlayView.locationStackView.userInteractionEnabled = true
        overlayView.locationStackView.addGestureRecognizer(gestureRecognizer)
        
        if overlayView != nil {
            initMenuBtn()
        }
    }
    
    func initMenuBtn() {
        if UserCache.instance.ifLogin() {
            let bombNum = UserCache.instance.user.bombNum
            if bombNum >= 100 {
                overlayView.bombNumBtn.setTitle("99+", forState: UIControlState.Normal)
            } else {
                overlayView.bombNumBtn.setTitle("\(bombNum)", forState: UIControlState.Normal)
            }
            overlayView.bombNumBtn.hidden = false
            overlayView.setBombBtn.hidden = false
            overlayView.monsterGuideBtn.hidden = false
        } else {
            overlayView.bombNumBtn.hidden = true
            overlayView.setBombBtn.hidden = true
            overlayView.monsterGuideBtn.hidden = true
        }
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
                    initMapDialog()
                    initMonsterGuide()
                }
                
                self.cameraOverlayView = overlayView
                initOverlayView()
            }
        } else {
            
        }
    }
    
    func initMonsterGuide() {
        let guideViewContents = NSBundle.mainBundle().loadNibNamed("MonsterGuideView",
                                                                   owner: view, options: nil)
        guideView = guideViewContents[0] as! MonsterGuideView
        guideView.layer.frame = CGRectMake(
            20,
            (screenRect.height - 200) / 2 - 50,
            screenRect.width - 40,
            200)
        self.view.addSubview(guideView)
        guideView.initView()
        guideView.hidden = true
    }
    
    func initMapDialog() {
        screenRect = UIScreen.mainScreen().bounds
        mapWidth = screenRect.width - 40
        grayView = UIView(frame: screenRect)
        grayView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        mapDialogController = storyboard.instantiateViewControllerWithIdentifier("mapDialog") as! MapDialogController
        mapDialogController.mapViewDelegate = self
        mapDialogController.view.layer.frame = CGRectMake(
            (screenRect.width - mapWidth) / 2,
            (screenRect.height - mapHeight) / 2,
            mapWidth,
            mapHeight)
        mapDialogController.view.userInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeController.closeMapDialog(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        grayView.addGestureRecognizer(gestureRecognizer)
        
        self.view.addSubview(grayView)
        self.view.addSubview(mapDialogController.view)
        mapDialogController.initView(mapWidth, mapHeight: mapHeight)
        grayView.hidden = true
        mapDialogController.view.hidden = true
    }
    
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        if updatingLocation {
            latitude = userLocation.coordinate.latitude
            longitude = userLocation.coordinate.longitude
            print("latitude : %f,longitude: %f", latitude, longitude);
            
            if(!locationFlag) {
                refreshMap();
                locationFlag = true;
            }
            
            refreshDistance()
            
            checkIfGoalDisplayed()
        }
    }
    
    func refreshDistance() {
        if startPoint != nil && endPoint != nil {
            distance = MAMetersBetweenMapPoints(startPoint, endPoint)
            overlayView.distanceLabel.text = NSString(format: NSLocalizedString("M", comment: "%.0f m"), distance) as String
        }
    }
    
    func checkIfGoalDisplayed() {
        if endGoal != nil {
            if endGoal.orientation == orientation && distance < 10 && (endGoal.valid) {
                overlayView.showGoal()
            } else {
                overlayView.hideGoal()
            }
        } else {
            overlayView.hideGoal()
        }
    }
    
    func updateEndGoal() {
        endGoal.valid = false
        GoalCache.instance.selectedGoal = nil
        GoalCache.instance.refreshClosestGoal(latitude, longitude: longitude)
        let list = NSMutableArray()
        list.addObject(endGoal)
        list.addObject(GoalCache.instance.selectedGoal!)
        setEndGoal()
        setGoalsOnMap(list)
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
                
                if UserCache.instance.ifLogin() && goal.createBy == UserCache.instance.user.pkId
                    && goal.type == Goal.GoalTypeEnum.bomb {
                    if goal.isSelected {
                        annotationView.image = UIImage(named: "box_selected_marker")
                    } else {
                        annotationView.image = UIImage(named: "box_marker")
                    }
                } else {
                    if goal.isSelected {
                        annotationView.image = UIImage(named: "box_selected_marker")
                    } else {
                        annotationView.image = UIImage(named: "box_marker")
                    }
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
        paramDict["version"] = "\(GoalCache.instance.version)"
        
        startPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(latitude, longitude));
        
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
                return ((element as! NSNumber).longLongValue == goalInfo.pkId)
            }) {
                
                let annotation = markerDictionary.objectForKey(NSNumber(longLong: goalInfo.pkId)) as! MAPointAnnotation
                if !goalInfo.valid {
                    overlayView.mapView.removeAnnotation(annotation)
                    overlayView.mapView.addAnnotation(annotation)
                    overlayView.mapView.removeAnnotation(annotation)
                    mapDialogController.mapView.removeAnnotation(annotation)
                    mapDialogController.mapView.addAnnotation(annotation)
                    mapDialogController.mapView.removeAnnotation(annotation)
                    markerDictionary.removeObjectForKey(NSNumber(longLong: goalInfo.pkId))
                    goalDictionary.removeObjectForKey(NSNumber(longLong: goalInfo.pkId))
                }
            } else {
                if goalInfo.valid {
                    let annotation = MAPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(goalInfo.latitude, goalInfo.longitude)
                    markerDictionary.setObject(annotation, forKey: NSNumber(longLong: goalInfo.pkId))
                    goalDictionary.setObject(goalInfo, forKey: NSNumber(longLong: goalInfo.pkId))
                    overlayView.mapView.addAnnotation(annotation)
                    mapDialogController.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func setEndGoal() {
        endGoal = GoalCache.instance.selectedGoal
        
        if endGoal != nil {
            endPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(endGoal.latitude, endGoal.longitude));
            
            overlayView.endGoal = endGoal
        }
        
        refreshDistance()
    }
    
    func setBomb() {
        if UserCache.instance.user.bombNum > 0 {
            if(latitude == nil || longitude == nil || orientation == -1) {
                return
            }
            
            let paramDict = NSMutableDictionary()
            paramDict["latitude"] = "\(latitude)"
            paramDict["longitude"] = "\(longitude)"
            paramDict["orientation"] = "\(orientation)"
            
            setBombManager.POST(UrlParam.SET_BOMB_URL, paramDict: paramDict, success: { (operation, responseObject) in
                let response = responseObject as! NSDictionary
                print("JSON: " + responseObject.description!)
                
                let bombNum = (response["result"] as! NSNumber).integerValue
                UserCache.instance.user.bombNum = bombNum
                self.overlayView.bombNumBtn.setTitle("\(bombNum)", forState: UIControlState.Normal)
            }) { (operation, error) in
                print("Error: " + error.localizedDescription)
            }
        } else {
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("NOT_HAS_BOMB", comment: "You don't have bombs. Go to store to buy some?"), preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"),
                                             style: UIAlertActionStyle.Cancel, handler: nil)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default, handler: { (action) in
                self.goToStore()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func goToStore() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("Store")
        
        self.navigationController?.pushViewController(viewController, animated: true)
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
    
    func getGoal() {
        let paramDict = NSMutableDictionary()
        let pkId: Int64 = (endGoal.pkId)
        let goalType: Int = (endGoal.type.rawValue)
        paramDict["goal_id"] = "\(pkId)"
        paramDict["goal_type"] = "\(goalType)"
        
        getGoalManager.POST(UrlParam.GET_GOAL_URL, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            let code = (response["code"] as! NSString).integerValue
            
            if code == CodeParam.SUCCESS {
                if self.endGoal.type == Goal.GoalTypeEnum.bomb {
                    HudToastFactory.showScore(self.endGoal.score, view: self.view)
                } else {
                    HudToastFactory.showScore(self.endGoal.score, view: self.view)
                }
                
                self.updateEndGoal()
            } else {
                let errorMessage = ErrorMessageFactory.get(code)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
            }
        }) { (operation, error) in
            let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
    
    func guideMonster() {
        if UserCache.instance.user.hasGuide {
                showMonsterGuide()
        } else {
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("NOT_HAS_GUIDE", comment: "You don't have monster guide. Go to store to buy one?"), preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"),
                                             style: UIAlertActionStyle.Cancel, handler: nil)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default, handler: { (action) in
                self.goToStore()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func showMonsterGuide() {
        if overlayView != nil && !overlayView.goalImageView.hidden {
            guideView.goalImageView.image = UIImage(named: GoalImageFactory.get(endGoal.type, showTypeName: endGoal.showTypeName))
            guideView.introductionLabel.text = endGoal!.introduction
            guideView.hidden = !guideView.hidden
        } else {
            if !guideView.hidden {
                guideView.hidden = true
            }
        }
    }
    
    func touchDown(tag: Int) {
        grayView.hidden = false
        mapDialogController.view.hidden = false
    }
    
    func closeMapDialog(sender: UITapGestureRecognizer) {
        grayView.hidden = true
        mapDialogController.view.hidden = true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        orientation = Int(newHeading.magneticHeading) / 90 * 90 % 360
        checkIfGoalDisplayed()
        print("angle: \(orientation)")
    }
    
    func hitMonster() {
        let paramDict = NSMutableDictionary()
        let pkId: Int64 = (endGoal?.pkId)!
        let accountRole: Int = UserCache.instance.user.role.rawValue
        paramDict["goal_id"] = "\(pkId)"
        paramDict["account_role"] = "\(accountRole)"
        
        getGoalManager.POST(UrlParam.HIT_MONSTER_URL, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            let code = (response["code"] as! NSString).integerValue
            
            if code == CodeParam.SUCCESS {
                let result = response["result"] as! NSDictionary
                if (result["score_sum"] != nil && !result.objectForKey("score_sum")!.isKindOfClass(NSNull)) {
                    HudToastFactory.showScore(self.endGoal.score, view: self.view)
                    if(UserCache.instance.ifLogin()) {
                        UserCache.instance.user.record = (result["score_sum"] as! NSString).doubleValue
                        self.updateEndGoal()
                    }
                }
            } else {
                let errorMessage = ErrorMessageFactory.get(code)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
                
                self.updateEndGoal()
            }
        }) { (operation, error) in
            let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
}
