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
    var manager: AFHTTPSessionManager!
    var setBombManager: CustomRequestManager!
    var getGoalManager: CustomRequestManager!
    var hitMonsterManager: CustomRequestManager!
    var updateUserInfoManager: CustomRequestManager!
//    var success: AFHTTPRequestOperation!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var endGoal: Goal!
    var endPoint: MAMapPoint!
    var startPoint: MAMapPoint!
    var distance: Double = 0
    var overlayView: CameraOverlayView!
    var markerDictionary = NSMutableDictionary()
    var goalDictionary = NSMutableDictionary()
    var time: Timer!
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

        manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        setBombManager = CustomRequestManager()
        setBombManager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        getGoalManager = CustomRequestManager()
        getGoalManager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        updateUserInfoManager = CustomRequestManager()
        updateUserInfoManager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        hitMonsterManager = CustomRequestManager()
        hitMonsterManager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        
        locManager = CLLocationManager()
        locManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.session != nil && !self.session.isRunning) {
            self.session.startRunning()
        }
        
        if self.locationManager != nil {
            self.locationManager.startUpdatingLocation()
        }
        
        time = Timer.scheduledTimer(timeInterval: REFRESH_MAP_INTERVAL, target: self, selector: #selector(HomeController.refreshMap), userInfo: nil, repeats: true)
        if overlayView != nil {
            initMenuBtn()
//            mapDialogController.initView(mapWidth, mapHeight: mapHeight)
            
            if UserCache.instance.ifLogin() {
                let user = UserCache.instance.user
                overlayView.welcomeLabel.isHidden = true
                overlayView.hintLabel.isHidden = false
                overlayView.roleImageView.image = UIImage(named: (user?.roleImageName)!)
                overlayView.roleNameLabel.text = user?.roleName
                
                updateUserInfo()
            } else {
                overlayView.welcomeLabel.isHidden = false
                overlayView.hintLabel.isHidden = true
            }
        }
        
        self.navigationController?.isNavigationBarHidden = true
        if CLLocationManager.headingAvailable() {
            locManager.startUpdatingHeading()
        }
        
        if GoalCache.instance.ifNeedClearMap {
            refresh()
        }
        
        refreshDistance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        if CLLocationManager.headingAvailable() {
            locManager.stopUpdatingHeading()
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
        _ = updateUserInfoManager.POST(UrlParam.UPDATE_USER_INFO_URL, paramDict: paramDict, success: { (operation, responseObject) in
            let response = responseObject as! NSDictionary
            print("JSON: " + responseObject.description!)
            
            self.setInfoFromUpdateUserInfoCallback(response)
        }) { (operation, error) in
            print("Error: " + error.localizedDescription)
        }
    }
    
    func setInfoFromUpdateUserInfoCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            UserCache.instance.user.bombNum = BaseInfoUtil.getIntegerFromAnyObject(result["bomb_num"])
            self.overlayView.bombNumBtn.setTitle("\(UserCache.instance.user.bombNum)", for: UIControlState())
            UserCache.instance.user.hasGuide = BaseInfoUtil.getIntegerFromAnyObject(result["has_guide"]) == 1
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func checkIfFirstUse() {
        let appVersion = UserDefaults.standard.object(forKey: UserDefaultParam.APP_VERSION) as? NSString
        
        if appVersion == nil || BaseInfoUtil.getAppVersion().compareTo(appVersion! as String, separator: ".") > 0 {
            self.tabBarController!.tabBar.isHidden = true
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
        
        overlayView = Bundle.main.loadNibNamed("CameraOverlay", owner: nil, options: nil)?.first as? CameraOverlayView
        if overlayView != nil {
            let frame = UIScreen.main.bounds
            overlayView?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            overlayView?.addMapView(self)
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(overlayView)
            let widthConstraint = NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
            let centerXConstraint = NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let centerYConstraint = NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            self.view.addConstraints([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
            initOverlayView()
            initMapDialog()
            initMonsterGuide()
            configLocationManager()
        }
    }
    
    func initCamera() {
        do {
            self.device = self.cameraWithPosition(AVCaptureDevicePosition.back)
            self.input = try AVCaptureDeviceInput(device: self.device)
            self.imageOutput = AVCaptureStillImageOutput()
            self.session = AVCaptureSession()
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
                self.session.sessionPreset = AVCaptureSessionPresetHigh
            } else {
                self.session.sessionPreset = AVCaptureSessionPresetMedium
            }
            
            if self.session.canAddInput(self.input) {
                self.session.addInput(self.input)
            }
        } catch {
            let errorMessage = NSLocalizedString("ERROR_INIT_CAMERA", comment: "Failed to initialize camera")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
        }
    }
    
    func cameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as NSArray
        
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
        overlayView.locationView.isUserInteractionEnabled = true
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
                overlayView.bombNumBtn.setTitle("99+", for: UIControlState())
            } else {
                overlayView.bombNumBtn.setTitle("\(bombNum)", for: UIControlState())
            }
            overlayView.bombNumBtn.isHidden = false
            overlayView.setBombBtn.isHidden = false
            overlayView.monsterGuideBtn.isHidden = false
            overlayView.warningBtn.isHidden = false
            overlayView.shareBtn.isHidden = false
            overlayView.roleInfoView.isHidden = false
        } else {
            overlayView.bombNumBtn.isHidden = true
            overlayView.setBombBtn.isHidden = true
            overlayView.monsterGuideBtn.isHidden = true
            overlayView.warningBtn.isHidden = true
            overlayView.shareBtn.isHidden = true
            overlayView.roleInfoView.isHidden = true
        }
    }
    
    func initMonsterGuide() {
        let guideViewContents = Bundle.main.loadNibNamed("MonsterGuideView",
                                                                   owner: view, options: nil)
        guideView = guideViewContents?[0] as! MonsterGuideView
        guideView.layer.frame = CGRect(
            x: 20,
            y: (screenRect.height - 300) / 2 - 50,
            width: screenRect.width - 40,
            height: 300)
        self.view.addSubview(guideView)
        guideView.initView()
        guideView.isHidden = true
        guideView.closeDelegate = self
    }
    
    func initMapDialog() {
        screenRect = UIScreen.main.bounds
        mapWidth = screenRect.width - 40
        mapHeight = mapWidth
        grayView = UIView(frame: screenRect)
        grayView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        mapDialogController = storyboard.instantiateViewController(withIdentifier: "mapDialog") as! MapDialogController
        mapDialogController.view.layer.frame = CGRect(
            x: (screenRect.width - mapWidth) / 2,
            y: (screenRect.height - mapHeight) / 2,
            width: mapWidth,
            height: mapHeight)
        mapDialogController.view.isUserInteractionEnabled = true
        mapDialogController.markerDictionary = markerDictionary
        mapDialogController.goalDictionary = goalDictionary
        mapDialogController.setEndGoalDelegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeController.closeMapDialog(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        grayView.addGestureRecognizer(gestureRecognizer)
        
        self.view.addSubview(grayView)
        self.view.addSubview(mapDialogController.view)
        mapDialogController.initView(mapWidth, mapHeight: mapHeight)
        grayView.isHidden = true
        mapDialogController.view.isHidden = true
    }
    
    func configLocationManager() {
        self.locationManager = AMapLocationManager()
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        if self.pointAnnotation == nil {
            self.pointAnnotation = MAPointAnnotation()
            self.circleAnnotation = MAPointAnnotation()
            
            self.overlayView.mapView.addAnnotation(self.pointAnnotation)
            self.overlayView.mapView.addAnnotation(self.circleAnnotation)
            self.mapDialogController.mapView.addAnnotation(self.pointAnnotation)
            self.mapDialogController.mapView.addAnnotation(self.circleAnnotation)
            refreshMap(false);
        }
        
        self.pointAnnotation.coordinate = location.coordinate
        self.circleAnnotation.coordinate = location.coordinate
        self.mapDialogController.pointAnnotation = self.pointAnnotation
        self.mapDialogController.circleAnnotation = self.circleAnnotation
        
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
            overlayView.distanceLabel.text = NSString(format: NSLocalizedString("M", comment: "%.0f m") as NSString, distance) as String
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
        _ = getGoalManager.POST(UrlParam.SEE_MONSTER_URL, paramDict: paramDict, success: { (operation, responseObject) in
            print("JSON: " + responseObject.description!)
            let response = responseObject as! NSDictionary
            let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
            
            if code != CodeParam.SUCCESS {
                let errorMessage = ErrorMessageFactory.get(code)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                    if code == CodeParam.ERROR_SESSION_INVALID {
                        UserInfoManager.instance.logout(self)
                    }
                })
                self.ifSeeGoal = false
            }
        }) { (operation, error) in
            let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
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
    
    func updateEndGoal(_ goalId: Int64) {
        GoalCache.instance.selectedGoal?.isSelected = false
        let goal = GoalCache.instance.getGoal(goalId)
        
        if goal != nil {
            goal!.isSelected = true
            GoalCache.instance.selectedGoal = goal!
            setEndGoal()
        } else {
            let errorMessage = NSLocalizedString("ERROR_GOAL_INVALID", comment: "The goal has disappeared or beyond your range")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
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
                    annotationView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                }
            } else if circleAnnotation == annotation as! MAPointAnnotation {
                let pointReuseIndetifier = "pointReuseIndetifier"
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
                
                if annotationView == nil {
                    annotationView = MAAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                    annotationView.image = UIImage(named: "location_circle")
                    annotationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
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
    
    func refreshMap(_ ifSure: Bool) {
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
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = NSLocalizedString("REFRESH_MAP_HINT", comment: "Refreshing map...")
            hud.dimBackground = true
        }
        
        startPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(latitude, longitude));
        
        if UserCache.instance.ifLogin() {
            let user = UserCache.instance.user
            paramDict["account_role"] = String(describing: user?.role.rawValue)
        }
        
        _ = manager.post(UrlParam.REFRESH_MAP_URL,
                    parameters: paramDict,
                    success: { (operation, responseObject) in
                        let response = responseObject as! NSDictionary
                        print("JSON: " + (responseObject as AnyObject).description!)
                        
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
    
    func setGoalsOnMap(_ goals: NSMutableArray) {
        for goal in goals {
            let goalInfo = goal as! Goal
            
            if markerDictionary.allKeys.contains(where: { element in
                return ((element as! NSNumber).int64Value == goalInfo.pkId)
            }) {
                
                if let annotation = markerDictionary.object(forKey: NSNumber(value: goalInfo.pkId as Int64)) as? MAPointAnnotation {
                    if !goalInfo.valid {
                        overlayView.mapView.removeAnnotation(annotation)
                        overlayView.mapView.addAnnotation(annotation)
                        overlayView.mapView.removeAnnotation(annotation)
                        mapDialogController.mapView.removeAnnotation(annotation)
                        mapDialogController.mapView.addAnnotation(annotation)
                        mapDialogController.mapView.removeAnnotation(annotation)
                        markerDictionary.removeObject(forKey: NSNumber(value: goalInfo.pkId as Int64))
                        goalDictionary.removeObject(forKey: NSNumber(value: goalInfo.pkId as Int64))
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
                    markerDictionary.setObject(annotation, forKey: NSNumber(value: goalInfo.pkId as Int64))
                    goalDictionary.setObject(goalInfo, forKey: NSNumber(value: goalInfo.pkId as Int64))
                    overlayView.mapView.addAnnotation(annotation)
                    mapDialogController.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func setEndGoal() {
        let list = NSMutableArray()
        if endGoal != nil {
            list.add(endGoal)
            list.add(GoalCache.instance.selectedGoal!)
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
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = NSLocalizedString("LOADING_HINT", comment: "Please wait...")
            hud.dimBackground = true
            
            let paramDict = NSMutableDictionary()
            paramDict["latitude"] = "\(latitude)"
            paramDict["longitude"] = "\(longitude)"
            paramDict["orientation"] = "\(orientation)"
            
            setBombManager.POST(UrlParam.SET_BOMB_URL, paramDict: paramDict, success: { (operation, responseObject) in
                let response = responseObject as! NSDictionary
                print("JSON: " + responseObject.description!)
                hud.removeFromSuperview()
                
                self.setInfoFromSetBombCallback(response)
            }) { (operation, error) in
                print("Error: " + error.localizedDescription)
                hud.removeFromSuperview()
            }
        } else {
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("NOT_HAS_BOMB", comment: "You don't have bombs. Go to store to buy some?"), preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"),
                                             style: UIAlertActionStyle.cancel, handler: nil)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default, handler: { (action) in
                self.goToStore()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func setInfoFromSetBombCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let bombNum = BaseInfoUtil.getIntegerFromAnyObject(response["result"])
            UserCache.instance.user.bombNum = bombNum
            self.overlayView.bombNumBtn.setTitle("\(bombNum)", for: UIControlState())
            refreshMap(true)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func goToStore() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Store")
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func guideMe() {
        if !UserCache.instance.ifLogin() {
            UserInfoManager.instance.checkIfGoToLogin(self)
            return
        }
        
        if endGoal != nil {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "Navigation") as! NavigationController
            viewController.arriveDelegate = self
            viewController.startPoint = AMapNaviPoint.location(withLatitude: CGFloat(latitude), longitude: CGFloat(longitude))
            viewController.endPoint = AMapNaviPoint.location(withLatitude: CGFloat(endGoal!.latitude), longitude: CGFloat(endGoal!.longitude))
            self.present(viewController, animated: true, completion: nil)
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
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
        }
    }
    
    func setInfoFromGetGoalCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            HudToastFactory.showScore(self.endGoal.score, view: self.view)
            
            UserCache.instance.user.record = BaseInfoUtil.getIntegerFromAnyObject(response["result"])
            self.updateEndGoal()
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
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
                                                    message: NSLocalizedString("NOT_HAS_GUIDE", comment: "You don't have monster guide. Go to store to buy one?"), preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"),
                                             style: UIAlertActionStyle.cancel, handler: nil)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default, handler: { (action) in
                self.goToStore()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showMonsterGuide() {
        if !ifSeeGoal {
            let errorMessage = NSLocalizedString("ERROR_GUIDE_NOT_SEE_MONSTER", comment: "You can only use the monster guide when you see the monster")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: nil)
            return
        }
        
        if overlayView != nil && !overlayView.goalImageView.isHidden {
            guideView.goalImageView.image = UIImage(named: GoalImageFactory.get(endGoal.type, showTypeName: endGoal.showTypeName))
            if endGoal.unionType == 1 {
                if endGoal.score < 0 {
                    guideView.roleLabel.text = NSLocalizedString("NONE", comment: "None") as String
                } else {
                    guideView.roleLabel.text = NSString(format: NSLocalizedString("LEAGUE_RACE", comment: "%d race is enough") as NSString, endGoal.unionType) as String
                }
            } else if endGoal.unionType > 1{
                 guideView.roleLabel.text = NSString(format: NSLocalizedString("LEAGUE_RACES", comment: "League of %d races") as NSString, endGoal.unionType) as String
            }
            
            if endGoal.score > 0 {
                guideView.winScoreTitle.text = NSLocalizedString("WIN_SCORE", comment: "Win Score: ")
            } else {
                guideView.winScoreTitle.text = NSLocalizedString("BEAT_SCORE", comment: "Beat Score: ")

            }
            guideView.introductionLabel.text = endGoal!.introduction
            guideView.rateView.initStar(endGoal.score)
            guideView.isHidden = !guideView.isHidden
        } else {
            if !guideView.isHidden {
                guideView.isHidden = true
            }
        }
    }
    
    func touchDown(_ tag: Int) {
        grayView.isHidden = false
        mapDialogController.view.isHidden = false
    }
    
    func closeMapDialog(_ sender: UITapGestureRecognizer) {
        grayView.isHidden = true
        mapDialogController.view.isHidden = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        orientation = Int(newHeading.magneticHeading) / 90 * 90 % 360
        checkIfGoalDisplayed()
        print("angle: \(orientation)")
    }
    
    func goToWarning() {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Warning") as! WarningController
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
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error)
            self.hitMonsterManager.ifLock = false
        }
        
        hitMonsterManager.ifLock = true
    }
    
    func setInfoFromHitMonsterCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            if (result["score_sum"] != nil && !(result.object(forKey: "score_sum")! as AnyObject).isKind(of: NSNull.self)) {
                HudToastFactory.showScore(self.endGoal.score, view: self.view)
        
                if(UserCache.instance.ifLogin()) {
                    UserCache.instance.user.record = BaseInfoUtil.getIntegerFromAnyObject(result["score_sum"])
                    self.updateEndGoal()
                }
            } else {
                let canSuccess = BaseInfoUtil.getIntegerFromAnyObject(result["if_can_success"])
                if canSuccess == 0 {
                    HudToastFactory.show(NSLocalizedString("MESSAGE_NOT_SUCCESS", comment: "Please see the monster guide on the right"), view: self.view, type: HudToastFactory.MessageType.warning)
                    overlayView.hintLabel.text = NSLocalizedString("NOT_MEET_CONDITION", comment: "Not meet hit-monster condition")
                }
            }
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
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
        guideView.isHidden = true
    }
    
    func share() {
        if endGoal == nil {
            let errorMessage = NSLocalizedString("ERROR_NO_GOAL", comment: "There is no goal for you")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: nil)
            return
        }
        
        if !ifSeeGoal {
            let errorMessage = NSLocalizedString("ERROR_NOT_SEE_MONSTER", comment: "You can only share the goal when you see it")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: nil)
            return
        }
        
        let shareParams = NSMutableDictionary()
        var shareUrl = "https://m.hideseek.cn/home/mindex/sharePage?goal_id=\(endGoal.pkId)" +
                "&nickname=" + (UserCache.instance.user.nickname as String) +
                "&role=\(UserCache.instance.user.role.rawValue)"
        shareUrl = shareUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        shareParams.ssdkSetupShareParams(byText: NSLocalizedString("SHARE_MESSAGE", comment: "My God! A monster is watching at me, please help me!"),
                                                images : UIImage(named: "ic_launcher"),
                                                url : URL(string: shareUrl),
                                                title : NSLocalizedString("SHARE_TITLE", comment: "Enter into the age of tribes"),
                                                type : SSDKContentType.auto)
        
        let platforms = [SSDKPlatformType.typeWechat.rawValue, SSDKPlatformType.typeQQ.rawValue]
        
        ShareSDK.showShareActionSheet(self.view,
                                      items: platforms,
                                      shareParams: shareParams) { (state, platformType, userData, contentEntity, error, end) in
                                        switch state {
                                        case SSDKResponseState.success:
                                            break;
                                        case SSDKResponseState.fail:
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
        self.tabBarController?.tabBar.isHidden = false
    }
}
