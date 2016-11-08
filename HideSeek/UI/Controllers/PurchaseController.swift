//
//  PurchaseController.swift
//  HideSeek
//
//  Created by apple on 8/2/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import StoreKit

class PurchaseController: UIViewController, PurchaseDelegate, ConfirmPurchaseDelegate,
    CloseDelegate, LoadMoreDelegate, ChangePayWayDelegate {
    let HtmlType = "text/html"
    let TAG_LOADING_IMAGEVIEW = 1
    
    @IBOutlet weak var collectionView: PurchaseCollectionView!
    var productRefreshControl: UIRefreshControl!
    var manager: AFHTTPRequestOperationManager!
    var angle: CGFloat = 0
    var loadingImageView: UIImageView!
    var customLoadingView: UIView!
    var productTableManager: ProductTableManager!
    var createOrderManager: CustomRequestManager!
    var payManager: PayManager!
    var purchaseDialogController: PurchaseDialogController!
    var screenRect: CGRect!
    var purchaseHeight: CGFloat = 250
    var purchaseWidth: CGFloat!
    var grayView: UIView!
    var isLoading: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet().setByAddingObject(HtmlType)
        
        createOrderManager = CustomRequestManager()
        createOrderManager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        productTableManager = ProductTableManager.instance
        payManager = PayWayFactory.get(purchaseDialogController.payWay)
        payManager.purchaseDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.collectionView.productList = ProductCache.instance.productList
        self.collectionView.reloadData()
        
        UIView.animateWithDuration(0.25,
                                   delay: 0,
                                   options: UIViewAnimationOptions.BeginFromCurrentState,
                                   animations: {
                                    
                                    self.collectionView.contentOffset = CGPointMake(0, -self.productRefreshControl.frame.size.height);
            }, completion: { (finished) in
                self.productRefreshControl.beginRefreshing()
                self.productRefreshControl.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        productRefreshControl = UIRefreshControl()
        productRefreshControl.addTarget(self, action: #selector(PurchaseController.refreshProductData), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(productRefreshControl)
        collectionView.alwaysBounceVertical = true
        collectionView.purchaseDelegate = self
        collectionView.loadMoreDelegate = self
        
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents[0] as! UIView
        loadingImageView = customLoadingView.viewWithTag(TAG_LOADING_IMAGEVIEW) as! UIImageView
        customLoadingView.frame = productRefreshControl.bounds
        productRefreshControl.addSubview(customLoadingView)
        screenRect = UIScreen.mainScreen().bounds
        purchaseWidth = screenRect.width - 40
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        purchaseDialogController = storyboard.instantiateViewControllerWithIdentifier("purchaseDialog") as! PurchaseDialogController
        purchaseDialogController.confirmPurchaseDelegate = self
        purchaseDialogController.closeDelegate = self
        purchaseDialogController.changePayWayDelegate = self
    }
    
    func refreshProductData() {
        let paramDict: NSMutableDictionary = ["version": "\(productTableManager.version)",
                                               "product_min_id": "\(productTableManager.productMinId)"]
        isLoading = true
        manager.POST(UrlParam.REFRESH_PRODUCT_URL,
                     parameters: paramDict,
                     success: { (operation, responseObject) in
                        let response = responseObject as! NSDictionary
                        print("JSON: " + responseObject.description!)
                        ProductCache.instance.setProducts(response["result"] as! NSDictionary)
                        
                        self.collectionView.productList = ProductCache.instance.cacheList
                        self.collectionView.reloadData()
                        self.productRefreshControl.endRefreshing()
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
    
    func purchase(product: Product, orderId: Int64) {
        if !UserCache.instance.ifLogin() {
            UserInfoManager.instance.checkIfGoToLogin(self)
            return
        }
        
        if product.pkId == 2 && UserCache.instance.user.hasGuide {
            let alertController = UIAlertController(title: nil,
                                                    message: NSLocalizedString("ALREADY_HAS_GUIDE", comment: "You already have a monster guide. Continue to buy?"), preferredStyle: UIAlertControllerStyle.Alert)
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
        purchaseDialogController.product = product
        purchaseDialogController.orderId = orderId
        
        self.view.addSubview(grayView)
        self.view.addSubview(purchaseDialogController.view)
    }
    
    func confirmPurchase(product: Product, count: Int, orderId: Int64) {
        let paramDict: NSMutableDictionary = ["store_id": "\(product.pkId)",
                                              "count": "\(count)"]
        createOrderManager.POST(UrlParam.CREATE_ORDER_URL,
                                paramDict: paramDict,
                                success: { (operation, responseObject) in
                                        let response = responseObject as! NSDictionary
                                    
                                    self.setInfoFromCreateOrderCallback(response, product: product, count: count)
                                    
                                }, failure: { (operation, error) in
                                    print("Error: " + error.localizedDescription)
                                })
    }
    
    func setInfoFromCreateOrderCallback(response: NSDictionary, product: Product, count: Int) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            let result = response["result"] as! NSDictionary
            self.purchaseDialogController.orderId = (result["order_id"] as! NSString).longLongValue
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
        purchaseDialogController.closePayWayView()
    }
    
    func showMessage(message: String, type: HudToastFactory.MessageType) {
        HudToastFactory.show(message, view: self.view, type: type)
    }
    
    func loadMore() {
        if !isLoading {
            isLoading = true
            let hasData = ProductCache.instance.getMoreProducts(10, hasLoaded: false)
            if self.collectionView.footer != nil {
                self.collectionView.footer.hidden = false
            }
            
            if(!hasData) {
                let paramDict: NSMutableDictionary = ["version": String(productTableManager.version), "product_min_id": String(productTableManager.productMinId)]
                manager.POST(UrlParam.GET_PRODUCT_URL,
                             parameters: paramDict,
                             success: { (operation, responseObject) in
                                print("JSON: " + responseObject.description!)
                                let response = responseObject as! NSDictionary
                                ProductCache.instance.addProducts(response["result"] as! NSDictionary)
                                if self.collectionView.footer != nil {
                                    self.collectionView.footer.hidden = true
                                }
                                self.collectionView.productList = ProductCache.instance.cacheList
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
                self.collectionView.productList.addObjectsFromArray(ProductCache.instance.productList as [AnyObject])
                if self.collectionView.footer != nil {
                    self.collectionView.footer.hidden = true
                }
                self.collectionView.reloadData()
                
                isLoading = false
            }
        }
    }
    
    func purchase() {
        if purchaseDialogController.orderId == 0 {
            return
        }
        
        let paramDict: NSMutableDictionary = ["order_id": "\(purchaseDialogController.orderId)"]
        createOrderManager.POST(UrlParam.PURCHASE_URL,
                                paramDict: paramDict,
                                success: { (operation, responseObject) in
                                    let response = responseObject as! NSDictionary
                                    print("JSON: " + responseObject.description!)
                                    
                                    self.setInfoFromPurchaseCallback(response)
                                    
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
                let errorMessage = ErrorMessageFactory.get(CodeParam.ERROR_VOLLEY_CODE)
                HudToastFactory.show(errorMessage, view: self.view, type: HudToastFactory.MessageType.ERROR)
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
            self.close()
            self.refreshProductData()
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
