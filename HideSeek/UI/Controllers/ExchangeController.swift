//
//  ExchangeController.swift
//  HideSeek
//
//  Created by apple on 8/2/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import AFNetworking

class ExchangeController: UIViewController, ExchangeDelegate,
    ConfirmExchangeDelegate, CloseDelegate, LoadMoreDelegate, ShowAreaDelegate, AreaPickerDelegate {
    let HtmlType = "text/html"
    let TAG_LOADING_IMAGEVIEW = 1
    
    @IBOutlet weak var collectionView: ExchangeCollectionView!
    var rewardRefreshControl: UIRefreshControl!
    var manager: AFHTTPSessionManager!
    var angle: CGFloat = 0
    var loadingImageView: UIImageView!
    var customLoadingView: UIView!
    var rewardTableManager: RewardTableManager!
    var createOrderManager: CustomRequestManager!
    var exchangeDialogController: ExchangeDialogController!
    var areaPickerView: AreaPickerView!
    var screenRect: CGRect!
    var exchangeHeight: CGFloat = 350
    var exchangeWidth: CGFloat!
    var grayView: UIView!
    var isLoading: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        manager = AFHTTPSessionManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        
        createOrderManager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        rewardTableManager = RewardTableManager.instance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.rewardList = RewardCache.instance.rewardList
        self.collectionView.reloadData()
        
        UIView.animate(withDuration: 0.25,
                                   delay: 0,
                                   options: UIViewAnimationOptions.beginFromCurrentState,
                                   animations: {
                                    
                                    self.collectionView.contentOffset = CGPoint(x: 0, y: -self.rewardRefreshControl.frame.size.height);
            }, completion: { (finished) in
                self.rewardRefreshControl.beginRefreshing()
                self.rewardRefreshControl.sendActions(for: UIControlEvents.valueChanged)
        })
    }
    
    func initView() {
        rewardRefreshControl = UIRefreshControl()
        rewardRefreshControl.addTarget(self, action: #selector(ExchangeController.refreshRewardData), for: UIControlEvents.valueChanged)
        collectionView.addSubview(rewardRefreshControl)
        collectionView.alwaysBounceVertical = true
        collectionView.exchangeDelegate = self
        collectionView.loadMoreDelegate = self
        
        let refreshContents = Bundle.main.loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents?[0] as! UIView
        loadingImageView = customLoadingView.viewWithTag(TAG_LOADING_IMAGEVIEW) as! UIImageView
        customLoadingView.frame = rewardRefreshControl.bounds
        rewardRefreshControl.addSubview(customLoadingView)
        screenRect = UIScreen.main.bounds
        exchangeWidth = screenRect.width - 40
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        exchangeDialogController = storyboard.instantiateViewController(withIdentifier: "exchangeDialog") as! ExchangeDialogController
        exchangeDialogController.confirmExchangeDelegate = self
        exchangeDialogController.closeDelegate = self
        exchangeDialogController.showAreaDelegate = self
        
        areaPickerView = Bundle.main.loadNibNamed("AreaPickerView", owner: nil, options: nil)?.first as! AreaPickerView
        areaPickerView.initWithStyle(AreaPickerView.AreaPickerStyle.areaPickerWithStateAndCityAndDistrict, delegate: self)
    
        areaPickerView.layer.frame = CGRect(
            x: 0,
            y: self.view.frame.height - 310,
            width: self.view.frame.width,
            height: 180)
    }
    
    func refreshRewardData() {
        let paramDict: NSMutableDictionary = ["version": "\(rewardTableManager.version)",
                                              "reward_min_id": "\(rewardTableManager.rewardMinId)"]
        isLoading = true
        _ = manager.post(UrlParam.REFRESH_REWARD_URL,
                         parameters: paramDict,
                         progress: nil,
                         success: { (dataTask, responseObject) in
                            let response = responseObject as! NSDictionary
                            print("JSON: " + (responseObject as AnyObject).description!)
                            RewardCache.instance.setRewards(response["result"] as! NSDictionary)
                            
                            self.collectionView.rewardList = RewardCache.instance.cacheList
                            self.collectionView.reloadData()
                            self.rewardRefreshControl.endRefreshing()
                            self.isLoading = false
            }, failure: { (dataTask, error) in
                print("Error: " + error.localizedDescription)
                self.isLoading = false
        })
        
        playAnimateRefresh()
    }
    
    func playAnimateRefresh() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.01)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(RaceGroupController.endAnimation))
        self.loadingImageView.transform = CGAffineTransform(rotationAngle: angle * CGFloat(M_PI / 180))
        UIView.commitAnimations()
    }
    
    func exchange(_ reward: Reward) {
        if !UserCache.instance.ifLogin() {
            UserInfoManager.instance.checkIfGoToLogin(self)
            return
        }
        
        grayView = UIView(frame: screenRect)
        grayView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        
        exchangeDialogController.view.layer.frame = CGRect(
            x: (screenRect.width - exchangeWidth) / 2,
            y: (screenRect.height - exchangeHeight) / 2 - 110,
            width: exchangeWidth,
            height: exchangeHeight)
        exchangeDialogController.rewardNameLabel.text = reward.name
        exchangeDialogController.record = reward.record
        exchangeDialogController.reward = reward
        self.view.addSubview(grayView)
        self.view.addSubview(exchangeDialogController.view)
    }
    
    func confirmExchange(_ reward: Reward, count: Int) {
        if count * reward.record > UserCache.instance.user.record {
            let errorMessage = NSLocalizedString("ERROR_RECORD_NOT_ENOUGH", comment: "You record is not enough")
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: nil)
            return;
        }
        
        let setDefault = exchangeDialogController.setDefaultSwitch.isOn ? "1" : "0"
        
        let paramDict: NSMutableDictionary = ["reward_id": "\(reward.pkId)",
                                              "count": "\(count)",
                                              "area": exchangeDialogController.area,
                                              "address": exchangeDialogController.address,
                                              "set_default": setDefault]
        
        _ = createOrderManager.POST(UrlParam.CREATE_EXCHANGE_ORDER_URL,
                                paramDict: paramDict,
                                success: { (operation, responseObject) in
                                    let response = responseObject as! NSDictionary
                                    self.setInfoFromCallback(response)
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func setInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            UserCache.instance.user.record = BaseInfoUtil.getIntegerFromAnyObject(response["result"])
            self.refreshRewardData()
            
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("SUCCESS_EXCHANGE", comment: "Exchange successfully! please wait for the reward notice. "), preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default, handler: { (action) in
                self.close()
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func close() {
        grayView.removeFromSuperview()
        exchangeDialogController.view.removeFromSuperview()
        areaPickerView.removeFromSuperview()
    }

    func loadMore() {
        if !isLoading {
            isLoading = true
            let hasData = RewardCache.instance.getMoreRewards(10, hasLoaded: false)
            if self.collectionView.footer != nil {
                self.collectionView.footer.isHidden = false
            }
            
            if(!hasData) {
                let paramDict: NSMutableDictionary = ["version": String(rewardTableManager.version), "reward_min_id": String(rewardTableManager.rewardMinId)]
                
                _ = manager.post(UrlParam.GET_REWARD_URL,
                                 parameters: paramDict,
                                 progress: nil,
                                 success: { (dataTask, responseObject) in
                                    print("JSON: " + (responseObject as AnyObject).description!)
                                    let response = responseObject as! NSDictionary
                                    
                                    RewardCache.instance.addRewards(response["result"] as! NSDictionary)
                                    if self.collectionView.footer != nil {
                                        self.collectionView.footer.isHidden = true
                                    }
                                    self.collectionView.rewardList = RewardCache.instance.cacheList
                                    self.collectionView.reloadData()
                                    self.isLoading = false
                    }, failure: { (dataTask, error) in
                        print("Error: " + error.localizedDescription)
                        if self.collectionView.footer != nil {
                            self.collectionView.footer.isHidden = true
                        }
                })
            } else {
            
                self.collectionView.rewardList.addObjects(
                    from: RewardCache.instance.rewardList as [AnyObject])
                if self.collectionView.footer != nil {
                    self.collectionView.footer.isHidden = true
                }
                self.collectionView.reloadData()
                
                isLoading = false
            }
        }
    }
    
    func showAreaPickerView() {
        self.view.addSubview(areaPickerView)
    }
    
    func pickerDidChange() {
        let location = areaPickerView.location
        if location.district == "" {
            exchangeDialogController.area = NSString(format: "%@-%@", location.state, location.city) as String
        } else {
            exchangeDialogController.area = NSString(format: "%@-%@-%@", location.state, location.city, location.district) as String
        }
        
        exchangeDialogController.checkIfConfirmEnabled()
        areaPickerView.removeFromSuperview()
    }
    
    func cancelChange() {
        exchangeDialogController.checkIfConfirmEnabled()
        areaPickerView.removeFromSuperview()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        exchangeDialogController.dismissKeyboard()
        exchangeDialogController.checkIfConfirmEnabled()
        areaPickerView.removeFromSuperview()
    }
}
