//
//  PurchaseDialogController.swift
//  HideSeek
//
//  Created by apple on 8/2/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class PurchaseDialogController: UIViewController {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    var count: Int = 1
    var price: Double!
    var amount: Double = 0
    var confirmPurchaseDelegate: ConfirmPurchaseDelegate!
    var closeDelegate: CloseDelegate!
    var product: Product!
    var orderId: Int64 = 0
    
    @IBAction func upBtnClicked(sender: AnyObject) {
        count += 1
        refreshAmount()
    }
    
    @IBAction func downBtnClicked(sender: AnyObject) {
        if(count > 0) {
            count -= 1
        }
        refreshAmount()
    }
    
    @IBAction func closeBtnClicked(sender: AnyObject) {
        closeDelegate?.close()
    }
    
    @IBAction func confirmBtnClicked(sender: AnyObject) {
        confirmPurchaseDelegate?.confirmPurchase(product, count: count, orderId: orderId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        confirmBtn.layer.cornerRadius = 5
        confirmBtn.layer.masksToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        count = 1
        refreshAmount()
    }
    
    func refreshAmount() {
        amount = Double(count) * price
        countTextField.text = "\(count)"
        priceLabel.text = "\(amount)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
