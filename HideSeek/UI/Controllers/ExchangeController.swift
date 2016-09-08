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
    ConfirmExchangeDelegate, CloseDelegate, LoadMoreDelegate {
    let HtmlType = "text/html"
    let TAG_LOADING_IMAGEVIEW = 1
    
    @IBOutlet weak var collectionView: ExchangeCollectionView!
    var rewardRefreshControl: UIRefreshControl!
    var manager: AFHTTPRequestOperationManager!
    var angle: CGFloat = 0
    var loadingImageView: UIImageView!
    var customLoadingView: UIView!
    var rewardTableManager: RewardTableManager!
    var createOrderManager: CustomRequestManager!
    var exchangeDialogController: ExchangeDialogController!
    var screenRect: CGRect!
    var exchangeHeight: CGFloat = 250
    var exchangeWidth: CGFloat!
    var grayView: UIView!
    var isLoading: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)
        
        createOrderManager = CustomRequestManager()
        createOrderManager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        rewardTableManager = RewardTableManager.instance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.collectionView.rewardList = RewardCache.instance.rewardList
        self.collectionView.reloadData()
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        exchangeDialogController = storyboard.instantiateViewControllerWithIdentifier("exchangeDialog") as! ExchangeDialogController
        exchangeDialogController.confirmExchangeDelegate = self
        exchangeDialogController.closeDelegate = self

        
        UIView.animateWithDuration(0.25,
                                   delay: 0,
                                   options: UIViewAnimationOptions.BeginFromCurrentState,
                                   animations: {
                                    
                                    self.collectionView.contentOffset = CGPointMake(0, -self.rewardRefreshControl.frame.size.height);
            }, completion: { (finished) in
                self.rewardRefreshControl.beginRefreshing()
                self.rewardRefreshControl.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        })
    }
    
    func initView() {
        rewardRefreshControl = UIRefreshControl()
        rewardRefreshControl.addTarget(self, action: #selector(ExchangeController.refreshRewardData), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(rewardRefreshControl)
        collectionView.alwaysBounceVertical = true
        collectionView.exchangeDelegate = self
        collectionView.loadMoreDelegate = self
        
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents[0] as! UIView
        loadingImageView = customLoadingView.viewWithTag(TAG_LOADING_IMAGEVIEW) as! UIImageView
        customLoadingView.frame = rewardRefreshControl.bounds
        rewardRefreshControl.addSubview(customLoadingView)
        screenRect = UIScreen.mainScreen().bounds
        exchangeWidth = screenRect.width - 40
    }
    
    func refreshRewardData() {
        let paramDict: NSMutableDictionary = ["version": "\(rewardTableManager.version)",
                                              "reward_min_id": "\(rewardTableManager.rewardMinId)"]
        isLoading = true
        manager.POST(UrlParam.REFRESH_REWARD_URL,
                     parameters: paramDict,
                     success: { (operation, responseObject) in
                        let response = responseObject as! NSDictionary
                        print("JSON: " + responseObject.description!)
                        RewardCache.instance.setRewards(response["result"] as! NSDictionary)
                        
                        self.collectionView.rewardList = RewardCache.instance.cacheList
                        self.collectionView.reloadData()
                        self.rewardRefreshControl.endRefreshing()
                        self.isLoading = false
            },
                     failure: { (operation, error) in
                        print("Error: " + error.localizedDescription)
                        self.isLoading = false
        })
        playAnimateRefresh()
    }
    
    func playAnimateRefresh() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.01)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStopSelector(#selector(RaceGroupController.endAnimation))
        self.loadingImageView.transform = CGAffineTransformMakeRotation(angle * CGFloat(M_PI / 180))
        UIView.commitAnimations()
    }
    
    func exchange(reward: Reward) {
        grayView = UIView(frame: screenRect)
        grayView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        exchangeDialogController.view.layer.frame = CGRectMake(
            (screenRect.width - exchangeWidth) / 2,
            (screenRect.height - exchangeHeight) / 2 - 110,
            exchangeWidth,
            exchangeHeight)
        exchangeDialogController.rewardNameLabel.text = reward.name
        exchangeDialogController.record = reward.record
        exchangeDialogController.reward = reward
        self.view.addSubview(grayView)
        self.view.addSubview(exchangeDialogController.view)
    }
    
    func confirmExchange(reward: Reward, count: Int) {
        let paramDict: NSMutableDictionary = ["reward_id": "\(reward.pkId)",
                                              "count": "\(count)"]
        
        createOrderManager.POST(UrlParam.CREATE_EXCHANGE_ORDER_URL,
                                paramDict: paramDict,
                                success: { (operation, responseObject) in
                                    let response = responseObject as! NSDictionary
                                    if(response["code"] as! NSString).integerValue == CodeParam.SUCCESS {
                                        UserCache.instance.user.record = response["result"] is NSString ?
                                            (response["result"] as! NSString).integerValue :
                                            (response["result"] as! NSNumber).integerValue
                                        self.close()
                                    }
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func close() {
        grayView.removeFromSuperview()
        exchangeDialogController.view.removeFromSuperview()
    }

    func loadMore() {
        if !isLoading {
            isLoading = true
            let hasData = RewardCache.instance.getMoreRewards(10, hasLoaded: false)
            if self.collectionView.footer != nil {
                self.collectionView.footer.hidden = false
            }
            
            if(!hasData) {
                let paramDict: NSMutableDictionary = ["version": String(rewardTableManager.version), "reward_min_id": String(rewardTableManager.rewardMinId)]
                manager.POST(UrlParam.GET_REWARD_URL,
                             parameters: paramDict,
                             success: { (operation, responseObject) in
                                print("JSON: " + responseObject.description!)
                                let response = responseObject as! NSDictionary
                                
                                RewardCache.instance.addRewards(response["result"] as! NSDictionary)
                                if self.collectionView.footer != nil {
                                    self.collectionView.footer.hidden = true
                                }
                                self.collectionView.rewardList = RewardCache.instance.cacheList
                                self.collectionView.reloadData()
                                self.isLoading = false
                    },
                             failure: { (operation, error) in
                                print("Error: " + error.localizedDescription)
                                if self.collectionView.footer != nil {
                                    self.collectionView.footer.hidden = true
                                }
                })
            } else {
            
                self.collectionView.rewardList.addObjectsFromArray(
                    RewardCache.instance.rewardList as [AnyObject])
                if self.collectionView.footer != nil {
                    self.collectionView.footer.hidden = true
                }
                self.collectionView.reloadData()
                
                isLoading = false
            }
        }
    }
}
