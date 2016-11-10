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
    
    fileprivate var _endGoal: Goal! = nil
    var endGoal: Goal! {
        get {
            return _endGoal
        }
        set {
            _endGoal = newValue
            goalImageView.endGoal = newValue
        }
    }
    
    @IBAction func getBtnClicked(_ sender: AnyObject) {
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
    
    @IBAction func refreshBtnClicked(_ sender: AnyObject) {
        refreshMapDelegate?.refresh()
    }
    
    @IBAction func setBombClicked(_ sender: AnyObject) {
        setBombDelegate?.setBomb()
    }
    
    @IBAction func monsterGuideClicked(_ sender: AnyObject) {
        guideMonsterDelegate?.guideMonster()
    }
    
    @IBAction func guideBtnClicked(_ sender: AnyObject) {
        guideDelegate?.guideMe()
    }
    
    @IBAction func bombNumClicked(_ sender: AnyObject) {
        setBombDelegate?.setBomb()
    }
    
    @IBAction func warningBtnClicked(_ sender: AnyObject) {
        warningDelegate?.goToWarning()
    }
    
    @IBAction func shareBtnClicked(_ sender: AnyObject) {
        shareDelegate?.share()
    }
    
    @IBAction func nextStepBtnClicked(_ sender: AnyObject) {
        refreshGuide()
    }
    
    @IBAction func startBtnClicked(_ sender: AnyObject) {
        refreshGuide()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getDuration(_ endGoal: Goal) -> Double{
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
    
    func addMapView(_ mapViewDelegate: MAMapViewDelegate) {
        if mapView == nil {
            mapView = MAMapView(frame: CGRect(x: 0, y: 0, width: mapUIView.bounds.width, height: mapUIView.bounds.height))
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
        goalImageView.isHidden = false
        goalImageView.startAnimating()
    }
    
    func hideGoal() {
        goalImageView.isHidden = true
        goalImageView.stopAnimating()
    }
    
    func ifGoalShow() -> Bool {
        return !goalImageView.isHidden
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
        self.guideView.isHidden = false
        self.nextStepBtn.isHidden = false
        self.mapGuideImageView.isHidden = false
        self.getGuideImageView.isHidden = true
        self.getMonsterGuideImageView.isHidden = true
        self.boxGuideImageView.isHidden = true
        self.refreshGuideImageView.isHidden = true
        self.refreshGuideArrowImageView.isHidden = true
        self.startBtn.isHidden = true
    }
    
    func showGetGuide() {
        self.guideView.isHidden = false
        self.nextStepBtn.isHidden = false
        self.mapGuideImageView.isHidden = true
        self.getGuideImageView.isHidden = false
        self.getMonsterGuideImageView.isHidden = true
        self.boxGuideImageView.isHidden = true
        self.refreshGuideImageView.isHidden = true
        self.refreshGuideArrowImageView.isHidden = true
        self.startBtn.isHidden = true
    }
    
    func showGetMonsterGuide() {
        self.guideView.isHidden = false
        self.nextStepBtn.isHidden = false
        self.mapGuideImageView.isHidden = true
        self.getGuideImageView.isHidden = true
        self.getMonsterGuideImageView.isHidden = false
        self.boxGuideImageView.isHidden = false
        self.refreshGuideImageView.isHidden = true
        self.refreshGuideArrowImageView.isHidden = true
        self.startBtn.isHidden = true
    }
    
    func showRefreshGuide() {
        self.guideView.isHidden = false
        self.nextStepBtn.isHidden = true
        self.mapGuideImageView.isHidden = true
        self.getGuideImageView.isHidden = true
        self.getMonsterGuideImageView.isHidden = true
        self.boxGuideImageView.isHidden = true
        self.refreshGuideImageView.isHidden = false
        self.refreshGuideArrowImageView.isHidden = false
        self.startBtn.isHidden = false
    }
    
    func finishGuide() {
        self.guideView.isHidden = true
        self.nextStepBtn.isHidden = true
        self.mapGuideImageView.isHidden = true
        self.getGuideImageView.isHidden = true
        self.getMonsterGuideImageView.isHidden = true
        self.boxGuideImageView.isHidden = true
        self.refreshGuideImageView.isHidden = true
        self.refreshGuideArrowImageView.isHidden = true
        self.startBtn.isHidden = true
        
        UserDefaults.standard.set(BaseInfoUtil.getAppVersion(), forKey: UserDefaultParam.APP_VERSION)
        UserDefaults.standard.synchronize()
        hideBottomBarDelegate?.hideBottomBar()
    }
}
