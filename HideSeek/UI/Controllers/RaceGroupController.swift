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
    var manager: CustomRequestManager!
    var refreshControl: UIRefreshControl!
    var customLoadingView: UIView!
    var loadingImageView: UIImageView!
    var angle: CGFloat = 0
    var raceGroupTableManager: RaceGroupTableManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        raceGroupTableManager = RaceGroupTableManager.instance
        initView()
        
        self.raceGroupTableView.raceGroupList = RaceGroupCache.instance.raceGrouplist
        self.raceGroupTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents[0] as! UIView
        loadingImageView = customLoadingView.viewWithTag(TAG_LOADING_IMAGEVIEW) as! UIImageView
        customLoadingView.frame = refreshControl.bounds
        refreshControl.addSubview(customLoadingView)
    }

    func refreshData() {
        let paramDict: NSMutableDictionary = ["version": String(raceGroupTableManager.version), "record_min_id": String(raceGroupTableManager.recordMinId)]
        manager.POST(UrlParam.REFRESH_RACE_GROUP_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        RaceGroupCache.instance.setRaceGroup(response["result"] as! NSDictionary)
                        self.raceGroupTableView.raceGroupList = RaceGroupCache.instance.cacheList
                        self.raceGroupTableView.reloadData()
                        self.refreshControl.endRefreshing()
            },
                     failure: { (operation, error) in
                        print("Error: " + error.localizedDescription)
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
    
    func loadMore() {
        let raceGroupList = RaceGroupCache.instance.getMoreRaceGroup(10)
        
        if(raceGroupList.count == 0) {
            let paramDict: NSMutableDictionary = ["version": String(raceGroupTableManager.version), "record_min_id": String(raceGroupTableManager.recordMinId)]
            manager.POST(UrlParam.GET_RACE_GROUP_URL,
                         paramDict: paramDict,
                         success: { (operation, responseObject) in
                            print("JSON: " + responseObject.description!)
                            let response = responseObject as! NSDictionary
                            RaceGroupCache.instance.addRaceGroup(response["result"] as! NSDictionary)
                            
                            self.raceGroupTableView.raceGroupList = RaceGroupCache.instance.cacheList
                            self.raceGroupTableView.reloadData()
                            self.raceGroupTableView.tableFooterView = nil
                },
                         failure: { (operation, error) in
                            print("Error: " + error.localizedDescription)
                            self.raceGroupTableView.tableFooterView = nil
            })
        } else {
            self.raceGroupTableView.raceGroupList.arrayByAddingObjectsFromArray(raceGroupList as [AnyObject])
            self.raceGroupTableView.reloadData()
        }
    }
}
