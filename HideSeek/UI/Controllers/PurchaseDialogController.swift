//
//  PurchaseDialogController.swift
//  HideSeek
//
//  Created by apple on 8/2/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class PurchaseDialogController: UIViewController, TouchDownDelegate, PickerViewDelegate {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var payWayLabel: UILabel!
    @IBOutlet weak var payWayView: UIView!
    @IBOutlet weak var payWayPickerView: ComboxPickerView!
    @IBOutlet weak var payView: MenuView!
    var count: Int = 1
    var price: Double!
    var amount: Double = 0
    var confirmPurchaseDelegate: ConfirmPurchaseDelegate!
    var closeDelegate: CloseDelegate!
    var changePayWayDelegate: ChangePayWayDelegate!
    var product: Product!
    var orderId: Int64 = 0
    var payWay: PayWayFactory.PayWayEnum = PayWayFactory.PayWayEnum.applePay
    
    @IBAction func upBtnClicked(_ sender: AnyObject) {
        count += 1
        refreshAmount()
    }
    
    @IBAction func downBtnClicked(_ sender: AnyObject) {
        if(count > 0) {
            count -= 1
        }
        refreshAmount()
    }
    
    @IBAction func closeBtnClicked(_ sender: AnyObject) {
        closeDelegate?.close()
    }
    
    @IBAction func confirmBtnClicked(_ sender: AnyObject) {
        confirmPurchaseDelegate?.confirmPurchase(product, count: count, orderId: orderId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        count = 1
        refreshAmount()
    }
    
    func initView() {
        confirmBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        confirmBtn.layer.cornerRadius = 5
        confirmBtn.layer.masksToBounds = true
        
        let itemArray = NSMutableArray()
        itemArray.add(NSLocalizedString("APPLE_PAY", comment: "Apple Pay"))
        
        if !Setting.IF_STORE_HIDDEN && Setting.LATEST_APP_VERSION.compareTo(BaseInfoUtil.getAppVersion(), separator: ".") >= 0 {
            itemArray.add(NSLocalizedString("ALIPAY", comment: "Alipay"))
        }
        
        payWayPickerView.items = itemArray
        payWayPickerView.pickerViewDelegate = self
        payView.touchDownDelegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PurchaseDialogController.closePayWayView))
        payWayView.isUserInteractionEnabled = true
        payWayView.addGestureRecognizer(gestureRecognizer)
        
        switch(payWay) {
        case PayWayFactory.PayWayEnum.applePay:
            payWayLabel.text = NSLocalizedString("APPLE_PAY", comment: "ApplePay")
            break;
        case PayWayFactory.PayWayEnum.alipay:
            payWayLabel.text = NSLocalizedString("ALIPAY", comment: "Alipay")
            break;
        }
    }
    
    func refreshAmount() {
        amount = Double(count) * price
        countTextField.text = "\(count)"
        priceLabel.text = "\(amount)"
    }
    
    func touchDown(_ tag: Int) {
        payWayView.isHidden = false
    }
    
    func closePayWayView() {
        payWayView.isHidden = true
    }
    
    func pickerViewSelected(_ row: Int, item: AnyObject) {
        payWayView.isHidden = true
        payWay = PayWayFactory.PayWayEnum(rawValue: row)!
        payWayLabel.text = item as? String
        changePayWayDelegate.payWayChanged(payWay)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
