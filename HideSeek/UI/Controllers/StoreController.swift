//
//  StoreController.swift
//  HideSeek
//
//  Created by apple on 7/20/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit
import AFNetworking

class StoreController: UIViewController {
    let HtmlType = "text/html"
    let TAG_LOADING_IMAGEVIEW = 1
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var purchaseCollectionView: PurchaseCollectionView!
    var manager: AFHTTPRequestOperationManager!
    var refreshControl: UIRefreshControl!
    var angle: CGFloat = 0
    var loadingImageView: UIImageView!
    var customLoadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes =  NSSet().setByAddingObject(HtmlType)
        
        UIView.animateWithDuration(0.25,
                                   delay: 0,
                                   options: UIViewAnimationOptions.BeginFromCurrentState,
                                   animations: {
                                    
                                    self.purchaseCollectionView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
            }, completion: { (finished) in
                self.refreshControl.beginRefreshing()
                self.refreshControl.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func segmentControlChanged(sender: AnyObject) {
        switch(self.segmentControl.selectedSegmentIndex) {
        case 0:
            showPurchaseArea()
            break;
        case 1:
            break;
        default:
            break;
        }
    }
    
    func initView() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(StoreController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        purchaseCollectionView.addSubview(refreshControl)
        purchaseCollectionView.alwaysBounceVertical = true
        let font = UIFont.systemFontOfSize(14.0)
        let color = UIColor.blackColor()
        let yellowColor = BaseInfoUtil.stringToRGB("#ffcc00")
        let nomalAttributes = NSDictionary(dictionary: [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName: color])
        let selectedAttributes = NSDictionary(dictionary: [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName: color])
        
        segmentControl.tintColor = UIColor.clearColor()
        segmentControl.setTitleTextAttributes(nomalAttributes as [NSObject : AnyObject], forState: UIControlState.Normal)
        segmentControl.setTitleTextAttributes(selectedAttributes as [NSObject : AnyObject], forState: UIControlState.Selected)
        segmentControl.setBackgroundImage(UIImage.createImageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        segmentControl.setBackgroundImage(UIImage.createImageWithColor(yellowColor), forState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
        segmentControl.layer.cornerRadius = 5;
        segmentControl.layer.masksToBounds = true;
        segmentControl.apportionsSegmentWidthsByContent = true
        
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshView",
                                                                 owner: self, options: nil)
        customLoadingView = refreshContents[0] as! UIView
        loadingImageView = customLoadingView.viewWithTag(TAG_LOADING_IMAGEVIEW) as! UIImageView
        customLoadingView.frame = refreshControl.bounds
        refreshControl.addSubview(customLoadingView)
    }
    
    func refreshData() {
        let paramDict: NSMutableDictionary = ["version": 0,
                                              "product_min_id": 0]
        manager.POST(UrlParam.REFRESH_PURCHASE_URL,
                     parameters: paramDict,
                     success: { (operation, responseObject) in
                        let response = responseObject as! NSDictionary
                        print("JSON: " + responseObject.description!)
                        ProductCache.instance.setProducts(response["result"] as! NSDictionary)
                        
                        self.purchaseCollectionView.productList = ProductCache.instance.cacheList
                        self.purchaseCollectionView.reloadData()
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
    
    func showPurchaseArea() {
        
    }

}
