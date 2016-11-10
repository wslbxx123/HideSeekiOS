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
    var arriveDelegate: ArriveDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        initWalkView()
        initWalkManager()
        speechSynthesizer = IFlySpeechSynthesizer.sharedInstance()
        speechSynthesizer.delegate = self
        speechSynthesizer.setParameter(IFlySpeechConstant.type_CLOUD(), forKey: IFlySpeechConstant.engine_TYPE())
        speechSynthesizer.setParameter("50", forKey: IFlySpeechConstant.volume())
        speechSynthesizer.setParameter("xiaoyan", forKey: IFlySpeechConstant.voice_NAME())
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    func walkManager(_ walkManager: AMapNaviWalkManager, update naviMode: AMapNaviMode) {
        NSLog("updateNaviMode:%ld", naviMode.rawValue);
    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, updateNaviRouteID naviRouteID: Int) {
        NSLog("updateNaviRouteID:%ld", naviRouteID);
    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, update naviRoute: AMapNaviRoute?) {
        NSLog("updateNaviRoute");
    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, update naviInfo: AMapNaviInfo?) {

    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, update naviLocation: AMapNaviLocation?) {
        NSLog("updateNaviLocation");
    }
    
    /**
     AMapNaviWalkManager Delegate
    **/
    func walkManager(_ walkManager: AMapNaviWalkManager, error: Error) {
        NSLog("error:{%ld - %@}", error._code, error.localizedDescription)
    }
    
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        NSLog("onCalculateRouteSuccess")
        
        self.walkManager.startGPSNavi()
    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, onCalculateRouteFailure error: Error) {
        NSLog("onCalculateRouteFailure:{%ld - %@}", error._code, error.localizedDescription)
    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, didStartNavi naviMode: AMapNaviMode) {
        NSLog("didStartNavi")
    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, playNaviSound soundString: String, soundStringType: AMapNaviSoundType) {
        
        NSLog("playNaviSoundString:{%ld:%@}", soundStringType.rawValue, soundString)
        
        speechSynthesizer.startSpeaking(soundString)
        
    }
    
    func walkManager(onArrivedDestination walkManager: AMapNaviWalkManager) {
        NSLog("arrived at the goal!")
        
        arriveDelegate?.arrivedAtGoal()
    }
    
    func walkViewCloseButtonClicked(_ walkView: AMapNaviWalkView) {
        self.walkManager.stopNavi()
        self.walkManager.removeDataRepresentative(self.walkView)
        
        self.walkView.removeFromSuperview()
        
        speechSynthesizer.stopSpeaking()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func calculateRoute() {
        self.walkManager.calculateWalkRoute(withStart: [startPoint], end: [endPoint])
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
    
    func onCompleted(_ error: IFlySpeechError!) {
        
    }
}
