//
//  NagivationController.swift
//  HideSeek
//
//  Created by apple on 7/18/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class NavigationController: UIViewController, AMapNaviWalkManagerDelegate, AMapNaviWalkViewDelegate, AMapNaviWalkDataRepresentable, IFlySpeechSynthesizerDelegate {
    
    var startPoint: AMapNaviPoint!
    var endPoint: AMapNaviPoint!
    var walkManager: AMapNaviWalkManager!
    var walkView: AMapNaviWalkView!
    var speechSynthesizer: IFlySpeechSynthesizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        initWalkView()
        initWalkManager()
        speechSynthesizer = IFlySpeechSynthesizer.sharedInstance()
        speechSynthesizer.delegate = self
        speechSynthesizer.setParameter(IFlySpeechConstant.TYPE_CLOUD(), forKey: IFlySpeechConstant.ENGINE_TYPE())
        speechSynthesizer.setParameter("50", forKey: IFlySpeechConstant.VOLUME())
        speechSynthesizer.setParameter("xiaoyan", forKey: IFlySpeechConstant.VOICE_NAME())
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.calculateRoute()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        AMapNaviWalkDataRepresentable
    **/
    func walkManager(walkManager: AMapNaviWalkManager, updateNaviMode naviMode: AMapNaviMode) {
        NSLog("updateNaviMode:%ld", naviMode.rawValue);
    }
    
    func walkManager(walkManager: AMapNaviWalkManager, updateNaviRouteID naviRouteID: Int) {
        NSLog("updateNaviRouteID:%ld", naviRouteID);
    }
    
    func walkManager(walkManager: AMapNaviWalkManager, updateNaviRoute naviRoute: AMapNaviRoute?) {
        NSLog("updateNaviRoute");
    }
    
    func walkManager(walkManager: AMapNaviWalkManager, updateNaviInfo naviInfo: AMapNaviInfo?) {

    }
    
    func walkManager(walkManager: AMapNaviWalkManager, updateNaviLocation naviLocation: AMapNaviLocation?) {
        NSLog("updateNaviLocation");
    }
    
    /**
     AMapNaviWalkManager Delegate
    **/
    func walkManager(walkManager: AMapNaviWalkManager, error: NSError) {
        NSLog("error:{%ld - %@}", error.code, error.localizedDescription)
    }
    
    func walkManagerOnCalculateRouteSuccess(walkManager: AMapNaviWalkManager) {
        NSLog("onCalculateRouteSuccess")
        
        self.walkManager.startGPSNavi()
    }
    
    func walkManager(walkManager: AMapNaviWalkManager, onCalculateRouteFailure error: NSError) {
        NSLog("onCalculateRouteFailure:{%ld - %@}", error.code, error.localizedDescription)
    }
    
    func walkManager(walkManager: AMapNaviWalkManager, didStartNavi naviMode: AMapNaviMode) {
        NSLog("didStartNavi")
    }
    
    func walkManager(walkManager: AMapNaviWalkManager, playNaviSoundString soundString: String, soundStringType: AMapNaviSoundType) {
        
        NSLog("playNaviSoundString:{%ld:%@}", soundStringType.rawValue, soundString)
        
        speechSynthesizer.startSpeaking(soundString)
        
    }
    
    func walkManagerOnArrivedDestination(walkManager: AMapNaviWalkManager) {
        NSLog("arrived at the goal!")
    }
    
    func walkViewCloseButtonClicked(walkView: AMapNaviWalkView) {
        self.walkManager.stopNavi()
        self.walkManager.removeDataRepresentative(self.walkView)
        
        self.walkView.removeFromSuperview()
        
        speechSynthesizer.stopSpeaking()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func calculateRoute() {
        self.walkManager.calculateWalkRouteWithStartPoints([startPoint], endPoints: [endPoint])
    }
    
    func initWalkView() {
        if self.walkView == nil {
            self.walkView = AMapNaviWalkView(frame: self.view.bounds)
            self.walkView.delegate = self
            self.walkView.showMoreButton = false
            
            self.view.addSubview(self.walkView)
        }
    }
    
    func initWalkManager() {
        if self.walkManager == nil {
            self.walkManager = AMapNaviWalkManager()
            self.walkManager.delegate = self
            
            self.walkManager.addDataRepresentative(walkView)
            self.walkManager.addDataRepresentative(self)
            self.walkManager.allowsBackgroundLocationUpdates = true
        }
    }
    
    func onCompleted(error: IFlySpeechError!) {
        
    }
}
