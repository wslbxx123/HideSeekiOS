//
//  ExchangeDialogController.swift
//  HideSeek
//
//  Created by apple on 8/11/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ExchangeDialogController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var rewardNameLabel: UILabel!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var setDefaultSwitch: UISwitch!
    
    var count: Int = 1
    var record: Int!
    var amount: Int = 0
    var confirmExchangeDelegate: ConfirmExchangeDelegate!
    var closeDelegate: CloseDelegate!
    var showAreaDelegate: ShowAreaDelegate!
    var reward: Reward!
    var _area: String = ""
    var area: String {
        get {
           return _area
        }
        set {
            _area = newValue
            areaTextField.text = newValue
        }
    }
    var address: String = ""

    @IBAction func addressChanged(_ sender: AnyObject) {
        address = addressTextField.text!
    }
    
    @IBAction func areaSelected(_ sender: AnyObject) {
        showAreaDelegate?.showAreaPickerView()
        
        dismissKeyboard()
    }
    
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
    
    @IBAction func confirmBtnClicked(_ sender: AnyObject) {
        confirmExchangeDelegate?.confirmExchange(reward, count: count)
    }
    
    @IBAction func closeBtnClicked(_ sender: AnyObject) {
        closeDelegate?.close()
    }
    
    func checkIfConfirmEnabled() {
        confirmBtn.isEnabled = !address.isEmpty && !area.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        confirmBtn.layer.cornerRadius = 5
        confirmBtn.layer.masksToBounds = true
        areaTextField.tintColor = BaseInfoUtil.stringToRGB("#0088ff")
        addressTextField.tintColor = BaseInfoUtil.stringToRGB("#0088ff")
        areaTextField.delegate = self
        addressTextField.isExclusiveTouch = true
        
        if UserCache.instance.ifLogin() {
            let user = UserCache.instance.user
            areaTextField.text = user?.defaultArea as? String
            addressTextField.text = user?.defaultAddress as? String
            _area = user?.defaultArea as! String
            address = user?.defaultAddress as! String
        }
        
        checkIfConfirmEnabled()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false;
    }
    
    func dismissKeyboard() {
        if self.addressTextField != nil && self.addressTextField.isExclusiveTouch {
            self.addressTextField.resignFirstResponder()
        }
    }
}
