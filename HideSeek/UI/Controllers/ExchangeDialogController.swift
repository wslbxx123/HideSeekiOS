//
//  ExchangeDialogController.swift
//  HideSeek
//
//  Created by apple on 8/11/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ExchangeDialogController: UIViewController {
    @IBOutlet weak var rewardNameLabel: UILabel!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    var count: Int = 1
    var record: Int!
    var amount: Int = 0
    var confirmExchangeDelegate: ConfirmExchangeDelegate!
    var closeDelegate: CloseDelegate!
    var reward: Reward!

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
    
    @IBAction func confirmBtnClicked(sender: AnyObject) {
        confirmExchangeDelegate?.confirmExchange(reward, count: count)
    }
    
    @IBAction func closeBtnClicked(sender: AnyObject) {
        closeDelegate?.close()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshAmount() {
        amount = count * record
        countTextField.text = "\(count)"
        recordLabel.text = "\(amount)"
    }
}
