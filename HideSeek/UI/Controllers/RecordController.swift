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
    @IBOutlet weak var scoreSumLabel: UILabel!
    @IBOutlet weak var noResultStackView: UIStackView!
    var refreshControl: UIRefreshControl!
    var recordTableManager: RecordTableManager!
    var loadingImageView: UIImageView!
    var customLoadingView: UIView!
    var angle: CGFloat = 0
    var isLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        recordTableManager = RecordTableManager.instance
        initView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scoreSumLabel.text = String(RecordCache.instance.scoreSum)
        self.recordTableView.recordList = RecordCache.instance.recordList
        self.recordTableView.reloadData()
        
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
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
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
        recordTableView.layoutMargins = UIEdgeInsetsZero
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func refreshData() {
        let paramDict: NSMutableDictionary = ["version": String(recordTableManager.version), "record_min_id": String(recordTableManager.recordMinId)]
        manager.POST(UrlParam.REFRESH_RECORD_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        
                        self.setInfoFromRefreshCallback(response)
                        
            },
                     failure: { (operation, error) in
                        print("Error: " + error.localizedDescription)
        })
        playAnimateRefresh()
    }
    
    func setInfoFromRefreshCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            RecordCache.instance.setRecords(response["result"] as! NSDictionary)
            self.scoreSumLabel.text = String(RecordCache.instance.scoreSum)
            self.recordTableView.recordList = RecordCache.instance.cacheList
            if self.recordTableView.recordList.count == 0 {
                self.noResultStackView.hidden = false
            } else {
                self.noResultStackView.hidden = true
            }
            self.recordTableView.reloadData()
            self.refreshControl.endRefreshing()
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
            self.refreshControl.endRefreshing()
        }
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
        if !isLoading {
            isLoading = true
            
            let hasData = RecordCache.instance.getMoreRecord(10, hasLoaded: false)
            
            if(!hasData) {
                let paramDict: NSMutableDictionary = ["version": String(recordTableManager.version), "record_min_id": String(recordTableManager.recordMinId)]
                manager.POST(UrlParam.GET_RECORD_URL,
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
                self.recordTableView.recordList.removeAllObjects()
                self.recordTableView.recordList.addObjectsFromArray(RecordCache.instance.recordList as [AnyObject])
                self.recordTableView.reloadData()
                
                isLoading = false
                self.recordTableView.tableFooterView?.hidden = true
            }
        }
    }
    
    func setInfoFromGetCallback(response: NSDictionary) {
        let code = (response["code"] as! NSString).integerValue
        
        if code == CodeParam.SUCCESS {
            RecordCache.instance.addRecords(response["result"] as! NSDictionary)
            
            self.recordTableView.recordList = RecordCache.instance.cacheList
            self.recordTableView.reloadData()
            self.isLoading = false
            self.recordTableView.tableFooterView?.hidden = true
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
