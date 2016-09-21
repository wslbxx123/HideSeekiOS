//
//  StoreController.swift
//  HideSeek
//
//  Created by apple on 7/20/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class StoreController: UIViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    var purchaseController: PurchaseController!
    var exchangeController: ExchangeController!
    var rect: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.segmentControl.selectedSegmentIndex = 0
        showPurchaseArea()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

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
        purchaseController = storyboard.instantiateViewControllerWithIdentifier("purchase") as! PurchaseController
        exchangeController = storyboard.instantiateViewControllerWithIdentifier("exchange") as! ExchangeController
        rect = UIScreen.mainScreen().bounds
        purchaseController.view.layer.frame = CGRectMake(
            purchaseController.view.layer.frame.minX,
            purchaseController.view.layer.frame.minY,
            purchaseController.view.layer.frame.width,
            purchaseController.view.layer.frame.height - 128)
        exchangeController.view.layer.frame = CGRectMake(
            exchangeController.view.layer.frame.minX,
            exchangeController.view.layer.frame.minY,
            exchangeController.view.layer.frame.width,
            exchangeController.view.layer.frame.height - 128)
    }
    
    func showPurchaseArea() {
        self.addChildViewController(purchaseController)
        contentView.addSubview(purchaseController.view)
        exchangeController.removeFromParentViewController()
    }

    func showExchangeArea() {
        self.addChildViewController(exchangeController)
        contentView.addSubview(exchangeController.view)
        
        purchaseController.removeFromParentViewController()
    }
}
