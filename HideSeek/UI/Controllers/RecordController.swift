//
//  RecordController.swift
//  HideSeek
//
//  Created by apple on 7/12/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class RecordController: UIViewController, UIScrollViewDelegate, LoadMoreDelegate {
    let HtmlType = "text/html"
    let TAG_LOADING_IMAGEVIEW = 1
    var manager: CustomRequestManager!
    @IBOutlet weak var recordTableView: RecordTableView!
    @IBOutlet weak var scoreSum: UILabel!
    var refreshControl: UIRefreshControl!
    var recordTableManager: RecordTableManager!
    var loadingImageView: UIImageView!
    var customLoadingView: UIView!
    var angle: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        recordTableManager = RecordTableManager.instance
        initView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(UserCache.instance.ifLogin()) {
            UIView.animateWithDuration(0.25,
                                       delay: 0,
                                       options: UIViewAnimationOptions.BeginFromCurrentState,
                                       animations: {
                                        
                                        self.recordTableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
                }, completion: { (finished) in
                    self.refreshControl.beginRefreshing()
                    self.refreshControl.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(RecordController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        recordTableView.addSubview(refreshControl)
        recordTableView.loadMoreDelegate = self
        recordTableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents[0] as! UIView
        loadingImageView = customLoadingView.viewWithTag(TAG_LOADING_IMAGEVIEW) as! UIImageView
        customLoadingView.frame = refreshControl.bounds
        refreshControl.addSubview(customLoadingView)
    }
    
    func refreshData() {
        let paramDict: NSMutableDictionary = ["version": String(recordTableManager.version), "record_min_id": String(recordTableManager.recordMinId)]
        manager.POST(UrlParam.REFRESH_RECORD_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        RecordCache.instance.setRecords(response["result"] as! NSDictionary)
                        self.scoreSum.text = String(RecordCache.instance.scoreSum)
                        self.recordTableView.recordList = RecordCache.instance.cacheList
                        self.recordTableView.reloadData()
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
        UIView.setAnimationDidStopSelector(#selector(RecordController.endAnimation))
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
        let recordList = RecordCache.instance.getMoreRecord(10)
        
        if(recordList.count == 0) {
            let paramDict: NSMutableDictionary = ["version": String(recordTableManager.version), "record_min_id": String(recordTableManager.recordMinId)]
            manager.POST(UrlParam.GET_RECORD_URL,
                         paramDict: paramDict,
                         success: { (operation, responseObject) in
                            print("JSON: " + responseObject.description!)
                            let response = responseObject as! NSDictionary
                            RecordCache.instance.setRecords(response["result"] as! NSDictionary)
                            
                            self.recordTableView.recordList = RecordCache.instance.cacheList
                            self.recordTableView.reloadData()
                            self.recordTableView.tableFooterView = nil
                },
                         failure: { (operation, error) in
                            print("Error: " + error.localizedDescription)
                            self.recordTableView.tableFooterView = nil
            })
        } else {
            self.recordTableView.recordList.arrayByAddingObjectsFromArray(recordList as [AnyObject])
            self.recordTableView.reloadData()
        }
    }
}
