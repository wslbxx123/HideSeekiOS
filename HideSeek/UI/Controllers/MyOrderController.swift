//
//  MyOrderController.swift
//  HideSeek
//
//  Created by apple on 8/6/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class MyOrderController: UIViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    var purchaseOrderController: PurchaseOrderController!
    var exchangeOrderController: ExchangeOrderController!
    var rect: CGRect!
    
    @IBAction func backBtnClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func segmentControlChanged(sender: AnyObject) {
        switch(self.segmentControl.selectedSegmentIndex) {
        case 0:
            showPurchaseArea()
            break;
        case 1:
            showExchangeArea()
            break;
        default:
            break;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        showPurchaseArea()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initView() {
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
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        purchaseOrderController = storyboard.instantiateViewControllerWithIdentifier("purchaseOrder") as! PurchaseOrderController
        exchangeOrderController = storyboard.instantiateViewControllerWithIdentifier("exchangeOrder") as! ExchangeOrderController
        rect = UIScreen.mainScreen().bounds
        purchaseOrderController.view.layer.frame = CGRectMake(
            purchaseOrderController.view.layer.frame.minX,
            purchaseOrderController.view.layer.frame.minY,
            purchaseOrderController.view.layer.frame.width,
            purchaseOrderController.view.layer.frame.height - 128)
        exchangeOrderController.view.layer.frame = CGRectMake(
            exchangeOrderController.view.layer.frame.minX,
            exchangeOrderController.view.layer.frame.minY,
            exchangeOrderController.view.layer.frame.width,
            exchangeOrderController.view.layer.frame.height - 128)
    }
    
    func showPurchaseArea() {
        self.addChildViewController(purchaseOrderController)
        contentView.addSubview(purchaseOrderController.view)
        exchangeOrderController.removeFromParentViewController()
    }
    
    func showExchangeArea() {
        self.addChildViewController(exchangeOrderController)
        contentView.addSubview(exchangeOrderController.view)
        
        purchaseOrderController.removeFromParentViewController()
    }
}
