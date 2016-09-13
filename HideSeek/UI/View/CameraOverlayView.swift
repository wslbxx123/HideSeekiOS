//
//  CameraOverlayView.swift
//  HideSeek
//
//  Created by apple on 6/22/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class CameraOverlayView: UIView, HitMonsterDelegate {
    var mapView:MAMapView!
    
    @IBOutlet weak var bombNumBtn: UIButton!
    @IBOutlet weak var guideBtn: UIButton!
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var setBombBtn: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var monsterGuideBtn: UIButton!
    @IBOutlet weak var distanceView: HomeView!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var goalImageView: GoalImageView!
    @IBOutlet weak var swordImageView: SwordImageView!
    @IBOutlet weak var warningBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    var refreshMapDelegate: RefreshMapDelegate!
    var setBombDelegate: SetBombDelegate!
    var guideDelegate: GuideDelegate!
    var getGoalDelegate: GetGoalDelegate!
    var hitMonsterDelegate: HitMonsterDelegate!
    var guideMonsterDelegate: GuideMonsterDelegate!
    var warningDelegate: WarningDelegate!
    var shareDelegate: ShareDelegate!
    
    private var _endGoal: Goal! = nil
    var endGoal: Goal! {
        get {
            return _endGoal
        }
        set {
            _endGoal = newValue
            goalImageView.endGoal = newValue
        }
    }
    
    @IBAction func getBtnClicked(sender: AnyObject) {
        if ifGoalShow() {
            switch(_endGoal.type) {
            case .mushroom:
                getGoalDelegate?.getGoal()
                break
            case .monster:
                swordImageView.hitMonster()
                hitMonsterDelegate?.hitMonster()
                break;
            default:
                break
            }
        }
    }
    
    @IBAction func refreshBtnClicked(sender: AnyObject) {
        refreshMapDelegate?.refresh()
    }
    
    @IBAction func setBombClicked(sender: AnyObject) {
        setBombDelegate?.setBomb()
    }
    
    @IBAction func monsterGuideClicked(sender: AnyObject) {
        guideMonsterDelegate?.guideMonster()
    }
    
    @IBAction func guideBtnClicked(sender: AnyObject) {
        guideDelegate?.guideMe()
    }
    
    @IBAction func bombNumClicked(sender: AnyObject) {
        setBombDelegate?.setBomb()
    }
    
    @IBAction func warningBtnClicked(sender: AnyObject) {
        warningDelegate?.goToWarning()
    }
    
    @IBAction func shareBtnClicked(sender: AnyObject) {
        shareDelegate?.share()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getDuration(endGoal: Goal) -> Double{
        switch(endGoal.type) {
        case .bomb:
            return 3
        case .mushroom:
            return 2
        case .monster:
            return 2
        default:
            return 0
        }
    }
    
    func addMapView(mapViewDelegate: MAMapViewDelegate) {
        if mapView == nil {
            mapView = MAMapView(frame: CGRectMake(0, 0, CGRectGetWidth(mapUIView.bounds), CGRectGetHeight(mapUIView.bounds)))
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
        mapUIView.addSubview(mapView)
    }
    
    func showGoal() {
        goalImageView.getGoalDelegate = getGoalDelegate
        swordImageView.hitMonsterDelegate = self
        
        print("goalImageView show!!!!!!!!'")
        goalImageView.hidden = false
        goalImageView.startAnimating()
    }
    
    func hideGoal() {
        goalImageView.hidden = true
        goalImageView.stopAnimating()
    }
    
    func ifGoalShow() -> Bool {
        return !goalImageView.hidden
    }
    
    func hitMonster() {
        goalImageView.hitMonster()
    }
}
