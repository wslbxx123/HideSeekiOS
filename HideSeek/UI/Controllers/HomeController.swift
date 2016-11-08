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
import MBProgressHUD
import AVFoundation

class HomeController: UIViewController, MAMapViewDelegate, SetBombDelegate, GuideDelegate, GetGoalDelegate, GuideMonsterDelegate, TouchDownDelegate, CLLocationManagerDelegate, HitMonsterDelegate, WarningDelegate, CloseDelegate, SetEndGoalDelegate, ShareDelegate, ArriveDelegate, RefreshMapDelegate, UpdateGoalDelegate, HideBottomBarDelegate,
    AMapLocationManagerDelegate{
    let HtmlType = "text/html"
    let REFRESH_MAP_INTERVAL: Double = 5
    var manager: AFHTTPRequestOperationManager!
    var setBombManager: CustomRequestManager!
    var getGoalManager: CustomRequestManager!
    var hitMonsterManager: CustomRequestManager!
    var updateUserInfoManager: CustomRequestManager!
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
    var mapHeight: CGFloat!
    var mapWidth: CGFloat!
    var grayView: UIView!
    var locManager: CLLocationManager!
    var guideView: MonsterGuideView!
    var ifSeeGoal: Bool = false
    var ifRefreshing: Bool = false
    var device: AVCaptureDevice!
    var input: AVCaptureDeviceInput!
    var imageOutput: AVCaptureStillImageOutput!
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var pointAnnotation: MAPointAnnotation!
    var circleAnnotation: MAPointAnnotation!
    var locationManager: AMapLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCamera()
        initView()

        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        setBombManager = CustomRequestManager()
        setBombManager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)
        getGoalManager = CustomRequestManager()
        getGoalManager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)
        updateUserInfoManager = CustomRequestManager()
        updateUserInfoManager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)
        hitMonsterManager = CustomRequestManager()
        hitMonsterManager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)
        
        locManager = CLLocationManager()
        locManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.session != nil && !self.session.running) {
            self.session.startRunning()
        }
        
        if self.locationManager != nil {
            self.locationManager.startUpdatingLocation()
        }
        
        time = NSTimer.scheduledTimerWithTimeInterval(REFRESH_MAP_INTERVAL, target: self, selector: #selector(HomeController.refreshMap), userInfo: nil, repeats: true)
        if overlayView != nil {
            initMenuBtn()
//            mapDialogController.initView(mapWidth, mapHeight: mapHeight)
            
            if UserCache.instance.ifLogin() {
                let user = UserCache.instance.user
                overlayView.welcomeLabel.hidden = true
                overlayView.hintLabel.hidden = false
                overlayView.roleImageView.image = UIImage(named: user.roleImageName)
                overlayView.roleNameLabel.text = user.roleName
                
                updateUserInfo()
            } else {
                overlayView.welcomeLabel.hidden = false
                overlayView.hintLabel.hidden = true
            }
        }
        
        self.navigationController?.navigationBarHidden = true
        if CLLocationManager.headingAvailable() {
            locManager.startUpdatingHeading()
        }
        
        if GoalCache.instance.ifNeedClearMap {
            refresh()
        }
        
        refreshDistance()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }    
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        if CLLocationManager.headingAvailable() {
            locManager.stopUpdatingHeading()
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (self.session != nil) {
            self.session.stopRunning()
        }
        
        if time != nil {
            time.invalidate()
            time = nil
        }
    }
    
    func updateUserInfo() {
        let paramDict = NSMutableDictionary()
        updateUserInfoManager.POST(UrlParam.UPDATE_USER_INFO_URL, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            print("JSON: " + responseObject.description!)
            
            self.setInfoFromUpdateUserInfoCallback(response)
        }) { (operation, error) in
            print("Error: " + error.localizedDescription)
        }
    }
    
    func setInfoFromUpdateUserInfoCallback(response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            UserCache.instance.user.bombNum = BaseInfoUtil.getIntegerFromAnyObject(result["bomb_num"])
            self.overlayView.bombNumBtn.setTitle("\(UserCache.instance.user.bombNum)", forState: UIControlState.Normal)
            UserCache.instance.user.hasGuide = BaseInfoUtil.getIntegerFromAnyObject(result["has_guide"]) == 1
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func checkIfFirstUse() {
        let appVersion = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultParam.APP_VERSION) as? NSString
        
        if appVersion == nil || BaseInfoUtil.getAppVersion().compareTo(appVersion! as String, separator: ".") > 0 {
            self.tabBarController!.tabBar.hidden = true
            overlayView.initGuide()
            overlayView.refreshGuide()
        }
    }
    
    func initView() {
        self.automaticallyAdjustsScrollViewInsets = false;
        if self.previewLayer == nil {
            self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.session)
            
            let bounds = self.view.bounds
            self.previewLayer.frame = bounds
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
            
            self.view.layer.addSublayer(previewLayer)
        }
        
        overlayView = NSBundle.mainBundle().loadNibNamed("CameraOverlay", owner: nil, options: nil).first as? CameraOverlayView
        if overlayView != nil {
            let frame = UIScreen.mainScreen().bounds
            overlayView?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            overlayView?.addMapView(self)
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(overlayView)
            let widthConstraint = NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
            let centerXConstraint = NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            let centerYConstraint = NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            self.view.addConstraints([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
            initOverlayView()
            initMapDialog()
            initMonsterGuide()
            configLocationManager()
        }
    }
    
    func initCamera() {
        do {
            self.device = self.cameraWithPosition(AVCaptureDevicePosition.Back)
            self.input = try AVCaptureDeviceInput(device: self.device)
            self.imageOutput = AVCaptureStillImageOutput()
            self.session = AVCaptureSession()
            
            if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
                self.session.sessionPreset = AVCaptureSessionPresetHigh
            } else {
                self.session.sessionPreset = AVCaptureSessionPresetMedium
            }
            
            if self.session.canAddInput(self.input) {
                self.session.addInput(self.input)
            }
        } catch {
            let errorMessage = NSLocalizedString("ERROR_INIT_CAMERA", comment: "Failed to initialize camera")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices as! [AVCaptureDevice]{
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    func initOverlayView() {
        overlayView.guideBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        overlayView.guideBtn.layer.cornerRadius = 5
        overlayView.guideBtn.layer.masksToBounds = true
        overlayView.refreshMapDelegate = self
        overlayView.setBombDelegate = self
        overlayView.guideDelegate = self
        overlayView.getGoalDelegate = self
        overlayView.guideMonsterDelegate = self
        overlayView.distanceView.touchDownDelegate = self
        overlayView.hitMonsterDelegate = self
        overlayView.warningDelegate = self
        overlayView.shareDelegate = self
        overlayView.hideBottomBarDelegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeController.touchDown))
        overlayView.locationView.userInteractionEnabled = true
        overlayView.locationView.addGestureRecognizer(gestureRecognizer)
        
        if overlayView != nil {
            initMenuBtn()
            checkIfFirstUse()
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
            overlayView.warningBtn.hidden = false
            overlayView.shareBtn.hidden = false
            overlayView.roleInfoView.hidden = false
        } else {
            overlayView.bombNumBtn.hidden = true
            overlayView.setBombBtn.hidden = true
            overlayView.monsterGuideBtn.hidden = true
            overlayView.warningBtn.hidden = true
            overlayView.shareBtn.hidden = true
            overlayView.roleInfoView.hidden = true
        }
    }
    
    func initMonsterGuide() {
        let guideViewContents = NSBundle.mainBundle().loadNibNamed("MonsterGuideView",
                                                                   owner: view, options: nil)
        guideView = guideViewContents[0] as! MonsterGuideView
        guideView.layer.frame = CGRectMake(
            20,
            (screenRect.height - 300) / 2 - 50,
            screenRect.width - 40,
            300)
        self.view.addSubview(guideView)
        guideView.initView()
        guideView.hidden = true
        guideView.closeDelegate = self
    }
    
    func initMapDialog() {
        screenRect = UIScreen.mainScreen().bounds
        mapWidth = screenRect.width - 40
        mapHeight = mapWidth
        grayView = UIView(frame: screenRect)
        grayView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        mapDialogController = storyboard.instantiateViewControllerWithIdentifier("mapDialog") as! MapDialogController
        mapDialogController.view.layer.frame = CGRectMake(
            (screenRect.width - mapWidth) / 2,
            (screenRect.height - mapHeight) / 2,
            mapWidth,
            mapHeight)
        mapDialogController.view.userInteractionEnabled = true
        mapDialogController.markerDictionary = markerDictionary
        mapDialogController.goalDictionary = goalDictionary
        mapDialogController.setEndGoalDelegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeController.closeMapDialog(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        grayView.addGestureRecognizer(gestureRecognizer)
        
        self.view.addSubview(grayView)
        self.view.addSubview(mapDialogController.view)
        mapDialogController.initView(mapWidth, mapHeight: mapHeight)
        grayView.hidden = true
        mapDialogController.view.hidden = true
    }
    
    func configLocationManager() {
        self.locationManager = AMapLocationManager()
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func amapLocationManager(manager: AMapLocationManager!, didUpdateLocation location: CLLocation!) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        if self.pointAnnotation == nil {
            self.pointAnnotation = MAPointAnnotation()
            self.pointAnnotation.coordinate = location.coordinate
            self.circleAnnotation = MAPointAnnotation()
            self.circleAnnotation.coordinate = location.coordinate
            self.mapDialogController.pointAnnotation = self.pointAnnotation
            self.mapDialogController.circleAnnotation = self.circleAnnotation
            
            self.overlayView.mapView.addAnnotation(self.pointAnnotation)
            self.overlayView.mapView.addAnnotation(self.circleAnnotation)
            self.mapDialogController.mapView.addAnnotation(self.pointAnnotation)
            self.mapDialogController.mapView.addAnnotation(self.circleAnnotation)
            refreshMap(false);
        }
        
        self.pointAnnotation.coordinate = location.coordinate
        
        self.overlayView.mapView.centerCoordinate = location.coordinate
        self.overlayView.mapView.zoomLevel = 15.1
        self.mapDialogController.mapView.centerCoordinate = location.coordinate
        self.mapDialogController.mapView.zoomLevel = 15.1
        
        refreshDistance()
        checkIfGoalDisplayed()
    }
    
    func refreshDistance() {
        if startPoint != nil && endPoint != nil {
            distance = MAMetersBetweenMapPoints(startPoint, endPoint) < 30 ? 0 : MAMetersBetweenMapPoints(startPoint, endPoint) - 30
            overlayView.distanceLabel.text = NSString(format: NSLocalizedString("M", comment: "%.0f m"), distance) as String
        }
    }
    
    func checkIfGoalDisplayed() {
        if endGoal != nil {
            if endGoal.orientation == orientation && distance < 10 && (endGoal.valid) {
                overlayView.showGoal()
                
                if !ifSeeGoal && UserCache.instance.ifLogin() {
                    ifSeeGoal = true
                    if endGoal.type == Goal.GoalTypeEnum.monster {
                        seeMonster()
                    }
                }
            } else {
                overlayView.hideGoal()
            }
        } else {
            overlayView.hideGoal()
        }
    }
    
    func seeMonster() {
        let paramDict = NSMutableDictionary()
        let pkId: Int64 = (endGoal.pkId)
        paramDict["goal_id"] = "\(pkId)"
        getGoalManager.POST(UrlParam.SEE_MONSTER_URL, paramDict: paramDict, success: { (operation, responseObject) in
            print("JSON: " + responseObject.description!)
            let response = responseObject as! NSDictionary
            let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
            
            if code != CodeParam.SUCCESS {
                let errorMessage = ErrorMessageFactory.get(code)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                    if code == CodeParam.ERROR_SESSION_INVALID {
                        UserInfoManager.instance.logout(self)
                    }
                })
                self.ifSeeGoal = false
            }
        }) { (operation, error) in
            let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
            self.ifSeeGoal = false
        }
    }
    
    func updateEndGoal() {
        overlayView.hideGoal()
        endGoal.valid = false
        endGoal.isSelected = false
        GoalCache.instance.selectedGoal = nil
        GoalCache.instance.refreshClosestGoal(latitude, longitude: longitude)
        setEndGoal()
    }
    
    func updateEndGoal(goalId: Int64) {
        GoalCache.instance.selectedGoal?.isSelected = false
        let goal = GoalCache.instance.getGoal(goalId)
        
        if goal != nil {
            goal!.isSelected = true
            GoalCache.instance.selectedGoal = goal!
            setEndGoal()
        } else {
            let errorMessage = NSLocalizedString("ERROR_GOAL_INVALID", comment: "The goal has disappeared or beyond your range")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
    
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        var annotationView : MAAnnotationView!
        if annotation.isKindOfClass(MAPointAnnotation) {
            if pointAnnotation == annotation as! MAPointAnnotation {
                let pointReuseIndetifier = "pointReuseIndetifier"
                annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pointReuseIndetifier)
                
                if annotationView == nil {
                    annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                    annotationView.image = UIImage(named: "location")
                    annotationView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                }
            } else if circleAnnotation == annotation as! MAPointAnnotation {
                let pointReuseIndetifier = "pointReuseIndetifier"
                annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pointReuseIndetifier)
                
                if annotationView == nil {
                    annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                    annotationView.image = UIImage(named: "location_circle")
                    annotationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                }
            } else {
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
                            annotationView.image = UIImage(named: "bomb_selected_marker")
                            annotationView.frame = CGRect(x: 0, y: 0, width: 15, height: 30)
                        } else {
                            annotationView.image = UIImage(named: "bomb_marker")
                            annotationView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                        }
                    } else {
                        if goal.isSelected {
                            annotationView.image = UIImage(named: "box_selected_marker")
                            annotationView.frame = CGRect(x: 0, y: 0, width: 15, height: 30)
                        } else {
                            annotationView.image = UIImage(named: "box_marker")
                            annotationView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                        }
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
    
    func refreshMap(ifSure: Bool) {
        if ifRefreshing && !ifSure {
            return
        }
        
        if latitude == nil || longitude == nil {
            return
        }
        
        ifRefreshing = true
        let paramDict = NSMutableDictionary()
        paramDict["latitude"] = "\(latitude)"
        paramDict["longitude"] = "\(longitude)"
        paramDict["version"] = "\(GoalCache.instance.version)"
        
        var hud: MBProgressHUD!
        if GoalCache.instance.version == 0 {
            hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.labelText = NSLocalizedString("REFRESH_MAP_HINT", comment: "Refreshing map...")
            hud.dimBackground = true
        }
        
        startPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(latitude, longitude));
        
        if UserCache.instance.ifLogin() {
            let user = UserCache.instance.user
            paramDict["account_role"] = String(user.role.rawValue)
        }
        
        manager.POST(UrlParam.REFRESH_MAP_URL,
                    parameters: paramDict,
                    success: { (operation, responseObject) in
                        let response = responseObject as! NSDictionary
                        print("JSON: " + responseObject.description!)
                        
                        if let resultInfo = response["result"] as? NSDictionary {
                            GoalCache.instance.setGoals(resultInfo, latitude: self.latitude, longitude: self.longitude)
                        }
                        
                        
                        if hud != nil {
                            GoalCache.instance.refreshClosestGoal(self.latitude, longitude: self.longitude)
                            self.setEndGoal()
                        }

                        self.setGoalsOnMap(GoalCache.instance.updateList)
                        
                        if hud != nil {
                            hud.removeFromSuperview()
                            hud = nil
                        }
                        
                        self.ifRefreshing = false
            },
                    failure: { (operation, error) in
                        print("Error: " + error.localizedDescription)
                        if hud != nil {
                            hud.removeFromSuperview()
                            hud = nil
                        }
                        self.ifRefreshing = false
        })

    }
    
    func setGoalsOnMap(goals: NSMutableArray) {
        for goal in goals {
            let goalInfo = goal as! Goal
            
            if markerDictionary.allKeys.contains({ element in
                return ((element as! NSNumber).longLongValue == goalInfo.pkId)
            }) {
                
                if let annotation = markerDictionary.objectForKey(NSNumber(longLong: goalInfo.pkId)) as? MAPointAnnotation {
                    if !goalInfo.valid {
                        overlayView.mapView.removeAnnotation(annotation)
                        overlayView.mapView.addAnnotation(annotation)
                        overlayView.mapView.removeAnnotation(annotation)
                        mapDialogController.mapView.removeAnnotation(annotation)
                        mapDialogController.mapView.addAnnotation(annotation)
                        mapDialogController.mapView.removeAnnotation(annotation)
                        markerDictionary.removeObjectForKey(NSNumber(longLong: goalInfo.pkId))
                        goalDictionary.removeObjectForKey(NSNumber(longLong: goalInfo.pkId))
                    } else {
                        overlayView.mapView.removeAnnotation(annotation)
                        overlayView.mapView.addAnnotation(annotation)
                        mapDialogController.mapView.removeAnnotation(annotation)
                        mapDialogController.mapView.addAnnotation(annotation)
                    }
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
        let list = NSMutableArray()
        if endGoal != nil {
            list.addObject(endGoal)
            list.addObject(GoalCache.instance.selectedGoal!)
        }
        setGoalsOnMap(list)
        endGoal = GoalCache.instance.selectedGoal
        overlayView.hintLabel.text = NSLocalizedString("MESSAGE_GOAL_HINT", comment: "Leader, a goal there!")
        
        if endGoal != nil {
            overlayView.endGoal = endGoal
            endPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(endGoal.latitude, endGoal.longitude));
            
            refreshDistance()
            checkIfGoalDisplayed()
        }
        
        self.ifSeeGoal = false;
    }
    
    func setBomb() {
        if UserCache.instance.user.bombNum > 0 {
            if(latitude == nil || longitude == nil || orientation == -1) {
                return
            }
            
            var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.labelText = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
            hud.dimBackground = true
            
            let paramDict = NSMutableDictionary()
            paramDict["latitude"] = "\(latitude)"
            paramDict["longitude"] = "\(longitude)"
            paramDict["orientation"] = "\(orientation)"
            
            setBombManager.POST(UrlParam.SET_BOMB_URL, paramDict: paramDict, success: { (operation, responseObject) in
                let response = responseObject as! NSDictionary
                print("JSON: " + responseObject.description!)
                hud.removeFromSuperview()
                hud = nil
                
                self.setInfoFromSetBombCallback(response)
            }) { (operation, error) in
                print("Error: " + error.localizedDescription)
                hud.removeFromSuperview()
                hud = nil
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
    
    func setInfoFromSetBombCallback(response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let bombNum = BaseInfoUtil.getIntegerFromAnyObject(response["result"])
            UserCache.instance.user.bombNum = bombNum
            self.overlayView.bombNumBtn.setTitle("\(bombNum)", forState: UIControlState.Normal)
            refreshMap(true)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func goToStore() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("Store")
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func guideMe() {
        if !UserCache.instance.ifLogin() {
            UserInfoManager.instance.checkIfGoToLogin(self)
            return
        }
        
        if endGoal != nil {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier("Navigation") as! NavigationController
            viewController.arriveDelegate = self
            viewController.startPoint = AMapNaviPoint.locationWithLatitude(CGFloat(latitude), longitude: CGFloat(longitude))
            viewController.endPoint = AMapNaviPoint.locationWithLatitude(CGFloat(endGoal!.latitude), longitude: CGFloat(endGoal!.longitude))
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    func getGoal() {
        if GoalCache.instance.ifNeedClearMap {
            return
        }
        
        if !UserCache.instance.ifLogin() {
            UserInfoManager.instance.checkIfGoToLogin(self)
            return
        }
        
        let paramDict = NSMutableDictionary()
        let pkId: Int64 = (endGoal.pkId)
        let goalType: Int = (endGoal.type.rawValue)
        paramDict["goal_id"] = "\(pkId)"
        paramDict["goal_type"] = "\(goalType)"
        
        getGoalManager.POST(UrlParam.GET_GOAL_URL, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            print("JSON: " + responseObject.description!)
            self.setInfoFromGetGoalCallback(response)
        }) { (operation, error) in
            let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
        }
    }
    
    func setInfoFromGetGoalCallback(response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            HudToastFactory.showScore(self.endGoal.score, view: self.view)
            
            UserCache.instance.user.record = BaseInfoUtil.getIntegerFromAnyObject(response["result"])
            self.updateEndGoal()
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
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
        if !ifSeeGoal {
            let errorMessage = NSLocalizedString("ERROR_GUIDE_NOT_SEE_MONSTER", comment: "You can only use the monster guide when you see the monster")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: nil)
            return
        }
        
        if overlayView != nil && !overlayView.goalImageView.hidden {
            guideView.goalImageView.image = UIImage(named: GoalImageFactory.get(endGoal.type, showTypeName: endGoal.showTypeName))
            if endGoal.unionType == 1 {
                if endGoal.score < 0 {
                    guideView.roleLabel.text = NSLocalizedString("NONE", comment: "None") as String
                } else {
                    guideView.roleLabel.text = NSString(format: NSLocalizedString("LEAGUE_RACE", comment: "%d race is enough"), endGoal.unionType) as String
                }
            } else if endGoal.unionType > 1{
                 guideView.roleLabel.text = NSString(format: NSLocalizedString("LEAGUE_RACES", comment: "League of %d races"), endGoal.unionType) as String
            }
            
            if endGoal.score > 0 {
                guideView.winScoreTitle.text = NSLocalizedString("WIN_SCORE", comment: "Win Score: ")
            } else {
                guideView.winScoreTitle.text = NSLocalizedString("BEAT_SCORE", comment: "Beat Score: ")

            }
            guideView.introductionLabel.text = endGoal!.introduction
            guideView.rateView.initStar(endGoal.score)
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
    
    func goToWarning() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("Warning") as! WarningController
        viewController.updateGoalDelegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func hitMonster() {
        if !UserCache.instance.ifLogin() {
            UserInfoManager.instance.checkIfGoToLogin(self)
            return
        }
        
        let paramDict = NSMutableDictionary()
        let pkId: Int64 = (endGoal?.pkId)!
        let accountRole: Int = UserCache.instance.user.role.rawValue
        paramDict["goal_id"] = "\(pkId)"
        paramDict["account_role"] = "\(accountRole)"
        
        hitMonsterManager.POST(UrlParam.HIT_MONSTER_URL, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            
            self.setInfoFromHitMonsterCallback(response)
            self.hitMonsterManager.ifLock = false
        }) { (operation, error) in
            let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
            self.hitMonsterManager.ifLock = false
        }
        
        hitMonsterManager.ifLock = true
    }
    
    func setInfoFromHitMonsterCallback(response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            if (result["score_sum"] != nil && !result.objectForKey("score_sum")!.isKindOfClass(NSNull)) {
                HudToastFactory.showScore(self.endGoal.score, view: self.view)
        
                if(UserCache.instance.ifLogin()) {
                    UserCache.instance.user.record = BaseInfoUtil.getIntegerFromAnyObject(result["score_sum"])
                    self.updateEndGoal()
                }
            } else {
                let canSuccess = BaseInfoUtil.getIntegerFromAnyObject(result["if_can_success"])
                if canSuccess == 0 {
                    HudToastFactory.show(NSLocalizedString("MESSAGE_NOT_SUCCESS", comment: "Please see the monster guide on the right"), view: self.view, type: HudToastFactory.MessageType.WARNING)
                    overlayView.hintLabel.text = NSLocalizedString("NOT_MEET_CONDITION", comment: "Not meet hit-monster condition")
                }
            }
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
            
            if code == CodeParam.ERROR_GOAL_DISAPPEAR {
                self.updateEndGoal()
            }
        }
    }
    
    func close() {
        guideView.hidden = true
    }
    
    func share() {
        if endGoal == nil {
            let errorMessage = NSLocalizedString("ERROR_NO_GOAL", comment: "There is no goal for you")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: nil)
            return
        }
        
        if !ifSeeGoal {
            let errorMessage = NSLocalizedString("ERROR_NOT_SEE_MONSTER", comment: "You can only share the goal when you see it")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: nil)
            return
        }
        
        let shareParams = NSMutableDictionary()
        var shareUrl = "https://m.hideseek.cn/home/mindex/sharePage?goal_id=\(endGoal.pkId)" +
                "&nickname=" + (UserCache.instance.user.nickname as String) +
                "&role=\(UserCache.instance.user.role.rawValue)"
        shareUrl = shareUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        shareParams.SSDKSetupShareParamsByText(NSLocalizedString("SHARE_MESSAGE", comment: "My God! A monster is watching at me, please help me!"),
                                                images : UIImage(named: "ic_launcher"),
                                                url : NSURL(string: shareUrl),
                                                title : NSLocalizedString("SHARE_TITLE", comment: "Enter into the age of tribes"),
                                                type : SSDKContentType.Auto)
        
        let platforms = [SSDKPlatformType.TypeWechat.rawValue, SSDKPlatformType.TypeQQ.rawValue]
        
        ShareSDK.showShareActionSheet(self.view,
                                      items: platforms,
                                      shareParams: shareParams) { (state, platformType, userData, contentEntity, error, end) in
                                        switch state {
                                        case SSDKResponseState.Success:
                                            break;
                                        case SSDKResponseState.Fail:
                                            break;
                                        default:
                                            break;
                                        }
                                        
        }
        
    }
    
    func arrivedAtGoal() {
        refreshDistance()
        
        checkIfGoalDisplayed()
    }
    
    func refresh() {
        overlayView.mapView.removeAnnotations(markerDictionary.allValues)
        mapDialogController.mapView.removeAnnotations(markerDictionary.allValues)
        endGoal = nil
        markerDictionary.removeAllObjects()
        goalDictionary.removeAllObjects()
        GoalCache.instance.reset()
        refreshMap(true)
    }
    
    func hideBottomBar() {
        self.tabBarController?.tabBar.hidden = false
    }
}
