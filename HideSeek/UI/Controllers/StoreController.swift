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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.segmentControl.selectedSegmentIndex = 0
        showPurchaseArea()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    @IBAction func segmentControlChanged(_ sender: AnyObject) {
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
        let font = UIFont.systemFont(ofSize: 14.0)
        let color = UIColor.black
        let yellowColor = BaseInfoUtil.stringToRGB("#ffcc00")
        let nomalAttributes = NSDictionary(dictionary: [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName: color])
        let selectedAttributes = NSDictionary(dictionary: [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName: color])
        
        segmentControl.tintColor = UIColor.clear
        segmentControl.setTitleTextAttributes(nomalAttributes as! [AnyHashable: Any], for: UIControlState())
        segmentControl.setTitleTextAttributes(selectedAttributes as! [AnyHashable: Any], for: UIControlState.selected)
        segmentControl.setBackgroundImage(UIImage.createImageWithColor(UIColor.white), for: UIControlState(), barMetrics: UIBarMetrics.default)
        segmentControl.setBackgroundImage(UIImage.createImageWithColor(yellowColor), for: UIControlState.selected, barMetrics: UIBarMetrics.default)
        segmentControl.layer.cornerRadius = 5;
        segmentControl.layer.masksToBounds = true;
        segmentControl.apportionsSegmentWidthsByContent = true
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        purchaseController = storyboard.instantiateViewController(withIdentifier: "purchase") as! PurchaseController
        exchangeController = storyboard.instantiateViewController(withIdentifier: "exchange") as! ExchangeController
        rect = UIScreen.main.bounds
        purchaseController.view.layer.frame = CGRect(
            x: purchaseController.view.layer.frame.minX,
            y: purchaseController.view.layer.frame.minY,
            width: purchaseController.view.layer.frame.width,
            height: purchaseController.view.layer.frame.height - 128)
        exchangeController.view.layer.frame = CGRect(
            x: exchangeController.view.layer.frame.minX,
            y: exchangeController.view.layer.frame.minY,
            width: exchangeController.view.layer.frame.width,
            height: exchangeController.view.layer.frame.height - 128)
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
