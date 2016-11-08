//
//  PurchaseOrderController.swift
//  HideSeek
//
//  Created by apple on 8/7/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class PurchaseOrderController: UIViewController, LoadMoreDelegate, PurchaseDelegate, ConfirmPurchaseDelegate,
    CloseDelegate, ChangePayWayDelegate {
    let HtmlType = "text/html"
    let TAG_LOADING_IMAGEVIEW = 1
    
    @IBOutlet weak var orderTableView: PurchaseOrderTableView!
    var manager: CustomRequestManager!
    var refreshControl: UIRefreshControl!
    var customLoadingView: UIView!
    var loadingImageView: UIImageView!
    var angle: CGFloat = 0
    var purchaseOrderTableManager: PurchaseOrderTableManager!
    var isLoading: Bool = true
    var grayView: UIView!
    var screenRect: CGRect!
    var purchaseDialogController: PurchaseDialogController!
    var purchaseHeight: CGFloat = 250
    var purchaseWidth: CGFloat!
    var getOrderManager: CustomRequestManager!
    var payManager: PayManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        
        getOrderManager = CustomRequestManager()
        getOrderManager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)

        purchaseOrderTableManager = PurchaseOrderTableManager.instance
        initView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.orderTableView.orderList = PurchaseOrderCache.instance.orderList
        self.orderTableView.reloadData()
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        purchaseDialogController = storyboard.instantiateViewControllerWithIdentifier("purchaseDialog") as! PurchaseDialogController
        purchaseDialogController.confirmPurchaseDelegate = self
        purchaseDialogController.closeDelegate = self
        purchaseDialogController.changePayWayDelegate = self
        payManager = PayWayFactory.get(purchaseDialogController.payWay)
        payManager.purchaseDelegate = self
        
        if(UserCache.instance.ifLogin()) {
            UIView.animateWithDuration(0.25,
                                       delay: 0,
                                       options: UIViewAnimationOptions.BeginFromCurrentState,
                                       animations: {
                                        
                                        self.orderTableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
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
        self.screenRect = UIScreen.mainScreen().bounds
        self.purchaseWidth = self.screenRect.width - 40
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PurchaseOrderController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        orderTableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        orderTableView.addSubview(refreshControl)
        orderTableView.loadMoreDelegate = self
        orderTableView.purchaseDelegate = self
        
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents[0] as! UIView
        loadingImageView = customLoadingView.viewWithTag(TAG_LOADING_IMAGEVIEW) as! UIImageView
        customLoadingView.frame = refreshControl.bounds
        refreshControl.addSubview(customLoadingView)
    }

    func refreshData() {
        let paramDict: NSMutableDictionary = ["version": String(purchaseOrderTableManager.version), "order_min_id": String(purchaseOrderTableManager.orderMinId)]
        isLoading = true
        manager.POST(UrlParam.REFRESH_PURCHASE_ORDERS_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.description!)
                        let response = responseObject as! NSDictionary
                        
                        self.setInfoFromRefreshCallback(response)
                        
                        self.isLoading = false
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
                self.isLoading = false
        })
        playAnimateRefresh()
    }
    
    func setInfoFromRefreshCallback(response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            PurchaseOrderCache.instance.setOrders(response["result"] as! NSDictionary)
            self.orderTableView.orderList = PurchaseOrderCache.instance.cacheList
            self.orderTableView.reloadData()
            self.refreshControl.endRefreshing()
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func playAnimateRefresh() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.01)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStopSelector(#selector(PurchaseOrderController.endAnimation))
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
            let hasData = PurchaseOrderCache.instance.getMoreOrders(10, hasLoaded: false)
            
            if(!hasData) {
                let paramDict: NSMutableDictionary = ["version": String(purchaseOrderTableManager.version), "order_min_id": String(purchaseOrderTableManager.orderMinId)]
                manager.POST(UrlParam.GET_PURCHASE_ORDERS_URL,
                             paramDict: paramDict,
                             success: { (operation, responseObject) in
                                print("JSON: " + responseObject.description!)
                                let response = responseObject as! NSDictionary
                                
                                self.setInfoFromGetCallback(response)
                    },
                             failure: { (operation, error) in
                                print("Error: " + error.localizedDescription)
                                self.orderTableView.tableFooterView?.hidden = true
                })
            } else {
                self.orderTableView.orderList.removeAllObjects();
                self.orderTableView.orderList.addObjectsFromArray(PurchaseOrderCache.instance.orderList as [AnyObject])
                self.orderTableView.reloadData()
                
                isLoading = false
                self.orderTableView.tableFooterView?.hidden = true
            }
        }
    }
    
    func setInfoFromGetCallback(response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            PurchaseOrderCache.instance.addOrders(response["result"] as! NSDictionary)
            
            self.orderTableView.orderList = PurchaseOrderCache.instance.cacheList
            self.orderTableView.reloadData()
            self.isLoading = false
            self.orderTableView.tableFooterView?.hidden = true
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })

        }
    }
    
    func purchase(product: Product, orderId: Int64) {
        if product.pkId == 2 && UserCache.instance.user.hasGuide {
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("ALREADY_HAS_GUIDE", comment: "You already have monster guide. Continue to buy?"), preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"),
                                             style: UIAlertActionStyle.Cancel, handler: nil)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default, handler: { (action) in
                self.openPurchaseDialog(product, orderId: orderId)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.openPurchaseDialog(product, orderId: orderId)
        }
    }
    
    func openPurchaseDialog(product: Product, orderId: Int64) {
        grayView = UIView(frame: screenRect)
        grayView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        purchaseDialogController.view.layer.frame = CGRectMake(
            (screenRect.width - purchaseWidth) / 2,
            (screenRect.height - purchaseHeight) / 2 - 110,
            purchaseWidth,
            purchaseHeight)
        purchaseDialogController.productNameLabel.text = product.name
        purchaseDialogController.price = product.price
        purchaseDialogController.orderId = orderId
        purchaseDialogController.product = product
        
        self.view.addSubview(grayView)
        self.view.addSubview(purchaseDialogController.view)
    }
    
    func confirmPurchase(product: Product, count: Int, orderId: Int64) {
        let paramDict: NSMutableDictionary = ["order_id": "\(orderId)",
                                              "store_id": "\(product.pkId)",
                                              "count": "\(count)"]
        getOrderManager.POST(UrlParam.GET_PURCHASE_ORDER_URL,
                                paramDict: paramDict,
                                success: { (operation, responseObject) in
                                    let response = responseObject as! NSDictionary
                                    
                                    self.setInfoFromGetOrderCallback(response, product: product, count: count)
                                    
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func setInfoFromGetOrderCallback(response: NSDictionary, product: Product, count: Int) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            self.payManager.purchase(
                result["sign"] as! NSString,
                tradeNo: result["trade_no"] as! NSString,
                product: product,
                count: count,
                orderId: purchaseDialogController.orderId)
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func close() {
        grayView.removeFromSuperview()
        purchaseDialogController.view.removeFromSuperview()
        refreshData()
    }
    
    func showMessage(message: String, type: HudToastFactory.MessageType) {
        HudToastFactory.show(message, view: self.view, type: type)
    }
    
    func purchase() {
        let successMessage = NSLocalizedString("SUCCESS_PURCHASE", comment: "Purchase the product successfully")
        HudToastFactory.show(successMessage, view: self.view, type: HudToastFactory.MessageType.SUCCESS)
        
        let paramDict: NSMutableDictionary = ["order_id": "\(purchaseDialogController.orderId)"]
        manager.POST(UrlParam.PURCHASE_URL,
                             paramDict: paramDict,
                             success: { (operation, responseObject) in
                                let response = responseObject as! NSDictionary
                                print("JSON: " + responseObject.description!)
                                
                                self.setInfoFromPurchaseCallback(response)
                                
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func setInfoFromPurchaseCallback(response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            let bombNum = BaseInfoUtil.getIntegerFromAnyObject(result["bomb_num"])
            let hasGuide = BaseInfoUtil.getIntegerFromAnyObject(result["has_guide"])
            
            UserCache.instance.user.bombNum = bombNum
            UserCache.instance.user.hasGuide = hasGuide == 1
            
            self.refreshData()
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func payWayChanged(payWay: PayWayFactory.PayWayEnum) {
        self.payManager = PayWayFactory.get(payWay)
    }
}
