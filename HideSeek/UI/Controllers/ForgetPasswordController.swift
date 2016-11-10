//
//  ForgetPasswordController.swift
//  HideSeek
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 mj. All rights reserved.
//

import UIKit

class ForgetPasswordController: UIViewController {
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var sendCodeBtn: UIButton!
    @IBOutlet weak var forgetPasswordScrollView: UIScrollView!
    
    var phone: String = ""
    var code: String = ""
    var countDownTimer: Timer!
    var countDownNum = 30

    @IBAction func closeBtnClicked(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextStepBtnClicked(_ sender: AnyObject) {
        checkVerificationCode()
    }
    
    @IBAction func phoneChanged(_ sender: AnyObject) {
        phone = phoneTextField.text!
        
        checkIfNextStepEnabled()
        checkIfCodeEnabled()
    }
    
    @IBAction func codeChanged(_ sender: AnyObject) {
        code = codeTextField.text!
        
        checkIfNextStepEnabled()
    }
    
    @IBAction func sendCodeBtnClicked(_ sender: AnyObject) {
        self.sendCodeBtn.isEnabled = false
        self.countDownNum = 30
        
        self.countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ForgetPasswordController.timeFireMethod), userInfo: nil, repeats: true)
        
        self.countDownTimer.fire()
        
        SMSSDK.getVerificationCode(by: SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86",
                                           customIdentifier: nil) { (error) in
                                            if (error == nil) {
                                                
                                            } else {
                                                NSLog("错误信息：%@", error.debugDescription)
                                            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        nextStepBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        nextStepBtn.layer.cornerRadius = 5
        nextStepBtn.layer.masksToBounds = true
        
        sendCodeBtn.setBackgroundColor("#fccb05", selectedColorStr: "#ffa200", disabledColorStr: "#bab8b8")
        sendCodeBtn.layer.cornerRadius = 5
        sendCodeBtn.layer.masksToBounds = true
        
        forgetPasswordScrollView.delaysContentTouches = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func checkIfCodeEnabled() {
        sendCodeBtn.isEnabled = !phone.isEmpty && phone.characters.count == 11
    }
    
    func checkIfNextStepEnabled() {
        nextStepBtn.isEnabled = !phone.isEmpty && !code.isEmpty
    }
    
    func checkVerificationCode() {
        SMSSDK.commitVerificationCode(self.code, phoneNumber: phone, zone: "86") { (error) in
            if ((error == nil)) {
                let storyboard = UIStoryboard(name:"Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "UpdatePassword") as! UpdatePasswordController
                viewController.phone = self.phone
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else
            {
                HudToastFactory.show(
                    NSLocalizedString("ERROR_VERIFICATION_CODE",
                        comment: "The input verification code is wrong"),
                    view: self.view,
                    type: HudToastFactory.MessageType.error)
                self.codeTextField.text = ""
            }
        }
    }
    
    func timeFireMethod() {
        if(countDownNum == 0) {
            countDownTimer.invalidate()
            countDownTimer = nil
            self.sendCodeBtn.isEnabled = true
            self.sendCodeBtn.setTitle(
                NSLocalizedString("SEND_VERIFICATION_CODE", comment: "Send Verification Code"),
                for: UIControlState())
        } else {
            self.sendCodeBtn.setTitle("\(countDownNum)s", for: UIControlState())
            countDownNum -= 1
        }
    }

}
