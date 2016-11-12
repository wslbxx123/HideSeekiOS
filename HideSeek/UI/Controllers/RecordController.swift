//
//  RecordController.swift
//  HideSeek
//
//  Created by apple on 7/12/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import OAStackView

class RecordController: UIViewController, UIScrollViewDelegate, LoadMoreDelegate {
    let HtmlType = "text/html"
    let TAG_LOADING_IMAGEVIEW = 1
    var manager: CustomRequestManager!
    @IBOutlet weak var recordTableView: RecordTableView!
    @IBOutlet weak var scoreSumLabel: UILabel!
    @IBOutlet weak var noResultView: OAStackView!
    var refreshControl: UIRefreshControl!
    var recordTableManager: RecordTableManager!
    var loadingImageView: UIImageView!
    var customLoadingView: UIView!
    var angle: CGFloat = 0
    var isLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        recordTableManager = RecordTableManager.instance
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scoreSumLabel.text = String(RecordCache.instance.scoreSum)
        self.recordTableView.recordList = RecordCache.instance.recordList
        self.recordTableView.reloadData()
        if self.recordTableView.recordList.count == 0 {
            self.noResultView.isHidden = false
            self.recordTableView.isHidden = true
        } else {
            self.noResultView.isHidden = true
            self.recordTableView.isHidden = false
        }
        
        if(UserCache.instance.ifLogin()) {
            UIView.animate(withDuration: 0.25,
                                       delay: 0,
                                       options: UIViewAnimationOptions.beginFromCurrentState,
                                       animations: {
                                        
                                        self.recordTableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.frame.size.height);
                }, completion: { (finished) in
                    self.refreshControl.beginRefreshing()
                    self.refreshControl.sendActions(for: UIControlEvents.valueChanged)
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(RecordController.refreshData), for: UIControlEvents.valueChanged)
        recordTableView.addSubview(refreshControl)
        recordTableView.loadMoreDelegate = self
        recordTableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        
        let refreshContents = Bundle.main.loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents?[0] as! UIView
        loadingImageView = customLoadingView.viewWithTag(TAG_LOADING_IMAGEVIEW) as! UIImageView
        customLoadingView.frame = refreshControl.bounds
        refreshControl.addSubview(customLoadingView)
        recordTableView.layoutMargins = UIEdgeInsets.zero
    }
    
    func refreshData() {
        let paramDict: NSMutableDictionary = ["version": String(recordTableManager.version), "record_min_id": String(recordTableManager.recordMinId)]
        _ = manager.POST(UrlParam.REFRESH_RECORD_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.debugDescription)
                        let response = responseObject as! NSDictionary
                        
                        self.setInfoFromRefreshCallback(response)
                        
            },
                     failure: { (operation, error) in
                        print("Error: " + error.localizedDescription)
        })
        playAnimateRefresh()
    }
    
    func setInfoFromRefreshCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            RecordCache.instance.setRecords(response["result"] as! NSDictionary)
            self.scoreSumLabel.text = String(RecordCache.instance.scoreSum)
            self.recordTableView.recordList = RecordCache.instance.cacheList
            if self.recordTableView.recordList.count == 0 {
                self.noResultView.isHidden = false
                self.recordTableView.isHidden = true
            } else {
                self.noResultView.isHidden = true
                self.recordTableView.isHidden = false
            }
            self.recordTableView.reloadData()
            self.refreshControl.endRefreshing()
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
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
        UIView.setAnimationDidStop(#selector(RecordController.endAnimation))
        self.loadingImageView.transform = CGAffineTransform(rotationAngle: angle * CGFloat(M_PI / 180))
        UIView.commitAnimations()
    }

    func endAnimation() {
        if(refreshControl.isRefreshing) {
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
                _ = manager.POST(UrlParam.GET_RECORD_URL,
                             paramDict: paramDict,
                             success: { (operation, responseObject) in
                                print("JSON: " + responseObject.debugDescription)
                                let response = responseObject as! NSDictionary
                                
                                self.setInfoFromGetCallback(response)
                    },
                             failure: { (operation, error) in
                                print("Error: " + error.localizedDescription)
                })
            } else {
                self.recordTableView.recordList.removeAllObjects()
                self.recordTableView.recordList.addObjects(from: RecordCache.instance.recordList as [AnyObject])
                self.recordTableView.reloadData()
                
                isLoading = false
                self.recordTableView.tableFooterView?.isHidden = true
            }
        }
    }
    
    func setInfoFromGetCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            RecordCache.instance.addRecords(response["result"] as! NSDictionary)
            
            self.recordTableView.recordList = RecordCache.instance.cacheList
            self.recordTableView.reloadData()
            self.isLoading = false
            self.recordTableView.tableFooterView?.isHidden = true
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
}
