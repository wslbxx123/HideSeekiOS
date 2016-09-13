//
//  RaceGroupController.swift
//  HideSeek
//
//  Created by apple on 7/3/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import AFNetworking

class RaceGroupController: UIViewController, UIScrollViewDelegate, LoadMoreDelegate{
    let HtmlType = "text/html"
    let TAG_LOADING_IMAGEVIEW = 1
    @IBOutlet weak var raceGroupTableView: RaceGroupTableView!
    @IBOutlet weak var noResultStackView: UIStackView!
    var manager: CustomRequestManager!
    var refreshControl: UIRefreshControl!
    var customLoadingView: UIView!
    var loadingImageView: UIImageView!
    var angle: CGFloat = 0
    var raceGroupTableManager: RaceGroupTableManager!
    var isLoading: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        raceGroupTableManager = RaceGroupTableManager.instance
        initView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.raceGroupTableView.raceGroupList = RaceGroupCache.instance.raceGroupList
        self.raceGroupTableView.reloadData()
        
        if(UserCache.instance.ifLogin()) {
            UIView.animateWithDuration(0.25,
                                       delay: 0,
                                       options: UIViewAnimationOptions.BeginFromCurrentState,
                                       animations: {
                                        
                                        self.raceGroupTableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
                }, completion: { (finished) in
                    self.refreshControl.beginRefreshing()
                    self.refreshControl.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initView() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(RaceGroupController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        raceGroupTableView.addSubview(refreshControl)
        raceGroupTableView.loadMoreDelegate = self
        raceGroupTableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents[0] as! UIView
        loadingImageView = customLoadingView.viewWithTag(TAG_LOADING_IMAGEVIEW) as! UIImageView
        customLoadingView.frame = refreshControl.bounds
        refreshControl.addSubview(customLoadingView)
        self.automaticallyAdjustsScrollViewInsets = false
    }

    func refreshData() {
        let paramDict: NSMutableDictionary = ["version": String(raceGroupTableManager.version), "record_min_id": String(raceGroupTableManager.recordMinId)]
        isLoading = true
        manager.POST(UrlParam.REFRESH_RACE_GROUP_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        self.setInfoFromRefreshCallback(response)
                        
                    }, failure: { (operation, error) in
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
    
    func endAnimation() {
        if(refreshControl.refreshing) {
            angle += 10;
            playAnimateRefresh()
        }
    }
    
    func setInfoFromRefreshCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            RaceGroupCache.instance.setRaceGroup(response["result"] as! NSDictionary)
            self.raceGroupTableView.raceGroupList = RaceGroupCache.instance.cacheList
            self.raceGroupTableView.reloadData()
            
            if self.raceGroupTableView.raceGroupList.count == 0 {
                self.noResultStackView.hidden = false
            } else {
                self.noResultStackView.hidden = true
            }
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
        
        self.refreshControl.endRefreshing()
        self.isLoading = false
    }
    
    func loadMore() {
        if !isLoading {
            isLoading = true
            let hasData = RaceGroupCache.instance.getMoreRaceGroup(10, hasLoaded: false)
            
            if(!hasData) {
                let paramDict: NSMutableDictionary = ["version": String(raceGroupTableManager.version), "record_min_id": String(raceGroupTableManager.recordMinId)]
                manager.POST(UrlParam.GET_RACE_GROUP_URL,
                             paramDict: paramDict,
                             success: { (operation, responseObject) in
                                print("JSON: " + responseObject.description!)
                                let response = responseObject as! NSDictionary
                                
                                self.setInfoFromGetCallback(response)
                    },
                             failure: { (operation, error) in
                                print("Error: " + error.localizedDescription)
                })
            } else {
                self.raceGroupTableView.raceGroupList.removeAllObjects();
                self.raceGroupTableView.raceGroupList.addObjectsFromArray(RaceGroupCache.instance.raceGroupList as [AnyObject])
                self.raceGroupTableView.reloadData()
                
                isLoading = false
                self.raceGroupTableView.tableFooterView?.hidden = true
            }
        }
    }
    
    func setInfoFromGetCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            RaceGroupCache.instance.addRaceGroup(response["result"] as! NSDictionary)
            
            self.raceGroupTableView.raceGroupList = RaceGroupCache.instance.cacheList
            self.raceGroupTableView.reloadData()
            self.isLoading = false
            self.raceGroupTableView.tableFooterView?.hidden = true
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
}
