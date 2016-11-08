//
//  CameraOverlayView.swift
//  HideSeek
//
//  Created by apple on 6/22/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import OAStackView

class CameraOverlayView: UIView, HitMonsterDelegate {
    var mapView:MAMapView!
    
    @IBOutlet weak var bombNumBtn: UIButton!
    @IBOutlet weak var guideBtn: UIButton!
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var setBombBtn: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var monsterGuideBtn: UIButton!
    @IBOutlet weak var distanceView: HomeView!
    @IBOutlet weak var locationView: OAStackView!
    @IBOutlet weak var goalImageView: GoalImageView!
    @IBOutlet weak var swordImageView: SwordImageView!
    @IBOutlet weak var warningBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var roleImageView: UIImageView!
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var mapGuideImageView: UIImageView!
    @IBOutlet weak var getGuideImageView: UIImageView!
    @IBOutlet weak var getMonsterGuideImageView: UIImageView!
    @IBOutlet weak var boxGuideImageView: UIImageView!
    @IBOutlet weak var refreshGuideImageView: UIImageView!
    @IBOutlet weak var refreshGuideArrowImageView: UIImageView!
    @IBOutlet weak var guideView: UIView!
    @IBOutlet weak var roleNameLabel: UILabel!
    @IBOutlet weak var roleInfoView: UIView!
    
    var refreshMapDelegate: RefreshMapDelegate!
    var setBombDelegate: SetBombDelegate!
    var guideDelegate: GuideDelegate!
    var getGoalDelegate: GetGoalDelegate!
    var hitMonsterDelegate: HitMonsterDelegate!
    var guideMonsterDelegate: GuideMonsterDelegate!
    var warningDelegate: WarningDelegate!
    var shareDelegate: ShareDelegate!
    var hideBottomBarDelegate: HideBottomBarDelegate!
    var step: Int = 0
    
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
    
    @IBAction func nextStepBtnClicked(sender: AnyObject) {
        refreshGuide()
    }
    
    @IBAction func startBtnClicked(sender: AnyObject) {
        refreshGuide()
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
        
        mapView.showsScale = true
        mapView.delegate = mapViewDelegate
        mapView.showsCompass = false
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
    
    func initGuide() {
        step = 0
    }
    
    func refreshGuide() {
        switch step {
        case 0:
            showMapGuide()
            break;
        case 1:
            showGetMonsterGuide()
            break;
        case 2:
            showGetGuide()
            break;
        case 3:
            showRefreshGuide()
            break;
        default:
            finishGuide()
            break;
        }
        
        step += 1
    }
    
    func showMapGuide() {
        self.guideView.hidden = false
        self.nextStepBtn.hidden = false
        self.mapGuideImageView.hidden = false
        self.getGuideImageView.hidden = true
        self.getMonsterGuideImageView.hidden = true
        self.boxGuideImageView.hidden = true
        self.refreshGuideImageView.hidden = true
        self.refreshGuideArrowImageView.hidden = true
        self.startBtn.hidden = true
    }
    
    func showGetGuide() {
        self.guideView.hidden = false
        self.nextStepBtn.hidden = false
        self.mapGuideImageView.hidden = true
        self.getGuideImageView.hidden = false
        self.getMonsterGuideImageView.hidden = true
        self.boxGuideImageView.hidden = true
        self.refreshGuideImageView.hidden = true
        self.refreshGuideArrowImageView.hidden = true
        self.startBtn.hidden = true
    }
    
    func showGetMonsterGuide() {
        self.guideView.hidden = false
        self.nextStepBtn.hidden = false
        self.mapGuideImageView.hidden = true
        self.getGuideImageView.hidden = true
        self.getMonsterGuideImageView.hidden = false
        self.boxGuideImageView.hidden = false
        self.refreshGuideImageView.hidden = true
        self.refreshGuideArrowImageView.hidden = true
        self.startBtn.hidden = true
    }
    
    func showRefreshGuide() {
        self.guideView.hidden = false
        self.nextStepBtn.hidden = true
        self.mapGuideImageView.hidden = true
        self.getGuideImageView.hidden = true
        self.getMonsterGuideImageView.hidden = true
        self.boxGuideImageView.hidden = true
        self.refreshGuideImageView.hidden = false
        self.refreshGuideArrowImageView.hidden = false
        self.startBtn.hidden = false
    }
    
    func finishGuide() {
        self.guideView.hidden = true
        self.nextStepBtn.hidden = true
        self.mapGuideImageView.hidden = true
        self.getGuideImageView.hidden = true
        self.getMonsterGuideImageView.hidden = true
        self.boxGuideImageView.hidden = true
        self.refreshGuideImageView.hidden = true
        self.refreshGuideArrowImageView.hidden = true
        self.startBtn.hidden = true
        
        NSUserDefaults.standardUserDefaults().setObject(BaseInfoUtil.getAppVersion(), forKey: UserDefaultParam.APP_VERSION)
        NSUserDefaults.standardUserDefaults().synchronize()
        hideBottomBarDelegate?.hideBottomBar()
    }
}
