//
//  ExchangeOrderController.swift
//  HideSeek
//
//  Created by apple on 8/7/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ExchangeOrderController: UIViewController, LoadMoreDelegate,
    ExchangeDelegate, ConfirmExchangeDelegate, CloseDelegate, ShowAreaDelegate, AreaPickerDelegate{
    let HtmlType = "text/html"
    let TAG_LOADING_IMAGEVIEW = 1
    
    @IBOutlet weak var orderTableView: ExchangeOrderTableView!
    var manager: CustomRequestManager!
    var refreshControl: UIRefreshControl!
    var customLoadingView: UIView!
    var loadingImageView: UIImageView!
    var angle: CGFloat = 0
    var exchangeOrderTableManager: ExchangeOrderTableManager!
    var isLoading: Bool = true
    var grayView: UIView!
    var screenRect: CGRect!
    var exchangeDialogController: ExchangeDialogController!
    var exchangeHeight: CGFloat = 250
    var exchangeWidth: CGFloat!
    var createOrderManager: CustomRequestManager!
    var areaPickerView: AreaPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CustomRequestManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: HtmlType) as? Set<String>
        exchangeOrderTableManager = ExchangeOrderTableManager.instance
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.orderTableView.orderList = ExchangeOrderCache.instance.orderList
        self.orderTableView.reloadData()
        
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
        self.exchangeWidth = self.screenRect.width - 40
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ExchangeOrderController.refreshData), for: UIControlEvents.valueChanged)
        orderTableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        orderTableView.addSubview(refreshControl)
        orderTableView.loadMoreDelegate = self
        orderTableView.exchangeDelegate = self
        
        let refreshContents = Bundle.main.loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents?[0] as! UIView
        loadingImageView = customLoadingView.viewWithTag(TAG_LOADING_IMAGEVIEW) as! UIImageView
        customLoadingView.frame = refreshControl.bounds
        refreshControl.addSubview(customLoadingView)
        
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
    
    func refreshData() {
        let paramDict: NSMutableDictionary = ["version": String(exchangeOrderTableManager.version), "order_min_id": String(exchangeOrderTableManager.orderMinId)]
        isLoading = true
        _ = manager.POST(UrlParam.REFRESH_EXCHANGE_ORDERS_URL,
                     paramDict: paramDict,
                     success: { (operation, responseObject) in
                        print("JSON: " + responseObject.debugDescription)
                        let response = responseObject as! NSDictionary
                        
                        self.setRefreshInfoFromCallback(response)
                        self.isLoading = false
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
                self.isLoading = false
        })
        playAnimateRefresh()
    }
    
    func setRefreshInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"] as AnyObject)
        
        if code == CodeParam.SUCCESS {
            ExchangeOrderCache.instance.setOrders(response["result"] as! NSDictionary)
            self.orderTableView.orderList = ExchangeOrderCache.instance.cacheList
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
        UIView.setAnimationDidStop(#selector(ExchangeOrderController.endAnimation))
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
                let paramDict: NSMutableDictionary = ["version": String(exchangeOrderTableManager.version), "order_min_id": String(exchangeOrderTableManager.orderMinId)]
                _ = manager.POST(UrlParam.GET_EXCHANGE_ORDERS_URL,
                             paramDict: paramDict,
                             success: { (operation, responseObject) in
                                print("JSON: " + responseObject.debugDescription)
                                let response = responseObject as! NSDictionary
                                
                                self.setInfoFromGetCallback(response)
                    },
                             failure: { (operation, error) in
                                print("Error: " + error.localizedDescription)
                                self.orderTableView.tableFooterView?.isHidden = true
                })
            } else {
                self.orderTableView.orderList.removeAllObjects();
                self.orderTableView.orderList.addObjects(from: ExchangeOrderCache.instance.orderList as [AnyObject])
                self.orderTableView.reloadData()
                
                isLoading = false
                self.orderTableView.tableFooterView?.isHidden = true
            }
        }
    }
    
    func setInfoFromGetCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"] as AnyObject)
        
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
    
    func exchange(_ reward: Reward) {
        grayView = UIView(frame: screenRect)
        grayView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        
        exchangeDialogController.view.layer.frame = CGRect(
            x: (screenRect.width - exchangeWidth) / 2,
            y: (screenRect.height - exchangeHeight) / 2 - 110,
            width: exchangeWidth,
            height: exchangeHeight)
        exchangeDialogController.rewardNameLabel.text = reward.name
        exchangeDialogController.record = reward.record
        
        self.view.addSubview(grayView)
        self.view.addSubview(exchangeDialogController.view)
    }
    
    func confirmExchange(_ reward: Reward, count: Int) {
        let paramDict: NSMutableDictionary = ["reward_id": "\(reward.pkId)",
                                              "count": "\(count)"]
        _ = createOrderManager.POST(UrlParam.CREATE_EXCHANGE_ORDER_URL,
                                paramDict: paramDict,
                                success: { (operation, responseObject) in
                                    let response = responseObject as! NSDictionary
                                    self.setCreateInfoFromCallback(response);
            }, failure: { (operation, error) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func setCreateInfoFromCallback(_ response: NSDictionary) {
        let code = BaseInfoUtil.getIntegerFromAnyObject(response["code"])
        
        if code == CodeParam.SUCCESS {
            UserCache.instance.user.record = BaseInfoUtil.getIntegerFromAnyObject(response["result"])
            self.refreshData()
            
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
