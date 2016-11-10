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
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as! Set<String>
        
        getOrderManager = CustomRequestManager()
        getOrderManager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as! Set<String>

        purchaseOrderTableManager = PurchaseOrderTableManager.instance
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.orderTableView.orderList = PurchaseOrderCache.instance.orderList
        self.orderTableView.reloadData()
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        purchaseDialogController = storyboard.instantiateViewController(withIdentifier: "purchaseDialog") as! PurchaseDialogController
        purchaseDialogController.confirmPurchaseDelegate = self
        purchaseDialogController.closeDelegate = self
        purchaseDialogController.changePayWayDelegate = self
        payManager = PayWayFactory.get(purchaseDialogController.payWay)
        payManager.purchaseDelegate = self
        
        if(UserCache.instance.ifLogin()) {
            UIView.animate(withDuration: 0.25,
                                       delay: 0,
                                       options: UIViewAnimationOptions.beginFromCurrentState,
                                       animations: {
                                        
                                        self.orderTableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.frame.size.height);
                }, completion: { (finished) in
                    self.refreshControl.beginRefreshing()
                    self.refreshControl.sendActions(for: UIControlEvents.valueChanged)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        self.screenRect = UIScreen.main.bounds
        self.purchaseWidth = self.screenRect.width - 40
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PurchaseOrderController.refreshData), for: UIControlEvents.valueChanged)
        orderTableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        orderTableView.addSubview(refreshControl)
        orderTableView.loadMoreDelegate = self
        orderTableView.purchaseDelegate = self
        
        let refreshContents = Bundle.main.loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents?[0] as! UIView
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
    
    func setInfoFromRefreshCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            PurchaseOrderCache.instance.setOrders(response["result"] as! NSDictionary)
            self.orderTableView.orderList = PurchaseOrderCache.instance.cacheList
            self.orderTableView.reloadData()
            self.refreshControl.endRefreshing()
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
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
        UIView.setAnimationDidStop(#selector(PurchaseOrderController.endAnimation))
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
                                self.orderTableView.tableFooterView?.isHidden = true
                })
            } else {
                self.orderTableView.orderList.removeAllObjects();
                self.orderTableView.orderList.addObjects(from: PurchaseOrderCache.instance.orderList as [AnyObject])
                self.orderTableView.reloadData()
                
                isLoading = false
                self.orderTableView.tableFooterView?.isHidden = true
            }
        }
    }
    
    func setInfoFromGetCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            PurchaseOrderCache.instance.addOrders(response["result"] as! NSDictionary)
            
            self.orderTableView.orderList = PurchaseOrderCache.instance.cacheList
            self.orderTableView.reloadData()
            self.isLoading = false
            self.orderTableView.tableFooterView?.isHidden = true
        } else {
            let errorMessage = ErrorMessageFactory.get(code)
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })

        }
    }
    
    func purchase(_ product: Product, orderId: Int64) {
        if product.pkId == 2 && UserCache.instance.user.hasGuide {
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("ALREADY_HAS_GUIDE", comment: "You already have monster guide. Continue to buy?"), preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"),
                                             style: UIAlertActionStyle.cancel, handler: nil)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default, handler: { (action) in
                self.openPurchaseDialog(product, orderId: orderId)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.openPurchaseDialog(product, orderId: orderId)
        }
    }
    
    func openPurchaseDialog(_ product: Product, orderId: Int64) {
        grayView = UIView(frame: screenRect)
        grayView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        
        purchaseDialogController.view.layer.frame = CGRect(
            x: (screenRect.width - purchaseWidth) / 2,
            y: (screenRect.height - purchaseHeight) / 2 - 110,
            width: purchaseWidth,
            height: purchaseHeight)
        purchaseDialogController.productNameLabel.text = product.name
        purchaseDialogController.price = product.price
        purchaseDialogController.orderId = orderId
        purchaseDialogController.product = product
        
        self.view.addSubview(grayView)
        self.view.addSubview(purchaseDialogController.view)
    }
    
    func confirmPurchase(_ product: Product, count: Int, orderId: Int64) {
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
    
    func setInfoFromGetOrderCallback(_ response: NSDictionary, product: Product, count: Int) {
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
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
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
    
    func showMessage(_ message: String, type: HudToastFactory.MessageType) {
        HudToastFactory.show(message, view: self.view, type: type)
    }
    
    func purchase() {
        let successMessage = NSLocalizedString("SUCCESS_PURCHASE", comment: "Purchase the product successfully")
        HudToastFactory.show(successMessage, view: self.view, type: HudToastFactory.MessageType.success)
        
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
    
    func setInfoFromPurchaseCallback(_ response: NSDictionary) {
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
            HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.error, callback: {
                if code == CodeParam.ERROR_SESSION_INVALID {
                    UserInfoManager.instance.logout(self)
                }
            })
        }
    }
    
    func payWayChanged(_ payWay: PayWayFactory.PayWayEnum) {
        self.payManager = PayWayFactory.get(payWay)
    }
}
