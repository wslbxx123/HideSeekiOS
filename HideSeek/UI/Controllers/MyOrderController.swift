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
    
    @IBAction func backBtnClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showPurchaseArea()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        segmentControl.setTitleTextAttributes(nomalAttributes as? [AnyHashable: Any], for: UIControlState())
        segmentControl.setTitleTextAttributes(selectedAttributes as? [AnyHashable: Any], for: UIControlState.selected)
        segmentControl.setBackgroundImage(UIImage.createImageWithColor(UIColor.white), for: UIControlState(), barMetrics: UIBarMetrics.default)
        segmentControl.setBackgroundImage(UIImage.createImageWithColor(yellowColor), for: UIControlState.selected, barMetrics: UIBarMetrics.default)
        segmentControl.layer.cornerRadius = 5;
        segmentControl.layer.masksToBounds = true;
        segmentControl.apportionsSegmentWidthsByContent = true
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        purchaseOrderController = storyboard.instantiateViewController(withIdentifier: "purchaseOrder") as! PurchaseOrderController
        exchangeOrderController = storyboard.instantiateViewController(withIdentifier: "exchangeOrder") as! ExchangeOrderController
        rect = UIScreen.main.bounds
        purchaseOrderController.view.layer.frame = CGRect(
            x: purchaseOrderController.view.layer.frame.minX,
            y: purchaseOrderController.view.layer.frame.minY,
            width: purchaseOrderController.view.layer.frame.width,
            height: purchaseOrderController.view.layer.frame.height - 128)
        exchangeOrderController.view.layer.frame = CGRect(
            x: exchangeOrderController.view.layer.frame.minX,
            y: exchangeOrderController.view.layer.frame.minY,
            width: exchangeOrderController.view.layer.frame.width,
            height: exchangeOrderController.view.layer.frame.height - 128)
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
